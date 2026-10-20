#import "../template.typ": *

#chapter([APIs and Libraries], intro: [
  Every Cisco collaboration product can be driven through an API: CUCM
  through AXL and UDS, Unity Connection through CUPI, Webex through its
  REST API. This chapter covers the web basics behind all of them, the
  data formats they speak, and the two Python libraries that do the
  heavy lifting: `requests` for REST and `zeep` for SOAP.
])

#section[HTTP Basics]

#slide(title: [What is an API?])[
  #cols(ratio: (1, 1))[
    #diagram("http-cycle", width: 96%)
    #v(-2pt)
    ```text
    GET /v1/people?email=alice.smith@clauto.lab HTTP/1.1
    Host: webexapis.com
    Authorization: Bearer <token>
    Accept: application/json
    ```
    ```text
    HTTP/1.1 200 OK
    Content-Type: application/json

    {"items": [{"displayName": "Alice Smith", ...}]}
    ```
  ][
    An *API* (application programming interface) is a door into a system
    made for programs instead of people. Where an admin clicks through
    the GUI, a script sends the same request directly.

    Almost every modern API runs over *HTTP(S)*: the client sends a
    *request*, the server answers with a *response*. Both are plain text
    with the same structure: a first line, headers, an optional body.

    #methods(
      header: ([API], [Style]),
      [CUCM AXL, RISPort], [SOAP: XML over HTTPS],
      [CUCM UDS, Unity CUPI], [REST: XML or JSON],
      [Webex], [REST: JSON],
    )
  ]
]

#slide(title: [Methods and URLs])[
  #cols(ratio: (1, 1))[
    #diagram("url-anatomy", width: 100%)
    #v(-2pt)
    ```text
    GET    /v1/people?email=…    find a user
    POST   /v1/messages          send a message
    PUT    /v1/people/{id}       replace a user record
    DELETE /v1/people/{id}       remove a user
    ```
  ][
    The *method* says what to do, the *URL* says with what. Together they
    form the first line of every request.

    #methods(
      header: ([Method], [Meaning]),
      [`GET`], [read data, changes nothing],
      [`POST`], [create something new, or run an action],
      [`PUT`], [replace an existing record completely],
      [`PATCH`], [change part of a record],
      [`DELETE`], [remove a record],
    )

    The *query string* after `?` filters or pages the result:
    `?email=…`, `?max=100`.

    #collab[
      SOAP APIs like AXL use `POST` for everything, even for reads. The
      operation (`getPhone`, `addLine`) is written inside the XML body.
    ]
  ]
]

#slide(title: [Status codes, headers and auth])[
  #cols(ratio: (1, 1))[
    #diagram("http-status", width: 80%)
    #v(-2pt)
    ```text
    Content-Type: application/json    # what I send
    Accept: application/json          # what I want back
    Authorization: Basic YXhsX3N2YzpwYXNzd29yZA==
    Authorization: Bearer <access token>
    ```
  ][
    The *status code* in the first response line tells you at once if
    the request worked. *Headers* carry extra information for both sides,
    most importantly the format and the login.

    #methods(
      header: ([Code], [What it usually means for you]),
      [`401`], [wrong user / password, or token expired],
      [`403`], [login OK, but the role is missing],
      [`404`], [wrong URL or the record does not exist],
      [`429`], [too many requests: wait `Retry-After` seconds],
      [`500` `503`], [server error or service down],
    )

    #collab[
      AXL uses *Basic* auth (base64 of `user:password`). Webex uses a
      *Bearer* token. Lab CUCMs have self-signed certificates, so
      certificate checks need extra care.
    ]
  ]
]

#section[JSON and XML]

#slide(title: [Same data, two formats])[
  #cols(ratio: (1, 1))[
    #diagram("data-tree", width: 86%)
    #v(-2pt)
    ```json
    {"phone": {"name": "SEP0A1B2C3D4E5F",
               "model": "Cisco 8851",
               "lines": ["1001", "1002"]}}
    ```
    ```xml
    <phone>
      <name>SEP0A1B2C3D4E5F</name>
      <model>Cisco 8851</model>
      <lines><line>1001</line><line>1002</line></lines>
    </phone>
    ```
  ][
    APIs send structured data as text. Both formats describe the same
    *tree*: a phone with a name, a model and a list of lines.

    #methods(
      header: ([JSON], [XML]),
      [object `{"k": v}`], [element `<k>v</k>`],
      [array `[a, b]`], [the same element repeated],
      [`true` `null` numbers], [everything is text],
      [compact, maps to `dict`/`list`], [verbose, has attributes and namespaces],
    )

    JSON maps directly to Python with `json.loads()` (see 1.8.2). XML needs
    a parser that walks the tree.

    #collab[
      Webex and most new APIs use JSON. AXL, RIS and many CUCM and Unity
      APIs answer in XML, so you need both.
    ]
  ]
]

#slide(title: [Reading XML with ElementTree])[
  #cols(ratio: (1, 1))[
    #diagram("xml-anatomy", width: 100%)
    #v(-2pt)
    ```python
    import xml.etree.ElementTree as ET

    root = ET.fromstring(xml_text)     # str → tree
    root.get("totalCount")             # '2' (attribute)

    for user in root.findall("user"):
        print(user.findtext("userName"),
              user.findtext("phoneNumber"))
    # alice.smith 1001
    # bob.jones 1002

    [e.text for e in root.iter("phoneNumber")]
    ```
  ][
    `ElementTree` (standard library) turns XML text into a tree of
    *elements*. Each element has a `tag`, optional *attributes* and a
    *text*. You search the tree with simple paths like `"user/userName"`.

    #methods(
      [`ET.fromstring(s)`], [parse text, returns the root element],
      [`el.find(path)`], [first matching child, or `None`],
      [`el.findall(path)`], [`list` of all matches],
      [`el.findtext(path)`], [text of the first match],
      [`el.get(name)`], [an attribute value],
      [`el.iter(tag)`], [every element with that tag, any depth],
    )

    #collab[
      CUCM UDS returns users as XML like this: one `<user>` element per
      user, with `<userName>` and `<phoneNumber>` inside.
    ]
  ]
]

