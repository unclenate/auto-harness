<!--
Copyright 2026 Nate DiNiro <UncleNate@gmail.com>
SPDX-License-Identifier: MIT OR Apache-2.0
Part of auto-harness — see LICENSE-MIT and LICENSE-APACHE at repository root.
-->

# GitHub Copilot Instructions

This project uses Next.js 15 with the App Router. Please:

- Use Server Components by default; add "use client" only when necessary
- Follow the existing component structure in `src/components/`
- All API routes go in `src/app/api/<name>/route.ts`
- Use Tailwind utility classes, not custom CSS
