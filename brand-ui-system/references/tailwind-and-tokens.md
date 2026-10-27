# Tokens, theme and global CSS
Canonical source: `src/styles/global.css` of `rt-electronics-website` (Tailwind v4, `@tailwindcss/vite`).
Two things are **not** source of truth there and must never be copied: `tailwind.config.js` (empty) and `tailwind.config.mjs` (Tailwind v3 syntax importing `@tailwindcss/typography`, which is not even installed). Tailwind v4 does not read them because the CSS has no `@config` directive.

## 1. Install

```bash
npm i tailwindcss @tailwindcss/vite @fontsource-variable/rubik
```

`astro.config.mjs`:

```js
import tailwindcss from '@tailwindcss/vite'

export default defineConfig({
  vite: { plugins: [tailwindcss()] },
})
```

Import the font once, in the layout frontmatter: `import '@fontsource-variable/rubik'`.
Rubik Variable ships `wght 300..900` plus italic. No `<link>` to Google Fonts, ever.

## 2. Canonical `global.css`

Copy this block whole. It is the clean Tailwind v4 pattern: light values live in `@theme`, dark values override the same custom properties on `.dark` / `[data-theme='dark']`.

**The runnable, assembled copy is `assets/bootstrap/global.css`.** It is what the starter actually ships. If this block and that file disagree, the bootstrap file wins — and the disagreement is a bug to fix here, not to reproduce.

