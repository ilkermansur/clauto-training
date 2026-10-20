#import "../template.typ": *

#chapter([Python Fundamentals], intro: [
  The core language you need before talking to CUCM and Webex: data types,
  control flow, functions and files. Every example comes from the
  collaboration world, so the syntax and the use case are learned together.
])

#section[Why Python?]

#slide(title: [Python for collaboration engineers])[
  #cols(ratio: (1, 1), align: horizon)[
    #diagram("python-collab-hub", width: 100%)
  ][
    *Python* is a high-level, general-purpose language with a readable,
    almost English-like syntax. It is interpreted and dynamically typed:
    write a few lines, run them, see the result. No compile step, no
    boilerplate.

    === Why it matters in Collaboration
    - *Scale:* add 500 users and phones with one loop instead of 500 GUI forms.
    - *Consistency:* the same partition, CSS and device pool every time,
      with no typos.
    - *Visibility:* registration status, inventory and CDRs in one report,
      in seconds.
    - *Integration:* one language speaks AXL, RIS, CUPI and the Webex REST API.

    #collab[
      Cisco DevNet samples for AXL and Webex are mostly written in Python,
      so you can reuse them from day one.
    ]
  ]
]

#section[Variables and Objects]

#slide(title: [Variables are labels, not boxes])[
  #cols(ratio: (3, 2))[
    #diagram("variables-labels", width: 82%)
    #v(-2pt)
    ```python
    dn = "1001"
    backup = dn           # second label, same box
    id(dn), id(backup)    # (4372019504, 4372019504)
    dn is backup          # True

    dn = "1002"           # dn moves to a new box
    backup                # '1001'
    ```
  ][
    Think of an *object* as a box in memory that holds a value and its
    type. A *variable* is not the box. It is a *label* tied to a box.
    Python has no explicit pointers: every name already points to an object.

    `=` never copies a value. It ties a label to a box. `backup = dn` gives
    the same box a second label. `dn = "1002"` unties `dn` and ties it to a
    new box. The old box is untouched.

    `id(x)` returns the box's identity: a unique number for the object's
    lifetime (its memory address in CPython). `a is b` compares identity,
    `a == b` compares values.

    #collab[
      `new = phone` on an AXL phone `dict` gives a second label, not a copy.
      Changing `new["description"]` changes `phone` too. Use `phone.copy()`.
    ]
  ]
]

#section[Data Types]

#slide(title: [Why do we need data types?])[
  #cols(ratio: (1, 1))[
    #diagram("why-types", width: 90%)
    #v(-2pt)
    ```python
    "1001" + "1"     # '10011'
    1001 + 1         # 1002
    "1001" + 1       # TypeError: can only
                     # concatenate str to str
    int("0012")      # 12  ← leading zeros lost
    ```
  ][
    Memory only holds bytes. On its own, `1001` could be a number, a
    directory number or four characters. A *data type* gives raw data its
    meaning and answers three questions:

    + *What is it?* Text, a whole number, a yes/no flag, a collection.
    + *What can I do with it?* Add numbers, join text, loop over a list.
    + *How is it shown and stored?* `"0012"` keeps its zeros, `12` does not.

    Python is *strongly typed*: it never guesses. `"1001" + 1` raises a
    `TypeError` instead of silently picking a meaning, so the bug shows
    up early, not in production.

    #collab[
      A DN looks like a number but is a `str`: `0012`, `+905551112233` and
      `\+90XXX` all break as `int`. Use `int` only for what you count or
      compare: ring count, max calls, timeouts.
    ]
  ]
]

#slide(title: [Built-in data types])[
  #cols(ratio: (1, 1), align: horizon)[
    #diagram("data-types-map", width: 100%)
  ][
    #show table: set text(size: 10.5pt)
    #table(
      columns: (auto, auto, 1fr),
      [Type], [Example], [Collab use],
      [`int`],   [`4`],                    [ring count, max calls],
      [`float`], [`0.25`],                 [packet loss ratio],
      [`str`],   [`"1001"`],               [DN, device name, MAC],
      [`bool`],  [`True`],                 [phone registered?],
      [`list`],  [`["1001", "1002"]`],     [lines on a phone],
      [`tuple`], [`("cucm-pub", 8443)`],   [host + port pair],
      [`range`], [`range(1001, 1100)`],    [generate a DN block],
      [`dict`],  [`{"dn": "1001"}`],       [one AXL / REST record],
      [`set`],   [`{"PT_Internal"}`],      [unique partitions],
      [`bytes`], [`b"INVITE sip:..."`],    [raw SIP message],
      [`None`],  [`None`],                 [empty field in a reply],
    )
  ]
]

#slide(title: [Mutable vs immutable])[
  #cols(ratio: (1, 1))[
    #diagram("mutability", width: 74%)
    #v(-2pt)
    ```python
    dn = "1001"
    before = id(dn)
    dn += "0"
    id(dn) == before       # False → new object

    lines = ["1001"]
    before = id(lines)
    lines.append("1002")
    id(lines) == before    # True → same object
    ```
  ][
    #immutable \
    The value can never change after the object is
    created. Every "change" builds a *new* object and moves the label:
    `int`, `float`, `str`, `bool`, `tuple`, `range`, `bytes`, `None`.

    #mutable \
    The object is changed *in place*. The `id` stays the
    same: `list`, `dict`, `set`, `bytearray`.

    Why it matters:
    - Two labels on a mutable box both see every change.
    - Only immutable values can be `dict` keys or `set` items.

    #collab[
      Reusing one phone template `dict` in a loop and editing it changes
      every phone built from it. Build a fresh `dict` per phone.
    ]
  ]
]

#subsection[int]

#slide(title: [int · whole numbers])[
  #cols(ratio: (1, 1))[
    ```python
    max_calls = 4
    max_calls + 1          # 5
    7 // 2, 7 % 2          # (3, 1)  floor div, remainder
    7 / 2                  # 3.5  ← "/" always gives float
    2 ** 100               # no overflow, any size
    1_000_000              # underscores for readability

    int("8443")            # 8443
    int("1001A")           # ValueError
    ```
  ][
    #immutable

    `int` holds whole numbers, positive or negative, with no size limit.
    Use it for anything you *count* or *calculate*: calls, ports, timers,
    retries.

    Arithmetic works as expected (`+ - * **`). Note that `/` always returns
    a `float`, while `//` keeps an `int`. `int()` converts text to a number
    and raises `ValueError` if the text is not a valid number.

    #collab[
      AXL returns every value as text: `"maxNumCalls": "4"`. Convert before
      comparing: `"10" > "9"` is `False` as strings, but
      `int("10") > int("9")` is `True`.
    ]
  ]
]

#subsection[float]

#slide(title: [float · decimal numbers])[
  #cols(ratio: (1, 1))[
    ```python
    lost, received = 12, 4800
    loss = lost / received   # 0.0025
    f"{loss:.2%}"            # '0.25%'

    mos = float("4.1")       # text → float
    mos >= 4.0               # True

    0.1 + 0.2                # 0.30000000000000004
    round(0.1 + 0.2, 2)      # 0.3
    int(4.9)                 # 4  (cuts, no rounding)
    ```
  ][
    #immutable

    `float` holds numbers with a decimal point. Any division with `/`
    produces a float, even `4 / 2` gives `2.0`.

    Floats are stored in binary, so some decimals cannot be stored exactly:
    `0.1 + 0.2` is not exactly `0.3`. Round when you *display* a value, and
    never compare two floats with `==`.

    `int(x)` drops the decimal part. It does not round.

    #collab[
      CMR (call management record) data gives packets lost and received.
      The loss ratio, jitter and MOS scores you calculate from them are
      `float`s.
    ]
  ]
]

#slide(title: [Working with numbers])[
  #cols(ratio: (1, 1))[
    ```python
    durations = [125, 340, 62, 410]  # seconds
    sum(durations) / len(durations)  # 234.25
    min(durations), max(durations)   # (62, 410)
    divmod(3725, 60)       # (62, 5) → 62 min 5 s
    round(234.567, 1)      # 234.6
    round(2.5), round(3.5) # (2, 4) to even!
    abs(-3)                # 3
    int("1F", 16), hex(31) # (31, '0x1f')
    (4.0).is_integer()     # True
    f"{1234567:,}"         # '1,234,567'
    f"{0.0025:.2%}"        # '0.25%'
    ```
  ][
    Numbers have few methods of their own. Most of the work is done by
    *built-in functions* and *f-string formats*:

    #methods(
      [`sum` `min` `max`], [total, smallest, largest of a list],
      [`divmod(a, b)`], [quotient and remainder in one call],
      [`round(x, n)`], [round to `n` digits (ties go to even)],
      [`abs(x)`], [distance from zero],
      [`int(s, 16)` `hex(n)`], [text in base 16 ↔ number],
      [`float.is_integer()`], [no decimal part?],
      [`f"{x:.2f}"` `f"{x:,}"`], [format for display only],
    )

    #collab[
      CDR durations are seconds. `divmod(duration, 60)` turns `3725` into
      62 min 5 s for a readable call report.
    ]
  ]
]