#slide(title: [Namespaces and the SOAP envelope])[
  #cols(ratio: (3, 2))[
    #diagram("soap-envelope", width: 70%)
    #v(-2pt)
    ```python
    SOAP = "http://schemas.xmlsoap.org/soap/envelope/"

    root = ET.fromstring(axl_reply)
    root.tag                        # '{' + SOAP + '}Envelope'
    root.find(".//phone/name").text # 'SEP0A1B2C3D4E5F'

    # prefixed tags need the namespace map
    root.find("soapenv:Body", {"soapenv": SOAP})
    ```
  ][
    A *namespace* is a URL that makes tag names unique: `soapenv:Body`
    really means `{http://…/envelope/}Body`. The short prefix
    (`soapenv:`, `ns:`) is only an alias declared with `xmlns:`.

    A SOAP reply wraps your data in layers: `Envelope`, `Body`, the
    operation response, then `return`. The `.//` path searches at any
    depth and skips the wrapping.

    #collab[
      AXL replies are SOAP envelopes, and AXL requests must be built the
      same way. Writing them by hand is slow and error-prone. `zeep`
      builds and unpacks them for you: that is the next section.
    ]
  ]
]

#section[requests]

#slide(title: [Your first request])[
  #cols(ratio: (1, 1))[
    #diagram("requests-call", width: 92%)
    #v(-2pt)
    ```python
    import os
    import requests          # pip install requests

    token = os.environ["WEBEX_TOKEN"]
    r = requests.get(
        "https://webexapis.com/v1/people/me",
        headers={"Authorization": f"Bearer {token}"},
        timeout=10,
    )
    r.status_code            # 200
    r.json()["displayName"]  # 'Alice Smith'
    r.raise_for_status()     # error if 4xx / 5xx
    ```
  ][
    `requests` turns an HTTP call into one function call. There is one
    function per method: `get`, `post`, `put`, `patch`, `delete`. Each
    returns a `Response` object.

    #methods(
      header: ([Response], [Gives you]),
      [`r.status_code` `r.ok`], [the code, `True` for 2xx],
      [`r.json()`], [body parsed into `dict` / `list`],
      [`r.text` `r.content`], [body as `str` / `bytes`],
      [`r.headers`], [response headers (a dict)],
      [`r.raise_for_status()`], [raise `HTTPError` on 4xx / 5xx],
    )

    #collab[
      `GET /v1/people/me` is the "hello world" of the Webex API: if it
      returns your name, the token works.
    ]
  ]
]

#slide(title: [Parameters, headers and JSON bodies])[
  #cols(ratio: (1, 1))[
    #diagram("requests-args", width: 90%)
    #v(-2pt)
    ```python
    url = "https://webexapis.com/v1"
    headers = {"Authorization": f"Bearer {token}"}

    query = {"email": "alice.smith@clauto.lab"}
    r = requests.get(f"{url}/people", headers=headers,
                     params=query, timeout=10)
    r.json()["items"][0]["displayName"]

    msg = {"toPersonEmail": "bob.jones@clauto.lab",
           "text": "SEP0A1B2C3D4E5F is down"}
    r = requests.post(f"{url}/messages", headers=headers,
                      json=msg, timeout=10)
    ```
  ][
    Keyword arguments map one to one onto the parts of the HTTP request.
    `requests` does the encoding: it builds the query string, turns the
    `dict` into JSON and sets `Content-Type`.

    - `params=` for filters in the URL. Never glue them in by hand.
    - `json=` for a JSON body (`POST`, `PUT`, `PATCH`).
    - `headers=` for tokens and formats.

    #pitfall[
      Without `timeout=` a request can wait *forever* if the server does
      not answer. Always set one, around 10 to 30 seconds.
    ]
  ]
]

#slide(title: [Auth, sessions and certificates])[
  #cols(ratio: (1, 1))[
    #diagram("requests-session", width: 90%)
    #v(-2pt)
    ```python
    r = requests.get(                       # Basic auth
        "https://cuc-pub.clauto.lab/vmrest/users",
        auth=("axl_svc", password),
        headers={"Accept": "application/json"},
        params={"query": "(alias is alice.smith)"},
        verify="certs/clauto-ca.pem",       # trust lab CA
        timeout=10)

    s = requests.Session()
    s.headers.update({"Authorization": f"Bearer {token}"})
    s.get(f"{url}/people/me", timeout=10)   # reused
    ```
  ][
    `auth=(user, password)` sends Basic auth, used by CUCM UDS and Unity
    CUPI. A `Session` keeps headers, auth and the TCP connection between
    calls: less code, and much faster in loops.

    `verify=` controls the TLS certificate check. Point it to your CA
    certificate file, so the check keeps protecting you.

    #warn[
      `verify=False` switches the check off and prints an
      `InsecureRequestWarning`. Acceptable for a first lab test, never
      for production scripts.
    ]
  ]
]

