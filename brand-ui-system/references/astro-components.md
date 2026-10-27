# Astro components

Every snippet assumes the tokens from `tailwind-and-tokens.md` are installed and the canonical names are preferred: `bg-canvas`, `bg-surface`, `text-ink`, `text-ink-muted`, `border-line`, `bg-primary`, `text-accent`.
All of them are `.astro` (no React islands), typed with `interface Props`, and use `class:list` for conditional classes.

## Conventions

- `class?: string` is always forwarded and appended last, so a caller can override.
- Interactive elements carry `focus-ring` (declared in the tokens file).
- Icons come from `lucide-astro`; always pass `aria-hidden="true"` when the icon is decorative, and `aria-label` on the button when it is the only label.
- No hex in markup. No `text-white` except on `bg-primary`.
- `p-` and `gap-` use the spacing rhythm: 6 / 8 / 16 / 20.

## Section shell

```astro
---
interface Props {
  id?: string
  tone?: 'transparent' | 'surface' | 'muted'
  class?: string
}

const { id, tone = 'transparent', class: className } = Astro.props

const tones = {
  transparent: 'bg-transparent',
  surface: 'bg-surface',
  muted: 'bg-surface/40 backdrop-blur-sm',
}
---

<section id={id} class:list={['border-t border-line py-24', tones[tone], className]}>
  <div class="mx-auto w-full max-w-7xl px-6">
    <slot />
  </div>
</section>
```

## Section header (the most repeated block)

Eyebrow badge + `h2` with a gradient fragment + lead paragraph. Reproduce this trio in every section or the page stops reading as RTElectronics.

```astro
---
interface Props {
  eyebrow?: string
  title: string
  highlight?: string
  description?: string
  align?: 'center' | 'left'
  class?: string
}

const { eyebrow, title, highlight, description, align = 'center', class: className } = Astro.props
const centered = align === 'center'
---

<div
  class:list={['mb-16 md:mb-20', centered && 'text-center', className]}
  data-reveal
>
  {
    eyebrow && (
      <span class="mb-6 inline-block rounded-full border border-primary/30 bg-primary/10 px-4 py-1.5 text-[10px] font-bold tracking-widest text-accent uppercase">
        {eyebrow}
      </span>
    )
  }
  <h2 class="mb-4 text-4xl font-extrabold md:text-5xl">
    {title}
    {highlight && <span class="text-gradient">{highlight}</span>}
  </h2>
  {
    description && (
      <p class:list={['text-ink-muted text-lg font-light leading-relaxed', centered && 'mx-auto max-w-2xl']}>
        {description}
      </p>
    )
  }
</div>
```

## Button

Five variants. `primary` is the only one allowed to carry a shadow, and its hover increases contrast with white in both modes.

```astro
---
interface Props {
  variant?: 'primary' | 'secondary' | 'outline' | 'ghost' | 'tinted'
  size?: 'sm' | 'md' | 'lg'
  href?: string
  type?: 'button' | 'submit' | 'reset'
  disabled?: boolean
  ariaLabel?: string
  class?: string
}

const {
  variant = 'primary',
  size = 'md',
  href,
  type = 'button',
  disabled = false,
  ariaLabel,
  class: className,
} = Astro.props

const base =
  'focus-ring inline-flex items-center justify-center gap-2 font-bold transition duration-300 disabled:pointer-events-none disabled:opacity-40'

const variants = {
  primary:
    'bg-primary text-white shadow-lg shadow-primary/25 hover:bg-primary-hover hover:scale-[1.02] active:scale-95',
  secondary:
    'border border-line bg-surface text-ink backdrop-blur-md hover:border-line-hover hover:bg-surface-hover',
  outline: 'border border-line-hover text-accent hover:bg-primary/10',
  ghost: 'text-ink-muted hover:bg-surface-hover hover:text-ink',
  tinted:
    'border border-primary/20 bg-primary/10 text-accent backdrop-blur-sm hover:bg-primary hover:text-white',
}

const sizes = {
  sm: 'rounded-xl px-5 py-2 text-sm',
  md: 'rounded-2xl px-6 py-3 text-sm md:px-8 md:py-4 md:text-base',
  lg: 'rounded-2xl px-10 py-5 text-lg',
}

const classes = [base, variants[variant], sizes[size], className]
---

{
  href ? (
    <a
      href={href}
      aria-label={ariaLabel}
      class:list={classes}
      data-disabled={disabled || undefined}
    >
      <slot />
    </a>
  ) : (
    <button
      type={type}
      disabled={disabled}
      aria-label={ariaLabel}
      class:list={classes}
    >
      <slot />
    </button>
  )
}
```

