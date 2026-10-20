# clauto — Cisco Collaboration Automation Slides

Typst slide deck for the 5-day *clauto* training. 16:9, green/white minimal
design, hand-drawn Excalidraw diagrams.

---

## 1. Setup (once)

| Requirement | Check | Notes |
|---|---|---|
| Typst ≥ 0.13 | `typst --version` | `brew install typst` |
| Node.js ≥ 18 | `node -v` | only needed to render diagrams |
| Fonts: Fira Sans, Source Sans 3, JetBrains Mono | `typst fonts \| grep -E "Fira Sans\|Source Sans 3\|JetBrains"` | install system-wide |
| Excalifont / Virgil | already in `fonts/` | loaded via `--font-path fonts` |

Install the diagram renderer dependencies:

```bash
cd tools && npm install
```

---

## 2. Build

```bash
typst compile --font-path fonts main.typ          # → main.pdf
typst watch   --font-path fonts main.typ          # rebuild on every save
```

> Always pass `--font-path fonts`, otherwise diagram text falls back to a
> default font.

---

## 3. Project layout

```
clauto_training/
├── main.typ                 cover info + chapter order
├── template.typ             design system (colors, fonts, all functions)
├── chapters/
│   └── python-fundamentals.typ   one file per chapter
├── diagrams/
│   ├── variables-objects.excalidraw   source (edit this)
│   └── variables-objects.svg          generated (never edit)
├── fonts/                   Excalifont-Regular.ttf, Virgil-Regular.ttf
├── tools/
│   └── excalidraw2svg.mjs   .excalidraw → .svg renderer
├── LAB.md                   naming conventions for all examples
└── README.md
```

---

## 4. `main.typ` — cover and chapter order

```typst
#import "template.typ": *

#show: clauto.with(
  title:    [Cisco Collaboration Automation],
  subtitle: [Python fundamentals for voice & collaboration engineers],
  author:   [Instructor Name],
  date:     [2026],
  image:    image("diagrams/cover.svg", width: 100%),   // or none
  // brand: "clauto",   // small wordmark top-left + footer
  // toc:   true,       // contents page after the cover
)

#include "chapters/python-fundamentals.typ"
#include "chapters/strings.typ"
#include "chapters/axl-basics.typ"
```

- Cover and contents page are generated automatically.
- **Chapter numbers come from the `#include` order.** Never write numbers in
  chapter files. Insert or move an `#include` line and every number, the
  contents page and the slide crumbs update by themselves.
- Splitting by day is up to you: just order the includes (you can add a
  comment like `// ── Day 2 ──`).

---

## 5. Writing a chapter

Create `chapters/<name>.typ`:

```typst
#import "../template.typ": *

#chapter([Strings], intro: [
  One short paragraph: what this chapter is about and why a collab
  engineer cares.
])

#section[String Basics]

#slide(title: [What is a string?])[
  #cols(ratio: (2, 3))[
    // LEFT: code or diagram
    ```python
    dn = "1001"
    ```
  ][
    // RIGHT: explanation text
    A string is an immutable sequence of characters…
  ]
]

#slide(title: [Indexing and slicing])[ … ]   // still 1.1

#section[String Methods]                      // → 1.2

#slide(title: [Common methods])[ … ]
```

### Structure rules

| Function | What it does | Shown in |
|---|---|---|
| `#chapter(title, intro: [...])` | full-page chapter opener with number badge, intro and list of its sections | Contents, crumb |
| `#section[Title]` | marks a sub-topic; attaches to the **next** slide, produces nothing visible by itself | Contents (`1.2`), crumb |
| `#subsection[Title]` | marks a sub-sub-topic (`1.3.2`); attaches to the **next** slide. Counting restarts at every new section | Contents (indented), crumb |
| `#slide(title: [...])[body]` | one content slide | — |

- The small grey line above every slide title (the *crumb*) shows the
  current section, e.g. `1.2 STRING METHODS`, or `1.3.2 DATA TYPES · FLOAT`
  inside a subsection.
- The chapter opener lists only sections. Subsections appear in Contents.
- Slide titles are **not** listed in the contents. Only chapters and sections are.
- `title:` is optional: `#slide[...]` gives a slide without a title.
- If the content is too long, Typst moves the rest to a new page without the
  header. That means the slide is too full: shorten it or split it into two slides.

---

## 6. Slide body building blocks

### 6.1 Two columns: `cols`

```typst
#cols(ratio: (1, 1))[ left ][ right ]   // 1/2 – 1/2
#cols(ratio: (2, 3))[ left ][ right ]   // 2/5 – 3/5
#cols(ratio: (3, 2))[ left ][ right ]   // 3/5 – 2/5
```

**House rule: code and diagrams go LEFT, explanation text goes RIGHT.**

Pick the ratio from the longest code line (code size 10.5 pt):