```css
@import 'tailwindcss';

/* One dark variant, driven by the class the theme toggle writes.
   Without this line `dark:` follows the OS, not the user's choice. */
@custom-variant dark (&:where(.dark, .dark *));

@theme {
  /* ── Canvas & surfaces ─────────────────────────────── */
  --color-bg-body: #e6e6e6;
  --color-bg-card: #ffffff;
  --color-bg-card-hover: #f3f4f6;

  /* ── Ink ───────────────────────────────────────────── */
  --color-text-main: #1a1a1a;
  --color-text-muted: #5b6270;
  --color-text-inverted: #ffffff;

  /* ── Lines ─────────────────────────────────────────── */
  --color-border: rgb(0 0 0 / 0.08);
  --color-border-hover: rgb(119 23 255 / 0.3);

  /* ── Brand fills (backgrounds, gradients, icons) ───── */
  --color-primary: #6200ea;
  --color-primary-light: #7c4dff;
  --color-primary-dark: #3700b3;
  --color-primary-hover: #7c4dff;
  --color-secondary: #ede7f6;

  /* ── Accent ink: the only violet legal as small text ── */
  --color-accent: #6200ea;

  /* ── Glass ─────────────────────────────────────────── */
  --glass-bg: rgb(255 255 255 / 0.7);
  --glass-border: rgb(0 0 0 / 0.05);
  --glass-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.05);

  /* ── Circuit texture ───────────────────────────────── */
  --circuit-stroke: #6200ea;
  --circuit-opacity: 0.15;

  /* ── Gradient tail for .text-gradient ──────────────── */
  --gradient-tail: #00b0ff;

  /* ── Type ──────────────────────────────────────────── */
  --font-sans: 'Rubik Variable', Rubik, sans-serif;
  --font-mono: ui-monospace, 'JetBrains Mono', 'SFMono-Regular', Menlo, monospace;

  /* ── Motion ────────────────────────────────────────── */
  --ease-brand: cubic-bezier(0.165, 0.84, 0.44, 1);
  --animate-float: float 5s ease-in-out infinite;
  --animate-pulse-slow: pulse 4s cubic-bezier(0.4, 0, 0.6, 1) infinite;

  /* ── Short aliases: prefer these in new code ───────── */
  --color-canvas: var(--color-bg-body);
  --color-surface: var(--color-bg-card);
  --color-surface-hover: var(--color-bg-card-hover);
  --color-ink: var(--color-text-main);
  --color-ink-muted: var(--color-text-muted);
  --color-line: var(--color-border);
  --color-line-hover: var(--color-border-hover);
}

/* Dark is the canonical reading mode. */
:root.dark,
:root[data-theme='dark'] {
  --color-bg-body: #0a0a0a;
  --color-bg-card: #141414;
  --color-bg-card-hover: #1f1f1f;

  --color-text-main: #ffffff;
  --color-text-muted: #9ea0af;
  --color-text-inverted: #1a1a1a;

  --color-border: rgb(255 255 255 / 0.08);
  --color-border-hover: rgb(157 86 255 / 0.4);

  --color-primary: #7717ff;
  --color-primary-light: #9d56ff;
  --color-primary-dark: #502faa;
  --color-primary-hover: #502faa; /* hover darkens: white ink stays at 10.9:1 */
  --color-secondary: #392178;

  --color-accent: #9d56ff;

  --glass-bg: rgb(20 20 20 / 0.6);
  --glass-border: rgb(255 255 255 / 0.08);
  --glass-shadow: none;

  --circuit-stroke: #9d56ff;
  --circuit-opacity: 0.25;

  --gradient-tail: #00f2ff;
}

/* Keyframes stay at top level so they always exist. */
@keyframes float {
  0%,
  100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-10px);
  }
}

@keyframes flow-pulse {
  0% {
    stroke-dashoffset: 1000;
    opacity: 0;
  }
  10%,
  90% {
    opacity: 1;
  }
  100% {
    stroke-dashoffset: 0;
    opacity: 0;
  }
}

@keyframes data-flow {
  from {
    stroke-dashoffset: 24;
  }
  to {
    stroke-dashoffset: 0;
  }
}

@layer utilities {
  .glassmorphism {
    background: var(--glass-bg);
    border: 1px solid var(--glass-border);
    box-shadow: var(--glass-shadow);
    backdrop-filter: blur(12px);
    -webkit-backdrop-filter: blur(12px);
  }

  .text-gradient {
    background-image: linear-gradient(135deg, var(--color-primary), var(--gradient-tail));
    background-clip: text;
    -webkit-background-clip: text;
    color: transparent;
    -webkit-text-fill-color: transparent;
  }

  /* Add to every interactive element. Never ship outline-none alone. */
  .focus-ring {
    @apply outline-none focus-visible:ring-2 focus-visible:ring-accent;
  }

  .scrollbar-hide {
    -ms-overflow-style: none;
    scrollbar-width: none;
  }

  .scrollbar-hide::-webkit-scrollbar {
    display: none;
  }

  .mask-linear-fade {
    mask-image: linear-gradient(to right, transparent 0%, black 10%, black 90%, transparent 100%);
  }

  .content-auto {
    content-visibility: auto;
    contain-intrinsic-size: 1px 500px;
  }

  /* One animated path per diagram, never more. */
  .flow-line {
    stroke-dasharray: 2 4;
    animation: data-flow 1.2s linear infinite;
  }

  .glow-accent {
    filter: drop-shadow(0 0 6px color-mix(in oklab, var(--color-accent) 45%, transparent));
  }
}

/* Circuit texture. Static traces plus the travelling pulse — without these two
   classes the backdrop is a dead drawing. */
.circuit-lines {
  stroke-width: 1.2;
}

.circuit-pulse {
  stroke-width: 2;
  stroke-dasharray: 1000;
  stroke-dashoffset: 1000;
  animation: flow-pulse 8s linear infinite;
  will-change: stroke-dashoffset, opacity;
}

@media (max-width: 1024px) {
  .circuit-lines {
    stroke-width: 0.8;
  }

  .circuit-pulse {
    stroke-width: 1.5;
  }
}

/* Scroll reveal. Desktop only, so mobile never hides content behind JS. */
@media (min-width: 768px) {
  [data-reveal] {
    opacity: 0;
    transform: translateY(30px);
    transition:
      opacity 0.8s var(--ease-brand),
      transform 0.8s var(--ease-brand);
  }

  [data-reveal].revealed {
    opacity: 1;
    transform: none;
  }
}

@media (prefers-reduced-motion: reduce) {
  [data-reveal] {
    opacity: 1 !important;
    transform: none !important;
    transition: none !important;
  }

  .animate-float,
  .animate-pulse-slow,
  .circuit-pulse,
  .flow-line {
    animation: none !important;
  }
}
```

## 3. No-flash theme boot (in `<head>`, blocking)

```html
<script is:inline>
  (() => {
    const stored = localStorage.getItem('theme')
    const dark = stored ? stored === 'dark' : matchMedia('(prefers-color-scheme: dark)').matches
    document.documentElement.classList.toggle('dark', dark)
    document.documentElement.dataset.theme = dark ? 'dark' : 'light'
  })()
</script>
```

Toggle handler: write `localStorage.theme`, then flip `classList` and `dataset.theme` together, and wrap it in `document.startViewTransition` when available. Re-run every `astro:page-load`.

**Never** duplicate the dark values under `@media (prefers-color-scheme: dark)` unless the project must work with JS disabled: duplication is exactly how the marketing site ended up with `dark:` following the OS while the tokens followed the class.