#subsection[str]

#slide(title: [str · text])[
  #cols(ratio: (1, 1))[
    #diagram("str-index", width: 96%)
    #v(-2pt)
    ```python
    name = "SEP0A1B2C3D4E5F"
    len(name)        # 15
    name[:3]         # 'SEP'
    name[3:]         # '0A1B2C3D4E5F'
    name.lower()     # new str, name unchanged
    name[0] = "X"    # TypeError: immutable
    ```
  ][
    #immutable

    `str` is an ordered sequence of characters, written in `'single'`,
    `"double"` or `"""triple"""` quotes. Every character has an index
    starting at `0`, so you can read one character or slice a part.

    Strings cannot be changed in place. Methods like `.lower()` or
    `.replace()` always return a *new* string. To keep the result, assign
    it: `name = name.lower()`.

    #collab[
      Most collab identifiers are strings: DNs, device names, MAC addresses,
      user IDs, SIP URIs. A phone's MAC is simply its name without the
      `SEP` prefix: `name[3:]`.
    ]
  ]
]

#slide(title: [str methods · clean up])[
  #cols(ratio: (1, 1))[
    #diagram("str-clean", width: 100%)
    #v(-2pt)
    ```python
    raw = "  sep0a1b2c3d4e5f \n"   # CSV cell
    raw.strip()             # 'sep0a1b2c3d4e5f'
    raw.strip().upper()     # 'SEP0A1B2C3D4E5F'
    "alice smith".title()   # 'Alice Smith'
    "0A:1B:2C:3D:4E:5F".replace(":", "")
                            # '0A1B2C3D4E5F'
    "12".zfill(4)           # '0012'
    "sip:1001".removeprefix("sip:")  # '1001'
    ```
  ][
    Clean-up methods return a *new* string, so they can be chained from
    left to right.

    #methods(
      [`strip()`], [remove spaces, tabs, newlines at both ends],
      [`lstrip()` `rstrip()`], [only left / only right side],
      [`lower()` `upper()` `title()`], [change letter case],
      [`replace(old, new)`], [swap every `old` with `new`],
      [`zfill(n)`], [pad with leading zeros to length `n`],
      [`removeprefix(p)` `removesuffix(s)`], [drop a fixed start / end],
    )

    #collab[
      MACs pasted from Excel come with spaces, lower case and colons.
      `"SEP" + mac.strip().upper().replace(":", "")` gives a valid
      device name for AXL.
    ]
  ]
]

#slide(title: [str methods · search and test])[
  #cols(ratio: (1, 1))[
    #diagram("device-prefix", width: 74%)
    #v(-2pt)
    ```python
    name = "SEP0A1B2C3D4E5F"
    name.startswith("SEP")     # True
    "cucm-pub.clauto.lab".endswith(".lab")
                               # True
    "A1" in name               # True
    name.find("A1")            # 4  (-1 if missing)
    name.index("ZZ")           # ValueError
    "G711u,G711a,G722".count("G711")   # 2
    "1001".isdigit()           # True
    ```
  ][
    Search methods answer *where* or *whether* a piece of text appears.
    They never change the string.

    #methods(
      [`startswith(p)` `endswith(s)`], [does it begin / end with this?],
      [`x in s`], [does `x` appear anywhere? (operator)],
      [`find(x)`], [first position, or `-1` if not found],
      [`index(x)`], [like `find`, but raises `ValueError`],
      [`count(x)`], [how many times `x` appears],
      [`isdigit()` `isalpha()` `isalnum()`], [only digits / letters / both?],
    )

    #collab[
      The first three letters of a device name tell you the device type.
      `name.startswith("CSF")` finds every Jabber client in a phone list.
    ]
  ]
]

#slide(title: [str methods · split, join, format])[
  #cols(ratio: (1, 1))[
    #diagram("str-split-join", width: 100%)
    #v(-2pt)
    ```python
    row = "alice.smith,1001,DP_HQ"
    user, dn, pool = row.split(",")
    uri = "sip:1001@cucm-pub.clauto.lab"
    uri.split("@")     # ['sip:1001', 'cucm-pub…']
    uri.partition("@") # ('sip:1001', '@', 'cucm…')
    ", ".join(["1001", "1002"])  # '1001, 1002'
    f"{user:<12}{dn:>6}"  # 'alice.smith   1001'
    ```
  ][
    `split` cuts a string into a *list*. `join` glues a list back into one
    string. They are opposites, and most parsing work is a mix of the two.

    #methods(
      [`split(sep)`], [cut at every `sep` → list (no `sep` = whitespace)],
      [`split(sep, 1)` `rsplit(sep, 1)`], [cut only once, from left / right],
      [`partition(sep)`], [cut once → `(before, sep, after)`],
      [`sep.join(items)`], [glue a list of strings with `sep`],
      [`f"{x:<10}"` `f"{x:>6}"`], [align left / right in a fixed width],
    )

    #collab[
      A SIP URI splits into user and host with `uri.partition("@")`.
      `join` builds the CSV lines and report rows you send back.
    ]
  ]
]

#subsection[bool]

#slide(title: [bool · True or False])[
  #cols(ratio: (1, 1))[
    ```python
    status = "Registered"
    is_reg = status == "Registered"   # True
    type(is_reg)              # <class 'bool'>

    bool(""), bool("1001")    # (False, True)
    bool([]), bool(["1001"])  # (False, True)
    True + True               # 2  (bool is an int)

    bool("false")             # True  ← careful!
    ```
  ][
    #immutable

    `bool` has exactly two values: `True` and `False`. Comparisons
    (`==`, `>`, `in`) produce a bool, and `if` statements consume them.

    Every object has a *truth value*. Empty or zero values are *falsy*:
    `""`, `0`, `[]`, `{}`, `None`. Everything else is *truthy*. Under the
    hood, `bool` is a subtype of `int`: `True == 1`.

    #pitfall[
      AXL sends booleans as text: `"true"` / `"false"`. Any non-empty string
      is truthy, so `bool("false")` is `True`. Compare instead:
      `enabled = value == "true"`.
    ]
  ]
]

#subsection[list]

#slide(title: [list · ordered collection])[
  #cols(ratio: (1, 1))[
    #diagram("list-index", width: 80%)
    #v(-2pt)
    ```python
    lines = ["1001", "1002", "1003"]
    lines[0]              # '1001'
    lines[-1]             # '1003'
    lines.append("1004")  # add to the end
    lines[1] = "1099"     # change in place
    len(lines)            # 4
    ```
  ][
    #mutable

    A `list` is an ordered collection in square brackets. It can hold any
    type, mixed types and duplicates. Items are read by index: `0` from
    the start, `-1` from the end.

    Lists change in place: `append`, `insert`, `remove` and item assignment
    modify the same object. Their order is kept, so they are the natural
    container for "many of something".

    #collab[
      `listPhone` returns a list of phones, a CSV import is a list of rows,
      and a phone's lines are a list of DNs. Most automation scripts loop
      over a list.
    ]
  ]
]

#slide(title: [list methods · add and remove])[
  #cols(ratio: (1, 1))[
    #diagram("list-ops", width: 92%)
    #v(-2pt)
    ```python
    lines = ["1001", "1002"]
    lines.append("1003")          # one, at the end
    lines.extend(["1004", "1005"])  # many
    lines.insert(0, "1000")       # at index 0
    lines.remove("1002")          # by value
    lines.pop()                   # '1005' last
    lines.pop(0)                  # '1000' by index
    lines         # ['1001', '1003', '1004']
    ```
  ][
    These methods change the list *in place* and keep the same `id`.

    #methods(
      [`append(x)`], [add one item to the end],
      [`extend(items)`], [add every item of another list],
      [`insert(i, x)`], [add `x` before position `i`],
      [`remove(x)`], [delete the first `x` (`ValueError` if missing)],
      [`pop()` `pop(i)`], [remove and *return* last / item `i`],
      [`clear()`], [remove everything],
    )

    #pitfall[
      `lines.append(["1002", "1003"])` adds *one* item, a nested list:
      `["1001", ["1002", "1003"]]`. Use `extend` to add many.
    ]
  ]
]

