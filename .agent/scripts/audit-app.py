#!/usr/bin/env python3
"""
flutter_security_audit.py
Static security audit for Flutter apps (Dart + Android + iOS config).

Usage:
  python flutter_security_audit.py /path/to/flutter/project --json out.json
  python flutter_security_audit.py . --severity high
"""

from __future__ import annotations

import argparse
import fnmatch
import json
import os
import re
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Iterable, List, Optional, Tuple


# -----------------------------
# Models
# -----------------------------

@dataclass
class Finding:
    rule_id: str
    title: str
    severity: str  # low/medium/high
    file: str
    line: int
    snippet: str
    recommendation: str


SEV_ORDER = {"low": 1, "medium": 2, "high": 3}


# -----------------------------
# Helpers
# -----------------------------

TEXT_EXTS = {
    ".dart", ".yaml", ".yml", ".json", ".xml", ".plist", ".gradle", ".kt", ".java", ".properties", ".txt", ".md"
}

EXCLUDE_DIRS = {
    ".git", ".dart_tool", ".idea", ".vscode", "build", ".flutter-plugins", ".flutter-plugins-dependencies",
    "ios/Pods", "android/.gradle", "android/build", "ios/build", "coverage"
}

def is_excluded(path: Path) -> bool:
    # Exclude by path segment, and support explicit nested paths like ios/Pods.
    parts = set(path.parts)
    posix_path = path.as_posix()
    for excluded in EXCLUDE_DIRS:
        if "/" in excluded:
            if excluded in posix_path:
                return True
        elif excluded in parts:
            return True
    # Also exclude common vendored folders even if nested.
    if "Pods" in parts or "Carthage" in parts:
        return True
    return False

def iter_files(root: Path) -> Iterable[Path]:
    for p in root.rglob("*"):
        if p.is_dir():
            continue
        if is_excluded(p):
            continue
        if p.suffix.lower() in TEXT_EXTS:
            yield p

def read_lines(path: Path) -> List[str]:
    try:
        return path.read_text(encoding="utf-8", errors="replace").splitlines()
    except Exception:
        return []

def add_finding(
    findings: List[Finding],
    rule_id: str,
    title: str,
    severity: str,
    path: Path,
    line_no: int,
    snippet: str,
    recommendation: str,
):
    findings.append(
        Finding(
            rule_id=rule_id,
            title=title,
            severity=severity,
            file=str(path),
            line=line_no,
            snippet=snippet.strip()[:300],
            recommendation=recommendation.strip(),
        )
    )

def severity_filter(findings: List[Finding], min_sev: str) -> List[Finding]:
    min_val = SEV_ORDER.get(min_sev, 1)
    return [f for f in findings if SEV_ORDER.get(f.severity, 1) >= min_val]


# -----------------------------
# Rules
# -----------------------------

RULES_DART: List[Tuple[str, str, str, re.Pattern, str]] = [
    (
        "DART_HTTP_URL",
        "Insecure HTTP URL found",
        "high",
        re.compile(r"""http://[^\s'"]+""", re.IGNORECASE),
        "Avoid plain HTTP. Use HTTPS. If you must use HTTP in dev, ensure it is blocked for release builds."
    ),
    (
        "DART_BAD_CERT_CALLBACK",
        "TLS certificate validation bypass (badCertificateCallback)",
        "high",
        re.compile(r"""\bbadCertificateCallback\b"""),
        "Remove badCertificateCallback in production. Use proper trust chain, or implement certificate pinning."
    ),
    (
        "DART_PRINT_LOG",
        "Debug logging detected (print/debugPrint/logger) may leak sensitive data",
        "low",
        re.compile(r"""\b(print|debugPrint|logger\.)\b"""),
        "Audit logs for secrets/PII. Gate logs behind kReleaseMode or remove in production."
    ),
    (
        "DART_WEBVIEW_JS",
        "WebView JavaScript enabled / risky WebView usage",
        "medium",
        re.compile(r"""(javascriptMode\s*:\s*JavascriptMode\.unrestricted|javaScriptEnabled\s*:\s*true)"""),
        "If you render remote content, minimize JS, disable file access, restrict navigation, and validate URLs. Consider CSP / allowlists."
    ),
    (
        "DART_BASE64_SECRET_HINT",
        "Suspicious base64-like string (possible embedded secret)",
        "medium",
        re.compile(r"""["']([A-Za-z0-9+/]{40,}={0,2})["']"""),
        "If this is a key/token, move it to secure backend or secret manager. Never ship long-lived secrets in the client."
    ),
]