## Card

The canonical surface. `rounded-4xl` (32px) + hairline + glass + a 2px lift on hover.

```astro
---
interface Props {
  href?: string
  variant?: 'solid' | 'glass'
  padding?: 'sm' | 'md' | 'lg'
  interactive?: boolean
  float?: boolean
  floatDelay?: number
  class?: string
}

const {
  href,
  variant = 'solid',
  padding = 'md',
  interactive = true,
  float = true,
  floatDelay = 0,
  class: className,
} = Astro.props

const surfaces = {
  solid: 'border-line bg-surface',
  glass: 'border-transparent glassmorphism',
}

const paddings = { sm: 'p-6', md: 'p-6 md:p-10', lg: 'p-8 md:p-12' }

const classes = [
  'group relative flex h-full flex-col overflow-hidden rounded-4xl border backdrop-blur-sm transition duration-500',
  surfaces[variant],
  paddings[padding],
  interactive && 'hover:-translate-y-2 hover:border-primary/40',
  className,
]

const Tag = href ? 'a' : 'div'
---

<Tag class:list={classes} href={href}>
  {
    float ? (
      <div class="lg:animate-float flex h-full flex-col" style={`animation-delay: ${floatDelay}s`}>
        <slot />
      </div>
    ) : (
      <slot />
    )
  }
</Tag>
```

**Float lives on the inner wrapper, never on the card.** `animate-float` animates `transform`, and an animation on `transform` overrides the card's `hover:-translate-y-2` transition: put both on the same element and the hover lift silently stops working. Outer card: hover lift. Inner wrapper: float. Stagger `floatDelay` by `index * 0.6s` so a grid does not breathe in unison. Below `lg` there is no float — mobile pays for no motion.

Card internals:

```astro
<div class="mb-8 flex h-16 w-16 items-center justify-center rounded-2xl bg-primary/10 text-primary transition-transform group-hover:scale-110">
  <Cpu class="h-7 w-7" aria-hidden="true" />
</div>
<h3 class="mb-4 text-2xl font-bold">Desarrollo de Hardware &amp; Firmware</h3>
<p class="text-ink-muted mb-6 font-light leading-relaxed">
  Diseño de PCBs, sistemas embebidos y firmware de bajo nivel.
</p>
<span class="text-accent text-sm font-bold transition-transform group-hover:translate-x-2">
  Ver Ingeniería Electrónica &rarr;
</span>
```

## Navbar

Fixed, glass, shrinks on scroll, CSS-only dropdown with a hover bridge, separate mobile panel. Breakpoint `min-[1080px]` keeps the desktop nav from wrapping.