#slide(title: [list methods · order and search])[
  #cols(ratio: (1, 1))[
    #diagram("sort-vs-sorted", width: 80%)
    #v(-2pt)
    ```python
    dns = ["1003", "1001", "1002"]
    sorted(dns)           # new sorted list
    dns.sort(reverse=True)  # in place
    dns.index("1002")     # 1
    dns.count("1001")     # 1
    "1004" in dns         # False
    backup = dns.copy()   # a real copy
    sorted(names, key=str.lower)  # ignore case
    ```
  ][
    Ordering and searching work on any list. Note the two ways to sort.

    #methods(
      [`sorted(lst)`], [*new* sorted list, original untouched],
      [`lst.sort()`], [sort in place, returns `None`],
      [`reverse=True` `key=...`], [descending order / sort by a rule],
      [`reverse()`], [flip the order in place],
      [`index(x)` `count(x)`], [position of `x` / how many `x`],
      [`copy()`], [shallow copy: a new list, same items],
    )

    #pitfall[
      `dns = dns.sort()` sets `dns` to `None`, because `sort()` returns
      nothing. Use `dns.sort()` alone, or `dns = sorted(dns)`.
    ]
  ]
]

#subsection[tuple]

#slide(title: [tuple · fixed sequence])[
  #cols(ratio: (1, 1))[
    ```python
    server = ("cucm-pub.clauto.lab", 8443)
    server[0]             # 'cucm-pub.clauto.lab'
    host, port = server   # unpacking
    server[1] = 443       # TypeError: immutable

    codecs = ("G722", "G711u", "G711a")
    "G722" in codecs      # True

    nodes = {("cucm-pub.clauto.lab", 8443): "pub"}
    ```
  ][
    #immutable

    A `tuple` looks like a list in round brackets, but it cannot change
    after creation. Use it for a fixed group of values that belong
    together, like a host and its port.

    *Unpacking* assigns each item to its own name in one line. Because
    tuples are immutable, they can be `dict` keys and `set` items. Lists
    cannot.

    #collab[
      A server address `(host, port)`, a fixed codec preference order, or a
      function result `(ok, message)` after an AXL call are all good
      tuples.
    ]
  ]
]

#subsection[range]

#slide(title: [range · number sequence])[
  #cols(ratio: (1, 1))[
    #diagram("range-line", width: 96%)
    #v(-2pt)
    ```python
    block = range(1001, 1011)
    len(block)                 # 10
    1005 in block              # True
    list(range(1001, 1011, 3)) # [1001, 1004, 1007, 1010]

    for n in range(1001, 1004):
        print("DN", str(n))    # DN 1001 … DN 1003
    ```
  ][
    #immutable

    `range(start, stop, step)` describes a sequence of whole numbers.
    `start` is included and `stop` is *not*. The default step is `1`.

    A range does not store its numbers. It calculates them when asked, so
    `range(1, 1_000_000)` uses almost no memory. Wrap it in `list()` to
    see the values.

    #collab[
      Generate a DN block for a new site with `range(1001, 1100)`. Remember
      that DNs are strings: convert each number with `str(n)` before
      sending it to AXL.
    ]
  ]
]

#slide(title: [tuple and range · useful operations])[
  #cols(ratio: (3, 2))[
    ```python
    codecs = ("G722", "G711u", "G711a", "G711u")
    codecs.count("G711u")     # 2
    codecs.index("G711a")     # 2
    len(codecs), codecs[:2]   # (4, ('G722', 'G711u'))

    block = range(1001, 1100)
    block.start, block.stop   # (1001, 1100)
    block[-1], len(block)     # (1099, 99)
    list(range(1003, 1000, -1))   # [1003, 1002, 1001]

    dns = ["1001", "1002"]
    users = ["alice.smith", "bob.jones"]
    dict(zip(dns, users))     # {'1001': 'alice.smith', …}
    list(enumerate(dns, start=1))  # [(1, '1001'), …]
    ```
  ][
    A `tuple` has only two methods. Everything else comes from operations
    every sequence shares: `len`, `in`, indexing, slicing, unpacking.
    A `range` supports the same, plus its `start`, `stop` and `step`.

    #methods(
      [`count(x)` `index(x)`], [how many `x` / position of `x`],
      [`len` `in` `[i]` `[a:b]`], [size, membership, index, slice],
      [`range(a, b, -1)`], [count down with a negative step],
      [`zip(a, b)`], [pair items of two sequences],
      [`enumerate(seq, start=1)`], [number each item],
    )

    #collab[
      Two Excel columns, DNs and user IDs, become one lookup table with
      `dict(zip(dns, users))`.
    ]
  ]
]

#subsection[dict]

#slide(title: [dict · key → value])[
  #cols(ratio: (1, 1))[
    #diagram("dict-map", width: 84%)
    #v(-2pt)
    ```python
    phone = {"name": "SEP0A1B2C3D4E5F",
             "model": "Cisco 8851"}
    phone["model"]                  # 'Cisco 8851'
    phone["devicePool"] = "DP_HQ"   # add a key
    phone.get("css")                # None, no error
    "name" in phone                 # True
    ```
  ][
    #mutable

    A `dict` maps *keys* to *values* in curly braces. Keys are unique and
    must be immutable (usually `str`). Values can be anything, even other
    dicts or lists. Python keeps the insertion order.

    Read with `phone["model"]`. A missing key raises `KeyError`.
    `phone.get("css")` returns `None` instead. Adding or changing a key
    modifies the dict in place.

    #collab[
      Every AXL or REST record is a dict: a phone, a line, a Webex user.
      JSON from the Webex API maps directly to nested dicts and lists.
    ]
  ]
]

#slide(title: [dict methods · read and update])[
  #cols(ratio: (1, 1))[
    #diagram("dict-get", width: 82%)
    #v(-2pt)
    ```python
    phone = {"name": "SEP0A1B2C3D4E5F",
             "model": "Cisco 8851"}
    phone.get("css")                  # None
    phone.get("css", "CSS_Internal")  # default
    phone.update({"devicePool": "DP_HQ",
                  "description": "Alice desk"})
    phone.pop("description")    # 'Alice desk'
    phone.setdefault("css", "CSS_Internal")
    del phone["css"]
    ```
  ][
    `[]` is strict: a missing key is an error. `get` is forgiving: it
    returns `None` or the default you give.

    #methods(
      [`d[k]`], [value of `k`, `KeyError` if missing],
      [`get(k, default)`], [value of `k`, or `default` / `None`],
      [`update(other)`], [add or overwrite many keys at once],
      [`pop(k)`], [remove `k` and return its value],
      [`setdefault(k, v)`], [set `k` to `v` only if it is missing],
      [`del d[k]`], [remove `k` (statement, not a method)],
    )

    #collab[
      Optional AXL fields may be missing from a reply. Read them with
      `phone.get("css")` so one incomplete record does not stop a script
      that walks 500 phones.
    ]
  ]
]

#slide(title: [dict methods · loop and nest])[
  #cols(ratio: (1, 1))[
    #diagram("axl-nested", width: 78%)
    #v(-2pt)
    ```python
    for key, value in phone.items():
        print(f"{key:<12} {value}")

    list(phone.keys())     # ['name', 'model']
    "SEP0A1B2C3D4E5F" in phone.values()  # True

    line = reply["phone"]["lines"]["line"][0]
    line["dirn"]["pattern"]   # '1001'
    copy = phone.copy()       # a new dict
    ```
  ][
    Three *views* expose a dict's content for loops and tests. Nested
    dicts and lists are read one level at a time.

    #methods(
      [`keys()`], [all keys],
      [`values()`], [all values],
      [`items()`], [`(key, value)` pairs, the usual loop],
      [`k in d`], [is `k` a key? (checks keys, not values)],
      [`d[a][b][0]`], [step down into nested data],
      [`copy()`], [shallow copy: new dict, same inner objects],
    )

    #collab[
      `getPhone` returns deeply nested data. Store an inner level in a
      variable (`line = …`) to keep each step short and readable.
    ]
  ]
]

#subsection[set]