#slide(title: [Errors and timeouts])[
  #cols(ratio: (1, 1))[
    ```python
    import requests

    try:
        r = s.get(f"{url}/people/me", timeout=10)
        r.raise_for_status()
    except requests.exceptions.Timeout:
        print("no answer in 10 s")
    except requests.exceptions.ConnectionError:
        print("host unreachable: DNS, VPN, firewall?")
    except requests.exceptions.HTTPError as e:
        print("API error:", e)
        # 401 Client Error: Unauthorized for url: …
    else:
        me = r.json()
    ```
  ][
    A request can fail in three different places, and `requests` raises a
    different exception for each. All of them live in
    `requests.exceptions`.

    #methods(
      header: ([Case], [Handle with]),
      [no answer in time], [`timeout=` + `except Timeout`],
      [host unreachable], [`except ConnectionError`],
      [answer is 4xx / 5xx], [`raise_for_status()` + `except HTTPError`],
    )

    A 4xx or 5xx answer is *not* an exception by itself: `r.status_code`
    is simply `401`. Call `raise_for_status()` to turn it into one.

    #collab[
      In a bulk job, catch these inside the loop (see 1.7) and write the
      device and the error to `failed.csv`.
    ]
  ]
]

#slide(title: [Rate limits and paging])[
  #cols(ratio: (1, 1))[
    #diagram("requests-paging", width: 84%)
    #v(-2pt)
    ```python
    import time

    people, next_url = [], f"{url}/people?max=100"
    while next_url:
        r = s.get(next_url, timeout=10)
        if r.status_code == 429:           # slow down
            wait = int(r.headers.get("Retry-After", 5))
            time.sleep(wait)
            continue                       # same page
        r.raise_for_status()
        people += r.json()["items"]
        next_url = r.links.get("next", {}).get("url")
    ```
  ][
    APIs protect themselves. *Rate limits* cap how many requests you may
    send: above the limit you get `429 Too Many Requests`, and the
    `Retry-After` header says how long to wait.

    *Paging* splits long lists: each response carries one page, and a
    `Link` header with `rel="next"` points to the next one. Follow it
    until there is no next link.

    #collab[
      Listing all users of a Webex org is a paging loop. `r.links` parses
      the `Link` header for you: `r.links["next"]["url"]`.
    ]
  ]
]

#section[zeep and AXL]

#slide(title: [SOAP, WSDL and zeep])[
  #cols(ratio: (1, 1))[
    #diagram("zeep-flow", width: 84%)
    #v(-2pt)
    ```text
    schema/
    └── 15.0/                 one folder per CUCM version
        ├── AXLAPI.wsdl
        ├── AXLSoap.xsd
        └── AXLEnums.xsd
    ```
    ```bash
    pip install zeep
    ```
  ][
    A *WSDL* file is the contract of a SOAP API: every operation, every
    field and its type. `zeep` reads it once and turns each operation into
    a Python method, so `axl.getPhone(name=…)` builds the SOAP envelope,
    sends it and turns the reply into an object.

    #methods(
      header: ([Prerequisite], [Where]),
      [Cisco AXL Web Service active], [Serviceability, on the Publisher],
      [AXL application user], [roles: Standard AXL API Access, Standard CCM Admin Users],
      [WSDL for *your* version], [CM Admin: Application → Plugins → AXL Toolkit],
      [Tomcat CA certificate], [OS Admin: Certificate Management],
    )

    #warn[
      The WSDL must match the cluster version. An older schema "mostly
      works" and silently misses newer fields. Re-test after every upgrade.
    ]
  ]
]

#slide(title: [Connecting to AXL])[
  #cols(ratio: (3, 2))[
    ```python
    from requests import Session
    from zeep import Client, Settings
    from zeep.cache import SqliteCache
    from zeep.transports import Transport

    BINDING = "{http://www.cisco.com/AXLAPIService/}AXLAPIBinding"
    URL = "https://cucm-pub.clauto.lab:8443/axl/"

    session = Session()
    session.auth = (user, password)       # from os.environ (1.11)
    session.verify = "certs/clauto-ca.pem"
    transport = Transport(session=session, timeout=30,
                          cache=SqliteCache())
    settings = Settings(strict=False, xml_huge_tree=True)
    client = Client("schema/15.0/AXLAPI.wsdl",
                    transport=transport, settings=settings)
    axl = client.create_service(BINDING, URL)

    axl.getCCMVersion()["return"]["componentVersion"]["version"]
    # '15.0.1.11900-23'
    ```
  ][
    The connection is built in layers. A `requests` `Session` carries the
    login and the certificate check. A `Transport` adds caching and a
    timeout. The `Client` reads the WSDL, and `create_service` points it
    at your Publisher.

    `SqliteCache` keeps the parsed WSDL on disk: the AXL schema is large,
    and parsing it on every run is slow.

    Run `getCCMVersion` first. If it returns a version, four things are
    proven at once: network, credentials, roles and certificate.

    #collab[
      Wrap these lines in one `get_axl()` function or the `AxlClient`
      class from 1.10. Every script then starts with one line.
    ]
  ]
]