```astro
---
import { Image } from 'astro:assets'
import { ChevronDown, Menu, X } from 'lucide-astro'
import logoLight from '@assets/images/imagotipo-2.webp'
import logoDark from '@assets/images/imagotipo-1.webp'
import ThemeToggle from './ThemeToggle.astro'

interface NavChild { title: string; href: string }
interface NavLink { title: string; href: string; children?: NavChild[] }

interface Props {
  links: NavLink[]
  cta?: { title: string; href: string }
  homeHref?: string
}

const { links, cta = { title: 'Contáctanos', href: '/contacto' }, homeHref = '/' } = Astro.props
---

<nav
  id="site-nav"
  class="focus-within:border-line-hover fixed top-0 left-0 z-[100] h-20 w-full border-b border-line bg-canvas/90 backdrop-blur-xl transition duration-500"
>
  <div class="flex h-full w-full items-center justify-between px-6 lg:px-12">
    <a href={homeHref} class="focus-ring relative block h-10 w-32 rounded-lg" aria-label="Inicio">
      <Image src={logoLight} alt="" class="absolute inset-0 h-full w-full object-contain dark:opacity-0" />
      <Image src={logoDark} alt="" class="absolute inset-0 h-full w-full object-contain opacity-0 dark:opacity-100" />
    </a>

    <ul class="hidden items-center gap-6 min-[1080px]:flex lg:gap-8">
      {
        links.map((link) => (
          <li class="group relative py-3">
            <a
              href={link.href}
              class="focus-ring flex items-center gap-1 rounded-md px-2 py-1 text-sm font-medium text-ink-muted transition-colors duration-300 hover:text-accent"
            >
              {link.title}
              {link.children && (
                <ChevronDown class="h-3 w-3 transition-transform duration-300 group-hover:rotate-180" aria-hidden="true" />
              )}
            </a>
            {link.children && (
              <div class="invisible absolute top-full left-0 w-56 translate-y-1 overflow-hidden rounded-2xl border border-line bg-surface/95 opacity-0 shadow-xl backdrop-blur-xl transition duration-300 group-hover:visible group-hover:translate-y-0 group-hover:opacity-100 group-focus-within:visible group-focus-within:translate-y-0 group-focus-within:opacity-100">
                <div class="py-2">
                  {link.children.map((child) => (
                    <a
                      href={child.href}
                      class="focus-ring block px-6 py-3 text-sm text-ink-muted transition-colors duration-300 hover:bg-surface-hover hover:text-accent"
                    >
                      {child.title}
                    </a>
                  ))}
                </div>
              </div>
            )}
          </li>
        ))
      }
      <li><ThemeToggle /></li>
      <li>
        <a
          href={cta.href}
          class="focus-ring rounded-xl bg-primary px-5 py-2 text-sm font-bold text-white shadow-lg shadow-primary/20 transition duration-300 hover:bg-primary-hover hover:scale-105"
        >
          {cta.title}
        </a>
      </li>
    </ul>

    <div class="flex items-center gap-4 min-[1080px]:hidden">
      <ThemeToggle />
      <button
        id="nav-open"
        class="focus-ring rounded-xl p-2 text-ink"
        aria-label="Abrir menú"
        aria-controls="nav-mobile"
        aria-expanded="false"
      >
        <Menu class="h-8 w-8" aria-hidden="true" />
      </button>
    </div>
  </div>

  <div
    id="nav-mobile"
    class="fixed inset-0 z-[150] flex min-h-[100dvh] translate-x-full flex-col overflow-y-auto bg-canvas px-6 pt-24 pb-10 transition-transform duration-500 min-[1080px]:hidden"
  >
    <button id="nav-close" class="focus-ring absolute top-6 right-6 rounded-xl p-2 text-ink-muted hover:text-accent" aria-label="Cerrar menú">
      <X class="h-8 w-8" aria-hidden="true" />
    </button>
    <ul class="flex w-full flex-col">
      {
        links.map((link) => (
          <li class="w-full border-b border-line py-4">
            <a href={link.href} data-nav-link class="focus-ring block text-lg font-medium text-ink-muted transition-colors hover:text-accent">
              {link.title}
            </a>
            {link.children && (
              <ul class="mt-3 space-y-3 pl-4">
                {link.children.map((child) => (
                  <li>
                    <a href={child.href} data-nav-link class="focus-ring block text-base text-ink-muted transition-colors hover:text-accent">
                      {child.title}
                    </a>
                  </li>
                ))}
              </ul>
            )}
          </li>
        ))
      }
    </ul>
    <a href={cta.href} data-nav-link class="focus-ring mt-6 flex w-full items-center justify-center rounded-2xl bg-primary py-3 text-base font-bold text-white active:scale-95">
      {cta.title}
    </a>
  </div>
</nav>

<script>
  const initNav = () => {
    const nav = document.getElementById('site-nav')
    const panel = document.getElementById('nav-mobile')
    const openBtn = document.getElementById('nav-open')
    const closeBtn = document.getElementById('nav-close')
    if (!nav || !panel || !openBtn || !closeBtn) return

    const open = () => {
      panel.classList.remove('translate-x-full')
      document.body.classList.add('overflow-hidden')
      openBtn.setAttribute('aria-expanded', 'true')
      closeBtn.focus()
    }
    const close = () => {
      panel.classList.add('translate-x-full')
      document.body.classList.remove('overflow-hidden')
      openBtn.setAttribute('aria-expanded', 'false')
    }

    openBtn.onclick = open
    closeBtn.onclick = close
    panel.querySelectorAll('[data-nav-link]').forEach((a) => a.addEventListener('click', close))
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && !panel.classList.contains('translate-x-full')) close()
    })

    let shrunk = false
    const onScroll = () => {
      const next = window.scrollY > 40
      if (next === shrunk) return
      shrunk = next
      nav.classList.toggle('h-16', next)
      nav.classList.toggle('h-20', !next)
      nav.classList.toggle('shadow-lg', next)
      nav.classList.toggle('shadow-black/20', next)
    }
    window.addEventListener('scroll', onScroll, { passive: true })
    onScroll()
  }

  document.addEventListener('astro:page-load', initNav)
</script>
```

