#!/usr/bin/env -S uv run
# /// script
# requires-python = ">=3.11"
# ///
"""
Convert Markdown text to Jira ADF (Atlassian Document Format).
This is useful when you have markdown descriptions and need to convert them to Jira's format.

Usage:
    markdown_to_jira_adf.py <markdown_file>
    echo "# Hello\n\nWorld" | markdown_to_jira_adf.py
"""
import sys
import json
import re

def markdown_to_adf(markdown_text):
    """
    Convert markdown text to Jira ADF format.

    Args:
        markdown_text: String containing markdown content

    Returns:
        Dictionary with ADF structure
    """
    content = []
    lines = markdown_text.strip().split('\n')
    i = 0

    while i < len(lines):
        line = lines[i]

        if not line.strip():
            i += 1
            continue

        if line.startswith('# '):
            content.append({
                "type": "heading",
                "attrs": {"level": 1},
                "content": [{"type": "text", "text": line[2:].strip()}]
            })
        elif line.startswith('## '):
            content.append({
                "type": "heading",
                "attrs": {"level": 2},
                "content": [{"type": "text", "text": line[3:].strip()}]
            })
        elif line.startswith('### '):
            content.append({
                "type": "heading",
                "attrs": {"level": 3},
                "content": [{"type": "text", "text": line[4:].strip()}]
            })
        elif line.startswith('- ') or line.startswith('* '):
            list_items = []
            while i < len(lines) and (lines[i].startswith('- ') or lines[i].startswith('* ')):
                item_text = lines[i][2:].strip()
                list_items.append({
                    "type": "listItem",
                    "content": [{
                        "type": "paragraph",
                        "content": parse_inline_formatting(item_text)
                    }]
                })
                i += 1
            content.append({
                "type": "bulletList",
                "content": list_items
            })
            continue
        elif line.startswith('```'):
            language = line[3:].strip() or "text"
            code_lines = []
            i += 1
            while i < len(lines) and not lines[i].startswith('```'):
                code_lines.append(lines[i])
                i += 1
            content.append({
                "type": "codeBlock",
                "attrs": {"language": language},
                "content": [{"type": "text", "text": '\n'.join(code_lines)}]
            })
        else:
            content.append({
                "type": "paragraph",
                "content": parse_inline_formatting(line)
            })

        i += 1

    return {
        "type": "doc",
        "version": 1,
        "content": content
    }

def parse_inline_formatting(text):
    """
    Parse inline markdown formatting (bold, italic, code).

    Args:
        text: String with inline markdown

    Returns:
        List of content nodes with marks
    """
    result = []
    current_text = ""
    i = 0

    while i < len(text):
        if i < len(text) - 1 and text[i:i+2] == '**':
            if current_text:
                result.append({"type": "text", "text": current_text})
                current_text = ""

            end = text.find('**', i + 2)
            if end != -1:
                result.append({
                    "type": "text",
                    "text": text[i+2:end],
                    "marks": [{"type": "strong"}]
                })
                i = end + 2
                continue

        if text[i] == '*' and (i == 0 or text[i-1] != '*'):
            if current_text:
                result.append({"type": "text", "text": current_text})
                current_text = ""

            end = text.find('*', i + 1)
            if end != -1 and (end == len(text) - 1 or text[end+1] != '*'):
                result.append({
                    "type": "text",
                    "text": text[i+1:end],
                    "marks": [{"type": "em"}]
                })
                i = end + 1
                continue

        if text[i] == '`':
            if current_text:
                result.append({"type": "text", "text": current_text})
                current_text = ""

            end = text.find('`', i + 1)
            if end != -1:
                result.append({
                    "type": "text",
                    "text": text[i+1:end],
                    "marks": [{"type": "code"}]
                })
                i = end + 1
                continue

        current_text += text[i]
        i += 1

    if current_text:
        result.append({"type": "text", "text": current_text})

    return result if result else [{"type": "text", "text": text}]

def main():
    """Main execution function."""
    if len(sys.argv) > 1:
        with open(sys.argv[1], 'r') as f:
            markdown_text = f.read()
    else:
        markdown_text = sys.stdin.read()

    adf = markdown_to_adf(markdown_text)
    print(json.dumps(adf, indent=2))

if __name__ == "__main__":
    main()
