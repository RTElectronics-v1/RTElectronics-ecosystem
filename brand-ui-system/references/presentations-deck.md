# Presentations: 16:9 decks

A deck is the brand at 1280×720 logical pixels, always dark, always one idea per slide.
Two supported paths: **Marp** (Markdown, fastest) and **Reveal.js / plain HTML** (full control). Both reuse the same tokens as the site.

## Non-negotiables

1. **Always dark.** No light slides: on a projector the accent and the glass collapse. Use the canonical dark values only.
2. **Scale for the back row.** Body text ≥ 28px, never below 24px. Titles 64–96px. Code 22–26px.
3. **One idea per slide.** ≤ 6 lines of body, ≤ 40 words. If it needs more, it is two slides.
4. **One accent per slide.** If a metric is violet, the title is not.
5. **Safe margins 80px.** Nothing closer than 80px to any edge.
6. **Contrast ≥ 7:1.** `text-ink` on `bg-canvas` is 19.9:1. Never grey-on-grey: use `text-ink-muted` only at ≥28px.
7. **No autoplay, no transitions longer than 300ms** between slides. Motion inside a slide is allowed and short.

### Scale table (at 1280×720)

| Role | px | Tailwind at 1× | Reveal class |
| --- | --- | --- | --- |
| Cover title | 88–96 | `text-7xl` | `title` |
| Slide title | 60–72 | `text-5xl`/`text-6xl` | `h1` |
| Subtitle / kicker | 24–28 | `text-2xl` | `h2` |
| Body | 28–32 | `text-3xl` | `p` |
| Bullet | 26–30 | `text-2xl`/`text-3xl` | `li` |
| Metric | 96–140 | `text-8xl`/`text-9xl` | `.metric` |
| Code | 22–26 | `text-xl` | `pre code` |
| Caption / source | 18–20 | `text-lg` | `small` |

## Shared deck stylesheet

Works for plain HTML and Reveal. Sized in container-query units so it scales from a 900px preview window to a 1920px projector without touching a value.

```css
/* deck.css — import after the project's global.css tokens */
.slide {
  container-type: inline-size;
  aspect-ratio: 16 / 9;
  width: 100%;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  /* Percentage, not cqw: an element that declares itself a container cannot
     resolve cqw against itself, only against an ancestor container. */
  padding: 6.25%; /* 80px on a 1280px slide */
  background: var(--color-bg-body);
  color: var(--color-text-main);
  font-family: var(--font-sans);
}

.slide-kicker {
  display: inline-block;
  margin-bottom: 2.5cqw;
  padding: 0.9cqw 2cqw;
  border: 1px solid rgb(157 86 255 / 0.3);
  border-radius: 999px;
  background: rgb(119 23 255 / 0.1);
  color: var(--color-accent);
  font-size: 1.4cqw;
  font-weight: 700;
  letter-spacing: 0.14em;
  text-transform: uppercase;
}

.slide-title {
  margin: 0;
  font-size: 5.6cqw; /* 72px */
  font-weight: 800;
  line-height: 1.05;
  letter-spacing: -0.01em;
}

.slide-body {
  margin-top: 2.5cqw;
  max-width: 62ch;
  color: var(--color-text-muted);
  font-size: 2.4cqw; /* 31px */
  font-weight: 300;
  line-height: 1.5;
}

.slide-footer {
  margin-top: auto;
  display: flex;
  justify-content: space-between;
  color: var(--color-text-muted);
  font-size: 1.5cqw;
  font-weight: 300;
}

.slide-code {
  margin: 0;
  padding: 3cqw;
  border: 1px solid var(--color-border);
  border-radius: 2.5cqw;
  background: rgb(0 0 0 / 0.55);
  color: var(--color-primary-light);
  font-family: ui-monospace, 'JetBrains Mono', Menlo, monospace;
  font-size: 1.8cqw; /* 23px */
  line-height: 1.6;
  overflow: auto;
}
```

`1cqw` = 1% of the slide width, so `5.6cqw` is 72px on a 1280px slide and 107px on a 1920px one. Same composition, bigger room. Everything that uses `cqw` must be a **descendant** of `.slide`, never `.slide` itself: a container cannot resolve its own container units, so its own padding uses `%`.

## Layouts

### 1. Cover

Big claim, one gradient word, one line of context. No bullet lists, no logos grid.