## Footer

```astro
---
type IconComponent = (typeof import('lucide-astro'))['Instagram']

interface Props {
  links: { title: string; href: string }[]
  email?: string
  tagline?: string
  socials?: { href: string; label: string; icon: IconComponent }[]
}

const { links, email = 'info@rtelectronics.co', tagline = 'Conectando ideas y realidades', socials = [] } = Astro.props
---

<footer class="content-auto border-t border-line pt-24 pb-12">
  <div class="mx-auto w-full max-w-7xl px-6">
    <div class="mb-20 grid gap-16 md:grid-cols-3">
      <div>
        <h4 class="mb-8 text-lg font-bold">Síguenos en redes</h4>
        <div class="mb-8 flex gap-4">
          {
            socials.map(({ href, label, icon: Icon }) => (
              <a
                href={href}
                target="_blank"
                rel="noopener noreferrer"
                aria-label={label}
                class="glassmorphism focus-ring flex h-10 w-10 items-center justify-center rounded-lg transition-colors duration-300 hover:bg-primary"
              >
                <Icon class="h-5 w-5 text-ink-muted transition-colors hover:text-white" aria-hidden="true" />
              </a>
            ))
          }
        </div>
        <p class="text-ink-muted font-light italic">&laquo;{tagline}&raquo;</p>
      </div>

      <div>
        <h4 class="mb-8 text-lg font-bold">Navegación</h4>
        <ul class="space-y-4">
          {
            links.map((link) => (
              <li>
                <a href={link.href} class="focus-ring rounded-md text-ink-muted font-light transition-colors duration-300 hover:text-accent">
                  {link.title}
                </a>
              </li>
            ))
          }
        </ul>
      </div>

      <div>
        <h4 class="mb-8 text-lg font-bold">Contacto</h4>
        <p class="text-ink-muted mb-4 font-light">Empoderando proyectos tecnológicos en todo el mundo.</p>
        <a href={`mailto:${email}`} class="focus-ring rounded-md text-accent font-medium hover:underline">{email}</a>
      </div>
    </div>

    <div class="border-t border-line pt-12 text-center">
      <p class="text-ink-muted text-sm font-light">&copy; {new Date().getFullYear()} RTElectronics. Todos los derechos reservados.</p>
    </div>
  </div>
</footer>
```

## Field (input, textarea, label, hint, error)

```astro
---
interface Props {
  id: string
  name: string
  label: string
  type?: 'text' | 'email' | 'tel'
  as?: 'input' | 'textarea'
  rows?: number
  placeholder?: string
  required?: boolean
  hint?: string
  error?: string
}

const {
  id,
  name,
  label,
  type = 'text',
  as = 'input',
  rows = 4,
  placeholder,
  required = false,
  hint,
  error,
} = Astro.props

const fieldClass = [
  'focus-ring w-full rounded-2xl border bg-surface px-5 py-4 text-sm text-ink transition-colors duration-300',
  'placeholder:text-ink-muted/60 focus:bg-surface-hover',
  error ? 'border-red-500/60' : 'border-line hover:border-line-hover focus:border-primary',
]
---

<div class="space-y-2">
  <label for={id} class="ml-1 block text-xs font-bold tracking-widest text-ink-muted uppercase">
    {label}{required && <span class="text-accent"> *</span>}
  </label>

  {
    as === 'textarea' ? (
      <textarea
        id={id}
        name={name}
        rows={rows}
        placeholder={placeholder}
        required={required}
        aria-invalid={error ? 'true' : undefined}
        aria-describedby={error ? `${id}-error` : hint ? `${id}-hint` : undefined}
        class:list={[...fieldClass, 'resize-none']}
      />
    ) : (
      <input
        id={id}
        name={name}
        type={type}
        placeholder={placeholder}
        required={required}
        aria-invalid={error ? 'true' : undefined}
        aria-describedby={error ? `${id}-error` : hint ? `${id}-hint` : undefined}
        class:list={fieldClass}
      />
    )
  }

  {hint && !error && <p id={`${id}-hint`} class="ml-1 text-xs text-ink-muted">{hint}</p>}
  {error && <p id={`${id}-error`} class="ml-1 text-xs text-red-500">{error}</p>}
</div>
```

## Select (accessible, light-mode safe)

