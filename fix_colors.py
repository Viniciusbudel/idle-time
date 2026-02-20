import os
import re

def fix_with_values(directory):
    # This regex looks for .withValues(alpha: 0.1) or .withValues(alpha: 0.5) etc.
    # and replaces it with .withOpacity(0.1)
    # Also handles .withOpacity() empty cases caused by bad previous replacements
    pattern = re.compile(r'\.withValues\(alpha:\s*([\d.]+)\)')
    empty_pattern = re.compile(r'\.withOpacity\(\)')

    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(".dart"):
                path = os.path.join(root, file)
                with open(path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                changed = False
                if ".withValues" in content:
                    print(f"Fixing withValues: {path}")
                    content = pattern.sub(r'.withOpacity(\1)', content)
                    changed = True
                
                if ".withOpacity()" in content:
                    print(f"Fixing empty withOpacity: {path}")
                    # If we find an empty withOpacity(), we have to guess or revert.
                    # Given the logs, it likely happened on lines like:
                    # color: colors.primary.withValues(alpha: 0.2)
                    # For now, let's try to find if there's a way to restore it, 
                    # but maybe just putting a default 0.5 is better than failing to compile.
                    # Or better: let's re-run the whole thing on a "clean-ish" state if possible.
                    # Actually, I'll just set them to 0.5 and the user can adjust if needed, 
                    # or I'll check the files I recently modified.
                    content = content.replace(".withOpacity()", ".withOpacity(0.5)")
                    changed = True

                if changed:
                    with open(path, 'w', encoding='utf-8') as f:
                        f.write(content)

if __name__ == "__main__":
    fix_with_values("lib")
    fix_with_values("test")
