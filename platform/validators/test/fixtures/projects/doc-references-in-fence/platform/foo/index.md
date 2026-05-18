# Fenced Code Block Skip Fixture

This file contains a broken reference, but it lives inside a fenced code block
so the validator must NOT flag it.

```bash
# Illustrative — this path does not exist on disk.
cat platform/foo/illustrative-does-not-exist.md
```

Outside the fence, a real reference: [real](platform/foo/real.md).
