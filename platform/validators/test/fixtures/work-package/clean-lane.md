# Work-Package Lane — Example (clean)

```yaml
lane:
  branch: feat/example-lane
  base: main
  prMode: draft
  allowedFiles:
    - "src/feature/**"
    - "docs/feature/*.md"
  readOnlyFiles:
    - "src/core/**"
  requiredChecks:
    - "npm test"
  forbiddenCommands:
    - "git push --force"
```
