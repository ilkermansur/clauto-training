// ─────────────────────────────────────────────────────────────
//  clauto — kitap şablonu (A4, Türkçe)
//  Derleme:  doc-format/build.sh
//  Slayt şablonuyla aynı görsel kimlik: yeşil / beyaz, Excalidraw
//  diyagramları. Diyagramlar ../diagrams klasöründen çekilir.
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
  blue:       rgb("#2F6690"),
  blue-soft:  rgb("#EDF4F9"),
)

#let fonts = (
  heading: "Fira Sans",
  body:    "Source Sans 3",
  mono:    "JetBrains Mono",
  hand:    "Excalifont",
)

#let size = (
  body:  10.5pt,
  code:  8.6pt,
  small: 9.5pt,
)

// ── iç durum ─────────────────────────────────────────────────
#let _main = state("clauto-main-matter", false)

// ── küçük yapı taşları ───────────────────────────────────────
#let num-badge(n, s: 1) = box(
  fill: clr.green, radius: 4pt * s,
  inset: (x: 7pt * s, y: 5pt * s),
  baseline: 25%,
  text(font: fonts.heading, weight: "bold", fill: white, size: 15pt * s, str(n)),
)

#let rule(w: 100%, t: 1.4pt) = line(length: w, stroke: t + clr.lime)

/// El yazısı not (diyagram stiliyle uyumlu; Türkçe harf içermeyen kısa notlar için).
#let hand(body, fill: clr.green, size: 15pt) = text(font: fonts.hand, fill: fill, size: size, body)

/// Küçük etiket, ör. #pill[immutable]
#let pill(body, fill: clr.lime-soft, accent: clr.green) = box(
  fill: fill, stroke: 0.7pt + accent, radius: 7pt,
  inset: (x: 6pt, y: 2.5pt), baseline: 18%,
  text(font: fonts.heading, size: 7.5pt, weight: "semibold", fill: accent, tracking: 0.06em, upper(body)),
)
#let immutable = pill[immutable]
#let mutable = pill(fill: clr.amber-soft, accent: clr.amber)[mutable]

/// Kompakt iki sütunlu "Metot | Ne yapar" tablosu.
#let methods(header: ([Metot], [Ne yapar]), ..rows) = {
  show table: set text(size: size.small)
  block(breakable: false, table(columns: (auto, 1fr), inset: (x: 6pt, y: 4.5pt), ..header, ..rows))
}

/// İki sütunlu yerleşim (kitapta nadiren: yan yana küçük kod + tablo).
#let cols(left, right, ratio: (1, 1), gutter: 0.7cm, align: horizon) = grid(
  columns: (ratio.at(0) * 1fr, ratio.at(1) * 1fr),
  column-gutter: gutter,
  std.align(align, left), std.align(align, right),
)

/// Excalidraw diyagramı: diagrams/<ad>.svg → numaralı Şekil.
#let diagram(name, width: 80%, caption: none) = figure(
  block(
    width: 100%, stroke: 0.6pt + clr.line, radius: 4pt,
    inset: (x: 8pt, y: 10pt),
    align(center, image("/diagrams/" + name + ".svg", width: width)),
  ),
  caption: caption,
)

// ── bilgi kutuları ───────────────────────────────────────────
#let _callout(label, body, fill, accent, icon) = block(
  width: 100%, fill: fill, radius: (right: 4pt),
  stroke: (left: 3pt + accent),
  inset: (x: 11pt, y: 9pt),
  breakable: false,
  above: 1.1em, below: 1.1em,
  {
    text(font: fonts.heading, weight: "semibold", size: 8.5pt, fill: accent, tracking: 0.05em)[#icon #upper(label)]
    v(-3pt)
    set text(size: 10pt)
    set par(justify: false)
    body
  },
)

/// Cisco Collaboration örneği.
#let collab(body, title: "Collab dünyasında") = _callout(title, body, clr.lime-soft, clr.green, sym.triangle.r.filled)
#let tip(body, title: "İpucu") = _callout(title, body, clr.lime-soft, clr.green, sym.star.filled)
#let warn(body, title: "Dikkat") = _callout(title, body, clr.amber-soft, clr.amber, "!")
#let pitfall(body, title: "Sık yapılan hata") = _callout(title, body, clr.red-soft, clr.red, sym.times)
/// Ses/telefoni dünyasından benzetme.
#let analogy(body, title: "Benzetme") = _callout(title, body, clr.blue-soft, clr.blue, sym.approx)