#slide(title: [Reading one phone · getPhone])[
  #cols(ratio: (1, 1))[
    #diagram("get-vs-list", width: 96%)
    #v(-2pt)
    ```python
    from zeep.helpers import serialize_object

    resp = axl.getPhone(name="SEP0A1B2C3D4E5F")
    phone = resp["return"]["phone"]

    phone.name               # 'SEP0A1B2C3D4E5F'
    phone.devicePoolName     # {'_value_1': 'DP_HQ',
                             #  'uuid': '{…}'}
    def axl_text(value):     # unwrap safely
        return getattr(value, "_value_1", value)

    axl_text(phone.devicePoolName)   # 'DP_HQ'
    serialize_object(phone, dict)    # plain dict
    ```
  ][
    `get` operations return *one* object with every field. The data is
    always inside `resp["return"]`, under the object name (`phone`, `line`,
    `user`). zeep objects work with dots and with brackets.

    Fields that point to other objects (device pool, CSS, location) come
    back as `{_value_1: name, uuid: …}`. Read them through one helper like
    `axl_text()`, never with `._value_1` all over the code: the shape can
    change between AXL versions.

    #pitfall[
      `getPhone` for a name that does not exist raises a `Fault`, not
      `None`. Wrap it in `try` / `except Fault` (next slides).
    ]
  ]
]

#slide(title: [Reading many phones · listPhone])[
  #cols(ratio: (1, 1))[
    #diagram("axl-paging", width: 74%)
    #v(-2pt)
    ```python
    def list_all(method, criteria, tags, page=500):
        skip = 0
        while True:
            resp = method(searchCriteria=criteria,
                          returnedTags=tags,
                          first=page, skip=skip)
            rows = resp["return"]
            batch = rows["phone"] if rows else []
            yield from batch
            if len(batch) < page:
                return
            skip += page

    tags = {"name": "", "description": ""}
    for p in list_all(axl.listPhone, {"name": "SEP%"},
                      tags):
        print(p.name, p.description)
    ```
  ][
    `list` operations return *many* objects, but only the fields you name
    in `returnedTags`. Three rules keep the Publisher healthy:

    #methods(
      header: ([Rule], [Why]),
      [always set `returnedTags`], [every field × 5000 phones = overload],
      [narrow `searchCriteria`], [`%` alone matches the whole cluster],
      [page with `first` / `skip`], [stop when a page comes back short],
    )

    `yield from` makes `list_all` a *generator*: it hands out one phone at
    a time, page after page, without holding them all in memory.

    #collab[
      `list_all` works for `listLine`, `listUser` and the other `list`
      operations too: only the result key changes.
    ]
  ]
]

#slide(title: [Adding objects · nested data])[
  #cols(ratio: (3, 2))[
    #diagram("axl-nested-write", width: 58%)
    #v(-2pt)
    ```python
    phone = {
        "name": "CSFALICE",
        "product": "Cisco Unified Client Services Framework",
        "class": "Phone", "protocol": "SIP", "protocolSide": "User",
        "commonPhoneConfigName": "Standard Common Phone Profile",
        "locationName": "Hub_None", "devicePoolName": "DP_HQ",
        "phoneTemplateName": "Standard Client Services Framework",
        "ownerUserName": "alice.smith",
        "lines": {"line": [
            {"index": "1", "label": "1001",
             "dirn": {"pattern": "1001",
                      "routePartitionName": "PT_Internal"}},
        ]},
    }
    axl.addPhone(phone=phone)      # returns the new uuid
    ```
  ][
    `add` operations take *one* argument named after the object
    (`phone=`, `user=`, `css=`, `sipTrunk=`) whose value is a nested `dict`
    that mirrors the AXL XML. zeep turns it into the request element by
    element.

    Every repeating element follows the same pattern: a *plural* wrapper
    key holding a *list* under the *singular* key.

    #pitfall[
      `updatePhone(name=…, lines={"line": […]})` *replaces* the whole line
      list. Send every line the phone should keep, not only the new one.
    ]

    #collab[
      The same shape adds partitions in a loop (`addRoutePartition`), CSS
      members (`members/member`) or trunk destinations.
    ]
  ]
]

#slide(title: [Writing data and handling faults])[
  #cols(ratio: (1, 1))[
    #diagram("axl-write-verify", width: 96%)
    #v(-2pt)
    ```python
    import time
    from zeep.exceptions import Fault

    for name, desc in updates.items():
        try:
            axl.updatePhone(name=name, description=desc)
        except Fault as e:
            failed.append((name, e.message))
            continue
        now = axl.getPhone(name=name)["return"]["phone"]
        if now.description != desc:
            failed.append((name, "not applied"))
        time.sleep(0.2)          # spare the Publisher
    ```
  ][
    `add`, `update` and `remove` operations change the database. Treat
    every write the same way: catch the `Fault`, re-read to *verify*, and
    pause between writes.

    #methods(
      header: ([Fault text (varies by release)], [Usual cause]),
      [`Item not valid … not found`], [typo in a name, pool or CSS],
      [`duplicate value`], [the object already exists],
      [`User not authorized`], [AXL role missing],
      [HTTP `503`], [write throttling: wait, then retry],
    )

    #warn[
      Send writes to the *Publisher* only. AXL is not real time and
      throttles bursts. It also does not know registration state: that
      lives in RisPort70.
    ]
  ]
]

#slide(title: [Seeing the raw XML · HistoryPlugin])[
  #cols(ratio: (3, 2))[
    #diagram("axl-history", width: 62%)
    #v(-2pt)
    ```python
    from lxml import etree
    from zeep.plugins import HistoryPlugin

    history = HistoryPlugin()
    client = Client(wsdl, transport=transport, plugins=[history])

    def show_history():
        for item in (history.last_sent, history.last_received):
            print(etree.tostring(item["envelope"], encoding="unicode",
                                 pretty_print=True))

    try:
        axl.addPhone(phone=phone)
    except Fault as f:
        print(f.message)
        show_history()          # what exactly was sent?
    ```
  ][
    When AXL answers with a `Fault`, the message alone is often not
    enough. `HistoryPlugin` keeps the last request and the last response
    as XML, so you can see exactly what zeep sent and what CUCM returned.

    Compare the sent XML with the AXL schema reference or with a request
    that works in SoapUI: missing fields, wrong nesting or a typo in an
    element name show up immediately.

    #tip[
      Call `show_history()` inside every `except Fault` while a script is
      new. Remove it, or log it to a file, once the script is stable.
    ]
  ]
]

