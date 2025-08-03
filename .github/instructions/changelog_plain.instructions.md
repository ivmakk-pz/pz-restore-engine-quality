---
applyTo: 'workshop_updates.txt'
---

# Plain Text Changelog Guide for Steam Workshop

> **Note:** This guide focuses on plain text formatting for Steam Workshop. For the main changelog rules and structure, see [changelog.instructions.md](changelog.instructions.md).

## Purpose
- Use the file [workshop_updates.txt](../../workshop_assets/workshop_updates.txt) for Steam Workshop update descriptions
- Convert structured [CHANGELOG.md](../../CHANGELOG.md) content into plain text format for easy copy-paste to Steam's mod updates UI
- Maintain chronological order with newest versions first

## Plain Text Format Requirements

### Version Header Format
```
v[VERSION] - YYYY-MM-DD
```
- Use "v" prefix before version number (e.g., "v1.1.1")
- Use ISO date format (YYYY-MM-DD)
- Single blank line after version header
- **Do not include "Unreleased" sections** - this format is only for tracking released changes that need to be posted to Steam Workshop

### Section Headings
Use these section headings in this exact order (when applicable):
- `Added`
- `Changed`
- `Deprecated` 
- `Removed`
- `Fixed`
- `Security`

### Content Formatting Rules
- No markdown formatting (no `###`, `**`, `*`, etc.)
- Use simple hyphens (-) for bullet points
- Single blank line between different sections
- Double blank line between different versions
- Each bullet point starts with "- " (hyphen + space)
- Keep descriptions concise and user-friendly

### Example Format Structure
```
v1.1.1 - 2025-06-27

Changed
- Renamed Mod Option from "Show View Distance Estimate" to "Show Items View Distance"


v1.1.0 - 2025-06-27

Added
- Functionality to display estimated view distances for small, medium, and large items
- Food search bonus based on Hunger level

Changed
- Refactored growing codebase and extracted Utilities file

Fixed
- Unused mod option "Show Zero Penalties" (previously, "Show Zero Trait Bonuses" was incorrectly used instead)
- Minor typos in localizations (EN)
```

## Content Guidelines
- Focus on user-facing changes and improvements
- Avoid technical jargon when possible
- Group similar changes under appropriate sections
- Omit internal code refactoring details unless they impact user experience
- Use clear, descriptive language that players can understand
- Don't include "Unreleased" section in the plain text version

## Steam Workshop Copy-Paste Process
1. Copy the relevant version section(s) from workshop_updates.txt
2. Paste directly into Steam Workshop's "Change Notes" field
3. Steam will preserve the plain text formatting for user readability
