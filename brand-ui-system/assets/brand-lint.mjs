#!/usr/bin/env node
// brand-lint — checks generated UI against the exclusion table in SKILL.md.
// Zero dependencies. Deterministic subset only: no taste, no layout, no contrast.
//
// Usage:
//   node assets/brand-lint.mjs [path ...] [--json] [--quiet]
//   node assets/brand-lint.mjs src --quiet
//
// Exit codes: 0 clean (warnings allowed), 1 at least one error, 2 bad usage.

import { readdirSync, readFileSync, statSync } from 'node:fs'
import { join, relative, resolve } from 'node:path'

const SKIP_DIRS = new Set([
  'node_modules',
  '.git',
  'dist',
  '.astro',
  '.netlify',
  '.codegraph',
  '.atl',
  '.vscode',
])
const EXTENSIONS = new Set(['.astro', '.tsx', '.jsx', '.html'])

// red is deliberately absent: it is the one semantic exception (error / alert).
const FAMILIES =
  'slate|gray|zinc|neutral|stone|orange|amber|yellow|lime|green|emerald|teal|cyan|sky|blue|indigo|violet|purple|fuchsia|pink|rose'
const PREFIXES =
  'bg|text|border|from|via|to|ring|ring-offset|fill|stroke|shadow|outline|decoration|divide|accent|caret'

const RULES = [
  {
    id: 'R1',
    severity: 'error',
    name: 'foreign-color-family',
    // bg-blue-500, text-gray-500, from-purple-600, border-slate-900
    re: new RegExp(`(?<![\\w-])(?:${PREFIXES})-(?:${FAMILIES})-(?:50|[1-9]00)\\b`, 'g'),
    message: 'Tailwind colour family outside the tokens',
    hint: 'use bg-surface / text-ink / text-ink-muted / border-line / text-accent',
  },
  {
    id: 'R2',
    severity: 'error',
    name: 'heavy-border',
    re: /(?<![\w-])(?:border|divide)(?:-[btlrxy])?-(?:2|4|8)\b/g,
    message: 'border thicker than 1px',
    hint: 'always 1px border-line; emphasise with hover colour, not thickness',
  },
  {
    id: 'R3',
    severity: 'error',
    name: 'off-scale-duration',
    re: /(?<![\w-])duration-(?:75|150|200|1000)\b/g,
    message: 'duration outside the motion scale',
    hint: 'duration-300 for colour, duration-500 for transform, duration-700 only for image zoom',
  },
  {
    id: 'R4',
    severity: 'error',
    name: 'transition-all',
    re: /(?<![\w-])transition-all\b/g,
    message: 'transition-all instead of explicit properties',
    hint: 'transition-colors or transition-transform',
  },
  {
    id: 'R5',
    severity: 'error',
    name: 'raw-hex-arbitrary',
    re: /\[#[0-9a-fA-F]{3,8}\]/g,
    message: 'raw hex inside an arbitrary value',
    hint: 'declare the role in @theme and use the utility',
  },
  {
    id: 'R6',
    severity: 'error',
    name: 'bounce',
    re: /(?<![\w-])animate-bounce\b/g,
    message: 'animate-bounce',
    hint: 'the motion system has no bounce; use duration-300/500 with the brand curve',
  },
  {
    id: 'W1',
    severity: 'warn',
    name: 'shadow-review',
    // shadow-md and above; confirm it is the primary CTA or the scrolled navbar.
    re: /(?<![\w-])shadow-(?:md|lg|xl|2xl)\b(?!-)/g,
    message: 'shadow above sm: only the primary CTA and the scrolled navbar may carry one',
    hint: 'cards get border-line + glass instead',
  },
  {
    id: 'W2',
    severity: 'warn',
    name: 'radius-full-review',
    re: /(?<![\w-])rounded-full\b/g,
    message: 'rounded-full: legal only for badges, chips, dots and the FAB',
    hint: 'cards use rounded-4xl (32), panels rounded-3xl (24), controls rounded-2xl (16)',
  },
  {
    id: 'W3',
    severity: 'warn',
    name: 'white-text-review',
    re: /(?<![\w-])text-white\b/g,
    message: 'text-white: confirm it sits on bg-primary',
    hint: 'on any surface use text-ink; on an accent use text-accent',
  },
  {
    id: 'W4',
    severity: 'warn',
    name: 'decorative-ping',
    re: /(?<![\w-])animate-ping\b/g,
    message: 'animate-ping: legal only on the WhatsApp FAB',
    hint: 'drop it everywhere else',
  },
]

const INLINE_STYLE_ALLOWED = [/animation-delay/, /transition-delay/, /radial-gradient/]

function walk(dir, out = []) {
  for (const entry of readdirSync(dir)) {
    const full = join(dir, entry)
    let stat
    try {
      stat = statSync(full)
    } catch {
      continue
    }
    if (stat.isDirectory()) {
      if (!SKIP_DIRS.has(entry)) walk(full, out)
    } else if (EXTENSIONS.has(entry.slice(entry.lastIndexOf('.')))) {
      out.push(full)
    }
  }
  return out
}

function checkInlineStyles(line) {
  const hits = []
  const re = /style="([^"]*)"/g
  let match
  while ((match = re.exec(line))) {
    const value = match[1]
    if (INLINE_STYLE_ALLOWED.some((allow) => allow.test(value))) continue
    // Astro expression styles (style={`…`}) are dynamic delays by convention; skip them.
    hits.push({
      id: 'R7',
      severity: 'error',
      name: 'inline-style',
      message: `inline style for a property that has a utility: ${value.slice(0, 48)}`,
      hint: 'utility or token; style is only for stagger delay and the decorative radial grid',
    })
  }
  return hits
}