## 4. Semantic usage table

| Role | Preferred class | Legacy name in the marketing site | Notes |
| --- | --- | --- | --- |
| Page background | `bg-canvas` | `bg-dark` (`--color-bg-body`) | The name `bg-dark` is misleading: it is the body token, not a dark-only color |
| Card / panel surface | `bg-surface` | `bg-[var(--color-bg-card)]` | |
| Hover surface | `bg-surface-hover` | `bg-[var(--color-bg-card-hover)]` | |
| Primary text | `text-ink` | `text-main` | |
| Secondary text | `text-ink-muted` | `text-muted` | Light value is `#5b6270`, not `#6b7280` |
| Text on a brand fill | `text-white` | `text-white` | Legal only over `bg-primary` |
| Hairline border | `border-line` | `border-[var(--color-border)]` | Always 1px |
| Hover border | `border-line-hover` | `border-[var(--color-border-hover)]` | |
| Brand fill | `bg-primary` | `bg-primary` | Buttons, icon plates, dots |
| Brand fill hover | `bg-primary-hover` | `hover:bg-primary-light` | Light lightens, dark darkens |
| Accent ink | `text-accent` | — (new token) | The only violet legal at `text-xs`/`text-sm` |
| Soft brand tint | `bg-primary/10` | `bg-primary/10` | Icon plates, badges, glow orbs |
| Soft secondary | `bg-secondary` | `to-secondary/20` | Was unmapped in `@theme`, so every gradient stop rendered transparent |
| Glass panel | `glassmorphism` | `glassmorphism` | |
| Error / alert | `text-red-500` / `text-red-400` | `text-red-500` | The only foreign family allowed, and only as a semantic state, never as a data series |
| Gradient text | `text-gradient` | `text-gradient` | |

## 5. AA pairing table (measured, WCAG 2.1)

| Foreground | Background | Ratio | Verdict |
| --- | --- | --- | --- |
| `--color-text-muted` `#5b6270` | light body `#e6e6e6` | 4.91 | AA ✅ |
| `--color-text-muted` `#5b6270` | light card `#ffffff` | 6.13 | AA ✅ |
| `--color-text-muted` `#5b6270` | light badge `#dbd7e9` | 4.35 | ✗ use `text-accent` |
| `--color-text-muted` `#9ea0af` | dark body `#0a0a0a` | 7.64 | AAA ✅ |
| `--color-text-muted` `#9ea0af` | dark card `#141414` | 7.11 | AAA ✅ |
| `--color-accent` `#6200ea` | light body | 6.21 | AA ✅ |
| `--color-accent` `#6200ea` | light badge | 5.51 | AA ✅ |
| `--color-accent` `#9d56ff` | dark body | 4.91 | AA ✅ |
| `--color-accent` `#9d56ff` | dark badge | 4.52 | AA ✅ |
| `--color-primary` `#7717ff` | dark body | 3.16 | ✗ as text; ✅ as icon/line (3:1) |
| `--color-primary-light` `#7c4dff` | light body | 3.86 | ✗ as text; ✅ as fill |
| White | `--color-primary` (both modes) | 7.76 / 6.27 | AA ✅ |
| White | light hover `#7c4dff` | 4.81 | AA ✅ |
| White | dark hover `#9d56ff` | 4.03 | ✗ → dark hover uses `#502faa` (10.9) |

Rules that follow from the table:

- Small accent text (`text-[10px]` to `text-lg`, weight ≤ 500) uses `text-accent`, never `text-primary` or `text-primary-light`.
- `text-primary` on icons, 1px lines, dots and gradients is fine: 3.16 ≥ 3.0 for non-text contrast.
- Hover on a primary button must **increase** contrast with white: light goes to `primary-light`, dark goes to `primary-dark`.
- Muted text on a tinted badge fails: badges use `text-accent` on `bg-primary/10`.

## 6. Typography

Rubik Variable. Weights in use: 300, 400, 500, 700, 800. Never 600.

| Role | Classes |
| --- | --- |
| Hero display | `text-4xl font-extrabold leading-[1.1] md:text-7xl` |
| Page title | `text-4xl font-extrabold md:text-5xl` |
| Section title | `text-4xl font-extrabold md:text-5xl` |
| Sub-section | `text-3xl font-bold` |
| Card title | `text-xl font-bold md:text-2xl` |
| Lead paragraph | `text-lg font-light leading-relaxed text-ink-muted md:text-xl` |
| Body | `text-base font-light leading-relaxed text-ink-muted` |
| Small | `text-sm font-light leading-relaxed text-ink-muted` |
| Micro label | `text-xs font-bold tracking-widest uppercase text-ink-muted` |
| Eyebrow badge | `text-[10px] font-bold tracking-widest uppercase text-accent` |
| Metric | `text-3xl font-extrabold text-gradient md:text-5xl` |