/// Bölüm sonu özeti.
#let recap(body, title: "Özetle") = block(
  width: 100%, fill: clr.lime-soft, radius: 4pt, breakable: false,
  stroke: 0.8pt + clr.lime, inset: (x: 13pt, y: 11pt), above: 1.4em, below: 1.2em,
  {
    text(font: fonts.heading, weight: "bold", size: 11pt, fill: clr.green, title)
    v(-2pt)
    set text(size: 10pt)
    set par(justify: false)
    body
  },
)

/// Kendin dene alıştırması.
#let exercise(body, title: "Kendin dene") = block(
  width: 100%, radius: 4pt, breakable: false,
  stroke: (dash: "dashed", paint: clr.green, thickness: 1pt),
  inset: (x: 13pt, y: 11pt), above: 1.2em, below: 1.2em,
  {
    text(font: fonts.heading, weight: "bold", size: 10.5pt, fill: clr.green)[✎ #title]
    v(-2pt)
    set text(size: 10pt)
    set par(justify: false)
    body
  },
)

/// Kodu satır satır açıklama: walk(("1", [açıklama]), ("2–3", [açıklama]))
#let walk(..items) = block(above: 0.9em, below: 1em, {
  text(font: fonts.heading, weight: "semibold", size: 9pt, fill: clr.muted, tracking: 0.05em)[KODU SATIR SATIR OKUYALIM]
  v(-2pt)
  set text(size: 10pt)
  set par(justify: false)
  grid(
    columns: (auto, 1fr), column-gutter: 9pt, row-gutter: 7pt,
    ..items.pos().map(it => (
      box(
        fill: clr.green, radius: 3pt, inset: (x: 5pt, y: 2.5pt), baseline: 0pt,
        text(font: fonts.mono, size: 8pt, weight: "bold", fill: white, it.at(0)),
      ),
      it.at(1),
    )).flatten(),
  )
})

// ── yapı ─────────────────────────────────────────────────────

/// Bölüm açılışı (chapter). Numara #include sırasından gelir.
/// goals: bu bölümde öğrenilecekler (madde listesi).
#let chapter(title, intro: none, goals: none) = {
  pagebreak(weak: true)
  context { if not _main.get() { counter(page).update(1) } }
  _main.update(true)
  counter(figure.where(kind: image)).update(0)
  heading(level: 1, title)
  if intro != none {
    set par(justify: true, leading: 0.7em)
    block(width: 92%, text(size: 12pt, intro))
  }
  if goals != none {
    v(6pt)
    block(
      width: 100%, fill: clr.lime-soft, radius: 4pt, inset: (x: 14pt, y: 12pt),
      breakable: false,
      {
        text(font: fonts.heading, weight: "semibold", size: 10pt, fill: clr.green, tracking: 0.05em)[BU BÖLÜMDE ÖĞRENECEKLERİNİZ]
        v(-2pt)
        set text(size: 10.5pt)
        goals
      },
    )
  }
  pagebreak(weak: true)
}

/// Section (1.2) — slayt şablonundaki #section ile aynı numara.
#let section(title) = heading(level: 2, title)

/// Subsection (1.3.2).
#let subsection(title) = heading(level: 3, title)

/// Konu başlığı: slayt başlığının kitaptaki karşılığı (numarasız, içindekilerde yok).
#let topic(title) = heading(level: 4, numbering: none, outlined: false, title)

/// Küçük ara başlık (yeşil, numarasız).
#let subhead(body) = block(above: 1em, below: 0.5em, sticky: true,
  text(font: fonts.heading, weight: "semibold", size: 11pt, fill: clr.green, body))

/// Kapanış sayfası.
#let finale(title: [Teşekkürler], subtitle: none, body) = page(header: none, footer: none, margin: (x: 2.3cm, y: 2.4cm))[
  #v(1fr)
  #text(font: fonts.heading, weight: "bold", size: 30pt, fill: clr.green, title)
  #v(-8pt)
  #rule(t: 2pt)
  #if subtitle != none {
    v(2pt)
    text(font: fonts.heading, size: 13pt, fill: clr.muted, subtitle)
  }
  #v(14pt)
  #body
  #v(1.3fr)
]

/// Ön söz gibi numarasız, içindekilerde görünmeyen başlıklar.
#let frontmatter(title, body) = {
  pagebreak(weak: true)
  heading(level: 1, numbering: none, outlined: false, title)
  body
}