Custom listbox on a `<button>`, roving focus into the options, value in a hidden input. This replaces the marketing site's version, which painted the chosen label `text-white` and therefore disappeared in light mode.

```astro
---
import { ChevronDown } from 'lucide-astro'

interface Option { value: string; label: string }
interface Props {
  id: string
  name: string
  label: string
  placeholder?: string
  options: Option[]
  required?: boolean
}

const { id, name, label, placeholder = 'Selecciona una opción', options, required = false } = Astro.props
---

<div class="space-y-2">
  <label for={`${id}-trigger`} class="ml-1 block text-xs font-bold tracking-widest text-ink-muted uppercase">
    {label}{required && <span class="text-accent"> *</span>}
  </label>

  <div class="relative" data-select>
    <input type="hidden" id={id} name={name} required={required} data-select-value />

    <button
      type="button"
      id={`${id}-trigger`}
      data-select-trigger
      class="focus-ring flex w-full items-center justify-between rounded-2xl border border-line bg-surface px-5 py-4 text-left text-sm transition-colors duration-300 hover:border-line-hover"
      aria-haspopup="listbox"
      aria-expanded="false"
      aria-controls={`${id}-list`}
    >
      <span data-select-label class="text-ink-muted">{placeholder}</span>
      <ChevronDown class="h-4 w-4 shrink-0 opacity-50 transition-transform duration-300" data-select-icon aria-hidden="true" />
    </button>

    <ul
      id={`${id}-list`}
      role="listbox"
      tabindex="-1"
      data-select-list
      class="absolute top-full left-0 z-50 mt-2 hidden max-h-60 w-full overflow-auto rounded-2xl border border-line bg-surface py-2 shadow-xl backdrop-blur-xl"
    >
      {
        options.map((option, index) => (
          <li
            role="option"
            id={`${id}-opt-${index}`}
            tabindex="-1"
            data-value={option.value}
            aria-selected="false"
            class="cursor-pointer border-b border-line px-5 py-3 text-sm text-ink-muted transition-colors duration-300 last:border-0 hover:bg-primary/10 hover:text-accent focus:bg-primary/10 focus:text-accent focus:outline-none"
          >
            {option.label}
          </li>
        ))
      }
    </ul>
  </div>
</div>

<script>
  const initSelects = () => {
    document.querySelectorAll<HTMLElement>('[data-select]').forEach((root) => {
      if (root.dataset.bound === 'true') return
      root.dataset.bound = 'true'

      const trigger = root.querySelector<HTMLButtonElement>('[data-select-trigger]')!
      const list = root.querySelector<HTMLUListElement>('[data-select-list]')!
      const label = root.querySelector<HTMLElement>('[data-select-label]')!
      const icon = root.querySelector<SVGElement>('[data-select-icon]')
      const value = root.querySelector<HTMLInputElement>('[data-select-value]')!
      const options = Array.from(list.querySelectorAll<HTMLLIElement>('[role="option"]'))
      let index = options.findIndex((o) => o.getAttribute('aria-selected') === 'true')

      const highlight = (next: number, moveFocus = false) => {
        index = Math.max(0, Math.min(next, options.length - 1))
        options.forEach((option, i) => {
          option.classList.toggle('bg-primary/10', i === index)
          option.classList.toggle('text-accent', i === index)
        })
        if (moveFocus) options[index]?.focus()
      }

      const open = () => {
        list.classList.remove('hidden')
        trigger.setAttribute('aria-expanded', 'true')
        icon?.classList.add('rotate-180')
        highlight(index < 0 ? 0 : index, true)
      }

      const close = (returnFocus = true) => {
        list.classList.add('hidden')
        trigger.setAttribute('aria-expanded', 'false')
        icon?.classList.remove('rotate-180')
        if (returnFocus) trigger.focus()
      }

      const select = (i: number) => {
        const option = options[i]
        if (!option) return
        options.forEach((o) => o.setAttribute('aria-selected', 'false'))
        option.setAttribute('aria-selected', 'true')
        value.value = option.dataset.value ?? ''
        label.textContent = option.textContent?.trim() ?? ''
        label.classList.remove('text-ink-muted')
        label.classList.add('text-ink')
        close()
        trigger.dispatchEvent(
          new CustomEvent('select-change', { bubbles: true, detail: { value: value.value } }),
        )
      }

      trigger.addEventListener('click', () => {
        list.classList.contains('hidden') ? open() : close()
      })

      trigger.addEventListener('keydown', (event) => {
        if (['ArrowDown', 'ArrowUp', 'Enter', ' '].includes(event.key)) {
          event.preventDefault()
          open()
        }
      })

      list.addEventListener('keydown', (event) => {
        switch (event.key) {
          case 'Escape':
            event.preventDefault()
            close()
            break
          case 'ArrowDown':
            event.preventDefault()
            highlight(index + 1, true)
            break
          case 'ArrowUp':
            event.preventDefault()
            highlight(index - 1, true)
            break
          case 'Home':
            event.preventDefault()
            highlight(0, true)
            break
          case 'End':
            event.preventDefault()
            highlight(options.length - 1, true)
            break
          case 'Enter':
          case ' ':
            event.preventDefault()
            select(index)
            break
          case 'Tab':
            close(false)
            break
        }
      })

      options.forEach((option, i) => {
        option.addEventListener('click', () => select(i))
        option.addEventListener('mouseenter', () => highlight(i))
      })

      document.addEventListener('click', (event) => {
        if (!document.body.contains(root)) return
        if (!root.contains(event.target as Node)) close(false)
      })
    })
  }

  document.addEventListener('astro:page-load', initSelects)
  initSelects()
</script>
```