#slide(title: [set · unique items])[
  #cols(ratio: (1, 1))[
    #diagram("set-venn", width: 80%)
    #v(-2pt)
    ```python
    cucm = {"PT_Internal", "PT_Local", "PT_Old"}
    need = {"PT_Internal", "PT_Local", "PT_Intl"}
    need - cucm    # {'PT_Intl'}  missing
    cucm - need    # {'PT_Old'}   unused
    cucm & need    # in both
    set(["1001", "1001", "1002"])  # duplicates gone
    ```
  ][
    #mutable

    A `set` is an unordered collection of *unique*, immutable items. Adding
    a value that is already there does nothing. A set has no index and no
    guaranteed order.

    Sets answer two questions very fast: "is this item in it?" (`in`) and
    "how do two groups differ?" Use `-` for difference, `&` for
    intersection and `|` for union.

    #collab[
      Config audits: compare the partitions in CUCM with the partitions in
      your design document. The missing and unused ones come out in one line.
    ]
  ]
]

#slide(title: [set methods])[
  #cols(ratio: (1, 1))[
    #diagram("set-subset", width: 78%)
    #v(-2pt)
    ```python
    pts = {"PT_Internal"}
    pts.add("PT_Local")       # add one
    pts.add("PT_Local")       # no effect, exists
    pts.update(["PT_Intl", "PT_Old"])  # add many
    pts.discard("PT_None")    # missing: no error
    pts.remove("PT_None")     # missing: KeyError

    required = {"PT_Internal", "PT_Local"}
    required.issubset(pts)    # True
    pts.isdisjoint({"PT_Blocked"})  # True
    ```
  ][
    Set methods add and remove items, and compare whole groups. The
    operators `| & -` from the previous slide have method versions that
    also accept lists.

    #methods(
      [`add(x)` `update(items)`], [add one / many (duplicates ignored)],
      [`discard(x)` `remove(x)`], [delete, silently / with `KeyError`],
      [`union` `intersection` `difference`], [same as `|`, `&`, `-`],
      [`issubset(b)` `issuperset(b)`], [all inside `b` / contains all of `b`],
      [`isdisjoint(b)`], [no item in common?],
    )

    #collab[
      Check that a CSS contains every required partition with
      `required.issubset(css_partitions)`: one line, one `True` or
      `False`.
    ]
  ]
]

#subsection[bytes]

#slide(title: [bytes · raw binary data])[
  #cols(ratio: (3, 2))[
    ```python
    msg = "INVITE sip:1001@cucm-pub.clauto.lab SIP/2.0"
    raw = msg.encode()     # str → bytes (UTF-8)
    raw[:6]                # b'INVITE'
    raw[0]                 # 73  ← one byte is a number
    raw.decode()           # bytes → str

    buf = bytearray(raw)   # mutable copy
    buf[0:6] = b"CANCEL"   # change in place
    ```
  ][
    #immutable #h(2pt) `bytes` #h(6pt) #mutable #h(2pt) `bytearray`

    `bytes` is a sequence of raw bytes (values 0–255), written as
    `b"..."`. Text becomes bytes with `.encode()` and back with
    `.decode()`. `bytearray` is the mutable version.

    Networks and files move bytes, not text. You meet them when reading
    sockets, files and certificates.

    #collab[
      With `requests`, `r.text` is a `str` and `r.content` is `bytes`. Use
      `bytes` for downloads like CDR files or certificates, and for raw SIP
      messages.
    ]
  ]
]

#slide(title: [bytes methods])[
  #cols(ratio: (3, 2))[
    #diagram("encode-decode", width: 72%)
    #v(-2pt)
    ```python
    raw = b"SIP/2.0 200 OK\r\nCSeq: 1 INVITE\r\n"
    raw.startswith(b"SIP/2.0 200")  # True
    raw.split(b"\r\n")[0].decode()  # 'SIP/2.0 200 OK'
    raw.find(b"CSeq")               # 16
    raw.hex()[:8]                   # '5349502f'
    bytes.fromhex("53495020")       # b'SIP '
    "café".encode()                 # b'caf\xc3\xa9'
    b"caf\xe9".decode(errors="replace")  # 'caf�'
    ```
  ][
    `bytes` shares most `str` methods (`split`, `find`, `startswith`,
    `strip`), but every argument must be `bytes` too: `b"..."`. Converting
    between the two is the key step.

    #methods(
      [`s.encode()`], [`str` → `bytes` (UTF-8 by default)],
      [`b.decode()`], [`bytes` → `str`],
      [`decode(errors="replace")`], [do not crash on bad bytes],
      [`hex()` `bytes.fromhex(s)`], [bytes ↔ hex text],
      [`split` `find` `startswith`], [same as `str`, with `b"..."`],
    )

    #collab[
      AXL uses HTTP Basic auth: the header is
      `base64.b64encode(b"axl_svc:password")`. `requests` does this for
      you, but it is bytes underneath.
    ]
  ]
]

#subsection[None]

#slide(title: [None · no value])[
  #cols(ratio: (1, 1))[
    ```python
    phone = {"name": "SEP0A1B2C3D4E5F",
             "description": None}
    desc = phone["description"]
    desc is None              # True
    phone.get("css")          # None, key missing

    result = print("hi")      # print returns None
    desc or "no description"  # fallback value
    desc.upper()              # AttributeError
    ```
  ][
    #immutable

    `None` means "no value here". It is the only object of type
    `NoneType`. A function without a `return` returns `None`, and
    `dict.get()` returns `None` for a missing key.

    `None` is falsy. Check for it with `is None`, not `== None`. Use
    `x or default` to fall back to a value.

    #pitfall[
      Empty AXL fields come back as `None`. Calling a string method on it,
      like `desc.upper()`, raises an `AttributeError`. Check for `None`
      first, or use a fallback: `(desc or "").upper()`.
    ]
  ]
]

#section[if Statements]

#slide(title: [if · run code only when])[
  #cols(ratio: (1, 1))[
    #diagram("if-flow", width: 96%)
    #v(-2pt)
    ```python
    status = "UnRegistered"

    if status != "Registered":
        print("ALERT: SEP0A1B2C3D4E5F is down")

    print("check finished")   # always runs
    ```
  ][
    `if` runs a block of code only when its *condition* is `True`. When
    the condition is `False`, Python skips the block and continues.

    The line ends with a colon `:`. The block below is *indented* with
    4 spaces; indentation, not brackets, tells Python where the block ends.

    #methods(
      header: ([Operator], [True when]),
      [`==` `!=`], [equal / not equal],
      [`<` `>` `<=` `>=`], [smaller / greater (or equal)],
      [`in` `not in`], [item is / is not inside a sequence],
      [`is` `is not`], [same object, e.g. `x is None`],
    )

    #collab[
      RISPort returns a status per device. `if status != "Registered"`
      is the heart of every phone-down alert.
    ]
  ]
]

#slide(title: [if / elif / else · choose one path])[
  #cols(ratio: (1, 1))[
    #diagram("elif-flow", width: 92%)
    #v(-2pt)
    ```python
    mos = 3.8

    if mos >= 4.0:
        quality = "good"
    elif mos >= 3.6:
        quality = "fair"
    else:
        quality = "poor"

    print(f"MOS {mos}: {quality}")  # MOS 3.8: fair
    ```
  ][
    `elif` ("else if") adds more conditions, as many as you need. `else`
    catches everything that matched none of them. Both are optional.

    Python checks the conditions *from top to bottom* and runs only the
    first branch that is `True`. All other branches are skipped, even if
    they would also be `True`.

    #pitfall[
      Order matters. If `mos >= 3.6` comes first, a MOS of `4.5` is
      labelled `"fair"`, because that branch matches first. Put the
      strictest condition at the top.
    ]

    #collab[
      Grade call quality from CMR data: MOS 4.0 and above is good, 3.6 to
      4.0 is fair, below 3.6 needs investigation.
    ]
  ]
]

#slide(title: [Combining conditions])[
  #cols(ratio: (3, 2))[
    ```python
    status = "UnRegistered"
    model = "Cisco 8851"
    lines = []                        # no DN yet

    if status != "Registered" and "88" in model:
        print("8800 series phone is down")

    if not lines:                     # empty → falsy
        print("phone has no line")

    if model in ("Cisco 8851", "Cisco 8865"):
        print("video capable")

    label = "OK" if status == "Registered" else "DOWN"
    ```
  ][
    Conditions can be combined, and any value can be a condition: empty
    values (`""`, `[]`, `{}`, `0`, `None`) count as `False`.

    #methods(
      header: ([Operator], [True when]),
      [`a and b`], [both are true],
      [`a or b`], [at least one is true],
      [`not a`], [`a` is false],
      [`x if c else y`], [one-line choice: `x` when `c`, else `y`],
    )

    #pitfall[
      `if model == "Cisco 8851" or "Cisco 8865":` is *always* `True`:
      the non-empty string `"Cisco 8865"` is truthy on its own. Write
      `if model in ("Cisco 8851", "Cisco 8865"):`.
    ]
  ]
]

