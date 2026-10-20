// ─────────────────────────────────────────────────────────────
//  clauto — slide template (16:9)
//  Build:  typst compile --font-path fonts main.typ
// ─────────────────────────────────────────────────────────────

#let clr = (
  green:      rgb("#4E7D23"),
  green-dark: rgb("#3A5E19"),
  lime:       rgb("#C3E38A"),
  lime-soft:  rgb("#F1F8E6"),
  ink:        rgb("#1F2420"),
  muted:      rgb("#6E766A"),
  line:       rgb("#E2E7DB"),
  code-bg:    rgb("#F5F7F2"),
  red:        rgb("#C2412D"),
  red-soft:   rgb("#FBEDEA"),
  amber-soft: rgb("#FDF6E3"),
  amber:      rgb("#B7791F"),
)

#let fonts = (
  heading: "Fira Sans",
  body:    "Source Sans 3",
  mono:    "JetBrains Mono",
  hand:    "Excalifont",
)

#let size = (
  body:    14pt,
  code:    10.5pt,
  title:   21pt,
  crumb:   9pt,
)

// ── internal state ───────────────────────────────────────────
#let _chapter     = counter("clauto-chapter")
#let _section     = counter("clauto-section")
#let _pending-sec = state("clauto-pending-section", none)
#let _cur-chapter = state("clauto-current-chapter", none)
#let _cur-section = state("clauto-current-section", none)
#let _subsection  = counter("clauto-subsection")
#let _pending-sub = state("clauto-pending-subsection", none)
#let _cur-sub     = state("clauto-current-subsection", none)
#let _doc         = state("clauto-doc", (:))

// ── small building blocks ────────────────────────────────────
#let num-badge(n, s: 1) = box(
  fill: clr.green, radius: 4pt * s,
  inset: (x: 7pt * s, y: 5pt * s),
  baseline: 25%,
  text(font: fonts.heading, weight: "bold", fill: white, size: 15pt * s, str(n)),
)

#let rule(w: 100%, t: 1.4pt) = line(length: w, stroke: t + clr.lime)

/// Handwritten annotation text (matches the diagram style).
#let hand(body, fill: clr.green, size: 15pt) = text(font: fonts.hand, fill: fill, size: size, body)

/// Small pill label, e.g. #pill[immutable]
#let pill(body, fill: clr.lime-soft, accent: clr.green) = box(
  fill: fill, stroke: 0.7pt + accent, radius: 7pt,
  inset: (x: 7pt, y: 3pt), baseline: 20%,
  text(font: fonts.heading, size: 9pt, weight: "semibold", fill: accent, tracking: 0.06em, upper(body)),
)
#let immutable = pill[immutable]
#let mutable = pill(fill: clr.amber-soft, accent: clr.amber)[mutable]

/// Compact two-column "Method | What it does" table.
/// #methods([`strip()`], [remove spaces], [`upper()`], [to upper case])
#let methods(header: ([Method], [What it does]), ..rows) = {
  show table: set text(size: 10.5pt)
  table(columns: (auto, 1fr), inset: (x: 6pt, y: 4.5pt), ..header, ..rows)
}

/// Hand-drawn diagram from diagrams/<name>.svg (rendered from <name>.excalidraw).
#let diagram(name, width: 100%, caption: none) = align(center, {
  image("/diagrams/" + name + ".svg", width: width)
  if caption != none { v(-2pt); hand(caption, fill: clr.muted, size: 13pt) }
})

/// Two-column slide body: left = code / diagram, right = text. ratio: (1, 1) · (2, 3) · (3, 2)
#let cols(left, right, ratio: (1, 1), gutter: 0.9cm, align: horizon) = grid(
  columns: (ratio.at(0) * 1fr, ratio.at(1) * 1fr),
  column-gutter: gutter,
  std.align(align, left), std.align(align, right),
)

#let _callout(label, body, fill, accent, icon) = block(
  width: 100%, fill: fill, radius: (right: 4pt),
  stroke: (left: 3pt + accent),
  inset: (x: 11pt, y: 9pt),
  {
    text(font: fonts.heading, weight: "semibold", size: 10pt, fill: accent, tracking: 0.04em)[#icon #upper(label)]
    v(-4pt)
    set text(size: 12.5pt)
    body
  },
)

/// Cisco Collaboration example box.
#let collab(body, title: "In the Collab world") = _callout(title, body, clr.lime-soft, clr.green, sym.triangle.r.filled)
#let tip(body, title: "Tip") = _callout(title, body, clr.lime-soft, clr.green, sym.star.filled)
#let warn(body, title: "Watch out") = _callout(title, body, clr.amber-soft, clr.amber, "!")
#let pitfall(body, title: "Common mistake") = _callout(title, body, clr.red-soft, clr.red, sym.times)

// ── structure ────────────────────────────────────────────────