```html
<section class="slide">
  <div style="margin-block: auto">
    <span class="slide-kicker">RTElectronics · 2026</span>
    <h1 class="slide-title" style="font-size: 7cqw; max-width: 18ch">
      Impulsamos la <span class="text-gradient">innovación</span>, creamos el futuro.
    </h1>
    <p class="slide-body" style="max-width: 46ch">
      Hardware, firmware, software e impresión 3D para industria.
    </p>
  </div>
  <div class="slide-footer">
    <span>Ing. Reider Troconis</span>
    <span>rtelectronics.co</span>
  </div>
</section>
```

Background: the dark circuit SVG from the site at `opacity: 0.25`, never the hero photograph: a photo behind text steals contrast on a projector.

### 2. Bento (2×2 or 3×2)

The site's card grid, fewer words, bigger padding.

```html
<section class="slide">
  <h2 class="slide-title">Un solo equipo, cuatro disciplinas</h2>
  <div style="display:grid; grid-template-columns:repeat(2,1fr); gap:2.5cqw; margin-top:4cqw; flex:1">
    <article class="glassmorphism" style="border-radius:2.5cqw; padding:3cqw">
      <div style="color:var(--color-primary); font-size:3cqw; font-weight:800">01</div>
      <h3 style="font-size:2.6cqw; font-weight:700; margin:1cqw 0">Hardware &amp; firmware</h3>
      <p style="color:var(--color-text-muted); font-size:1.9cqw; font-weight:300">
        PCB multicapa, STM32 / ESP32, protocolos industriales.
      </p>
    </article>
    <!-- 3 more -->
  </div>
</section>
```

### 3. Split (text + code or diagram)

```html
<section class="slide">
  <div style="display:grid; grid-template-columns:1fr 1.15fr; gap:5cqw; align-items:center; flex:1">
    <div>
      <span class="slide-kicker">Arquitectura</span>
      <h2 class="slide-title" style="font-size:4.6cqw">Telemetría en tiempo real</h2>
      <ul class="slide-body" style="padding-left:1.5cqw">
        <li>MQTT sobre TLS, QoS 1</li>
        <li>Buffer local ante pérdida de enlace</li>
        <li>Dashboard con 3 s de latencia</li>
      </ul>
    </div>
    <pre class="slide-code"><code>{
  "device": "grc-pcp-2000",
  "rate_hz": 10,
  "transport": ["mqtt", "modbus"],
  "offline_buffer": true
}</code></pre>
  </div>
</section>
```

### 4. Metrics

Three numbers, one sentence. The numbers use `text-gradient`; the labels are muted micro-caps.

```html
<section class="slide">
  <h2 class="slide-title">Resultados medidos, no prometidos</h2>
  <div style="display:grid; grid-template-columns:repeat(3,1fr); gap:4cqw; flex:1; align-items:center">
    <div>
      <div class="text-gradient" style="font-size:9cqw; font-weight:800; line-height:1">50+</div>
      <div style="margin-top:1cqw; color:var(--color-text-muted); font-size:1.5cqw; font-weight:700; letter-spacing:.14em; text-transform:uppercase">Proyectos entregados</div>
    </div>
    <!-- 2 more -->
  </div>
</section>
```

### 5. Process / timeline

Five steps maximum. On a slide the connector is one 1px line with a violet dot per step, not arrows.

```html
<section class="slide">
  <h2 class="slide-title">Del concepto a la manufactura</h2>
  <ol style="display:grid; grid-template-columns:repeat(5,1fr); gap:1.6cqw; margin-top:5cqw; list-style:none; padding:0">
    <li style="border-top:1px solid var(--color-border); padding-top:2cqw; position:relative">
      <span style="position:absolute; top:-0.5cqw; left:0; width:1cqw; height:1cqw; border-radius:999px; background:var(--color-primary)"></span>
      <div style="font-size:1.4cqw; color:var(--color-accent); font-weight:700">01</div>
      <div style="font-size:2cqw; font-weight:700; margin-top:.6cqw">Consultoría</div>
      <div style="font-size:1.5cqw; color:var(--color-text-muted); font-weight:300">Alcance, riesgos y arquitectura.</div>
    </li>
    <!-- 4 more -->
  </ol>
</section>
```

### 6. Closing

```html
<section class="slide" style="justify-content:center; text-align:center">
  <h2 class="slide-title" style="font-size:6cqw">
    ¿Tu visión necesita <span class="text-gradient">poder tecnológico</span>?
  </h2>
  <p class="slide-body" style="margin-inline:auto">info@rtelectronics.co · rtelectronics.co</p>
</section>
```

## Marp

Frontmatter and theme are enough; no build step beyond `marp-cli`.

