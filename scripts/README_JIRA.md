# Jira Automation Scripts

Scripts to automate Jira ticket creation using JSON payloads.

## Prerequisites

- `uv` installed (Python package manager)
- Jira API credentials

## Setup

1. Create a `.env` file in the scripts directory:

```bash
JIRA_EMAIL=your-email@company.com
JIRA_API_TOKEN=your-api-token
JIRA_DOMAIN=your-domain
```

2. Generate an API token: https://id.atlassian.com/manage-profile/security/api-tokens

**Note:** Scripts use `uv run` with inline dependencies - no manual installation needed!

## Scripts

### 1. Get Available Fields

Discover all available fields for your Jira project:

```bash
python jira_get_fields.py
```

This generates:
- `jira_all_fields.json` - All Jira fields
- `jira_project_metadata.json` - Project-specific fields with allowed values

### 2. Create Tickets from JSON

```bash
python jira_create_ticket.py my_ticket.json
```

### 3. Convert Markdown to Jira ADF

```bash
python markdown_to_jira_adf.py description.md > description_adf.json
```

Or pipe:

```bash
echo "# Hello\n\nThis is **bold**" | python markdown_to_jira_adf.py
```

## JSON Template Structure

Use `jira_ticket_template.json` as base. Common fields:

```json
{
  "fields": {
    "project": {"key": "ANA"},
    "summary": "Ticket title",
    "description": {
      "type": "doc",
      "version": 1,
      "content": [...]
    },
    "issuetype": {"name": "Task"},
    "priority": {"name": "High"},
    "labels": ["tag1", "tag2"],
    "assignee": {"accountId": "user-id"},
    "duedate": "2024-12-31"
  }
}
```

## Workflow with GEM

1. Ask GEM to generate a JSON using the template
2. GEM can write markdown descriptions
3. Convert markdown to ADF if needed
4. Create ticket from JSON

Example:

```bash
python markdown_to_jira_adf.py gem_description.md > adf.json
python jira_create_ticket.py gem_ticket.json
```

## Priority Values

Common values: `Highest`, `High`, `Medium`, `Low`, `Lowest`

Run `jira_get_fields.py` to see exact values for your instance.
