#!/usr/bin/env -S uv run
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "requests",
#     "python-dotenv",
# ]
# ///
"""
Script to create Jira tickets from JSON payload files or stdin.
Usage:
    jira_create_ticket.py <json_file>
    jira_create_ticket.py -
    echo '{"fields": {...}}' | jira_create_ticket.py
    pbpaste | jira_create_ticket.py
"""
import os
import sys
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

# Clean up domain: remove https://, http://, and trailing slashes
domain = domain.replace("https://", "").replace("http://", "").rstrip("/")

if ".atlassian.net" in domain:
    base_url = f"https://{domain}"
else:
    base_url = f"https://{domain}.atlassian.net"

auth = (email, token)
headers = {
    "Accept": "application/json",
    "Content-Type": "application/json"
}

def get_current_user():
    """Get the authenticated user's account ID."""
    url = f"{base_url}/rest/api/3/myself"
    response = requests.get(url, headers=headers, auth=auth)
    if response.status_code == 200:
        return response.json().get("accountId")
    return None

def get_active_sprint(board_id=None, sprint_pattern=None):
    """
    Get the active sprint ID and name for a board.
    If board_id is not provided, tries to find the first active sprint matching the pattern.
    Returns: tuple (sprint_id, sprint_name) or (None, None)
    """
    if board_id:
        url = f"{base_url}/rest/agile/1.0/board/{board_id}/sprint"
        params = {"state": "active"}
        response = requests.get(url, headers=headers, auth=auth, params=params)
        if response.status_code == 200:
            sprints = response.json().get("values", [])
            for sprint in sprints:
                if not sprint_pattern or sprint_pattern.lower() in sprint["name"].lower():
                    return sprint["id"], sprint["name"]

    url = f"{base_url}/rest/agile/1.0/board"
    response = requests.get(url, headers=headers, auth=auth)
    if response.status_code == 200:
        boards = response.json().get("values", [])
        for board in boards:
            sprint_url = f"{base_url}/rest/agile/1.0/board/{board['id']}/sprint"
            sprint_response = requests.get(sprint_url, headers=headers, auth=auth, params={"state": "active"})
            if sprint_response.status_code == 200:
                sprints = sprint_response.json().get("values", [])
                for sprint in sprints:
                    if not sprint_pattern or sprint_pattern.lower() in sprint["name"].lower():
                        return sprint["id"], sprint["name"]
    return None, None

def create_issue(payload):
    """
    Create a Jira issue from a payload dictionary.

    Args:
        payload: Dictionary containing the issue fields

    Returns:
        Dictionary with the created issue data
    """
    if "fields" not in payload:
        payload["fields"] = {}

    if "customfield_12041" not in payload["fields"]:
        payload["fields"]["customfield_12041"] = [{"value": "All Customers"}]

    country_field = os.getenv("JIRA_COUNTRY_FIELD")
    if country_field and country_field not in payload["fields"]:
        payload["fields"][country_field] = [{"value": "All"}]

    reporting_type_field = os.getenv("JIRA_REPORTING_TYPE_FIELD")
    if reporting_type_field and reporting_type_field not in payload["fields"]:
        payload["fields"][reporting_type_field] = {"value": "Team"}

    auto_assign = os.getenv("JIRA_AUTO_ASSIGN", "true").lower() == "true"
    if auto_assign and "assignee" not in payload["fields"]:
        account_id = get_current_user()
        if account_id:
            payload["fields"]["assignee"] = {"accountId": account_id}
            print(f"→ Auto-assigning to current user")

    sprint_field = os.getenv("JIRA_SPRINT_FIELD", "customfield_10020")
    auto_sprint = os.getenv("JIRA_AUTO_SPRINT", "true").lower() == "true"
    if auto_sprint and sprint_field not in payload["fields"]:
        board_id = os.getenv("JIRA_BOARD_ID")
        sprint_pattern = os.getenv("JIRA_SPRINT_PATTERN", "Analytics")
        sprint_id, sprint_name = get_active_sprint(
            int(board_id) if board_id else None,
            sprint_pattern
        )
        if sprint_id:
            payload["fields"][sprint_field] = sprint_id
            print(f"→ Adding to active sprint: {sprint_name}")

    url = f"{base_url}/rest/api/3/issue"
    response = requests.post(url, data=json.dumps(payload), headers=headers, auth=auth)

    if response.status_code == 201:
        issue_data = response.json()
        issue_key = issue_data['key']
        issue_url = f"{base_url}/browse/{issue_key}"
        print(f"✓ Ticket created: {issue_url}")
        return issue_data
    else:
        print(f"✗ Error {response.status_code}")
        print(f"Response: {response.text}")
        response.raise_for_status()

def load_payload_from_file(file_path):
    """
    Load JSON payload from file.

    Args:
        file_path: Path to the JSON file

    Returns:
        Dictionary with the payload data
    """
    path = Path(file_path)
    if not path.exists():
        raise FileNotFoundError(f"File not found: {file_path}")

    with open(path, 'r') as f:
        return json.load(f)

def main():
    """Main execution function."""
    try:
        if len(sys.argv) < 2 or sys.argv[1] == "-":
            if sys.stdin.isatty():
                print("Usage: python jira_create_ticket.py <json_file>")
                print("       python jira_create_ticket.py -")
                print("       echo '{...}' | python jira_create_ticket.py")
                print("\nExamples:")
                print("  python jira_create_ticket.py ticket.json")
                print("  cat ticket.json | python jira_create_ticket.py")
                print("  pbpaste | python jira_create_ticket.py")
                sys.exit(1)

            print("Reading JSON from stdin...")
            payload = json.load(sys.stdin)
        else:
            json_file = sys.argv[1]
            print(f"Loading payload from: {json_file}")
            payload = load_payload_from_file(json_file)

        print(f"Creating ticket in project: {payload.get('fields', {}).get('project', {}).get('key', 'N/A')}")
        print(f"Summary: {payload.get('fields', {}).get('summary', 'N/A')}\n")

        create_issue(payload)

    except FileNotFoundError as e:
        print(f"✗ {e}")
        sys.exit(1)
    except requests.exceptions.HTTPError as e:
        print(f"✗ HTTP Error: {e.response.status_code}")
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"✗ Invalid JSON: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"✗ Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