`font-light` is for prose only, never for UI labels or buttons.

## 7. Geometry

| Radius | Utility | Use |
| --- | --- | --- |
| 12px | `rounded-xl` | icon plates, small controls, social buttons |
| 16px | `rounded-2xl` | inputs, selects, buttons, dropdown panels |
| 24px | `rounded-3xl` | stat cards, compact panels |
| 32px | `rounded-4xl` | canonical card |
| 40px | `rounded-[40px]` | section shell, hero panel, form panel |
| 9999 | `rounded-full` | badges, filter chips, dots, FAB only |

Spacing: section `py-24`, container `px-6`, header block `mb-16`/`mb-20`, grids `gap-6`/`gap-8`/`gap-16`, card padding `p-6 md:p-10` or `p-8`.

Layout: the marketing site uses `container mx-auto px-6` with `--breakpoint-3xl: 1920px`, which makes `.container` run edge to edge up to 1920px. For a new site prefer `mx-auto w-full max-w-7xl px-6`.

## 8. Motion

| Intent | Value |
| --- | --- |
| Colour / opacity / border | `duration-300` |
| Transform / size / height | `duration-500` |
| Image zoom on card hover | `duration-700` |
| Brand easing | `cubic-bezier(0.165, 0.84, 0.44, 1)` (`--ease-brand`) |
| Scroll reveal | 0.8s `--ease-brand`, `translateY(30px)`, threshold 0.15, once |
| Loader bar | 2.5s `cubic-bezier(0.65, 0, 0.35, 1)` |
| Counters | 2000ms, easeOutExpo |
| `float` | 5s ease-in-out, −10px |
| `pulse-slow` | 4s |
| Circuit pulse | 8s linear, dash 1000, delays 2s–7s |
| Stagger | `transition-delay: index * 0.1s` |
| Dropdown hover intent | 120ms close delay |
| Mobile menu / dropdown open | `duration-500` / `duration-300` |

Never animate `box-shadow` or `filter` on scroll. Transitions list the properties explicitly, never `all`, except in legacy markup.

## 9. Forbidden patterns

| Forbidden | Why | Use |
| --- | --- | --- |
| `tailwind.config.js` / `tailwind.config.mjs` | Dead in v4, and the legacy one imports an uninstalled plugin | `@theme` in CSS |
| `:global(.dark) .x` in a plain `.css` file | `:global()` is Astro/Svelte syntax; browsers drop the whole rule | `:root.dark .x` or `:root[data-theme='dark'] .x` |
| `dark:` without `@custom-variant` | Follows the OS, not the toggle | Ship the `@custom-variant` line |
| `--color-x: var(--color-x)` in `@theme` | Self-reference; only survives because an unlayered `:root` overrides it | Literal value in `@theme`, override in `.dark` |
| `rounded-full` on cards or panels | Breaks the box language | `rounded-4xl` / `rounded-[40px]` |
| `shadow-md/lg/xl` on a card | Depth is a hairline plus glass | `border border-line` + `glassmorphism` |
| `animate-fade-in` and other unregistered animation names | Tailwind emits nothing; the class is inert | Declare `--animate-*` in `@theme` |
| `bg-dark-card` | In the marketing site it maps to the *hover* surface | `bg-surface-hover` |
| `text-white` for an "active" state | Invisible in light mode | `text-ink` or `text-accent` |
| `outline-none` with no ring | Removes the only keyboard affordance | `.focus-ring` |
| Raw `#hex` in component markup | Untraceable drift | Tokens only |

## 10. Legacy migration map

| Marketing site today | Preferred |
| --- | --- |
| `bg-dark` | `bg-canvas` |
| `bg-[var(--color-bg-card)]` | `bg-surface` |
| `text-main` | `text-ink` |
| `border-[var(--color-border)]` | `border-line` |
| `text-primary-light` on a small label | `text-accent` |
| `hover:bg-primary-light` in dark | `hover:bg-primary-hover` |
| `--color-text-muted: #6b7280` | `#5b6270` |
| `--color-secondary` unmapped | now mapped in `@theme` |