````markdown
---
marp: true
size: 16:9
paginate: true
theme: rte
---

<!-- _class: cover -->

# Impulsamos la **innovación**, creamos el futuro.

RTElectronics · 2026

---

## Un solo equipo, cuatro disciplinas

- Hardware & firmware
- Software, webs y apps
- Automatización industrial
- Impresión 3D
````

Theme file (`theme/rte.css`), registered with `--theme-set theme/`:

```css
/* @theme rte */
@import 'tailwindcss/theme.css';

section {
  padding: 80px;
  background: #0a0a0a;
  color: #ffffff;
  font-family: 'Rubik Variable', Rubik, sans-serif;
  font-weight: 300;
}

h1,
h2 {
  font-weight: 800;
  letter-spacing: -0.01em;
  color: #ffffff;
}

h1 {
  font-size: 88px;
  line-height: 1.05;
}

h2 {
  font-size: 60px;
}

p,
li {
  font-size: 30px;
  line-height: 1.5;
  color: #9ea0af;
}

strong {
  color: #ffffff;
  font-weight: 700;
}

code {
  background: rgb(0 0 0 / 0.55);
  border: 1px solid rgb(255 255 255 / 0.08);
  border-radius: 12px;
  color: #9d56ff;
  font-size: 24px;
}

section.cover h1,
section.cover strong {
  background: linear-gradient(135deg, #7717ff, #00f2ff);
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
}

section::after {
  content: attr(data-marpit-pagination) ' / ' attr(data-marpit-pagination-total);
  color: #9ea0af;
  font-size: 18px;
}
```

```bash
npx @marp-team/marp-cli deck.md --theme-set theme/ --pdf --allow-local-files
```

## Reveal.js

```html
<!doctype html>
<html>
  <head>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="/deck.css" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/reveal.js@5/dist/reveal.css" />
    <style>
      :root {
        --r-background-color: #0a0a0a;
        --r-main-color: #ffffff;
        --r-heading-color: #ffffff;
        --r-main-font: 'Rubik Variable', Rubik, sans-serif;
        --r-heading-font: 'Rubik Variable', Rubik, sans-serif;
        --r-main-font-size: 32px;
        --r-heading-font-weight: 800;
        --r-link-color: #9d56ff;
      }
      .reveal .slides section {
        text-align: left;
        padding: 80px;
      }
    </style>
  </head>
  <body>
    <div class="reveal">
      <div class="slides">
        <section data-background-color="#0a0a0a">
          <span class="slide-kicker">RTElectronics · 2026</span>
          <h1 class="slide-title">Impulsamos la <span class="text-gradient">innovación</span></h1>
        </section>
      </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/reveal.js@5/dist/reveal.js"></script>
    <script>
      Reveal.initialize({
        width: 1280,
        height: 720,
        margin: 0,
        controls: true,
        progress: true,
        hash: true,
        transition: 'fade',
        transitionSpeed: 'fast',
      })
    </script>
  </body>
</html>
```

## Diagrams and charts on a slide

An architecture diagram is the strongest slide you can build with this system, and the easiest to ruin. Read `diagrams-and-charts.md` before the first node.

- **One diagram per deck section.** Two architecture maps back to back means the deck has no argument.
- **3 to 6 nodes.** Above six, split into a sequence of slides where each one adds a node.
- **Nodes at 18cqw** inside the `aspect-[2/1]` canvas. At a 1280px slide that is 230px wide, which still reads from the back row.
- **Edge labels at `text-[10px]` mono uppercase.** Anything smaller disappears on a projector; anything bigger competes with the node titles.
- **Exactly one `.flow-line`.** On a beamer, two animated paths look like a loading screen.
- **Mermaid on a slide** works, but render at `fontSize: '18px'` and never rely on its default node padding: a 12-node flowchart does not survive 1280x720. Above 8 nodes, use the Astro canvas instead, where you control the geometry.
- **Charts: one number per slide.** A three-series bar chart on a projector is a table with extra steps; if you need the table, build the table.
- **PDF export keeps the SVG**, so the deck stays crisp; a PNG screenshot of a chart does not.

## Export and delivery

- PDF from Marp: `--pdf`. PDF from Reveal: print with `?print-pdf`, then "Save as PDF" with background graphics enabled.
- Hand out the PDF, keep the source in the repo under `decks/<year>-<topic>/`.
- Never ship a deck without opening it at projector brightness once. The glow and the gradient look twice as strong on a real beamer.
- Every slide with a chart or photo needs `alt` text or a spoken description.
