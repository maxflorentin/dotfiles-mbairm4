# Jira ADF (Atlassian Document Format) Guide

This guide explains how to format `description` and `environment` fields in Jira tickets.

## Basic Structure

```json
{
  "type": "doc",
  "version": 1,
  "content": [
    // Array of content blocks
  ]
}
```

## Content Block Types

### Paragraph

```json
{
  "type": "paragraph",
  "content": [
    {"type": "text", "text": "Plain text"}
  ]
}
```

### Headings

Levels 1-6:

```json
{
  "type": "heading",
  "attrs": {"level": 2},
  "content": [
    {"type": "text", "text": "Section Title"}
  ]
}
```

### Bullet List

```json
{
  "type": "bulletList",
  "content": [
    {
      "type": "listItem",
      "content": [
        {"type": "paragraph", "content": [{"type": "text", "text": "Item 1"}]}
      ]
    },
    {
      "type": "listItem",
      "content": [
        {"type": "paragraph", "content": [{"type": "text", "text": "Item 2"}]}
      ]
    }
  ]
}
```

### Ordered List

```json
{
  "type": "orderedList",
  "content": [
    {
      "type": "listItem",
      "content": [
        {"type": "paragraph", "content": [{"type": "text", "text": "Step 1"}]}
      ]
    }
  ]
}
```

### Code Block

```json
{
  "type": "codeBlock",
  "attrs": {"language": "python"},
  "content": [
    {"type": "text", "text": "def hello():\n    print('world')"}
  ]
}
```

Languages: `python`, `javascript`, `bash`, `sql`, `json`, `yaml`, `java`, etc.

### Panel (Callout)

```json
{
  "type": "panel",
  "attrs": {"panelType": "info"},
  "content": [
    {
      "type": "paragraph",
      "content": [{"type": "text", "text": "Important information"}]
    }
  ]
}
```

Panel types: `info`, `note`, `warning`, `error`, `success`

## Text Formatting (Marks)

### Bold

```json
{
  "type": "text",
  "text": "bold text",
  "marks": [{"type": "strong"}]
}
```

### Italic

```json
{
  "type": "text",
  "text": "italic text",
  "marks": [{"type": "em"}]
}
```

### Inline Code

```json
{
  "type": "text",
  "text": "code",
  "marks": [{"type": "code"}]
}
```

### Strikethrough

```json
{
  "type": "text",
  "text": "deleted",
  "marks": [{"type": "strike"}]
}
```

### Underline

```json
{
  "type": "text",
  "text": "underlined",
  "marks": [{"type": "underline"}]
}
```

### Link

```json
{
  "type": "text",
  "text": "Google",
  "marks": [
    {
      "type": "link",
      "attrs": {"href": "https://google.com"}
    }
  ]
}
```

### Multiple Marks

```json
{
  "type": "text",
  "text": "bold and italic",
  "marks": [
    {"type": "strong"},
    {"type": "em"}
  ]
}
```

## Complete Example

```json
{
  "type": "doc",
  "version": 1,
  "content": [
    {
      "type": "heading",
      "attrs": {"level": 2},
      "content": [{"type": "text", "text": "Problem Description"}]
    },
    {
      "type": "paragraph",
      "content": [
        {"type": "text", "text": "The "},
        {"type": "text", "text": "audit-logs-ms", "marks": [{"type": "code"}]},
        {"type": "text", "text": " service needs "},
        {"type": "text", "text": "read permissions", "marks": [{"type": "strong"}]},
        {"type": "text", "text": " on StarRocks."}
      ]
    },
    {
      "type": "heading",
      "attrs": {"level": 3},
      "content": [{"type": "text", "text": "Environments"}]
    },
    {
      "type": "bulletList",
      "content": [
        {
          "type": "listItem",
          "content": [{"type": "paragraph", "content": [{"type": "text", "text": "DEV"}]}]
        },
        {
          "type": "listItem",
          "content": [{"type": "paragraph", "content": [{"type": "text", "text": "Staging"}]}]
        },
        {
          "type": "listItem",
          "content": [{"type": "paragraph", "content": [{"type": "text", "text": "Production"}]}]
        }
      ]
    },
    {
      "type": "heading",
      "attrs": {"level": 3},
      "content": [{"type": "text", "text": "Required Grants"}]
    },
    {
      "type": "codeBlock",
      "attrs": {"language": "sql"},
      "content": [
        {"type": "text", "text": "GRANT SELECT ON DATABASE audit_logs TO ROLE 'audit_reader';"}
      ]
    },
    {
      "type": "panel",
      "attrs": {"panelType": "warning"},
      "content": [
        {
          "type": "paragraph",
          "content": [
            {"type": "text", "text": "Requires approval from "},
            {"type": "text", "text": "DBA team", "marks": [{"type": "strong"}]}
          ]
        }
      ]
    }
  ]
}
```

## Tips for GEM

When generating Jira ticket JSON:

1. Always wrap description in ADF format (doc → content array)
2. Use headings to organize sections
3. Use bullet lists for requirements/items
4. Use code blocks for commands/code
5. Use panels for important notes/warnings
6. Combine text marks for formatting (bold + italic, etc.)
7. Keep inline code for short snippets, code blocks for multiline
8. Use ordered lists for sequential steps
9. Add proper language attributes to code blocks

## Common Fields Reference

```json
{
  "fields": {
    "project": {"key": "PROJECT_KEY"},
    "summary": "Short title (max 255 chars)",
    "description": {ADF_OBJECT},
    "issuetype": {"name": "Task|Bug|Story|Epic"},
    "priority": {"name": "Highest|High|Medium|Low|Lowest"},
    "labels": ["tag1", "tag2"],
    "assignee": {"accountId": "user-account-id"},
    "reporter": {"accountId": "user-account-id"},
    "duedate": "YYYY-MM-DD",
    "components": [{"name": "Component Name"}],
    "fixVersions": [{"name": "v1.0.0"}],
    "environment": {ADF_OBJECT}
  }
}
```