/// Kapak sayfası.
#let cover(title: none, subtitle: none, tagline: none, author: none, date: none, image: none, brand: "clauto") = page(
  header: none, footer: none, margin: 0pt,
)[
  #block(width: 100%, height: 100%, {
    block(width: 100%, fill: clr.lime-soft, inset: (x: 2.3cm, top: 2.2cm, bottom: 1.2cm), {
      text(font: fonts.heading, weight: "bold", size: 16pt, fill: clr.green, brand)
      v(-9pt)
      rule(w: 1.6cm, t: 3pt)
      v(1.2cm)
      if image != none { align(center, image) }
    })
    block(width: 100%, inset: (x: 2.3cm, top: 1.2cm), {
      if tagline != none {
        text(font: fonts.heading, weight: "semibold", size: 10.5pt, fill: clr.muted, tracking: 0.12em, upper(tagline))
        v(-4pt)
      }
      text(font: fonts.heading, weight: "bold", size: 34pt, fill: clr.green, hyphenate: false, title)
      if subtitle != none {
        v(-12pt)
        text(font: fonts.heading, size: 15pt, fill: clr.muted, subtitle)
      }
    })
    place(bottom, block(width: 100%, inset: (x: 2.3cm, bottom: 1.8cm), {
      rule(t: 1pt)
      v(-4pt)
      set text(font: fonts.heading, size: 11pt, fill: clr.muted)
      grid(columns: (1fr, auto), author, date)
    }))
  })
]

