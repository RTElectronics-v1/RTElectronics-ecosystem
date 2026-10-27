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
