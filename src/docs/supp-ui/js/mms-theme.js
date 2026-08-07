/*
 * Theme picker interaction.
 *
 * The palette is already applied by the inline bootstrap in head-prelude.hbs
 * before first paint; this only handles clicks, keeps the pressed states in
 * step, and persists the choice. It also follows the OS appearance while the
 * reader has not made an explicit brightness choice.
 *
 * Author: Paul Snow
 * Since: 0.0.0
 */
;(function () {
  'use strict'

  var root = document.documentElement

  // ── Mermaid ───────────────────────────────────────────────────────────
  // The playbook sets start_on_load: false, so nothing has rendered yet.
  // Diagrams are rendered here with mermaid's "base" theme fed from the
  // active palette tokens, and re-rendered whenever the palette changes.

  var MERMAID_URL = 'https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.esm.min.mjs'
  var blocks = document.querySelectorAll('.mermaid')
  var mermaidLib = null
  var sources = []

  Array.prototype.forEach.call(blocks, function (el, i) {
    sources[i] = el.textContent
  })

  function token (name) {
    return getComputedStyle(root).getPropertyValue(name).trim()
  }

  function themeVariables () {
    var text = token('--text')
    var dim = token('--dim')
    var line = token('--line2')
    var s1 = token('--s1')
    var s2 = token('--s2')
    var s3 = token('--s3')
    var accent = token('--accline')
    return {
      darkMode: root.getAttribute('data-bright') === 'dark',
      background: s1,
      fontFamily: '"Manrope", system-ui, sans-serif',
      fontSize: '14px',
      primaryColor: s2,
      primaryTextColor: text,
      primaryBorderColor: accent,
      secondaryColor: s3,
      secondaryTextColor: text,
      secondaryBorderColor: line,
      tertiaryColor: s1,
      tertiaryTextColor: text,
      tertiaryBorderColor: line,
      lineColor: dim,
      textColor: text,
      mainBkg: s2,
      nodeBorder: accent,
      nodeTextColor: text,
      clusterBkg: s1,
      clusterBorder: line,
      titleColor: text,
      edgeLabelBackground: s1,
      labelBoxBkgColor: s2,
      labelBoxBorderColor: line,
      labelTextColor: text,
      actorBkg: s2,
      actorBorder: accent,
      actorTextColor: text,
      actorLineColor: dim,
      signalColor: text,
      signalTextColor: text,
      loopTextColor: text,
      noteBkgColor: s3,
      noteTextColor: text,
      noteBorderColor: line,
      activationBkgColor: s3,
      activationBorderColor: accent,
      sequenceNumberColor: token('--onacc'),
      classText: text,
      attributeBackgroundColorOdd: s1,
      attributeBackgroundColorEven: s2
    }
  }

  function renderMermaid () {
    if (!blocks.length || !mermaidLib) return
    Array.prototype.forEach.call(blocks, function (el, i) {
      el.removeAttribute('data-processed')
      // Assigning textContent replaces every child, discarding the SVG
      // mermaid rendered on the previous pass.
      el.textContent = sources[i]
    })
    mermaidLib.initialize({ startOnLoad: false, theme: 'base', themeVariables: themeVariables() })
    mermaidLib.run({ nodes: blocks }).catch(function (e) {
      console.error('mermaid render failed', e)
    })
  }

  if (blocks.length) {
    import(MERMAID_URL)
      .then(function (mod) {
        mermaidLib = mod.default || mod
        renderMermaid()
      })
      .catch(function (e) {
        console.error('mermaid load failed', e)
      })
  }

  // ── Picker ────────────────────────────────────────────────────────────

  var picker = document.getElementById('mms-theme')
  if (!picker) return

  var swatches = picker.querySelectorAll('[data-palette]')
  var brights = picker.querySelectorAll('[data-bright]')

  function store (key, value) {
    try {
      localStorage.setItem(key, value)
    } catch (e) {
      /* private browsing — the choice just will not persist */
    }
  }

  function sync () {
    var palette = root.getAttribute('data-palette')
    var bright = root.getAttribute('data-bright')
    Array.prototype.forEach.call(swatches, function (el) {
      el.setAttribute('aria-pressed', String(el.dataset.palette === palette))
    })
    Array.prototype.forEach.call(brights, function (el) {
      el.setAttribute('aria-pressed', String(el.dataset.bright === bright))
    })
  }

  Array.prototype.forEach.call(swatches, function (el) {
    el.addEventListener('click', function () {
      root.setAttribute('data-palette', el.dataset.palette)
      store('mms-palette', el.dataset.palette)
      sync()
      renderMermaid()
    })
  })

  Array.prototype.forEach.call(brights, function (el) {
    el.addEventListener('click', function () {
      root.setAttribute('data-bright', el.dataset.bright)
      store('mms-bright', el.dataset.bright)
      sync()
      renderMermaid()
    })
  })

  // Track the OS setting until the reader overrides it explicitly.
  if (window.matchMedia) {
    var query = window.matchMedia('(prefers-color-scheme: light)')
    var onChange = function (event) {
      var chosen
      try {
        chosen = localStorage.getItem('mms-bright')
      } catch (e) {}
      if (chosen === 'light' || chosen === 'dark') return
      root.setAttribute('data-bright', event.matches ? 'light' : 'dark')
      sync()
      renderMermaid()
    }
    if (query.addEventListener) {
      query.addEventListener('change', onChange)
    } else if (query.addListener) {
      query.addListener(onChange)
    }
  }

  sync()
})()