// ── belge kuralı ─────────────────────────────────────────────
#let kitap(
  title: [Başlık],
  subtitle: none,
  tagline: none,
  author: none,
  date: none,
  image: none,
  brand: "clauto",
  body,
) = {
  set document(title: title, author: "Ilker Mansur")
  set page(
    paper: "a4",
    margin: (x: 2.3cm, top: 2.5cm, bottom: 2.3cm),
    numbering: "1",
    header: context {
      let pg = here().page()
      let opener = query(heading.where(level: 1)).any(h => h.location().page() == pg)
      if _main.get() and not opener {
        let chap = query(heading.where(level: 1)).filter(h => h.location().page() <= pg)
        let cn = if chap.len() > 0 { counter(heading).at(chap.last().location()).first() } else { 0 }
        let secs = query(heading.where(level: 2)).filter(h => h.location().page() <= pg and counter(heading).at(h.location()).first() == cn)
        set text(font: fonts.heading, size: 8.5pt, fill: clr.muted, tracking: 0.04em)
        grid(
          columns: (1fr, auto),
          if chap.len() > 0 { upper(chap.last().body) },
          if secs.len() > 0 { secs.last().body },
        )
        v(-6pt)
        line(length: 100%, stroke: 0.5pt + clr.line)
      }
    },
    footer: context {
      set text(font: fonts.heading, size: 8.5pt, fill: clr.muted)
      let n = counter(page).get().first()
      if _main.get() {
        grid(
          columns: (1fr, auto),
          [#text(fill: clr.green, weight: "semibold", brand) #h(4pt) · #h(4pt) #title],
          str(n),
        )
      } else if n > 1 {
        align(center, numbering("i", n))
      }
    },
  )
  set text(font: fonts.body, size: size.body, fill: clr.ink, lang: "tr")
  show heading: set text(hyphenate: false)
  set par(leading: 0.66em, spacing: 0.95em, justify: true)

  // listeler
  set list(marker: text(fill: clr.green, size: 0.8em, baseline: -0.1em)[■], indent: 4pt, body-indent: 7pt, spacing: 0.65em)
  set enum(numbering: n => text(fill: clr.green, weight: "bold", font: fonts.heading)[#n.], indent: 4pt, spacing: 0.65em)

  // vurgu
  show strong: set text(fill: clr.green-dark)
  show link: set text(fill: clr.green)

  // başlıklar
  set heading(numbering: "1.1.1")
  show heading.where(level: 1): it => {
    if it.numbering == none {
      block(above: 0pt, below: 1.2em, {
        text(font: fonts.heading, weight: "bold", size: 24pt, fill: clr.green, it.body)
        v(-8pt)
        rule(t: 2pt)
      })
    } else {
      let n = counter(heading).at(it.location()).first()
      let loc = it.location()
      let secs = query(heading.where(level: 2).after(loc)).filter(h => counter(heading).at(h.location()).first() == n)
      v(2.2cm)
      grid(
        columns: (auto, 1fr), column-gutter: 14pt, align: horizon,
        num-badge(n, s: 2.3),
        text(font: fonts.heading, weight: "bold", size: 30pt, fill: clr.green, it.body),
      )
      v(2pt)
      rule(t: 2pt)
      v(8pt)
      if secs.len() > 0 {
        set text(font: fonts.heading, size: 10.5pt, fill: clr.muted)
        grid(
          columns: (auto, 1fr), column-gutter: 8pt, row-gutter: 6pt,
          ..secs.enumerate().map(((i, h)) => (
            text(fill: clr.green, weight: "semibold")[#n.#(i + 1)], h.body,
          )).flatten(),
        )
        v(10pt)
      }
    }
  }
  show heading.where(level: 2): it => block(above: 2em, below: 1em, sticky: true, {
    let nums = counter(heading).at(it.location())
    text(font: fonts.heading, weight: "bold", size: 19pt, fill: clr.green)[
      #text(fill: clr.green)[#numbering("1.1", ..nums.slice(0, 2))] #h(6pt) #it.body
    ]
    v(-9pt)
    rule()
  })
  show heading.where(level: 3): it => block(above: 1.7em, below: 0.8em, sticky: true, {
    let nums = counter(heading).at(it.location())
    text(font: fonts.heading, weight: "semibold", size: 14.5pt, fill: clr.green-dark)[
      #numbering("1.1.1", ..nums.slice(0, 3)) #h(5pt) #it.body
    ]
  })
  show heading.where(level: 4): it => block(above: 1.4em, below: 0.7em, sticky: true,
    text(font: fonts.heading, weight: "semibold", size: 12pt, fill: clr.ink, {
      box(width: 3pt, height: 0.85em, fill: clr.lime, baseline: 0.1em)
      h(6pt)
      it.body
    }))

  // şekiller
  set figure(numbering: (..n) => numbering("1.1", counter(heading).get().first(), ..n))
  show figure: set block(above: 1.3em, below: 1.3em)
  show figure.caption: it => block(above: 0.6em, text(font: fonts.heading, size: 8.5pt, fill: clr.muted,
    [*#it.supplement #context it.counter.display(it.numbering).* #it.body]))

  // kod
  show raw: set text(font: fonts.mono, ligatures: false, features: (calt: 0))
  show raw.where(block: false): it => box(
    fill: clr.code-bg, stroke: 0.5pt + clr.line, radius: 2.5pt,
    inset: (x: 2.5pt), outset: (y: 2.5pt),
    text(size: 0.88em, it),
  )
  show raw.where(block: true): it => {
    let numbered = it.lang in ("python", "xml", "json")
    let is-out = it.lang == "output"
    show raw.line: l => {
      if numbered {
        box(width: 1.5em, align(right, text(fill: clr.muted.lighten(25%), size: 0.85em, str(l.number))))
        h(0.9em)
      }
      l.body
    }
    block(
      width: 100%, fill: if is-out { white } else { clr.code-bg },
      stroke: if is-out { (left: 2.5pt + clr.lime, rest: 0.6pt + clr.line) } else { 0.6pt + clr.line },
      radius: 4pt, inset: (x: 10pt, y: 8pt),
      breakable: it.lines.len() > 22,
      above: 1em, below: 1em,
      {
        set text(size: size.code)
        set par(leading: 0.5em, justify: false)
        if is-out {
          text(font: fonts.heading, size: 7pt, weight: "semibold", fill: clr.green, tracking: 0.08em)[ÇIKTI]
          v(-2pt)
        }
        it
      },
    )
  }

  // tablolar
  set table(
    stroke: (x, y) => (
      top: if y == 0 { 1.2pt + clr.green } else if y == 1 { 0.8pt + clr.green } else { 0.5pt + clr.line },
    ),
    inset: (x: 7pt, y: 5pt),
    fill: (x, y) => if y == 0 { clr.lime-soft },
  )
  show table.cell.where(y: 0): set text(font: fonts.heading, weight: "semibold", size: 9.5pt, fill: clr.green-dark)
  show table: set text(size: size.small)
  show table: set par(justify: false)
  show table: it => block(stroke: (bottom: 1.2pt + clr.green), above: 1em, below: 1em, it)

  // içindekiler
  show outline.entry.where(level: 1): it => {
    v(9pt, weak: true)
    set text(font: fonts.heading, weight: "semibold", size: 12pt)
    it
  }
  show outline.entry.where(level: 2): set text(font: fonts.heading, size: 10.5pt)
  show outline.entry.where(level: 3): set text(font: fonts.heading, size: 9.5pt, fill: clr.muted)

  cover(title: title, subtitle: subtitle, tagline: tagline, author: author, date: date, image: image, brand: brand)
  page(header: none)[
    #heading(level: 1, numbering: none, outlined: false)[İçindekiler]
    #v(4pt)
    #outline(title: none, depth: 3, indent: 1.4em)
  ]
  body
}
