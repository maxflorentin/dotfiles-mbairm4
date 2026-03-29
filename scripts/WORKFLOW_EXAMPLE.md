# Jira Automation Workflow with GEM

Complete workflow for creating Jira tickets using GEM AI to generate content.

## Prerequisites

1. Set up `.env` file:
```bash
JIRA_EMAIL=your-email@company.com
JIRA_API_TOKEN=your-api-token
JIRA_DOMAIN=your-domain
```

2. Discover available fields:
```bash
make jira-fields
# or
python jira_get_fields.py
```

Review `jira_project_metadata.json` to see which fields are required/available.

## Workflow Option 1: Direct JSON Generation

Ask GEM to generate a complete JSON using the template:

**Prompt to GEM:**
```
Using this Jira ticket template (see jira_full_template.json),
generate a JSON for a ticket with:

Title: "Add read permissions for my-service on the database"
Priority: High
Labels: analytics, permissions, infrastructure

Description should include:
- Overview of the request
- Environments: DEV, Staging, Production
- Required SQL grants
- Security considerations

Use proper Jira ADF format for the description.
```

**GEM Output:** `gem_ticket.json`

**Create the ticket:**
```bash
make jira-create FILE=gem_ticket.json
```

## Workflow Option 2: Markdown + Template Merge

Ask GEM to generate markdown first (easier for GEM):

**Prompt to GEM:**
```
Write a detailed markdown description for a Jira ticket about
granting database read permissions to my-service
across DEV/Staging/Production environments.

Include:
- Problem overview
- Required permissions
- SQL grant statements
- Rollback plan
- Security notes

Use markdown with headings, bullet lists, and code blocks.
```

**GEM Output:** `gem_description.md`

**Merge with template:**
```bash
make jira-merge \
  TEMPLATE=jira_ticket_template.json \
  MD=gem_description.md \
  OUTPUT=final_ticket.json

make jira-create FILE=final_ticket.json
```

## Workflow Option 3: Manual Merge

1. Generate markdown description with GEM
2. Convert to ADF format:
```bash
make md-to-adf FILE=gem_description.md > description_adf.json
```

3. Manually edit template and insert the ADF
4. Create ticket:
```bash
make jira-create FILE=manual_ticket.json
```

## Tips for GEM Prompts

### For Direct JSON Generation

```
Generate a Jira ticket JSON with these specifications:

Project: PROJ
Issue Type: Task
Priority: High
Summary: [Your title]

Description (use Jira ADF format):
- Heading 2: "Problem Statement"
- Paragraph: [Context]
- Heading 3: "Technical Details"
- Bullet list: [Requirements]
- Code block (SQL): [Grant statements]
- Panel (warning): [Important notes]

Labels: [your, labels]

Reference JIRA_ADF_FORMAT.md for proper formatting.
```

### For Markdown Generation

```
Write a detailed markdown document for a Jira ticket:

Title: [Your title]

Structure:
## Problem Statement
[Context and background]

## Requirements
- Item 1
- Item 2

## Technical Implementation
1. Step 1
2. Step 2

### Required Commands
```bash
command here
```

## Rollback Plan
[Rollback steps]

> **Warning:** [Important security notes]
```

## Complete Example

**GEM Prompt:**
```
Create a Jira ticket JSON for:

Project: PROJ
Title: "Configure database permissions for my-service"
Priority: High
Labels: analytics, permissions, infrastructure

Description:
## Overview
The my-service microservice requires read-only access to the analytics
database across all environments.

## Environments
- Development (DEV)
- Staging (STG)
- Production (PRD)

## Required Grants
```sql
GRANT SELECT ON DATABASE my_db TO ROLE 'reader_role';
GRANT ROLE 'reader_role' TO USER 'my-service'@'%';
```

## Security Considerations
- Read-only access (no INSERT/UPDATE/DELETE)
- Scoped to my_db database only
- Requires DBA approval

Use proper Jira ADF format.
```

**GEM generates:** `ticket.json`

**Create ticket:**
```bash
python jira_create_ticket.py ticket.json
# Output: ✓ Ticket created: https://your-domain.atlassian.net/browse/PROJ-1234
```

## Automation Scripts

Quick reference:

```bash
make jira-fields                                    # Discover fields
make jira-create FILE=ticket.json                   # Create ticket
make md-to-adf FILE=description.md                  # Convert markdown
make jira-merge TEMPLATE=t.json MD=d.md OUTPUT=f.json  # Merge files
make jira-help                                      # Show help
```

## Custom Fields

After running `make jira-fields`, check `jira_project_metadata.json` for custom fields like:

```json
"customfield_10016": {
  "name": "Story Points",
  "schema": {"type": "number"}
}
```

Add them to your template:

```json
{
  "fields": {
    "customfield_10016": 8
  }
}
```

## Troubleshooting

**403 Forbidden:**
- Check API token is valid
- Verify user has permission to create issues in project

**400 Bad Request:**
- Run `make jira-fields` to see required fields
- Check field values match allowed values
- Ensure ADF format is correct

**Required field missing:**
- Add missing field to JSON
- Check `jira_project_metadata.json` for field details