/// Chapter opener. Numbers are assigned automatically in main.typ order.
#let chapter(title, intro: none) = page(header: none, footer: none, margin: (x: 2cm, y: 1.8cm))[
  #_chapter.step()
  #_section.update(0)
  #_cur-chapter.update(title)
  #_cur-section.update(none)
  #_pending-sec.update(none)
  #_subsection.update(0)
  #_cur-sub.update(none)
  #_pending-sub.update(none)
  #metadata((kind: "chapter", title: title))<clauto-toc>

  #v(1fr)
  #context {
    let n = _chapter.get().first()
    grid(
      columns: (auto, 1fr), column-gutter: 14pt, align: horizon,
      num-badge(n, s: 2.2),
      text(font: fonts.heading, weight: "bold", size: 36pt, fill: clr.green, title),
    )
  }
  #v(4pt)
  #rule(t: 2pt)
  #v(10pt)
  #if intro != none {
    set par(justify: true, leading: 0.62em)
    block(width: 88%, text(size: 14pt, intro))
  }
  #v(8pt)
  #context {
    let n = _chapter.get().first()
    let mine = ()
    let seen = 0
    for m in query(<clauto-toc>) {
      if m.value.kind == "chapter" { seen += 1; continue }
      if seen == n and m.value.kind == "section" { mine.push(m) }
    }
    if mine.len() > 0 {
      set text(font: fonts.heading, size: 11.5pt, fill: clr.muted)
      grid(
        columns: (auto,) * calc.min(mine.len(), 3), column-gutter: 22pt, row-gutter: 6pt,
        ..mine.enumerate().map(((i, m)) => [
          #text(fill: clr.green, weight: "semibold")[#n.#(i + 1)] #h(3pt) #m.value.title
        ]),
      )
    }
  }
  #v(1.3fr)
]

/// Section marker — attaches to the next slide (shown in the crumb + contents).
#let section(title) = _pending-sec.update(title)

/// Sub-section marker (1.3.1, 1.3.2 …) — attaches to the next slide.
#let subsection(title) = _pending-sub.update(title)

/// A content slide.
/// center: vertically center the body below the title (default).
#let slide(title: none, center: true, body) = {
  pagebreak(weak: true)
  context {
    let p = _pending-sec.get()
    if p != none {
      _section.step()
      _cur-section.update(p)
      _pending-sec.update(none)
      _subsection.update(0)
      _cur-sub.update(none)
      [#metadata((kind: "section", title: p))<clauto-toc>]
    }
  }
  context {
    let p = _pending-sub.get()
    if p != none {
      _subsection.step()
      _cur-sub.update(p)
      _pending-sub.update(none)
      [#metadata((kind: "subsection", title: p))<clauto-toc>]
    }
  }
  // crumb
  context {
    let c = _chapter.get().first()
    let s = _section.get().first()
    let sec = _cur-section.get()
    let sub = _cur-sub.get()
    let chap = _cur-chapter.get()
    set text(font: fonts.heading, size: size.crumb, fill: clr.muted, tracking: 0.05em)
    if sub != none [
      #text(fill: clr.green, weight: "semibold")[#c.#s.#_subsection.get().first()] #h(2pt) #upper(sec) #h(3pt) · #h(3pt) #upper(sub)
    ] else if sec != none [
      #text(fill: clr.green, weight: "semibold")[#c.#s] #h(2pt) #upper(sec)
    ] else if chap != none [
      #text(fill: clr.green, weight: "semibold")[#c] #h(2pt) #upper(chap)
    ]
  }
  v(-6pt)
  if title != none {
    text(font: fonts.heading, weight: "semibold", size: size.title, fill: clr.green, title)
    v(-9pt)
  }
  rule()
  if center {
    // body is centered in the space below the title (no stretching)
    v(1fr)
    body
    v(1fr)
  } else {
    v(6pt)
    body
  }
}

/// Closing page: full page, no crumb, not numbered. Put it last in main.typ.
#let finale(title: [Thank you], subtitle: none, body) = page(header: none, footer: none, margin: (x: 2cm, y: 1.8cm))[
  #v(1fr)
  #text(font: fonts.heading, weight: "bold", size: 38pt, fill: clr.green, title)
  #v(-8pt)
  #rule(t: 2pt)
  #if subtitle != none {
    v(2pt)
    text(font: fonts.heading, size: 16pt, fill: clr.muted, subtitle)
  }
  #v(14pt)
  #body
  #v(1.3fr)
]