#slide(title: [SQL queries · executeSQLQuery])[
  #cols(ratio: (3, 2))[
    ```python
    sql = """
    select d.name, n.dnorpattern
    from device d
    join devicenumplanmap m on m.fkdevice = d.pkid
    join numplan n on n.pkid = m.fknumplan
    where d.name like 'SEP%'
    """
    resp = axl.executeSQLQuery(sql=sql)
    rows = resp["return"]["row"] if resp["return"] else []

    for row in rows:              # row = list of XML elements
        print({el.tag: el.text for el in row})
    # {'name': 'SEP0A1B2C3D4E5F', 'dnorpattern': '1001'}
    # {'name': 'SEP0A1B2C3D4E60', 'dnorpattern': '1002'}
    ```
  ][
    *Thick AXL* runs a read-only SQL query on the CUCM database and
    returns one `row` per result line. Each row is a list of XML elements:
    `el.tag` is the column name, `el.text` the value.

    One query can join tables that would need many `list` calls, which
    makes it ideal for cluster-wide reports.

    #warn[
      Prefer normal AXL methods when one exists: table and column names
      change between releases (check the *Data Dictionary* for yours).
      Never use `executeSQLUpdate`: it bypasses CUCM's business logic.
    ]
  ]
]

#slide(title: [A safe AXL workflow])[
  #cols(ratio: (1, 1))[
    #diagram("axl-workflow", width: 92%)
    #v(-2pt)
    ```python
    import argparse

    p = argparse.ArgumentParser()
    p.add_argument("--input-file", required=True)
    p.add_argument("--apply", action="store_true")
    args = p.parse_args()

    changes = plan(axl, read_input(args.input_file))
    print_plan(changes)
    if not args.apply:
        raise SystemExit("DRY RUN: use --apply to write")
    write_rollback(changes)          # old values first
    apply_and_verify(axl, changes)
    ```
  ][
    A script that only writes is dangerous. A script that checks, shows
    the plan, writes, re-checks and records is a tool you can trust in a
    change window.

    #methods(
      header: ([Use], [When]),
      [BAT], [uniform change, fits a BAT template],
      [Python + AXL], [each object needs a decision, a check, or data
        from another system],
    )

    *Dry run is the default.* Writing needs an explicit `--apply`, and the
    old values are saved before the first write.

    #collab[
      Working examples: `github.com/ilkermansur/collab_automation`
      (AXL, RIS, CMS, Expressway, Netmiko). Read more: "Automating Cisco
      Voice Administration (CUCM) with Python", Cisco Community, 2026.
    ]
  ]
]

#section[RisPort70]

#slide(title: [Real-time status with RisPort70])[
  #cols(ratio: (1, 1))[
    #diagram("axl-vs-ris", width: 92%)
    #v(-2pt)
    ```python
    HOST = "https://cucm-pub.clauto.lab:8443"
    RIS = HOST + "/realtimeservice2/services/RISService70"
    NS = "{http://schemas.cisco.com/ast/soap}"

    client = Client(RIS + "?wsdl", transport=transport)
    ris = client.create_service(NS + "RisBinding", RIS)
    ```
  ][
    AXL only knows the *configuration*: a phone exists, has DN 1001, sits in
    `DP_HQ`. Whether it is registered right now lives in the *Real-time
    Information Service* (RIS). RisPort70 is its SOAP API.

    It works with the same tools as AXL: a `requests` `Session`, a zeep
    `Transport` and `create_service`. The WSDL is served by CUCM itself,
    so there is no toolkit to download.

    #methods(
      header: ([AXL], [RisPort70]),
      [`/axl/`], [`/realtimeservice2/services/RISService70`],
      [WSDL from the AXL Toolkit], [WSDL from `…/RISService70?wsdl`],
      [config: what it *should* be], [state: what it *is* now],
    )

    #collab[
      The application user needs the *Standard CCM Admin Users* and
      *Standard RealtimeAndTraceCollection* roles.
    ]
  ]
]

#slide(title: [Asking for device status · selectCmDevice])[
  #cols(ratio: (3, 2))[
    #diagram("ris-tree", width: 46%)
    #v(-2pt)
    ```python
    def ris_status(names):
        criteria = {
            "MaxReturnedDevices": 1000, "DeviceClass": "Phone",
            "Model": 255, "Status": "Any",   # 255 = any model
            "SelectBy": "Name",
            "SelectItems": {"item": [{"Item": n} for n in names]},
        }
        resp = ris.selectCmDevice(StateInfo="",
                                  CmSelectionCriteria=criteria)
        status = {}
        for node in resp["SelectCmDeviceResult"]["CmNodes"]["item"]:
            found = node["CmDevices"]    # None if the node has none
            for dev in (found["item"] if found else []):
                status[dev["Name"]] = (dev["Status"], node["Name"])
        return status
    ```
  ][
    `selectCmDevice` takes *selection criteria*: which device class,
    which status, and a list of names (wildcards like `SEP*` work too).

    The answer is grouped *per CUCM node*. A phone appears under the node
    it is registered to, so loop over every node.

    #methods(
      header: ([Status], [Meaning]),
      [`Registered`], [online on that node],
      [`UnRegistered`], [was registered, now gone],
      [`Rejected`], [CUCM refused the registration],
    )

    #pitfall[
      Reading only `CmNodes["item"][0]` checks the Publisher alone.
      Phones registered to a Subscriber are silently missed.
    ]
  ]
]