# Strong-ish secret patterns (heuristics)
SECRET_PATTERNS: List[Tuple[str, str, str, re.Pattern, str]] = [
    (
        "SECRET_PRIVATE_KEY",
        "Private key material found",
        "high",
        re.compile(r"""-----BEGIN (RSA|EC|OPENSSH|PRIVATE) KEY-----"""),
        "Remove from repo immediately. Revoke/rotate keys. Use secure secret storage and CI secrets."
    ),
    (
        "SECRET_AWS_KEY",
        "Possible AWS Access Key ID found",
        "high",
        re.compile(r"""\bAKIA[0-9A-Z]{16}\b"""),
        "Remove and rotate the credential. Do not embed cloud credentials in mobile apps."
    ),
    (
        "SECRET_GCP_KEY",
        "Possible Google API key found",
        "high",
        re.compile(r"""\bAIza[0-9A-Za-z\-_]{35}\b"""),
        "Remove and restrict/rotate key. Prefer backend proxy and key restrictions."
    ),
    (
        "SECRET_JWT",
        "Possible hardcoded JWT found",
        "high",
        re.compile(r"""\beyJ[A-Za-z0-9_\-]{10,}\.[A-Za-z0-9_\-]{10,}\.[A-Za-z0-9_\-]{10,}\b"""),
        "Never hardcode tokens. Treat as compromised and rotate/revoke."
    ),
    (
        "SECRET_GENERIC",
        "Possible hardcoded secret (apikey/token/password/secret)",
        "medium",
        re.compile(r"""(?i)\b(api[_-]?key|token|secret|password|passwd|auth)\b\s*[:=]\s*["'][^"']{8,}["']"""),
        "Do not embed secrets in the client. Use backend-issued short-lived tokens, secure storage, and remote config with caution."
    ),
]

# Android / iOS config patterns
ANDROID_RULES: List[Tuple[str, str, str, re.Pattern, str]] = [
    (
        "ANDROID_CLEARTEXT",
        "Android allows cleartext traffic (usesCleartextTraffic=true)",
        "high",
        re.compile(r"""android:usesCleartextTraffic\s*=\s*["']true["']""", re.IGNORECASE),
        "Disable cleartext traffic. Use HTTPS. If needed for specific domains, use Network Security Config with strict allowlist."
    ),
    (
        "ANDROID_DEBUGGABLE",
        "Android debuggable=true",
        "high",
        re.compile(r"""android:debuggable\s*=\s*["']true["']""", re.IGNORECASE),
        "Never ship with debuggable=true. Ensure release builds disable debugging."
    ),
    (
        "ANDROID_EXPORTED",
        "Android component exported=true (review exposure)",
        "medium",
        re.compile(r"""android:exported\s*=\s*["']true["']""", re.IGNORECASE),
        "Verify exported components require permissions and validate intents. Prefer exported=false unless required."
    ),
]

IOS_RULES: List[Tuple[str, str, str, re.Pattern, str]] = [
    (
        "IOS_ATS_ARBITRARY_LOADS",
        "iOS ATS allows arbitrary loads (NSAllowsArbitraryLoads)",
        "high",
        re.compile(r"""NSAllowsArbitraryLoads"""),
        "Do not allow arbitrary loads. Use ATS defaults. If exceptions are needed, scope them to specific domains."
    ),
]