#section[Loops]

#slide(title: [What is a loop?])[
  #cols(ratio: (1, 1))[
    #diagram("loop-kinds", width: 96%)
    #v(-2pt)
    ```python
    # without a loop: one line per phone
    print("reset", "SEP0A1B2C3D4E5F")
    print("reset", "SEP0A1B2C3D4E60")
    # ... 498 more lines

    # with a loop: two lines for any number
    for name in phones:
        print("reset", name)
    ```
  ][
    A *loop* repeats a block of code. You write the work once and Python
    runs it as many times as needed: for 3 phones or for 3000. This is
    where automation saves its time.

    #methods(
      header: ([Term], [Meaning]),
      [body], [the indented block that is repeated],
      [iteration], [one run of the body (one "round")],
      [loop variable], [name that holds the current item],
      [condition], [`True` / `False` test that decides to go on],
    )

    Python has two loops. `for` repeats *once per item* of a collection.
    `while` repeats *as long as a condition* stays `True`.

    #collab[
      Reset, audit or update 500 phones: the code for one phone goes in
      the body, the loop takes care of the other 499.
    ]
  ]
]

#subsection[for]

#slide(title: [for · repeat for every item])[
  #cols(ratio: (1, 1))[
    #diagram("for-flow", width: 92%)
    #v(-2pt)
    ```python
    dns = ["1001", "1002", "1003"]

    for dn in dns:
        print(f"Adding line {dn}")

    print("done")          # after the loop
    ```
  ][
    A `for` loop runs its body *once for every item* of a collection. In
    each round, the loop variable (`dn`) holds the next item. When no
    items are left, the loop ends and the code after it runs.

    Like `if`, the line ends with `:` and the body is indented. The loop
    variable is a normal name: pick one that says what one item is.

    `for` works on anything you can step through: `list`, `tuple`, `str`,
    `dict`, `set`, `range`, and later files and API replies.

    #collab[
      This is the core of bulk provisioning: read 500 rows from a CSV,
      then `for row in rows:` build and send one AXL `addLine` or
      `addPhone` request per row.
    ]
  ]
]

#slide(title: [for · common patterns])[
  #cols(ratio: (3, 2))[
    ```python
    for n in range(1001, 1004):            # numbers
        print(str(n))

    for i, dn in enumerate(dns, start=1):  # position + item
        print(i, dn)                       # 1 1001 …

    for key, value in phone.items():       # dict pairs
        print(key, value)

    for dn, user in zip(dns, users):       # two lists at once
        print(dn, "->", user)              # 1001 -> alice.smith

    total = 0
    for d in durations:                    # accumulate
        total += d                         # 937
    ```
  ][
    Five patterns cover most loops in automation scripts:

    #methods(
      header: ([Pattern], [Use it to]),
      [`range(a, b)`], [repeat for a block of numbers],
      [`enumerate(seq)`], [get the position and the item],
      [`d.items()`], [walk a dict key by key],
      [`zip(a, b)`], [walk two lists side by side],
      [`total += x`], [build a sum, count or new list],
    )

    #collab[
      `zip(dns, users)` pairs the DN column with the user column of an
      Excel sheet, ready to associate each line with its owner.
    ]
  ]
]

#slide(title: [break and continue])[
  #cols(ratio: (1, 1))[
    #diagram("break-continue", width: 92%)
    #v(-2pt)
    ```python
    phones = ["SEP0A1B2C3D4E5F", "CSFALICE",
              "SEP0A1B2C3D4E60"]

    for name in phones:
        if name.startswith("CSF"):
            continue          # skip, go to next item
        if name == "SEP0A1B2C3D4E60":
            print("found", name)
            break             # leave the loop now
        print("checking", name)
    ```
  ][
    Two keywords change the normal flow of a loop:

    - `continue` skips the rest of the body and starts the *next round*.
    - `break` leaves the loop *immediately*. The remaining items are not
      visited.

    Both are usually inside an `if`. They work the same way in `for` and
    `while` loops.

    #collab[
      `continue` to skip Jabber clients (`CSF…`) in a desk phone audit.
      `break` as soon as the device you are searching for is found, so the
      script does not walk the remaining thousand phones.
    ]
  ]
]

#subsection[while]

#slide(title: [while · repeat while true])[
  #cols(ratio: (1, 1))[
    #diagram("while-flow", width: 92%)
    #v(-2pt)
    ```python
    replies = ["Unknown", "Unknown", "Registered"]
    attempts = 0
    status = ""

    while status != "Registered" and attempts < 5:
        status = replies[attempts]   # RIS reply
        attempts += 1
        print(f"try {attempts}: {status}")
    ```
  ][
    A `while` loop repeats its body *as long as* its condition is `True`.
    The condition is checked before every round. As soon as it is
    `False`, the loop ends.

    Use `while` when you do not know in advance how many rounds you need:
    "until the phone is registered", "until the job is done".

    #pitfall[
      If nothing in the body changes the condition, the loop never ends.
      Always add a limit like `attempts < 5`. Stop a stuck script with
      `Ctrl+C`.
    ]
  ]
]

#slide(title: [while True · poll until done])[
  #cols(ratio: (3, 2))[
    ```python
    import time

    attempts = 0
    while True:
        attempts += 1
        status = get_status("SEP0A1B2C3D4E5F")  # your RIS call
        if status == "Registered":
            print("phone is back")
            break
        if attempts == 10:
            print("giving up after 10 tries")
            break
        time.sleep(30)          # wait before asking again
    ```
  ][
    `while True` loops forever on purpose. The exits are written inside
    the body with `break`. This keeps several exit rules readable.

    #methods(
      header: ([Loop], [Best when]),
      [`for`], [you have a collection or a known count],
      [`while cond`], [repeat until a condition changes],
      [`while True` + `break`], [several exit rules, polling],
    )

    #collab[
      After resetting a phone, poll RIS until it registers again. RIS is
      rate-limited, so always `sleep` between requests and cap the
      number of attempts.
    ]
  ]
]

#section[Functions]

#slide(title: [What is a function?])[
  #cols(ratio: (1, 1))[
    #diagram("function-machine", width: 100%)
    #v(-2pt)
    ```python
    def build_device_name(mac):
        """Turn a raw MAC into a CUCM device name."""
        clean = mac.strip().upper().replace(":", "")
        return "SEP" + clean

    name = build_device_name("0a:1b:2c:3d:4e:5f")
    print(name)        # SEP0A1B2C3D4E5F
    ```
  ][
    A *function* is a named block of code that does one job. You *define*
    it once with `def`, then *call* it by name as often as you need, with
    different input each time.

    #methods(
      header: ([Part], [Meaning]),
      [`def name(...):`], [define the function, body indented below],
      [parameter], [the input name in the definition (`mac`)],
      [argument], [the actual value passed in a call],
      [`return`], [send a result back and leave the function],
      [`"""docstring"""`], [one line that says what it does],
    )

    #collab[
      Every rule you apply more than once (naming, cleaning, validating)
      belongs in a function: fix it in one place, every script benefits.
    ]
  ]
]

#slide(title: [Parameters, defaults and return])[
  #cols(ratio: (3, 2))[
    ```python
    def line_label(dn, user, site="HQ"):
        return f"{user} ({dn}) - {site}"

    line_label("1001", "alice.smith")    # alice.smith (1001) - HQ
    line_label("1002", "bob.jones", "Branch")      # positional
    line_label(user="carol.white", dn="1003")      # keyword

    def check(status):
        if status == "Registered":
            return True, "ok"
        return False, f"status is {status}"

    ok, msg = check("UnRegistered")    # two values back (tuple)
    ```
  ][
    - *Positional* arguments match parameters by order, *keyword*
      arguments by name (`user="…"`), in any order.
    - A *default* value (`site="HQ"`) makes a parameter optional.
    - `return a, b` returns a tuple. Without `return`, a function
      returns `None`.
    - Names created inside a function are *local*: they disappear when
      the function ends.

    #pitfall[
      Never use a mutable default: `def add(dn, lines=[])` shares *one*
      list between all calls. Use `lines=None`, then
      `if lines is None: lines = []`.
    ]
  ]
]