## Modal (new design, not present in the marketing site)

Native `<dialog>`: `showModal()` gives the focus trap and Escape for free. The backdrop is written in CSS because a `backdrop:` utility may not exist in every Tailwind build.

```astro
---
interface Props {
  id: string
  title: string
  description?: string
}

const { id, title, description } = Astro.props
---

<dialog
  id={id}
  data-modal
  aria-labelledby={`${id}-title`}
  class="w-[min(92vw,42rem)] rounded-4xl border border-line bg-surface p-0 text-ink backdrop:bg-black/60"
>
  <div class="relative overflow-hidden rounded-4xl">
    <div class="pointer-events-none absolute -top-24 -right-24 h-48 w-48 rounded-full bg-primary/20 blur-[80px]"></div>

    <div class="relative z-10 p-8 md:p-10">
      <div class="mb-6 flex items-start justify-between gap-6">
        <div>
          <h2 id={`${id}-title`} class="text-2xl font-bold">{title}</h2>
          {description && <p class="mt-2 text-sm font-light text-ink-muted">{description}</p>}
        </div>
        <button
          type="button"
          data-modal-close
          class="focus-ring rounded-xl p-2 text-ink-muted transition-colors hover:bg-surface-hover hover:text-accent"
          aria-label="Cerrar"
        >
          <svg viewBox="0 0 24 24" class="h-5 w-5" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
            <path d="M18 6 6 18M6 6l12 12" stroke-linecap="round" />
          </svg>
        </button>
      </div>

      <div class="text-ink-muted font-light leading-relaxed">
        <slot />
      </div>

      <div class="mt-8 flex flex-col-reverse gap-4 sm:flex-row sm:justify-end">
        <slot name="footer" />
      </div>
    </div>
  </div>
</dialog>

<style>
  dialog[data-modal]::backdrop {
    background: rgb(0 0 0 / 0.6);
    backdrop-filter: blur(4px);
  }
</style>

<script>
  const initModals = () => {
    document.querySelectorAll<HTMLDialogElement>('dialog[data-modal]').forEach((dialog) => {
      if (dialog.dataset.bound === 'true') return
      dialog.dataset.bound = 'true'

      document
        .querySelectorAll<HTMLElement>(`[data-modal-open="${dialog.id}"]`)
        .forEach((trigger) => trigger.addEventListener('click', () => dialog.showModal()))

      dialog.querySelectorAll('[data-modal-close]').forEach((button) =>
        button.addEventListener('click', () => dialog.close()),
      )

      dialog.addEventListener('click', (event) => {
        if (event.target === dialog) dialog.close()
      })
    })
  }

  document.addEventListener('astro:page-load', initModals)
  initModals()
</script>
```

Open it from anywhere with `<button data-modal-open="mi-modal">Abrir</button>`.

## ThemeToggle

Works because `dark:` is class-driven (`@custom-variant`). Without that line the sun and moon never swap when the OS disagrees with the toggle.