HTTP_URL_PATTERN = re.compile(r"""http://[^\s'")>\]]+""", re.IGNORECASE)
RANDOM_PATTERN = re.compile(r"""\bRandom\s*\(""")
RANDOM_SECURITY_CONTEXT_PATTERN = re.compile(
    r"""(?i)\b(token|secret|password|passwd|auth|session|nonce|salt|credential|jwt|api[_-]?key|private[_-]?key|signature|crypto|encrypt|decrypt)\b"""
)

# Exclude internal agent/docs content from endpoint checks to reduce noise.
URL_SCAN_EXCLUDED_PATH_GLOBS = (
    ".agent/**",
    "docs/**",
)

URL_SCAN_IGNORED_PREFIXES = (
    "http://schemas.android.com/",
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd",
)

DEFAULT_IGNORE_REL_PATH = ".agent/audit-ignore.json"


# -----------------------------
# Audit functions
# -----------------------------

def scan_file_for_patterns(
    path: Path,
    lines: List[str],
    patterns: List[Tuple[str, str, str, re.Pattern, str]],
    findings: List[Finding],
):
    for idx, line in enumerate(lines, start=1):
        for rule_id, title, severity, pat, rec in patterns:
            if pat.search(line):
                add_finding(findings, rule_id, title, severity, path, idx, line, rec)

def scan_dart_random_security_context(path: Path, lines: List[str], findings: List[Finding]):
    for idx, line in enumerate(lines, start=1):
        if not RANDOM_PATTERN.search(line):
            continue
        start = max(0, idx - 3)
        end = min(len(lines), idx + 2)
        context = "\n".join(lines[start:end])
        if not RANDOM_SECURITY_CONTEXT_PATTERN.search(context):
            continue
        add_finding(
            findings,
            "DART_INSECURE_RANDOM",
            "Potential weak randomness (Random()) in security-sensitive context",
            "medium",
            path,
            idx,
            line,
            "Use cryptographically secure randomness for security-sensitive values (tokens, keys, auth/session material).",
        )

def _path_matches_any_glob(rel_posix_path: str, globs: Iterable[str]) -> bool:
    for pattern in globs:
        if fnmatch.fnmatch(rel_posix_path, pattern):
            return True
    return False

def scan_http_urls(path: Path, rel_posix_path: str, lines: List[str], findings: List[Finding]):
    if _path_matches_any_glob(rel_posix_path, URL_SCAN_EXCLUDED_PATH_GLOBS):
        return
    for idx, line in enumerate(lines, start=1):
        for match in HTTP_URL_PATTERN.finditer(line):
            url = match.group(0)
            if any(url.startswith(prefix) for prefix in URL_SCAN_IGNORED_PREFIXES):
                continue
            add_finding(
                findings,
                "URL_HTTP_ANY",
                "Insecure HTTP URL found in project file",
                "high",
                path,
                idx,
                line,
                "Avoid shipping HTTP endpoints. Use HTTPS and enforce ATS/Network Security Config.",
            )

def _to_rel_posix(path: Path, root: Path) -> str:
    path_posix = path.resolve().as_posix()
    root_posix = root.resolve().as_posix()
    if path_posix.startswith(root_posix):
        rel = path_posix[len(root_posix):].lstrip("/")
        return rel
    return path.as_posix()

def load_ignore_rules(root: Path, ignore_file: Optional[str]) -> List[dict]:
    if ignore_file:
        ignore_path = Path(ignore_file)
        if not ignore_path.is_absolute():
            ignore_path = (root / ignore_path).resolve()
    else:
        ignore_path = (root / DEFAULT_IGNORE_REL_PATH).resolve()

    if not ignore_path.exists():
        return []

    try:
        data = json.loads(ignore_path.read_text(encoding="utf-8"))
    except Exception:
        return []

    if isinstance(data, list):
        rules = data
    elif isinstance(data, dict):
        rules = data.get("ignore", [])
    else:
        return []

    return [rule for rule in rules if isinstance(rule, dict)]