/// Contents page built from chapter / section markers.
#let contents(title: "Contents") = page(header: none)[
  #text(font: fonts.heading, weight: "bold", size: 26pt, fill: clr.green, title)
  #v(-10pt)
  #rule(t: 2pt)
  #v(8pt)
  #context {
    let items = query(<clauto-toc>)
    let c = 0
    let s = 0
    let ss = 0
    let rows = ()
    for m in items {
      let pg = m.location().page()
      if m.value.kind == "chapter" {
        c += 1
        s = 0
        ss = 0
        rows.push(block(above: 10pt, below: 4pt, breakable: false, {
          set text(font: fonts.heading, size: 13pt)
          box(width: 22pt, num-badge(c, s: 0.72))
          h(4pt)
          link(m.location(), text(weight: "semibold", fill: clr.ink, m.value.title))
          box(width: 1fr, repeat(text(fill: clr.line)[.#h(3pt)]))
          text(fill: clr.green, weight: "semibold", str(pg))
        }))
      } else if m.value.kind == "subsection" {
        ss += 1
        rows.push(block(above: 5pt, below: 5pt, {
          set text(size: 10.5pt, fill: clr.muted)
          h(54pt)
          box(width: 34pt, text(fill: clr.green)[#c.#s.#ss])
          link(m.location(), m.value.title)
          box(width: 1fr, repeat(text(fill: clr.line)[.#h(3pt)]))
          str(pg)
        }))
      } else {
        s += 1
        ss = 0
        rows.push(block(above: 7pt, below: 6pt, {
          set text(size: 12pt, fill: clr.muted)
          h(26pt)
          box(width: 28pt, text(fill: clr.green)[#c.#s])
          link(m.location(), m.value.title)
          box(width: 1fr, repeat(text(fill: clr.line)[.#h(3pt)]))
          str(pg)
        }))
      }
    }
    columns(2, gutter: 1.2cm, rows.join())
  }
]

/// Cover page.
#let cover(title: none, subtitle: none, author: none, date: none, image: none, brand: "clauto") = page(
  header: none, footer: none, margin: 0pt,
)[
  #grid(
    columns: if image != none { (1.05fr, 1fr) } else { (1fr,) },
    rows: 100%,
    block(inset: (left: 2cm, right: 1cm, y: 1.6cm), height: 100%, {
      text(font: fonts.heading, weight: "bold", size: 15pt, fill: clr.green, brand)
      v(-9pt)
      rule(w: 1.4cm, t: 3pt)
      v(1fr)
      text(font: fonts.heading, weight: "bold", size: 34pt, fill: clr.green, title)
      if subtitle != none {
        v(-10pt)
        text(font: fonts.heading, size: 17pt, fill: clr.muted, subtitle)
      }
      v(1.4fr)
      rule(t: 1pt)
      v(-4pt)
      set text(font: fonts.heading, size: 11pt, fill: clr.muted)
      grid(columns: (1fr, auto), author, date)
    }),
    ..if image != none {
      (block(fill: clr.lime-soft, width: 100%, height: 100%, inset: 1.4cm,
        align(center + horizon, image)),)
    },
  )
]

// ── document show rule ───────────────────────────────────────
#let clauto(
  title: [Title],
  subtitle: none,
  author: none,
  date: none,
  image: none,
  brand: "clauto",
  toc: true,
  body,
) = {
  set document(title: title)
  set page(
    paper: "presentation-16-9",
    margin: (x: 1.5cm, top: 1.1cm, bottom: 1.3cm),
    fill: white,
    footer: context {
      set text(font: fonts.heading, size: 8.5pt, fill: clr.muted)
      line(length: 100%, stroke: 0.5pt + clr.line)
      v(-6pt)
      grid(
        columns: (1fr, auto),
        [#text(fill: clr.green, weight: "semibold", brand) #h(4pt) · #h(4pt) #title],
        counter(page).display(),
      )
    },
  )
  set text(font: fonts.body, size: size.body, fill: clr.ink, lang: "en")
  set par(leading: 0.58em, spacing: 0.95em)

  // lists
  set list(marker: text(fill: clr.green, size: 0.8em, baseline: -0.1em)[■], indent: 2pt, body-indent: 7pt, spacing: 0.7em)
  set enum(numbering: n => text(fill: clr.green, weight: "bold", font: fonts.heading)[#n.], indent: 2pt, spacing: 0.7em)

  // emphasis
  show strong: set text(fill: clr.green-dark)
  show link: set text(fill: clr.green)

  // headings inside slides (=, ==, === are small sub-heads, never numbered)
  show heading: it => block(above: 0.9em, below: 0.55em,
    text(font: fonts.heading, weight: "semibold", size: 14.5pt, fill: clr.green, it.body))

  // code
  show raw: set text(font: fonts.mono, ligatures: false, features: (calt: 0))
  show raw.where(block: false): it => box(
    fill: clr.code-bg, stroke: 0.5pt + clr.line, radius: 2.5pt,
    inset: (x: 3pt), outset: (y: 2.5pt),
    text(size: 0.86em, it),
  )
  show raw.where(block: true): it => block(
    width: 100%, fill: clr.code-bg, stroke: 0.6pt + clr.line, radius: 4pt,
    inset: (x: 10pt, y: 9pt),
    {
      set text(size: size.code)
      set par(leading: 0.5em)
      it
    },
  )

  // tables
  set table(
    stroke: (x, y) => (
      top: if y == 0 { 1.2pt + clr.green } else if y == 1 { 0.8pt + clr.green } else { 0.5pt + clr.line },
    ),
    inset: (x: 7pt, y: 5.5pt),
    fill: (x, y) => if y == 0 { clr.lime-soft },
  )
  show table.cell.where(y: 0): set text(font: fonts.heading, weight: "semibold", size: 11.5pt, fill: clr.green-dark)
  show table: set text(size: 12pt)
  show table: it => block(stroke: (bottom: 1.2pt + clr.green), it)

  cover(title: title, subtitle: subtitle, author: author, date: date, image: image, brand: brand)
  if toc { contents() }
  body
}