```astro
---
import { Moon, Sun } from 'lucide-astro'
---

<button
  type="button"
  data-theme-toggle
  class="glassmorphism focus-ring relative flex h-10 w-10 shrink-0 items-center justify-center rounded-xl text-ink-muted transition duration-300 hover:border-primary/50 hover:bg-primary/10 hover:text-accent active:scale-95"
  aria-label="Alternar tema"
>
  <Sun class="absolute h-5 w-5 rotate-0 scale-100 transition duration-300 dark:-rotate-90 dark:scale-0" aria-hidden="true" />
  <Moon class="absolute h-5 w-5 rotate-90 scale-0 transition duration-300 dark:rotate-0 dark:scale-100" aria-hidden="true" />
</button>

<script>
  const apply = (theme: 'dark' | 'light') => {
    const root = document.documentElement
    root.classList.toggle('dark', theme === 'dark')
    root.dataset.theme = theme
    localStorage.setItem('theme', theme)
  }

  const initThemeToggle = () => {
    document.querySelectorAll<HTMLElement>('[data-theme-toggle]').forEach((button) => {
      button.onclick = () => {
        const next = document.documentElement.classList.contains('dark') ? 'light' : 'dark'
        if (!document.startViewTransition) return apply(next)
        document.startViewTransition(() => apply(next))
      }
    })
  }

  document.addEventListener('astro:page-load', initThemeToggle)
  initThemeToggle()
</script>
```

## Reveal, counters and marquee

```astro
<!-- layout -->
<script>
  import '../scripts/reveal'
</script>
```

```ts
// src/scripts/reveal.ts
let observer: IntersectionObserver | null = null

const prefersReduced = () => window.matchMedia('(prefers-reduced-motion: reduce)').matches

function initReveal() {
  observer?.disconnect()
  const targets = document.querySelectorAll<HTMLElement>('[data-reveal]')

  if (prefersReduced()) {
    targets.forEach((el) => el.classList.add('revealed'))
    return
  }

  observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return
        entry.target.classList.add('revealed')
        observer?.unobserve(entry.target)
      })
    },
    { threshold: 0.15 },
  )

  targets.forEach((el) => observer?.observe(el))
}

document.addEventListener('astro:page-load', initReveal)
```

Counter (2000ms, easeOutExpo, once):

```ts
const animateCounters = () => {
  document.querySelectorAll<HTMLElement>('[data-counter]').forEach((counter) => {
    const target = Number(counter.dataset.target ?? 0)
    const prefix = counter.dataset.prefix ?? ''
    const suffix = counter.dataset.suffix ?? ''
    const start = performance.now()

    const frame = (now: number) => {
      const progress = Math.min((now - start) / 2000, 1)
      const eased = progress === 1 ? 1 : 1 - Math.pow(2, -10 * progress)
      counter.textContent = `${prefix}${Math.floor(eased * target)}${suffix}`
      if (progress < 1) requestAnimationFrame(frame)
    }

    const observer = new IntersectionObserver(
      ([entry]) => {
        if (!entry.isIntersecting) return
        requestAnimationFrame(frame)
        observer.disconnect()
      },
      { threshold: 0.5 },
    )

    observer.observe(counter)
  })
}

document.addEventListener('astro:page-load', animateCounters)
```

## Wiring the layout

```astro
---
import '../styles/global.css'
import '@fontsource-variable/rubik'
import { ClientRouter } from 'astro:transitions'
import Navbar from '@components/Navbar.astro'
import Footer from '@components/Footer.astro'
---

<!doctype html>
<html lang="es" class="scroll-smooth">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <script is:inline>/* theme boot, see tokens file */</script>
    <ClientRouter />
  </head>
  <body class="relative min-h-screen bg-canvas font-sans text-ink antialiased">
    <div class="pointer-events-none fixed inset-0 z-0 overflow-hidden opacity-60">
      <!-- circuit SVG, see tokens file §2 -->
    </div>
    <div class="relative z-10 mx-auto max-w-[1920px]">
      <Navbar links={navLinks} />
      <main><slot /></main>
      <Footer links={navLinks} />
    </div>
  </body>
</html>
```

Every page must repeat: `<div class="relative z-10">` over the circuit layer, `pt-32` on inner pages so content clears the fixed navbar, and `data-reveal` on each top-level block.

## Forbidden per component

Per-component consequences of the exclusion table in `SKILL.md`. Read both before writing a component. Every row is either a defect this reference implementation already produced or a constraint it already enforces; none is a general best practice.