| Ratio | Left column fits | Use when |
|---|---|---|
| `(2, 3)` | ~35 characters | short code, more text |
| `(1, 1)` | ~45 characters | balanced |
| `(3, 2)` | ~55 characters | long code lines or a wide diagram |
| no `cols` | ~95 characters | full-width code (rare) |

Vertically a slide holds about **16 lines of code** below the title. Use
fewer lines if there is a diagram above the code.

Optional arguments: `gutter: 0.9cm`, `align: top` (or `horizon` to center vertically).

### 6.2 Text

```typst
Normal paragraph. *bold = green emphasis*, _italic_, `inline code`.

- bullet (green square marker)
- another bullet

+ numbered step
+ next step

=== Small sub-heading   // green, inside a slide, not numbered
```

Keep each slide to 2–3 short paragraphs **or** 3–5 bullets: between a book
and a slide.

### 6.3 Code blocks

````typst
```python
phone = {"name": "SEP0A1B2C3D4E5F", "lines": ["1001"]}
print(phone["name"])
```
````

- Always write the language (`python`, `xml`, `json`, `bash`) to get syntax highlighting.
- Keep lines within the limit in the table above; long lines wrap and are hard to read.
- Show output as a comment: `print(dn)   # 1001`.

### 6.4 Tables

```typst
#table(
  columns: (auto, auto, 1fr),
  [Method], [Example], [Result],          // first row = header (green)
  [`upper()`], [`"sep".upper()`], [`"SEP"`],
  [`strip()`], [`" 1001 ".strip()`], [`"1001"`],
)
```

Header styling and lines are automatic. `1fr` = the column takes the remaining width.

For method overviews use the compact two-column helper (smaller text,
header `Method | What it does`):

```typst
#methods(
  [`strip()`], [remove spaces at both ends],
  [`upper()`], [to upper case],
)
```

### 6.4b Vertical centering

Slide bodies are centered vertically below the title, and `cols` centers
both columns against each other (`align: horizon`). Nothing is stretched.
Use `#slide(title: [...], center: false)[...]` to start at the top, or
`#cols(align: top)[...][...]` to top-align the columns.

### 6.5 Callout boxes

```typst
#collab[ Cisco example: CUCM, AXL, Webex… ]     // green: "IN THE COLLAB WORLD"
#tip[ Useful shortcut… ]                        // green: "TIP"
#warn[ Be careful with… ]                       // amber: "WATCH OUT"
#pitfall[ Typical beginner error… ]             // red:   "COMMON MISTAKE"

#collab(title: "AXL example")[ … ]              // custom label
```

Every topic should have at least one `#collab` box or one Cisco example in the code.

### 6.6 Handwritten note

```typst
#hand[this is the key idea!]                     // green, Excalifont
#hand(fill: clr.red, size: 18pt)[careful]
```

### 6.6b Labels (pills)

```typst
#immutable                                       // green  IMMUTABLE label
#mutable                                         // amber  MUTABLE label
#pill[new in 3.12]                               // any short label
```

