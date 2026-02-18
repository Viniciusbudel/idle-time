import os
import re

def refactor_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    new_content = ""
    i = 0
    length = len(content)
    modified = False

    while i < length:
        # specific strings "withOpacity("
        match = content.find("withOpacity(", i)
        if match == -1:
            new_content += content[i:]
            break

        new_content += content[i:match]
        
        # Start of argument
        arg_start = match + len("withOpacity(")
        
        # Balance parens to find end of argument
        paren_depth = 1
        j = arg_start
        while j < length and paren_depth > 0:
            if content[j] == '(':
                paren_depth += 1
            elif content[j] == ')':
                paren_depth -= 1
            j += 1
        
        if paren_depth == 0:
            # j is now after the closing ')'
            arg = content[arg_start : j-1]
            new_content += f"withValues(alpha: {arg})"
            modified = True
            i = j
        else:
            # Malformed or EOF? Just skip this one
            new_content += content[match : match + len("withOpacity(")]
            i = match + len("withOpacity(")

    if modified:
        print(f"Refactoring {filepath}")
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)

def main():
    root_dir = os.getcwd()
    for dirpath, _, filenames in os.walk(root_dir):
        if '.dart_tool' in dirpath or 'build' in dirpath:
            continue
            
        for filename in filenames:
            if filename.endswith('.dart'):
                refactor_file(os.path.join(dirpath, filename))

if __name__ == '__main__':
    main()
