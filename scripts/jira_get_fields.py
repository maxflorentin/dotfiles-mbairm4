#!/usr/bin/env -S uv run
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "requests",
#     "python-dotenv",
# ]
# ///
"""
Script to fetch all available fields in Jira.
This helps you understand exactly which fields can be used in your JSON payload.
"""
import os
import requests
import json
from pathlib import Path
from dotenv import load_dotenv

script_dir = Path(__file__).parent
env_file = script_dir / ".env"
load_dotenv(env_file)

email = os.getenv("JIRA_EMAIL")
token = os.getenv("JIRA_API_TOKEN")
domain = os.getenv("JIRA_DOMAIN")

if not all([email, token, domain]):
    raise ValueError("Missing environment variables: JIRA_EMAIL, JIRA_API_TOKEN or JIRA_DOMAIN")

if ".atlassian.net" in domain:
    base_url = f"https://{domain}"
else:
    base_url = f"https://{domain}.atlassian.net"

auth = (email, token)
headers = {"Accept": "application/json"}

def get_all_fields():
    """Fetch all available fields in Jira."""
    url = f"{base_url}/rest/api/3/field"
    response = requests.get(url, headers=headers, auth=auth)
    response.raise_for_status()
    return response.json()

def get_project_metadata(project_key):
    """Fetch project-specific metadata and issue type fields."""
    url = f"{base_url}/rest/api/3/issue/createmeta"
    params = {
        "projectKeys": project_key,
        "expand": "projects.issuetypes.fields"
    }
    response = requests.get(url, headers=headers, auth=auth, params=params)
    response.raise_for_status()
    return response.json()

def main():
    print("Fetching Jira fields...\n")

    all_fields = get_all_fields()
    with open("jira_all_fields.json", "w") as f:
        json.dump(all_fields, f, indent=2)
    print(f"✓ General fields saved to: jira_all_fields.json ({len(all_fields)} fields)\n")

    project_key = "ANA"
    metadata = get_project_metadata(project_key)
    with open("jira_project_metadata.json", "w") as f:
        json.dump(metadata, f, indent=2)
    print(f"✓ Project '{project_key}' metadata saved to: jira_project_metadata.json\n")

    if metadata.get("projects"):
        project = metadata["projects"][0]
        print(f"Project: {project['name']} ({project['key']})")

        for issue_type in project.get("issuetypes", []):
            if issue_type["name"] == "Task":
                print(f"\nAvailable fields for '{issue_type['name']}':\n")
                fields = issue_type.get("fields", {})

                for field_key, field_info in sorted(fields.items()):
                    required = "REQUIRED" if field_info.get("required") else "optional"
                    field_name = field_info.get("name", "")
                    field_type = field_info.get("schema", {}).get("type", "")

                    print(f"  • {field_key:30s} [{required:12s}] {field_name:30s} ({field_type})")

                    if "allowedValues" in field_info:
                        values = [v.get("name", v.get("value", str(v))) for v in field_info["allowedValues"][:5]]
                        if len(field_info["allowedValues"]) > 5:
                            values.append(f"... and {len(field_info['allowedValues']) - 5} more")
                        print(f"    → Values: {', '.join(values)}")
                break

if __name__ == "__main__":
    try:
        main()
    except requests.exceptions.HTTPError as e:
        print(f"✗ HTTP Error: {e.response.status_code}")
        print(f"Details: {e.response.text}")
    except Exception as e:
        print(f"✗ Error: {e}")
