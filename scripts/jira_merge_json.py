#!/usr/bin/env -S uv run
# /// script
# requires-python = ">=3.11"
# ///
"""
Merge a markdown description into a Jira JSON template.
This combines a template JSON with a markdown description file.

Usage:
    jira_merge_json.py --template template.json --markdown desc.md --output ticket.json
    jira_merge_json.py -t template.json -m desc.md
"""
import sys
import json
import argparse
from pathlib import Path
from markdown_to_jira_adf import markdown_to_adf

def load_json(file_path):
    """Load JSON from file."""
    with open(file_path, 'r') as f:
        return json.load(f)

def load_markdown(file_path):
    """Load markdown from file."""
    with open(file_path, 'r') as f:
        return f.read()

def merge_description(template, markdown_text):
    """
    Merge markdown description into template.

    Args:
        template: Base JSON template dict
        markdown_text: Markdown content to convert and insert

    Returns:
        Updated template dict
    """
    adf = markdown_to_adf(markdown_text)

    if "fields" not in template:
        template["fields"] = {}

    template["fields"]["description"] = adf
    return template

def main():
    """Main execution function."""
    parser = argparse.ArgumentParser(
        description="Merge markdown description into Jira JSON template"
    )
    parser.add_argument(
        "-t", "--template",
        required=True,
        help="Path to JSON template file"
    )
    parser.add_argument(
        "-m", "--markdown",
        required=True,
        help="Path to markdown description file"
    )
    parser.add_argument(
        "-o", "--output",
        help="Output JSON file (default: stdout)"
    )
    parser.add_argument(
        "--summary",
        help="Override ticket summary/title"
    )
    parser.add_argument(
        "--priority",
        help="Override priority (Highest|High|Medium|Low|Lowest)"
    )
    parser.add_argument(
        "--labels",
        help="Comma-separated labels to add/override"
    )

    args = parser.parse_args()

    try:
        template = load_json(args.template)
        markdown = load_markdown(args.markdown)

        result = merge_description(template, markdown)

        if args.summary:
            result["fields"]["summary"] = args.summary

        if args.priority:
            result["fields"]["priority"] = {"name": args.priority}

        if args.labels:
            labels = [label.strip() for label in args.labels.split(",")]
            result["fields"]["labels"] = labels

        output_json = json.dumps(result, indent=2)

        if args.output:
            with open(args.output, 'w') as f:
                f.write(output_json)
            print(f"✓ Merged JSON saved to: {args.output}")
        else:
            print(output_json)

    except FileNotFoundError as e:
        print(f"✗ File not found: {e}", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"✗ Invalid JSON: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"✗ Error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