| Component | Forbidden | Why this system breaks |
| --- | --- | --- |
| **Navbar** | Framework state for the dropdown, `lg` as the desktop breakpoint, links without `focus-ring`, `text-white` for the active item. | The nav ships six entries and only fits from `min-[1080px]`; at 1024px it overflows. `text-white` for "active" is invisible on the light canvas, which is exactly what `Navbar.astro` did before this patch. |
| **Button** | `rounded-full`, `shadow-xl`/`shadow-2xl`, `hover:scale-110`, `font-light`, a second accent hue, `disabled` without `pointer-events-none` + `opacity-40`. | Radius scale, single shadow owner, and a 300ms hover that must stay sober. The label has to remain readable at hover in both modes: light goes to `--color-primary-light`, dark goes to `--color-primary-dark`. |
| **Card** | Shadow, `rounded-2xl` on the card shell, `border-2`, `hover:scale-*` on the card, more than one badge, more than one icon plate. | The card lifts 8px (`hover:-translate-y-2`); scaling it changes the grid rhythm and blurs image edges. The icon plate is the only place `group-hover:scale-110` is legal. |
| **Select** | `appearance-none` on a native `<select>` with no accessible replacement, a combobox library, `text-white` on the chosen value, opening without moving focus into the list. | The chosen label sits on `bg-surface`; white on white was a real bug at `contacto.astro:301`. Keyboard users need `ArrowUp/Down`, `Home`, `End`, `Enter`, `Escape` and `Tab` to close. |
| **Field** | `outline-none` without `focus-ring`, family-colored placeholder, a label without `for`, an error without `aria-invalid` + `aria-describedby`, `resize-y`. | In a form the focus ring is the only affordance other than the border. The label is `text-xs font-bold tracking-widest uppercase`; nothing else. |
| **Modal** | A fixed-position `div` with a hand-rolled focus trap, an unverified `backdrop:` utility, closing only through the X button. | Native `<dialog>` + `showModal()` gives the trap, the inert background and Escape for free. `backdrop:` may not exist in the build; an ungenerated class is inert. Write `::backdrop` in a `<style>` block. |
| **ThemeToggle** | Two icons cross-faded with `opacity` only, a toggle that writes only `data-theme`, a second competing theme bootstrap. | `dark:` is class-driven here (`@custom-variant`), so the toggle must write `classList` **and** `dataset.theme`, and only one bootstrap may win. |

## Non-negotiable anatomy

Minimum each component must contain, regardless of layout changes.

| Component | Required |
| --- | --- |
| Navbar | `fixed top-0 left-0 z-[100] h-20 w-full border-b border-line bg-canvas/90 backdrop-blur-xl`; shrink to `h-16` + `shadow-lg shadow-black/20` past 40px of scroll; desktop from `min-[1080px]`; mobile panel `fixed inset-0 z-[150] translate-x-full` with `overflow-hidden` on `body` and Escape to close; dropdown with a hover bridge (`py-3` on the item) and `focus-within` for keyboard; `ThemeToggle` before the CTA. |
| Button | A variant map (`primary`, `secondary`, `outline`, `ghost`, `tinted`) and a size map (`sm`, `md`, `lg`); `focus-ring`; `disabled:pointer-events-none disabled:opacity-40`; `active:scale-95`; only `primary` carries `shadow-lg shadow-primary/25`. |
| Card | `rounded-4xl border border-line bg-surface backdrop-blur-sm transition duration-500`; hover lift `hover:-translate-y-2 hover:border-primary/40` on the card; `lg:animate-float` on an **inner** wrapper with a staggered `animation-delay`; icon plate `h-16 w-16 rounded-2xl bg-primary/10 text-primary`; one eyebrow badge in `text-accent`; CTA line with `group-hover:translate-x-2`. |
| SectionHeader | Eyebrow badge, `h2` with a `text-gradient` fragment, lead paragraph `text-ink-muted text-lg font-light`, `data-reveal` on the wrapper. |
| Select | Hidden input carrying the value, `aria-haspopup="listbox"`, `aria-expanded`, `aria-controls`, `role="listbox"`/`role="option"`, `tabindex="-1"` on options, roving focus, click-outside close, rebind on `astro:page-load`. |
| Field | `for`/`id` pair, `focus-ring`, placeholder at `text-ink-muted/60`, error wired with `aria-invalid` + `aria-describedby`. |
| Modal | `<dialog>` + `showModal()`, `aria-labelledby`, `::backdrop` in a `<style>` block, close via X, backdrop click and Escape, footer slot for actions. |

Any deviation from these two tables is a defect to report, not a style choice.