def should_ignore_finding(finding: Finding, root: Path, ignore_rules: List[dict]) -> bool:
    finding_path = _to_rel_posix(Path(finding.file), root)
    for rule in ignore_rules:
        rule_id = str(rule.get("rule_id", "*"))
        path_glob = str(rule.get("path", "**"))
        snippet_contains = rule.get("snippet_contains")
        severity = rule.get("severity")

        if rule_id != "*" and rule_id != finding.rule_id:
            continue
        if severity is not None and str(severity) != finding.severity:
            continue
        if path_glob and not fnmatch.fnmatch(finding_path, path_glob):
            continue
        if snippet_contains is not None and str(snippet_contains) not in finding.snippet:
            continue
        return True
    return False

def scan_manifest_exported_missing(path: Path, lines: List[str], findings: List[Finding]):
    """
    Android 12+ requires android:exported for components with intent-filters.
    We do a heuristic:
      - if line contains <activity ...> and later has <intent-filter>
      - and the activity tag doesn't contain android:exported
    This is not a full XML parser, but catches many cases.
    """
    content = "\n".join(lines)
    # Find activity/service/receiver blocks that contain intent-filter
    tag_re = re.compile(r"""<(activity|service|receiver)\b([^>]*)>(.*?)</\1>""", re.DOTALL | re.IGNORECASE)
    for m in tag_re.finditer(content):
        tag = m.group(1).lower()
        attrs = m.group(2)
        inner = m.group(3)
        if "<intent-filter" in inner.lower():
            if re.search(r"""android:exported\s*=""", attrs, re.IGNORECASE) is None:
                # approximate line number
                start_pos = m.start()
                line_no = content[:start_pos].count("\n") + 1
                add_finding(
                    findings,
                    "ANDROID_EXPORTED_MISSING",
                    f"Android {tag} has intent-filter but missing android:exported (build/runtime risk)",
                    "medium",
                    path,
                    line_no,
                    f"<{tag}{attrs}> ... <intent-filter> ...",
                    "Add android:exported explicitly. Use exported=false unless external apps must invoke it."
                )

def detect_pubspec_security_notes(root: Path, findings: List[Finding]):
    pubspec = root / "pubspec.yaml"
    if not pubspec.exists():
        return
    lines = read_lines(pubspec)
    joined = "\n".join(lines)

    # Heuristic checks for potentially risky packages (not inherently insecure, but review)
    risky = [
        ("PKG_HTTP", "Uses package:http (review TLS/pinning, no secrets in headers)", "low", r"(?m)^\s*http:\s"),
        ("PKG_DIO", "Uses dio (review interceptors, certificate pinning, logging)", "low", r"(?m)^\s*dio:\s"),
        ("PKG_WEBVIEW", "Uses WebView package (review JS, navigation restrictions)", "medium", r"(?m)^\s*(webview_flutter|flutter_inappwebview):\s"),
        ("PKG_SECURE_STORAGE", "Uses flutter_secure_storage (good, verify usage)", "low", r"(?m)^\s*flutter_secure_storage:\s"),
        ("PKG_SHARED_PREFS", "Uses shared_preferences (do not store secrets)", "medium", r"(?m)^\s*shared_preferences:\s"),
    ]
    for rule_id, title, sev, pat in risky:
        if re.search(pat, joined):
            add_finding(
                findings,
                rule_id,
                title,
                sev,
                pubspec,
                1,
                title,
                "Review how this package is used. Ensure secrets are never stored in plaintext and networking is secure."
            )