function checkMissingProps(file, source) {
  if (!file.endsWith('.astro')) return []
  if (!source.includes('Astro.props')) return []
  if (source.includes('interface Props') || source.includes('type Props')) return []
  return [
    {
      id: 'W5',
      severity: 'warn',
      name: 'untyped-props',
      line: 1,
      message: 'reads Astro.props without an interface Props',
      hint: 'declare interface Props and destructure with defaults',
    },
  ]
}

function lintFile(file) {
  const source = readFileSync(file, 'utf8')
  const lines = source.split('\n')
  const findings = []

  lines.forEach((line, index) => {
    for (const rule of RULES) {
      rule.re.lastIndex = 0
      let match
      while ((match = rule.re.exec(line))) {
        findings.push({
          id: rule.id,
          severity: rule.severity,
          name: rule.name,
          line: index + 1,
          column: match.index + 1,
          token: match[0],
          message: rule.message,
          hint: rule.hint,
        })
      }
    }
    for (const hit of checkInlineStyles(line)) findings.push({ ...hit, line: index + 1, column: 1 })
  })

  findings.push(...checkMissingProps(file, source))
  return findings
}

// ── main ────────────────────────────────────────────────────────────────────
const args = process.argv.slice(2)
const json = args.includes('--json')
const quiet = args.includes('--quiet')
const errorsOnly = args.includes('--errors-only')
const targets = args.filter((arg) => !arg.startsWith('--'))
if (!targets.length) targets.push('.')

const files = []
for (const target of targets) {
  const abs = resolve(target)
  try {
    if (statSync(abs).isDirectory()) files.push(...walk(abs))
    else files.push(abs)
  } catch {
    console.error(`brand-lint: cannot read ${target}`)
    process.exit(2)
  }
}

// One row per rule per line, with every offending token merged into it.
function group(findings) {
  const map = new Map()
  for (const finding of findings) {
    const key = `${finding.id}@${finding.line ?? 1}`
    const current = map.get(key)
    if (current) {
      if (finding.token && !current.tokens.includes(finding.token)) current.tokens.push(finding.token)
    } else {
      map.set(key, { ...finding, tokens: finding.token ? [finding.token] : [] })
    }
  }
  return [...map.values()].sort((a, b) => (a.line ?? 1) - (b.line ?? 1))
}

const report = files
  .map((file) => ({
    file,
    findings: group(
      lintFile(file).filter((f) => !errorsOnly || f.severity === 'error'),
    ),
  }))
  .filter((r) => r.findings.length)
const errors = report.flatMap((r) => r.findings).filter((f) => f.severity === 'error').length
const warnings = report.flatMap((r) => r.findings).filter((f) => f.severity === 'warn').length

if (json) {
  console.log(JSON.stringify({ files: files.length, errors, warnings, report }, null, 2))
  process.exit(errors ? 1 : 0)
}

const root = resolve(targets[0])
console.log(`brand-lint  ${files.length} file(s) scanned`)
if (!report.length) {
  console.log('clean')
} else {
  console.log(`✖ ${errors} error(s)   ⚠ ${warnings} warning(s)\n`)
  for (const { file, findings } of report) {
    console.log(relative(root, file) || file)
    for (const f of findings) {
      const where = `${f.line ?? 1}:${f.column ?? 1}`.padStart(8)
      const mark = f.severity === 'error' ? '✖' : '⚠'
      const tokens = f.tokens?.length ? ` \`${f.tokens.join('`, `')}\`` : ''
      console.log(`  ${where}  ${mark} ${f.id} ${f.message}${tokens}`)
      if (!quiet) console.log(`  ${' '.repeat(8)}     ${f.hint}`)
    }
    console.log()
  }
}

process.exit(errors ? 1 : 0)