#slide(title: [Function vs method])[
  #cols(ratio: (1, 1))[
    #diagram("function-vs-method", width: 92%)
    #v(-2pt)
    ```python
    name = "sep0a1b2c3d4e5f"

    len(name)              # function: object goes in
    name.upper()           # method: called on the object
    str.upper(name)        # same method, function style

    lines = ["1001"]
    lines.append("1002")   # list method
    len(lines)             # one len() for every type

    name.append("x")       # AttributeError: no such
                           # method on str
    ```
  ][
    A *method* is a function that *belongs to an object's type*. You call
    it with a dot on the object, and the object is passed in
    automatically. A plain *function* stands alone and gets the object as
    an argument.

    #methods(
      header: ([Function], [Method]),
      [`len(name)`], [`name.upper()`],
      [defined with `def` in a module], [defined with `def` inside a class],
      [works on many types], [only exists on its own type],
      [object passed as argument], [object passed automatically (`self`)],
    )

    #warn[
      Not every dot is a method. In `requests.get(url)` or
      `json.loads(text)` the dot only opens a *module*: `get` and `loads`
      are plain functions.
    ]
  ]
]

#subsection[args and kwargs]

#slide(title: [\*args · any number of positional arguments])[
  #cols(ratio: (1, 1))[
    #diagram("args-pack", width: 88%)
    #v(-2pt)
    ```python
    def reset_phones(*names):
        print(type(names))     # <class 'tuple'>
        for name in names:
            print("reset", name)

    reset_phones("SEP0A1B2C3D4E5F")
    reset_phones("SEP0A1B2C3D4E5F", "SEP0A1B2C3D4E60")
    reset_phones(*phones)      # unpack a list
    ```
  ][
    A parameter with a single star collects *all extra positional
    arguments* into a `tuple`. The function can be called with zero, one
    or a hundred values.

    The name after `*` is free; `*args` is the convention when there is
    no better name. Normal parameters can come first:
    `def reset(site, *names)`.

    In a *call*, the star works the other way round: `f(*phones)`
    unpacks a list into separate arguments.

    #collab[
      One `reset_phones()` helper serves a single phone from the CLI and a
      whole list from a CSV import, without two versions of the function.
    ]
  ]
]

#slide(title: [\*\*kwargs · any number of keyword arguments])[
  #cols(ratio: (1, 1))[
    #diagram("kwargs-pack", width: 90%)
    #v(-2pt)
    ```python
    def add_phone(name, model, **fields):
        phone = {"name": name, "model": model}
        phone.update(fields)       # fields is a dict
        return phone

    add_phone("SEP0A1B2C3D4E5F", "Cisco 8851",
              devicePoolName="DP_HQ",
              description="Alice desk")

    defaults = {"devicePoolName": "DP_HQ"}
    add_phone("SEP0A1B2C3D4E60", "Cisco 8865",
              **defaults)          # unpack a dict
    ```
  ][
    A parameter with two stars collects *all extra keyword arguments*
    into a `dict`: the names become keys, the values become values.

    #methods(
      header: ([Syntax], [Meaning]),
      [`def f(*args)`], [extra positional → `tuple`],
      [`def f(**kwargs)`], [extra keyword → `dict`],
      [`f(*lst)`], [unpack a list into positional args],
      [`f(**d)`], [unpack a dict into keyword args],
    )

    Order in a definition: normal, `*args`, keyword-only, `**kwargs`.

    #collab[
      An AXL phone has dozens of optional fields. With `**fields` one
      helper accepts any of them without listing every one.
    ]
  ]
]

#subsection[Modules and import]

#slide(title: [Modules · use code from another file])[
  #cols(ratio: (1, 1))[
    #diagram("modules-import", width: 96%)
    #v(-2pt)
    ```python
    # main.py
    import cucm_tools
    cucm_tools.build_device_name("0a:1b:2c:3d:4e:5f")

    from cucm_tools import build_device_name, CUCM_HOST
    build_device_name("0a:1b:2c:3d:4e:60")

    import cucm_tools as ct     # short alias
    ct.CUCM_HOST                # 'cucm-pub.clauto.lab'
    ```
  ][
    Every `.py` file is a *module*. `import` loads another file once and
    gives you access to its functions and variables, so code is written
    in one place and used everywhere.

    #methods(
      header: ([Form], [Then use]),
      [`import m`], [`m.func()`: clear where it comes from],
      [`from m import func`], [`func()`: shorter, pick names],
      [`import m as x`], [`x.func()`: alias for long names],
    )

    Python looks for modules in the script's folder, then in the standard
    library, then in installed packages.

    #pitfall[
      Never name your own file like a real module: a `json.py` or
      `requests.py` in your folder hides the real one.
    ]
  ]
]

#slide(title: [Standard library and packages])[
  #cols(ratio: (1, 1))[
    #diagram("python-layers", width: 88%)
    #v(-2pt)
    ```python
    import json, time               # standard library
    from datetime import datetime

    json.loads('{"dn": "1001"}')    # str → dict
    time.sleep(2)                   # wait 2 seconds
    datetime.now().strftime("%Y-%m-%d")

    import requests                 # pip install requests
    ```
  ][
    Three layers of ready-made code:

    - *Built-ins* like `print` and `len` need no import.
    - The *standard library* ships with Python: `import json`.
    - *Third-party packages* come from PyPI: `pip install requests`,
      then `import requests`.

    Install packages into a *virtual environment* per project, so every
    project keeps its own versions:

    ```bash
    python3 -m venv .venv && source .venv/bin/activate
    pip install requests zeep
    ```

    #collab[
      `requests` for REST (Webex, CUPI), `zeep` for SOAP (AXL, RIS),
      `json` and `csv` for the data around them.
    ]
  ]
]

#slide(title: [Scripts vs modules · \_\_name\_\_])[
  #cols(ratio: (1, 1))[
    #diagram("name-main", width: 96%)
    #v(-2pt)
    ```python
    # cucm_tools.py
    def build_device_name(mac):
        return "SEP" + mac.replace(":", "").upper()

    if __name__ == "__main__":
        # only when run directly
        print(build_device_name("0a:1b:2c:3d:4e:5f"))
    ```
  ][
    Python sets `__name__` to `"__main__"` in the file you run, and to
    the module name in a file that is imported. The `if` block is a
    self-test that never runs on import.

    A folder of modules is a *package*. Import with dots:

    ```text
    clauto/
    ├── main.py          from cucm.axl import add_phone
    └── cucm/
        ├── __init__.py  (marks the folder as a package)
        ├── axl.py
        └── ris.py
    ```

    #collab[
      Keep AXL, RIS and Webex helpers in their own modules. Every new
      script then starts with two `import` lines instead of copy-paste.
    ]
  ]
]

#section[Exceptions]

#slide(title: [What is an exception?])[
  #cols(ratio: (1, 1))[
    #diagram("exception-flow", width: 92%)
    #v(-2pt)
    ```python
    phone = {"name": "SEP0A1B2C3D4E5F"}
    phone["css"]
    ```
    ```text
    Traceback (most recent call last):
      File "audit.py", line 2, in <module>
        phone["css"]
    KeyError: 'css'
    ```
  ][
    An *exception* is Python's way of saying "I cannot continue here".
    If nothing handles it, the script stops and prints a *traceback*.
    Read it from the *bottom*: the last line names the error type and the
    message, the lines above show where it happened.

    #methods(
      header: ([Exception], [Typical cause]),
      [`KeyError`], [missing key in a dict],
      [`IndexError`], [list position does not exist],
      [`ValueError`], [right type, wrong value: `int("84x3")`],
      [`TypeError`], [wrong type: `"1001" + 1`],
      [`AttributeError`], [no such method: `None.upper()`],
      [`FileNotFoundError`], [CSV path is wrong],
    )

    #collab[
      Libraries add their own: `requests` raises `Timeout`, `zeep` raises
      a `Fault` when AXL rejects a request (duplicate name, missing CSS).
    ]
  ]
]

#slide(title: [try / except / else / finally])[
  #cols(ratio: (1, 1))[
    #diagram("try-flow", width: 82%)
    #v(-2pt)
    ```python
    def to_int(text):
        try:
            value = int(text)
        except ValueError:
            print(f"not a number: {text!r}")
            value = None
        else:
            print("converted", value)
        finally:
            print("checked", text)
        return value

    to_int("8443")    # converted 8443, checked 8443
    to_int("84x3")    # not a number: '84x3', checked 84x3
    ```
  ][
    Put risky code in `try`. If an exception of the named type is raised,
    Python jumps to the matching `except` block instead of stopping.

    #methods(
      header: ([Block], [Runs when]),
      [`try:`], [always first: the risky code],
      [`except Error:`], [that error happened in `try`],
      [`except (A, B) as e:`], [one of several, `e` is the error],
      [`else:`], [`try` finished *without* an error],
      [`finally:`], [always, error or not: clean-up],
    )

    #pitfall[
      A bare `except:` or `except Exception: pass` hides every bug,
      typos included. Catch the specific error you expect, and always
      print or log what went wrong.
    ]
  ]
]

