# Starter kit

A runnable Astro + Tailwind v4 project with the brand already wired: tokens, dark mode, glass, reveal, circuit texture, chart palette and a golden-path page. Copy it, run two commands, and you are developing instead of assembling.

## Preferred: one command

```bash
# Git Bash, macOS, Linux
bash ../install.sh ./mi-proyecto

# Windows PowerShell (no bash, no WSL)
powershell -NoProfile -ExecutionPolicy Bypass -File ..\install.ps1 -Target .\mi-proyecto
```

Installs the skill where the agent finds it, scaffolds, runs `npm install`, `astro check`, `build` and `brand-lint`. Use the steps below only when you want the scaffold alone.

## Three commands

```bash
bash scaffold.sh ./mi-proyecto
cd ./mi-proyecto
npm install && npm run verify
```

No bash (Windows PowerShell):

```powershell
New-Item -ItemType Directory -Force mi-proyecto/src/{styles,layouts,scripts,pages} | Out-Null
Copy-Item global.css  mi-proyecto/src/styles/global.css
Copy-Item Base.astro  mi-proyecto/src/layouts/Base.astro
Copy-Item reveal.ts   mi-proyecto/src/scripts/reveal.ts
Copy-Item index.astro mi-proyecto/src/pages/index.astro
Copy-Item package.json,astro.config.mjs,tsconfig.json mi-proyecto/
cd mi-proyecto; npm install; npm run verify
```

## What lands where

| Kit file | Destination | Why it exists |
| --- | --- | --- |
| `global.css` | `src/styles/global.css` | The assembled token block: `@theme`, dark overrides, glass, reveal, chart palette, `focus-ring`, `flow-line` |
| `Base.astro` | `src/layouts/Base.astro` | Document shell, theme boot before first paint, `ClientRouter`, circuit backdrop |
| `reveal.ts` | `src/scripts/reveal.ts` | `[data-reveal]` observer, rebinds on `astro:page-load` |
| `index.astro` | `src/pages/index.astro` | Golden-path page: hero, badge, cards, CTAs — passes the linter |
| `package.json` | root | Astro 7, Tailwind 4, Rubik, lucide, `verify` script |
| `astro.config.mjs` | root | `@tailwindcss/vite` plugin, prefetch, compressed HTML |
| `tsconfig.json` | root | `strict` plus the `@components/*`, `@layouts/*`, `@assets/*`, `@styles/*` aliases |

## Acceptance gate

Both must pass before the first feature:

```bash
npm run verify                                                  # astro check + build
node ../../brand-ui-system/assets/brand-lint.mjs src --quiet     # 0 errors expected
```

The starter ships with **0 lint errors and 3 expected warnings**: `rounded-full` on the eyebrow badge, `shadow-lg` on the primary CTA, and `text-white` on `bg-primary`. Those three are correct by design — the warnings exist so you confirm the context, not to silence them.

## First feature

1. Read the Decision Gates row for your target in `SKILL.md`.
2. Paste the component anatomy from the matching reference; never invent a radius, a colour or a duration.
3. Keep `data-reveal` on each top-level block.
4. Re-run `brand-lint` before returning.

## Known drift

`global.css` is the *assembled* result of `references/tailwind-and-tokens.md` §2 plus `references/diagrams-and-charts.md` §0. If either changes, re-assemble by hand. The token names are the contract; the file is a build artifact.
