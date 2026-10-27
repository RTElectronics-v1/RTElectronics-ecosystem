---
name: brand-ui-system
description: "Trigger: RTElectronics UI, brand UI, design system, landing, dashboard, diagram, chart, slide deck. Builds Astro pages, components, SVG diagrams and 16:9 decks in the RTElectronics visual language."
license: Apache-2.0
metadata:
  author: "gentleman-programming"
  version: "1.6"
---

## Activation Contract

Load when the task must look native to RTElectronics: pages, dashboards, components, diagrams, charts or decks. Not for content-only edits.

Visual manifest — engineering light on graphite: near-black canvas, one violet accent, glass as material, generous radii, Rubik 300 against 800, slow motion. Circuit traces are texture, never decoration.

## Hard Rules

1. Dark-first. Light is a supported variant, never the design source. Never invent a color, radius, duration or easing: values come from `references/tailwind-and-tokens.md`.
2. Tailwind v4 only. `@theme` is the single source of truth. No `tailwind.config.*`: the v3 config imports an uninstalled plugin.
3. Accent ink is `text-accent`. `text-primary` is fill, gradient and icon only: at small size it fails AA on dark (3.16:1).
4. Every interactive element ships `hover`, `focus-visible` (a ring, never bare `outline-none`), `active` and `disabled`.
5. A request that conflicts with the table is refused with the brand alternative proposed, never silently executed.
6. Load only the references the table names: two per task.

## 🚫 Anti-Patterns and Exclusion Rules (STRICT DO NOTs)

Hard prohibitions, not preferences. Check every row before returning.

| Category | ❌ NEVER DO THIS (anti-pattern) | ✅ DO THIS INSTEAD (brand standard) |
| --- | --- | --- |
| **Color** | `bg-blue-500`, `text-gray-500`, `bg-slate-900`, raw hex, `bg-white/5` surfaces in light. | Tokens only: `text-ink-muted`, `border-line`, `text-accent`; a missing role goes into `@theme`. |
| **Color** | `bg-black/40` in light, arbitrary opacity, 3+ stop gradients, purple-to-pink. | `.glassmorphism`; tints `/5`–`/40`; only `.text-gradient` and primary glow orbs; one accent per view. |
| **Geometry** | `rounded-full` on cards, button radius equal to card radius, `rounded-sm/none` on surfaces. | One radius per level, descending 32/24/16/12; `full` only badges, chips, dots, FAB. |
| **Borders** | `border-2/4`, `divide-y-2`, family colors, stacked contradicting borders. | Always 1px `border-line`; emphasis by hover color, never thickness. |
| **Depth** | `shadow-md/lg/xl` on cards, opaque black shadow in dark, decorative `drop-shadow`, inline `box-shadow`, `ring-*` as decoration. | `border-line` + glass; shadow only primary CTA and scrolled navbar; `ring` is focus only; one signal per element. |
| **Typography** | `font-semibold`, `font-black`, italic, `tracking-tight` in prose, `leading-none/loose`, centered paragraphs. | Weights 300/400/500/700/800; `tracking-widest` only micro-caps; `leading-relaxed` prose; center only the header block. |
| **Typography** | `font-extrabold` in paragraphs or labels; `font-light` in buttons or nav. | `extrabold` only h1/h2/metrics; `light` only prose; controls and nav at 500/700. |
| **Motion** | `animate-bounce`, decorative `ping/spin`, `ease-linear`, `duration-150/200/1000`, `hover:scale-110` on buttons. | `duration-300` color, `duration-500` transform, `cubic-bezier(0.165,0.84,0.44,1)`, max `scale-105`; `700` only image zoom. |
| **Motion** | `transition-all`, infinite loops outside the tokens, no reduced-motion guard. | Explicit transition properties; only `float`/`pulse-slow`/circuit loops; honour `prefers-reduced-motion`. |
| **Astro + TS** | Inline `style` for color, padding or radius. | Utility or token; `style` only for stagger delay and the decorative radial grid. |
| **Astro + TS** | React/Svelte island or any UI library for dropdown, menu, toggle, modal. | Native `<script>` or Web Component, rebound on `astro:page-load`; `<dialog>` for modals. |
| **Astro + TS** | No `interface Props`, hardcoded copy, `any`, unguarded `querySelector(...)!`. | Typed props with defaults, copy via props or `src/data/`, early return, `class?: string` forwarded. |

## Decision Gates

Every row assumes the token block.

| Target | Read |
| --- | --- |
| New project, or any new token | `assets/bootstrap/`, then tokens |
| Any Astro component | `references/astro-components.md` |
| Any diagram, flow or chart | `references/diagrams-and-charts.md` |
| Any slide or 16:9 deck | `references/presentations-deck.md` |
| Dashboard | components, then diagrams |
| A page that also ships a deck | the page row, then presentations |
| Auditing existing UI | Hard Rules and the table only; report, do not redesign |

## Execution Steps

1. Read the routing row, then scan the table before writing any class.
2. Paste the `@theme` block, `@custom-variant dark`, utilities and keyframes.
3. Build dark first, then verify light: every `text-*`, hover and focus ring.
4. Run `assets/brand-lint.mjs` over the changed files and fix every error.
5. Return the files changed, the lint result and the pairs you verified.

## Output Contract

Return: files changed, the lint result, and one line per WCAG pair (`pair: ratio: pass|fail`).

## References

- `assets/install.sh` (or `install.ps1`) + `assets/bootstrap/` — install, scaffold, run the gate.
- `references/tailwind-and-tokens.md` — `@theme`, palette, AA pairs, type, motion.
- `references/astro-components.md` — typed components, forbidden and required anatomy.
- `references/diagrams-and-charts.md` — chart tokens, nodes, canvas, Mermaid, SVG charts.
- `references/presentations-deck.md` — 16:9 deck rules and slide templates.