#slide(title: [Limits and an unregistered-phone report])[
  #cols(ratio: (3, 2))[
    #diagram("ris-join", width: 36%)
    #v(-2pt)
    ```python
    def chunks(items, size=1000):        # max per request
        for i in range(0, len(items), size):
            yield items[i:i + size]

    phones = list_all(axl.listPhone, {"name": "SEP%"},
                      {"name": ""})               # AXL
    names = [p.name for p in phones]
    status = {}
    for part in chunks(names):
        status.update(ris_status(part))           # RIS
        time.sleep(5)                             # limit

    for name in names:
        state, node = status.get(name, ("not seen", "-"))
        if state != "Registered":
            print(name, state, node)
    ```
  ][
    RIS protects the cluster with hard limits: at most *1000 devices per
    request*, and by default about *15 requests per minute*. Larger
    inventories are sent in chunks with a pause in between.

    A phone that has not tried to register since the last CUCM restart
    is not in RIS at all. Only joining with the AXL inventory finds it:
    configured but "not seen".

    #collab[
      Run this report every morning: the AXL list says what should be
      online, RIS says what is. The difference is the list for the site
      team.
    ]
  ]
]

#section[Netmiko]

#slide(title: [CLI automation over SSH])[
  #cols(ratio: (3, 2))[
    #diagram("netmiko-ssh", width: 70%)
    #v(-2pt)
    ```python
    import os
    from netmiko import ConnectHandler   # pip install netmiko

    cube = {
        "device_type": "cisco_xe",
        "host": "cube-01.clauto.lab",
        "username": os.environ["CUBE_USER"],
        "password": os.environ["CUBE_PASSWORD"],
    }

    with ConnectHandler(**cube) as conn:     # SSH login
        print(conn.send_command("show version | include uptime"))
    # cube-01 uptime is 12 weeks, 3 days, 4 hours
    ```
  ][
    Not every box has an API. CUBE and IOS voice gateways are configured
    through the *CLI*. Netmiko opens an SSH session, sends a command,
    waits for the prompt and returns the output as a `str`.

    #methods(
      header: ([Part], [Meaning]),
      [`device_type`], [CLI flavour: `cisco_xe` for CUBE on IOS-XE],
      [`ConnectHandler(**d)`], [log in; `**` unpacks the dict (1.6.1)],
      [`with … as conn`], [logs out automatically at the end],
      [`send_command(cmd)`], [run one `show` command, get the text],
    )

    #pitfall[
      Without `with`, call `conn.disconnect()` yourself. Forgotten
      sessions stay open until the VTY lines on the router run out.
    ]
  ]
]

#slide(title: [Turning show output into data])[
  #cols(ratio: (3, 2))[
    #diagram("netmiko-parse", width: 70%)
    #v(-2pt)
    ```python
    import re

    out = conn.send_command("show call active voice brief")
    m = re.search(r"Total call-legs:\s*(\d+)", out)
    legs = int(m.group(1)) if m else 0
    calls = legs // 2          # one call = two legs on CUBE

    rows = conn.send_command("show ip interface brief",
                             use_textfsm=True)
    rows[0]   # {'interface': 'GigabitEthernet1', 'status': 'up', …}
    ```
  ][
    CLI output is text made for humans. Picking a value by line number
    and column (`splitlines()[13].split()[4]`) breaks as soon as a
    software upgrade adds one line.

    - *Regex* (`re`) finds a value by its label: `Total call-legs:`
      works wherever that line moves.
    - *TextFSM* (`use_textfsm=True`) parses known commands into a list of
      dicts using the ntc-templates collection.

    #warn[
      ntc-templates covers many routing commands but almost no voice
      commands (only `show isdn status` today). For CUBE, plan on regex.
    ]
  ]
]

#slide(title: [Changing configuration])[
  #cols(ratio: (3, 2))[
    #diagram("netmiko-config", width: 72%)
    #v(-2pt)
    ```python
    def alternate_announcement(conn, enable):
        commands = [
            "dial-peer voice 9000 voip",
            "no shutdown" if enable else "shutdown",
        ]
        out = conn.send_config_set(commands)
        if "% Invalid" in out:
            raise RuntimeError(out)
        conn.save_config()             # write memory

    with ConnectHandler(**cube) as conn:
        alternate_announcement(conn, enable=True)
        print(conn.send_command("show dial-peer voice summary"))
    ```
  ][
    `send_config_set` takes a *list* of config lines. It enters
    configuration mode, sends every line and leaves again. `save_config()`
    then writes the running config to startup.

    The router does not raise an error for a wrong command: it answers
    with `% Invalid input`. Check the returned text, and verify the
    result with a `show` command.

    #pitfall[
      Do not put `"conf t"` into the list: Netmiko already entered config
      mode, so the extra line only adds noise or an error.
    ]
  ]
]

#slide(title: [Scheduled checks · RIS + CUBE])[
  #cols(ratio: (3, 2))[
    #diagram("netmiko-monitor", width: 74%)
    #v(-2pt)
    ```python
    import time
    from netmiko import (NetmikoTimeoutException,
                         NetmikoAuthenticationException)

    agents = ["CSFAGENT01", "CSFAGENT02"]

    while True:
        status = ris_status(agents)                  # 2.5
        up = any(s == "Registered" for s, _ in status.values())
        try:
            with ConnectHandler(**cube) as conn:
                alternate_announcement(conn, enable=not up)
        except (NetmikoTimeoutException,
                NetmikoAuthenticationException) as e:
            print(time.asctime(), "CUBE not reachable:", e)
        time.sleep(60)
    ```
  ][
    Scripts become most useful when they combine sources: RIS knows
    whether the contact-center agents are registered, the CUBE decides
    where calls go. A loop with `time.sleep()` (or the `schedule`
    package) runs the check every minute.

    Netmiko raises its own exceptions for a host that does not answer
    and for a wrong login. Catch them, log them, and keep the loop alive.

    #collab[
      If no agent's Jabber is registered, enable the dial peer that sends
      callers to an alternate announcement. When an agent is back, shut
      it again.
    ]
  ]
]