#slide(title: [Errors in bulk jobs · raise])[
  #cols(ratio: (1, 1))[
    #diagram("bulk-errors", width: 86%)
    #v(-2pt)
    ```python
    failed = []
    for name in phones:
        try:
            add_phone_axl(name)     # your AXL call
        except Exception as e:
            failed.append((name, str(e)))
            continue
        print("added", name)
    print(f"{len(failed)} failed")

    def build_device_name(mac):
        mac = mac.replace(":", "").upper()
        if len(mac) != 12:
            raise ValueError(f"bad MAC: {mac!r}")
        return "SEP" + mac
    ```
  ][
    In a bulk job one bad row must not stop the others. Put `try` *inside*
    the loop: record the failure, `continue` with the next item, and report
    all failures at the end. Here a broad `except Exception` is fine,
    because the error is stored and shown.

    `raise` creates an exception yourself. Use it when input is wrong,
    *before* it reaches CUCM: a clear `ValueError("bad MAC")` is much
    easier to debug than a confusing AXL fault later.

    #collab[
      Import 500 phones: 499 are added, 1 duplicate is written to
      `failed.csv` with its AXL error message for a second run.
    ]
  ]
]

#section[Files]

#slide(title: [Working with files])[
  #cols(ratio: (1, 1))[
    #diagram("file-with", width: 90%)
    #v(-2pt)
    ```python
    f = open("phones.txt", encoding="utf-8")
    text = f.read()
    f.close()                  # easy to forget

    with open("phones.txt", encoding="utf-8") as f:
        text = f.read()        # closed automatically

    from pathlib import Path
    path = Path("data") / "phones.txt"
    path.exists()              # True / False
    ```
  ][
    `open()` connects your script to a file on disk and returns a *file
    object*. Always use it with `with`: the file is closed when the block
    ends, even if an exception happens inside.

    #methods(
      header: ([Mode], [Meaning]),
      [`"r"`], [read (default), error if the file is missing],
      [`"w"`], [write, *erases* existing content],
      [`"a"`], [append to the end],
      [`"x"`], [create a new file, error if it exists],
      [`"rb"` `"wb"`], [binary: bytes instead of str],
    )

    Pass `encoding="utf-8"` for text, and use `pathlib.Path` to build
    paths that work on macOS, Linux and Windows.
  ]
]

#slide(title: [Reading and writing text files])[
  #cols(ratio: (1, 1))[
    #diagram("text-lines", width: 82%)
    #v(-2pt)
    ```python
    with open("phones.txt", encoding="utf-8") as f:
        for line in f:             # one line per round
            name = line.strip()    # drop "\n"
            if not name:
                continue           # skip empty lines
            print(name)

    with open("report.txt", "w", encoding="utf-8") as f:
        f.write("Phone report\n")
        f.write(f"{name}\n")       # add "\n" yourself
    ```
  ][
    A file object can be looped over *line by line*. Each line still ends
    with `"\n"`, so `strip()` it first. Reading line by line keeps memory
    low even for very large files.

    #methods(
      [`f.read()`], [whole file as one `str`],
      [`for line in f`], [one line at a time],
      [`f.readlines()`], [`list` of all lines],
      [`f.write(text)`], [write a `str`; no newline added],
      [`Path(p).read_text()`], [open, read and close in one call],
    )

    #pitfall[
      `"w"` empties the file the moment it is opened. Writing the report
      over your input file destroys it. Use a new file name or `"a"`.
    ]
  ]
]

#subsection[CSV]

#slide(title: [Reading CSV files])[
  #cols(ratio: (1, 1))[
    #diagram("csv-dict", width: 92%)
    #v(-2pt)
    ```python
    import csv

    with open("users.csv", newline="",
              encoding="utf-8") as f:
        for row in csv.DictReader(f):
            print(row["user"], row["dn"])
    # alice.smith 1001
    # bob.jones 1002
    ```
  ][
    CSV is the most common input for bulk jobs: every Excel sheet can be
    saved as one. `csv.DictReader` turns each row into a `dict` and uses
    the header row as its keys, so you read columns by *name*.

    Every value is a `str`. Convert numbers yourself, and open the file
    with `newline=""` as the `csv` module expects.

    #warn[
      Excel in Turkish or German locale saves with `;` and a hidden BOM.
      Read such files with `delimiter=";"` and `encoding="utf-8-sig"`,
      or the first key becomes `"\ufeffuser"`.
    ]
  ]
]

#slide(title: [Writing CSV files])[
  #cols(ratio: (3, 2))[
    ```python
    import csv

    results = [
        {"device": "SEP0A1B2C3D4E5F", "status": "added"},
        {"device": "SEP0A1B2C3D4E60", "status": "failed"},
    ]

    with open("result.csv", "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=["device", "status"])
        writer.writeheader()
        writer.writerows(results)
    ```
    ```text
    device,status
    SEP0A1B2C3D4E5F,added
    SEP0A1B2C3D4E60,failed
    ```
  ][
    `csv.DictWriter` writes a list of dicts as rows. `fieldnames` sets the
    column order, `writeheader()` writes the first row.

    #methods(
      header: ([Tool], [Works with]),
      [`csv.DictReader`], [rows as `dict`, keys from header],
      [`csv.DictWriter`], [write `dict` rows],
      [`csv.reader`], [rows as `list`, by position],
      [`csv.writer`], [write `list` rows],
    )

    #collab[
      Read `users.csv`, provision each row, write `result.csv` with
      device and status. The same file opens in Excel for the customer.
    ]
  ]
]

#subsection[JSON]

#slide(title: [JSON · load and dump])[
  #cols(ratio: (1, 1))[
    #diagram("json-map", width: 92%)
    #v(-2pt)
    ```python
    import json

    with open("phone.json", "w", encoding="utf-8") as f:
        json.dump(phone, f, indent=2)   # dict → file

    with open("phone.json", encoding="utf-8") as f:
        data = json.load(f)             # file → dict

    text = json.dumps(phone)            # dict → str
    json.loads(text)["lines"]           # str → dict
    ```
  ][
    JSON is the text format of REST APIs. Its structure matches Python
    almost one to one, so the `json` module converts in both directions.
    The `s` in `dumps` / `loads` means *string*; without it, a file.

    #methods(
      header: ([Python], [JSON]),
      [`dict`], [object `{}`],
      [`list` (and `tuple`)], [array `[]`],
      [`str`], [string `""`],
      [`int` `float`], [number],
      [`True` `False` `None`], [`true` `false` `null`],
    )

    #collab[
      Webex APIs send and receive JSON. Saving the current config with
      `json.dump(..., indent=2)` before a change gives you a readable
      backup.
    ]
  ]
]

#section[Comprehensions]

#slide(title: [List comprehension])[
  #cols(ratio: (1, 1))[
    #diagram("comp-anatomy", width: 100%)
    #v(-2pt)
    ```python
    phones = ["SEP0A1B2C3D4E5F", "CSFALICE",
              "SEP0A1B2C3D4E60"]

    desk = []                         # loop version
    for p in phones:
        if p.startswith("SEP"):
            desk.append(p[3:])

    desk = [p[3:] for p in phones if p.startswith("SEP")]
    # ['0A1B2C3D4E5F', '0A1B2C3D4E60']

    dns = [str(n) for n in range(1001, 1004)]
    ```
  ][
    A *comprehension* builds a new list from another collection in one
    expression. It replaces the pattern "empty list, loop, `if`,
    `append`" and reads almost like a sentence.

    It has up to three parts, always in this order:

    + *what to keep*: the item itself or a transformed value,
    + *the loop*: `for item in collection`,
    + *a filter* (optional): `if condition`.

    The original list is not changed: you always get a *new* list.

    #collab[
      One line turns a phone list into the MAC list a Webex device
      onboarding sheet needs, or keeps only the desk phones of a site.
    ]
  ]
]

