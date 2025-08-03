---
applyTo: 'CHANGELOG.md'
---
# Changelog Guide

Based on https://keepachangelog.com/en/1.1.0/

## 1. Purpose
- Use the file [CHANGELOG.md](../../CHANGELOG.md) for tracking changes for newer version of the mod
- Use semver for version naming like 1.1.0
- In your output explain that a changelog documents notable changes in chronological order.  
- Emphasize that it is meant for humans (users and contributors), not machines.  

## 2. Changelog Format Requirements  
- Must include an entry for **every released version**, with versions sorted **newest first**.  
- Each version entry needs:
  - **Version number** (follow SemVer if used)
  - **Release date** in ISO format (`YYYY-MM-DD`)
  - **Section headings** for change types, in this order:  
    - `Added`
    - `Changed`
    - `Deprecated`
    - `Removed`
    - `Fixed`
    - `Security`

## 3. Linking and Referencing  
- Version headers and section headings should support linking.  
- Optionally mention when Semantic Versioning is used.

## 4. "Unreleased" Section  
- Include a top-level section labeled `## [Unreleased]`.  
- Use it to collect upcoming changes before release.  
- On release, move those entries into a new version section and add the date.

## 5. Guiding Principles (Keep it clear and meaningful)  
- **For humans**: use plain language, avoid noisy commit dumps.  
- **Group similar items** under the same section heading.  
- **Don’t omit important changes**—e.g., deprecations, removals, breaking changes.  
- **Consistent date format**: use ISO format to avoid confusion (`YYYY-MM-DD`).
- Avoid logs that are too granular or machine-oriented.

## 6. Avoiding Common Misuse  
- Do not treat the changelog as a full git log history.  
- Audit that every significant update (deprecation, removal, fix) is listed.  
- Do not rely on regional date formats that can be ambiguous.

## 7. Workshop Updates Synchronization
- **Always maintain both files**: When updating CHANGELOG.md, also update the corresponding plain text version in `workshop_updates.txt`
- **Consistency is critical**: Ensure entries in both files match in content and formatting
- **Steam Workshop requirement**: The plain text version is used for Steam Workshop update descriptions, so it must be kept current
- **Release workflow**: When moving entries from "Unreleased" to a new version in CHANGELOG.md, simultaneously create the corresponding version entry in workshop_updates.txt