#section[CMS REST API]

#slide(title: [Cisco Meeting Server API])[
  #cols(ratio: (3, 2))[
    #diagram("cms-flow", width: 72%)
    #v(-2pt)
    ```python
    import os
    import requests
    import xmltodict                  # pip install xmltodict

    BASE = "https://cms-01.clauto.lab:445/api/v1"
    s = requests.Session()
    s.auth = (os.environ["CMS_USER"], os.environ["CMS_PASSWORD"])
    s.verify = "certs/clauto-ca.pem"

    r = s.get(f"{BASE}/system/status", timeout=10)
    r.raise_for_status()
    status = xmltodict.parse(r.content)["status"]
    status["softwareVersion"], status["callLegsActive"]
    # ('3.10', '2')
    ```
  ][
    CMS has a REST API on its *Web Admin* port (often 445). It uses Basic
    auth, sends *form data* for writes and answers in *XML*, not JSON.

    `xmltodict` turns the XML into nested dicts, so the rest feels like
    working with JSON from Webex.

    #methods(
      header: ([Object], [Endpoint]),
      [spaces], [`/coSpaces`, `/coSpaces/<id>`],
      [active meetings], [`/calls`],
      [participants], [`/calls/<id>/callLegs`],
      [server health], [`/system/status`],
    )

    #collab[
      Create an *API user* in CMS for scripts (`api_svc`), separate from
      the admin login, and keep it in `.env` (1.11).
    ]
  ]
]

#slide(title: [Example 1 · list all spaces])[
  #cols(ratio: (3, 2))[
    #diagram("cms-xmltodict", width: 72%)
    #v(-2pt)
    ```python
    def list_spaces(name_filter=""):
        spaces, offset = [], 0
        while True:
            params = {"offset": offset, "limit": 20,
                      "filter": name_filter}
            r = s.get(f"{BASE}/coSpaces", params=params, timeout=10)
            r.raise_for_status()
            xml = xmltodict.parse(r.content, force_list=("coSpace",))
            data = xml["coSpaces"]
            page = data.get("coSpace", [])
            spaces += page
            offset += len(page)
            if not page or offset >= int(data["@total"]):
                return spaces

    for sp in list_spaces():
        print(sp["@id"], sp["name"])
    ```
  ][
    CMS returns lists in small pages. The root element carries the
    `total` count. Move `offset` forward page by page until you have
    `total` items.

    `filter` searches by name on the server, so you do not download
    every space to find one.

    #pitfall[
      With one result, `xmltodict` returns a single `dict` instead of a
      `list`, and the `for` loop walks over its keys. Pass
      `force_list=("coSpace",)` to always get a list.
    ]
  ]
]

#slide(title: [Example 2 · create spaces from a CSV])[
  #cols(ratio: (3, 2))[
    #diagram("cms-create", width: 62%)
    #v(-2pt)
    ```python
    import csv

    with open("users.csv", newline="", encoding="utf-8") as f:
        for row in csv.DictReader(f):
            form = {"name": f"{row['name']} Space",
                    "uri": f"{row['user']}.space",
                    "passcode": "4711"}
            r = s.post(f"{BASE}/coSpaces", data=form, timeout=10)
            if r.status_code != 200:
                print("failed:", row["user"], r.text)
                continue
            space_id = r.headers["Location"].split("/")[-1]
            print("created", form["uri"], space_id)

    s.put(f"{BASE}/coSpaces/{space_id}", data={"passcode": "2026"})
    s.delete(f"{BASE}/coSpaces/{space_id}")
    ```
  ][
    Writes send *form data*: `data=` (not `json=`) in `requests`. A
    successful `POST` returns an empty body; the new object's id is in
    the `Location` header.

    #methods(
      header: ([Call], [Effect]),
      [`POST /coSpaces`], [create a space],
      [`PUT /coSpaces/<id>`], [change only the fields you send],
      [`DELETE /coSpaces/<id>`], [remove the space],
    )

    Errors come back as `400` with a `<failureDetails>` element, for
    example `duplicateCoSpaceUri`: log it and go on (1.7).
  ]
]

#slide(title: [Example 3 · who is in which meeting])[
  #cols(ratio: (3, 2))[
    #diagram("cms-calls", width: 66%)
    #v(-2pt)
    ```python
    def get_xml(path, key, item):
        r = s.get(f"{BASE}{path}", timeout=10)
        r.raise_for_status()
        return xmltodict.parse(r.content, force_list=(item,))[key]

    calls = get_xml("/calls", "calls", "call")
    for call in calls.get("call", []):
        legs = get_xml(f"/calls/{call['@id']}/callLegs",
                       "callLegs", "callLeg")
        print(f"{call['name']}: {legs['@total']} participants")
        for leg in legs.get("callLeg", []):
            print("   ", leg["name"], leg["remoteParty"])
    # Space 01: 2 participants
    #     Alice Smith alice.smith@clauto.lab
    #     Bob Jones bob.jones@clauto.lab
    ```
  ][
    An active meeting is a *call*; every participant in it is a *call
    leg*. Two nested requests give a live meeting report.

    A small helper like `get_xml()` keeps the parsing in one place, so
    every new report is just a few lines.

    #collab[
      Run it before maintenance: if no call is active, CMS can be
      restarted without dropping a meeting. Add it to the daily RIS
      report (2.5) for one morning overview.
    ]
  ]
]