#slide(title: [Dict and set comprehensions])[
  #cols(ratio: (3, 2))[
    ```python
    rows = [{"user": "alice.smith", "dn": "1001"},
            {"user": "bob.jones",   "dn": "1002"},
            {"user": "carol.white", "dn": "1003"}]

    dn_of = {r["user"]: r["dn"] for r in rows}    # dict
    dn_of["bob.jones"]                            # '1002'

    dns = ["1001", "1002", "2000"]
    {dn[:2] for dn in dns}                        # set
    # {'10', '20'}  DN ranges in use

    statuses = ["Registered", "UnRegistered", "Registered"]
    ["up" if s == "Registered" else "down" for s in statuses]
    # ['up', 'down', 'up']

    sum(1 for s in statuses if s != "Registered")    # 1 down
    all(p.startswith("SEP") for p in desk)           # True
    ```
  ][
    The same idea works for every collection. The brackets decide what
    you get back:

    #methods(
      header: ([Form], [Result]),
      [`[x for …]`], [`list`],
      [`{k: v for …}`], [`dict`],
      [`{x for …}`], [`set`, duplicates removed],
      [`(x for …)`], [generator: one item at a time],
    )

    A generator inside `sum()`, `any()` or `all()` needs no extra
    brackets.

    #collab[
      `{r["user"]: r["dn"] for r in rows}` turns a CSV into a lookup
      table: find any user's DN instantly, without a loop.
    ]
  ]
]

#slide(title: [lambda and key functions])[
  #cols(ratio: (1, 1))[
    #diagram("lambda-anatomy", width: 100%)
    #v(-2pt)
    ```python
    phones = [{"name": "SEP0A1B2C3D4E60", "dn": "1002"},
              {"name": "SEP0A1B2C3D4E5F", "dn": "1001"}]
    sorted(phones, key=lambda p: p["dn"])  # by DN

    cdrs = [{"caller": "1001", "duration": 125},
            {"caller": "1002", "duration": 410}]
    max(cdrs, key=lambda c: c["duration"])
    # {'caller': '1002', 'duration': 410}
    ```
  ][
    A `lambda` is a tiny function without a name: one parameter list,
    one expression, returned automatically. It is used where a function
    is needed for a moment only.

    Its most common job is the `key=` argument. `sorted`, `min` and `max`
    call the key function on every item and compare the results instead
    of the items themselves.

    #pitfall[
      If a comprehension or lambda no longer fits on one readable line,
      write a normal loop or `def`. Short and clear beats clever.
    ]

    #collab[
      Sort phones by DN for a report, or find the longest call in a CDR
      export with `max(cdrs, key=…)`.
    ]
  ]
]

#section[Classes]

#slide(title: [Classes and objects])[
  #cols(ratio: (1, 1))[
    #diagram("class-blueprint", width: 88%)
    #v(-2pt)
    ```python
    class Phone:
        def __init__(self, name, model, dn):
            self.name = name        # attributes
            self.model = model
            self.dn = dn

    desk = Phone("SEP0A1B2C3D4E5F", "Cisco 8851", "1001")
    lobby = Phone("SEP0A1B2C3D4E60", "Cisco 8865", "1002")

    desk.dn          # '1001'
    lobby.model      # 'Cisco 8865'
    ```
  ][
    A *class* is a blueprint for your own type. It says which data
    (*attributes*) and which behaviour (*methods*) every object of that
    type has. Each *object* (instance) built from it has its own values.

    #methods(
      header: ([Part], [Meaning]),
      [`class Phone:`], [define a new type (CamelCase name)],
      [`__init__`], [runs when an object is created],
      [`self.name = …`], [store an attribute on the object],
      [`Phone(...)`], [create a new object],
      [`desk.dn`], [read an attribute with a dot],
    )

    #collab[
      A `dict` holds a phone's data. A class holds the data *and* the rules
      that belong to it, so every script treats a phone the same way.
    ]
  ]
]

#slide(title: [Methods and self])[
  #cols(ratio: (3, 2))[
    #diagram("class-self", width: 100%)
    #v(-2pt)
    ```python
    class Phone:
        VIDEO_MODELS = ("Cisco 8845", "Cisco 8865")  # shared

        def __init__(self, name, model, dn):
            self.name, self.model, self.dn = name, model, dn
            self.status = "Unknown"

        def mac(self):
            return self.name[3:]

        def is_video(self):
            return self.model in self.VIDEO_MODELS

    desk = Phone("SEP0A1B2C3D4E5F", "Cisco 8851", "1001")
    desk.mac()                   # '0A1B2C3D4E5F'
    desk.is_video()              # False
    desk.status = "Registered"   # attributes can change
    ```
  ][
    A *method* is a function defined inside a class. Its first parameter,
    `self`, is the object the method was called on. Python fills it in:
    `desk.mac()` runs as `Phone.mac(desk)`.

    Through `self` a method reads and changes the object's own attributes.
    A *class attribute* like `VIDEO_MODELS` is shared by all objects.

    Names with double underscores are special: `__init__` builds the
    object, `__repr__` decides how `print(desk)` looks.

    #pitfall[
      Forgetting `self` in `def mac():` raises a `TypeError`: "takes 0
      positional arguments but 1 was given".
    ]
  ]
]

#slide(title: [Classes in the libraries you will use])[
  #cols(ratio: (1, 1))[
    #diagram("response-object", width: 92%)
    #v(-2pt)
    ```python
    class AxlClient:
        def __init__(self, host, user, password):
            self.url = f"https://{host}:8443/axl/"
            self.auth = (user, password)

        def get_phone(self, name):
            ...        # send the AXL request here

    axl = AxlClient("cucm-pub.clauto.lab",
                    "axl_svc", password)
    axl.get_phone("SEP0A1B2C3D4E5F")
    ```
  ][
    Most of the time you *use* classes rather than write them. Every
    library hands you objects: you read their attributes and call their
    methods with a dot.

    #methods(
      header: ([Object], [From]),
      [`Response`], [`requests.get()`: `.status_code`, `.json()`],
      [`Session`], [`requests.Session()`: reuses login and connection],
      [`Client`], [`zeep.Client(wsdl)`: `.service.getPhone()`],
    )

    Writing a small class of your own pays off when several functions
    share the same settings, like host and credentials.

    #collab[
      An `AxlClient` stores the CUCM host and login once. Every script then
      just calls `axl.get_phone(...)` or `axl.add_line(...)`.
    ]
  ]
]

#section[Credentials]

#slide(title: [Keep secrets out of your code])[
  #cols(ratio: (1, 1))[
    #diagram("secrets-flow", width: 96%)
    #v(-2pt)
    ```python
    password = "Cisco123!"          # never do this

    from getpass import getpass
    password = getpass("AXL password: ")   # not echoed

    import os
    user = os.environ["AXL_USER"]   # KeyError if not set
    password = os.environ.get("AXL_PASSWORD")  # or None
    ```
    ```bash
    export AXL_USER=axl_svc         # in the terminal
    ```
  ][
    A password written in a script travels with the script: into git,
    into an email to a colleague, onto a shared screen. Keep secrets
    *outside* the code and read them when the script runs.

    #methods(
      header: ([Source], [Good for]),
      [`getpass()`], [interactive runs: asks, shows nothing],
      [`os.environ`], [values set in the shell or by a scheduler],
      [`.env` file], [per-project settings on your laptop],
    )

    `os.environ` behaves like a `dict` of strings: `[...]` fails on a
    missing name, `.get()` returns `None`.

    #collab[
      Use a dedicated AXL application user (`axl_svc`) with only the
      *Standard AXL API Access* and *Standard CCM Admin Users* roles,
      never your own admin account.
    ]
  ]
]

#slide(title: [.env files and a safe setup])[
  #cols(ratio: (1, 1))[
    #diagram("dotenv-flow", width: 92%)
    #v(-2pt)
    ```text
    # .env  (in .gitignore)
    CUCM_HOST=cucm-pub.clauto.lab
    AXL_USER=axl_svc
    AXL_PASSWORD=change-me
    ```
    ```python
    # pip install python-dotenv
    import os
    from dotenv import load_dotenv

    load_dotenv()                    # .env → os.environ
    missing = [k for k in ("AXL_USER", "AXL_PASSWORD")
               if k not in os.environ]
    if missing:
        raise SystemExit(f"missing settings: {missing}")
    ```
  ][
    `python-dotenv` reads a `.env` file and puts every line into
    `os.environ`. The code stays the same on your laptop, a jump host or
    a scheduler; only the `.env` changes.

    Checking all required settings *at the start* gives one clear
    message instead of a failure halfway through a bulk job.

    #methods(
      header: ([Do], [Why]),
      [add `.env` to `.gitignore`], [secrets never reach the repo],
      [commit `.env.example`], [others see which names are needed],
      [one AXL user per tool], [easy to audit and to revoke],
      [never `print` a secret], [logs and screens are shared],
    )
  ]
]