def audit(root: Path) -> List[Finding]:
    findings: List[Finding] = []

    detect_pubspec_security_notes(root, findings)

    for path in iter_files(root):
        lines = read_lines(path)
        if not lines:
            continue

        p = str(path).replace("\\", "/")
        rel_posix_path = path.relative_to(root).as_posix()

        # Dart + general secrets
        if path.suffix.lower() == ".dart":
            scan_file_for_patterns(path, lines, RULES_DART, findings)
            scan_dart_random_security_context(path, lines, findings)
            scan_file_for_patterns(path, lines, SECRET_PATTERNS, findings)

        # General secrets in all text files (but avoid noisy md unless you want)
        if path.suffix.lower() in {".yaml", ".yml", ".json", ".properties", ".gradle", ".kt", ".java", ".xml", ".plist"}:
            scan_file_for_patterns(path, lines, SECRET_PATTERNS, findings)

        # Android manifest checks
        if p.endswith("android/app/src/main/AndroidManifest.xml") or p.endswith("AndroidManifest.xml"):
            scan_file_for_patterns(path, lines, ANDROID_RULES, findings)
            scan_manifest_exported_missing(path, lines, findings)

        # iOS plist checks
        if p.endswith("ios/Runner/Info.plist") or p.endswith("Info.plist"):
            scan_file_for_patterns(path, lines, IOS_RULES, findings)

        # Any file: insecure URLs
        if path.suffix.lower() in TEXT_EXTS:
            scan_http_urls(path, rel_posix_path, lines, findings)

    # Deduplicate identical findings (same rule/file/line/snippet)
    uniq = {}
    for f in findings:
        k = (f.rule_id, f.file, f.line, f.snippet)
        uniq[k] = f
    return list(uniq.values())


# -----------------------------
# Output formatting
# -----------------------------

def print_report(findings: List[Finding]):
    if not findings:
        print("✅ No findings detected by this static audit (heuristic-based).")
        return

    findings_sorted = sorted(findings, key=lambda f: (-SEV_ORDER.get(f.severity, 1), f.file, f.line))

    # Summary
    counts = {"high": 0, "medium": 0, "low": 0}
    for f in findings_sorted:
        counts[f.severity] = counts.get(f.severity, 0) + 1

    print("=== Flutter Security Audit Report (static, heuristic) ===")
    print(f"Findings: high={counts.get('high',0)} medium={counts.get('medium',0)} low={counts.get('low',0)}\n")

    # Details
    for f in findings_sorted:
        print(f"[{f.severity.upper()}] {f.rule_id}: {f.title}")
        print(f"  File: {f.file}:{f.line}")
        print(f"  Snippet: {f.snippet}")
        print(f"  Recommendation: {f.recommendation}")
        print("-" * 72)

def write_json(findings: List[Finding], out_path: Path):
    data = [asdict(f) for f in sorted(findings, key=lambda f: (-SEV_ORDER.get(f.severity, 1), f.file, f.line))]
    out_path.write_text(json.dumps({"findings": data}, indent=2), encoding="utf-8")


# -----------------------------
# Main
# -----------------------------

def main():
    ap = argparse.ArgumentParser(description="Static security audit for Flutter apps (Dart/Android/iOS).")
    ap.add_argument("path", help="Path to Flutter project root")
    ap.add_argument("--json", dest="json_out", help="Write findings to JSON file")
    ap.add_argument(
        "--ignore-file",
        dest="ignore_file",
        help="Optional ignore JSON path (default: .agent/audit-ignore.json when present)",
    )
    ap.add_argument("--severity", choices=["low", "medium", "high"], default="low",
                    help="Minimum severity to show (default: low)")
    args = ap.parse_args()

    root = Path(args.path).resolve()
    if not root.exists() or not root.is_dir():
        raise SystemExit(f"Invalid path: {root}")

    findings = audit(root)
    ignore_rules = load_ignore_rules(root, args.ignore_file)
    if ignore_rules:
        findings = [
            finding
            for finding in findings
            if not should_ignore_finding(finding, root, ignore_rules)
        ]
    findings = severity_filter(findings, args.severity)

    print_report(findings)

    if args.json_out:
        out_path = Path(args.json_out).resolve()
        write_json(findings, out_path)
        print(f"\nJSON written to: {out_path}")

if __name__ == "__main__":
    main()