#section[Remote Phone Control]

#slide(title: [The phone's own web server])[
  #cols(ratio: (1, 1))[
    #diagram("phone-web", width: 96%)
    #v(-2pt)
    ```text
    POST http://<phone>/CGI/Execute
    Content-Type: application/x-www-form-urlencoded

    XML=<CiscoIPPhoneExecute>
          <ExecuteItem URL="Key:Settings"/>
        </CiscoIPPhoneExecute>
    ```
    ```python
    def phone_hosts(names):     # ris_status (2.5), but
        ...                     # keeps the address
        for dev in devs:
            ip = dev["IPAddress"]["item"][0]["IP"]
            hosts[dev["Name"]] = ip
        return hosts
    ```
  ][
    Some jobs have no API at all: erasing the ITL file, resetting a menu
    setting, taking a picture of the screen. But every Cisco IP phone runs
    a small web server, and `/CGI/Execute` lets a script *press keys* or
    *dial* as if someone stood in front of the phone.

    #methods(
      header: ([Prerequisite], [Where]),
      [Web Access enabled], [phone config in CUCM],
      [end user with the phone], [user's *Controlled Devices*],
      [phone address], [from RIS (`IPAddress`), never typed by hand],
    )

    The phone asks CUCM to check the login, so a normal end user that
    owns the phone is enough. The reply is a small XML document:
    `<ResponseItem … Status="0"/>` means success.
  ]
]

#slide(title: [Pressing keys remotely])[
  #cols(ratio: (3, 2))[
    #diagram("phone-keys", width: 82%)
    #v(-2pt)
    ```python
    import time
    import xml.etree.ElementTree as ET
    import requests

    def press(host, item, wait=1):
        xml = f'<CiscoIPPhoneExecute><ExecuteItem URL="{item}"/>' \
              '</CiscoIPPhoneExecute>'
        r = requests.post(f"http://{host}/CGI/Execute",
                          data={"XML": xml}, auth=auth, timeout=10)
        r.raise_for_status()
        time.sleep(wait)                     # let the menu open
        return ET.fromstring(r.content).find("ResponseItem") \
                 .get("Status") == "0"

    ITL_88XX = ["Key:Applications", "Key:KeyPad6", "Key:KeyPad4",
                "Key:KeyPad4", "Key:Soft3", "Key:Soft1"]
    for name, host in phone_hosts(phones).items():   # from RIS
        ok = all(press(host, key) for key in ITL_88XX)
        print(name, "done" if ok else "check manually")
    ```
  ][
    Each `ExecuteItem` is one action. A key sequence is a list, sent one
    `POST` at a time with a short pause, exactly like a person walking
    through the menu.

    #methods(
      header: ([Item], [Action]),
      [`Key:Settings` `Key:Applications`], [hard keys],
      [`Key:KeyPad0` … `Key:KeyPad9`], [dial pad],
      [`Key:Soft1` … `Key:Soft4`], [soft keys under the screen],
      [`Dial:1002`], [place a call],
    )

    #warn[
      Menu paths differ by model and firmware: keep one key list per
      model and test it on one phone first. The script cannot see the
      screen, so a missed step goes unnoticed (next slide).
    ]
  ]
]

#slide(title: [Screenshots · CGI/Screenshot])[
  #cols(ratio: (3, 2))[
    ```python
    from pathlib import Path

    def screenshot(name, host):
        r = requests.get(f"http://{host}/CGI/Screenshot",
                         auth=auth, timeout=10)
        r.raise_for_status()
        out = Path("shots") / f"{name}.png"
        out.parent.mkdir(exist_ok=True)
        out.write_bytes(r.content)     # bytes, 1.3.10
        return out

    for name, host in phone_hosts(phones).items():
        try:
            print(screenshot(name, host))
        except requests.exceptions.RequestException as e:
            print(name, "failed:", e)
    # shots/SEP0A1B2C3D4E5F.png
    ```
  ][
    A `GET` on `/CGI/Screenshot` returns the current screen as an image.
    `r.content` holds the raw `bytes`, written straight to a `.png` file.

    Use it to *verify* what the key presses did, or to document a
    problem without visiting the desk: "is the line registered", "which
    error is on the screen".

    #collab[
      After a bulk ITL erase, take a screenshot of every phone and scroll
      through the folder: one look shows which phones did not reach the
      expected menu.
    ]

    #tip[
      Working reference: `erase_itl.py` in the course repository holds
      tested key sequences for 69xx, 78xx, 88xx and 99xx models.
    ]
  ]
]

#section[Wrap-up]

#slide(title: [What you can do now])[
  #cols(ratio: (1, 1))[
    #diagram("course-map", width: 100%)
  ][
    In five days you went from the first `print` to scripts that read,
    change and check a whole collaboration cluster:

    - *Python* as the language: data, decisions, loops, functions, files
      and errors.
    - *APIs* as the doors: AXL and RIS on CUCM, REST on Webex and CMS,
      SSH on CUBE, the web server on every phone.
    - *A safe way of working*: secrets outside the code, dry run first,
      verify after every change, keep a record.

    #collab[
      Start small: one read-only report that runs every morning. Every
      later script reuses the same connection, loop and error handling.
    ]
  ]
]