Put a label on its own line (end it with `\`) so it doesn't push the
paragraph's line spacing apart.

### 6.7 Diagrams

```typst
#diagram("variables-objects")                    // diagrams/variables-objects.svg
#diagram("if-flow", width: 70%)
#diagram("if-flow", width: 70%, caption: "if / else flow")
```

Give only the name, without folder or extension. See section 7 for how to draw them.

### 6.7b Closing page

```typst
#finale(title: [Thank you], subtitle: [Questions?])[ … ]   // own file, included last
```

### 6.8 Spacing

`#v(6pt)` adds vertical space. `#v(1fr)` pushes what follows to the bottom.

---

## 7. Diagrams with Excalidraw

### 7.1 Workflow

```
draw in Excalidraw  →  save diagrams/<name>.excalidraw  →  npm run diagrams  →  #diagram("<name>")
```

1. **Open the editor**, either of:
   - **excalidraw.com** in the browser. Open an existing file with
     *Menu → Open*, save with *Menu → Save to… → Save to disk*.
   - **VS Code**: install the *Excalidraw* extension (`pomdtr.excalidraw-editor`).
     It opens `.excalidraw` files directly and saves with ⌘S. This is the easiest option.
2. **Save** as `diagrams/<name>.excalidraw`. Use kebab-case names
   (`axl-request-flow`, `string-slicing`).
3. **Render** all diagrams to SVG:

   ```bash
   cd tools && npm run diagrams
   ```

   or a single one: `node tools/excalidraw2svg.mjs diagrams/<name>.excalidraw`
4. **Use** it in a slide: `#diagram("<name>")`. With `typst watch` running,
   the PDF updates by itself.

> Do **not** use Excalidraw's own *Export → SVG*. It embeds fonts in a way
> Typst can't render. Always keep the `.excalidraw` file and render with
> `npm run diagrams`.

### 7.2 Drawing style guide

Keep diagrams consistent across the deck:

| Setting | Use |
|---|---|
| Font | **Excalifont** (default "hand-drawn" font). Size S/M (16–24) |
| Sloppiness | *Artist* (middle), the default |
| Stroke width | *Bold* (2) for shapes and arrows |
| Fill | *Hachure* (diagonal lines) for boxes, *Solid* only for small accents |
| Corners | Round for data/object boxes, sharp for process steps |
| Background | none (transparent), since the slide is white |

**Color palette** (Excalidraw's built-in swatches):

| Role | Stroke / text | Fill |
|---|---|---|
| Normal shapes, text | black `#1e1e1e` | — |
| True / OK / labels, types | green `#2f9e44` | light green `#b2f2bb` |
| False / errors / warnings | red `#e03131` | light red `#ffc9c9` |
| Notes, secondary labels | grey `#868e96` | — |
| Python objects / data | — | yellow `#ffec99`, blue `#a5d8ff`, lime `#d8f5a2` |
| Start / End circles | black | dark grey `#495057` hachure |

Tips:
- Make diagrams **wider than tall** (around 600×350 px). Slides are 16:9.
- Use the same names in diagrams as in the code (`dn`, `phone`, `SEP0A1B2C3D4E5F`).
- Write red handwritten notes with a curved arrow to the important point,
  like the reference image.
- Don't fill the canvas edge to edge: the renderer crops to the content
  plus a small margin.

### 7.3 What the renderer supports

| Supported | Not supported |
|---|---|
| rectangle (sharp / round), diamond, ellipse | embedded images |
| arrow & line (straight, curved, elbow), arrowheads: arrow, triangle | frames, embeds, iframes |
| text, also text inside shapes | Excalidraw "libraries" with images |
| freedraw (pen) | links |
| fill: hachure, cross-hatch, solid · stroke: solid, dashed, dotted | |
| rotation, opacity, groups | |

Fonts in Excalidraw map to: *Excalifont / Virgil* → handwritten,
*Nunito / Helvetica* → Fira Sans, *Comic Shanns / Cascadia* → JetBrains Mono.


### 7.4 Drawing diagrams from code (exlib)

Instead of drawing by hand you can generate a `.excalidraw` file with a
short script; the result opens and edits in Excalidraw like any other.

```js
// tools/diagram-src/hello-flow.mjs
import { C, text, box, arrow, save } from '../exlib.mjs';
save('hello-flow', [
  box(0, 20, 150, 56, 'script', { fill: C.fillYellow, round: true }),
  arrow([[156, 48], [256, 48]], { stroke: C.green }),
  box(262, 20, 170, 56, 'server', { fill: C.fillBlue, round: true }),
]);
```

```bash
node tools/diagram-src/hello-flow.mjs && cd tools && npm run diagrams
```

Helpers: `box`, `text`, `arrow`, `rect`, `ellipse`, `diamond`,
`measure(text, size)` (size boxes from their label), palette `C`.

---

## 8. Content conventions

- **Language:** English.
- **Scope per topic:** explanation + 1 Cisco voice/collab example; 1–3 slides.
- **Names, never IPs.** All hostnames, DNs, users and devices come from
  [LAB.md](LAB.md) (e.g. `cucm-pub.clauto.lab`, DN `1001`, `alice.smith`,
  `SEP0A1B2C3D4E5F`). Add new names there before using them.
- **Code left, text right** in two-column slides.
- **Diagrams** on most slides where they help understanding.

---

## 9. Customizing the design

Everything lives at the top of `template.typ`:

```typst
#let clr = (green: rgb("#4E7D23"), lime: rgb("#C3E38A"), …)   // colors
#let fonts = (heading: "Fira Sans", body: "Source Sans 3", mono: "JetBrains Mono", hand: "Excalifont")
#let size = (body: 14pt, code: 10.5pt, title: 21pt, crumb: 9pt)
```

You can use the colors in slides too: `#text(fill: clr.red)[…]`.

---

## 10. Troubleshooting

| Problem | Fix |
|---|---|
| Diagram text looks like a normal font | compile with `--font-path fonts` |
| `file not found … diagrams/x.svg` | run `cd tools && npm run diagrams`; check the name |
| Slide spills onto an extra page without a title | content too long: shorten, reduce `width:` of the diagram, or split the slide |
| Chapter number wrong | check the `#include` order in `main.typ` |
| A section doesn't appear in Contents | `#section[...]` must be followed by a `#slide` |
| Code wraps | pick a wider left column (see 6.1) or shorten the line |
| `unknown font family` warning | install Fira Sans / Source Sans 3 / JetBrains Mono system-wide |
| `! Excalifont has no glyph for →` while rendering | Excalifont lacks that symbol: use `->`, `=` or words instead |
