# RTElectronics ecosystem

Brand system for everything RTElectronics ships: the visual language as a machine-readable contract, a runnable starter, and a linter that enforces it.

```text
brand-ui-system/     the skill: SKILL.md, references/, assets/
```

Repository: `github.com/RTElectronics-v1/RTElectronics-ecosystem`
Skill version: **1.6**

---

## Install

One canonical copy, junctioned into every agent. Update once, all agents see it.

### Windows (PowerShell)

```powershell
git clone https://github.com/RTElectronics-v1/RTElectronics-ecosystem.git "$env:TEMP\rte-ecosystem"
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:TEMP\rte-ecosystem\brand-ui-system\assets\install.ps1" -Target .\mi-proyecto -Agents all
```

### Git Bash, macOS, Linux

```bash
git clone https://github.com/RTElectronics-v1/RTElectronics-ecosystem.git /tmp/rte-ecosystem
bash /tmp/rte-ecosystem/brand-ui-system/assets/install.sh ./mi-proyecto --agents all
```

Both commands: install the skill for every agent, scaffold a project, run `npm install`, `astro check`, `build` and `brand-lint`.

### Options

| PowerShell | Bash | Effect |
| --- | --- | --- |
| `-Agents all` | `--agents all` | Link into `agents`, `pi`, `claude`, `codex`, `gemini`, `copilot` |
| `-Agents pi,claude` | `--agents pi,claude` | Link only those |
| `-Scope user` (default) | `--scope user` (default) | Canonical copy at `~/.agents/skills/brand-ui-system` |
| `-Scope project` | `--scope project` | Also copy into `<target>/.agents/skills/` for reproducibility |
| `-NoScaffold` | `--no-scaffold` | Only install and link; do not create a project |
| `-From <url>` | `--from <url>` | Clone the skill from any git URL |
| `-Force` | `--force` | Replace a real directory sitting at a link path |

Windows gets a **directory junction**, Unix a **symlink**. If neither is available the installer copies and says so.

---

## Use it

The skill activates on its own when a task matches its `description`. If your agent does not auto-discover skills, hand it the path.

```text
Leé C:\Users\reide\.agents\skills\brand-ui-system\SKILL.md y seguí su contrato.
Armame la página de precios con tres planes.
```

### Four examples

**A landing page.** Prompt: *"Armame la página de precios con tres planes y una comparativa de features."*
The agent routes to `astro-components.md`, copies the card and section-header anatomy, builds with `rounded-4xl`, one accent, one shadow, `data-reveal`, then runs the linter. You get components, not a template.

**A dashboard.** Prompt: *"Dashboard de telemetría: tres KPIs, una sparkline por sensor y una tabla."*
Routes to `astro-components.md` + `diagrams-and-charts.md`. Uses `chart-1` for the datum you are arguing about and the neutral ladder for context. Charts are CSS and SVG, no chart library.

**An architecture diagram.** Prompt: *"Diagrama del flujo Edge → Gateway → Ingesta → Base de datos."*
Routes to `diagrams-and-charts.md`. Builds `DiagramNode` + `DiagramCanvas` on a fixed 2:1 canvas (`1cqw = 10` viewBox units) with one animated `.flow-line`. No measured JS connectors.

**A deck.** Prompt: *"Un deck de 8 slides para presentar el caso GRC-PCP 2000."*
Routes to `presentations-deck.md`. 16:9, dark, projection type scale (28px body minimum), cover + bento + technical + metrics layouts, Marp or Reveal output.

### What the agent is required to do

1. Read only the reference rows the routing table names — two per task, not four.
2. Build dark first, then verify light.
3. Run `brand-lint` and fix every error before returning.
4. Report the files changed, the lint result, and one line per WCAG pair checked.

---

## What is inside the skill

| Path | Purpose |
| --- | --- |
| `SKILL.md` | Contract: activation, 6 hard rules, 13-row exclusion table, routing gates |
| `references/tailwind-and-tokens.md` | Canonical `@theme`, palette, AA pairs, type, motion, circuit texture |
| `references/astro-components.md` | Typed components + per-component forbidden/required anatomy |
| `references/diagrams-and-charts.md` | Chart tokens, `DiagramNode`/`Canvas`, Mermaid theme, SVG charts |
| `references/presentations-deck.md` | 16:9 rules and slide templates |
| `assets/bootstrap/` | Runnable starter: tokens, layout, golden-path page, configs |
| `assets/brand-lint.mjs` | Deterministic checker for the exclusion table, 0 dependencies |
| `assets/install.sh` · `install.ps1` | Install for one or many agents, scaffold, run the gate |

---

## Gate

```bash
node brand-ui-system/assets/brand-lint.mjs <dir> --quiet        # 0 = no errors
node brand-ui-system/assets/brand-lint.mjs <dir> --errors-only
node brand-ui-system/assets/brand-lint.mjs <dir> --json
```

Errors block: foreign colour families, borders above 1px, off-scale durations, `transition-all`, raw hex in arbitrary values, `animate-bounce`, unjustified inline `style`.
Warnings need a human eye: `shadow-*`, `rounded-full`, `text-white`, `animate-ping`, props without an interface.

The starter ships clean: **0 errors, 3 expected warnings** (badge radius, CTA shadow, white text on `bg-primary`).

---

## Maintain

```bash
git clone git@github.com:RTElectronics-v1/RTElectronics-ecosystem.git
cd RTElectronics-ecosystem
# edit brand-ui-system/…
git commit -am "fix: …"
git push
```

After changing the skill, refresh the installed copies:

```bash
bash brand-ui-system/assets/install.sh --no-scaffold --agents all
```

### Versioning

`metadata.version` in `SKILL.md` is the contract version. Bump it when the rules or the routing change, tag the repo (`v1.6`), and note the change in the commit body. The junctions already point at the canonical copy, so no relinking is needed after an update.

### Known drift

`brand-ui-system/assets/bootstrap/global.css` is the assembled artifact of `references/tailwind-and-tokens.md` §2 plus `references/diagrams-and-charts.md` §0. The bootstrap file is the runnable truth: if they disagree, the bootstrap wins and the reference is the bug.

---

## Licence

Apache-2.0, declared in the `SKILL.md` frontmatter.
