#import "../../template.typ": *

#section[JSON and XML]

#topic[Same data, two formats]

API'ler yapılandırılmış veriyi *metin* olarak gönderir. En yaygın iki format JSON ve XML'dir. İkisi de aynı şeyi anlatır: bir *ağaç* (tree). Aşağıdaki phone'un bir adı, bir modeli ve bir line listesi var.

#diagram("data-tree", width: 66%, caption: [Aynı veri, aynı ağaç yapısı: iki farklı yazım.])

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

#walk(
  ("1–3", [JSON'da süslü parantez bir *nesneyi* (object) anlatır: `"key": value` çiftleri. Köşeli parantez bir *dizidir* (array). Bu, Python'daki `dict` ve `list` ile birebir örtüşür.]),
  ("1–5", [XML'de her bilgi bir *element*'tir: `<name>...</name>`. Açılış ve kapanış etiketleri (tag) arasında değer ya da başka element'ler bulunur.]),
  ("4–5", [XML'de bir dizi yoktur; aynı element tekrarlanır: iki `<line>` iki line demektir.]),
)

#methods(
  header: ([JSON], [XML]),
  [nesne `{"k": v}`], [element `<k>v</k>`],
  [dizi `[a, b]`], [aynı element tekrarlanır],
  [`true` `null` ve sayılar], [her şey metindir],
  [kompakt, `dict` / `list`'e çevrilir], [ayrıntılı, attribute ve namespace içerir],
)

JSON, `json.loads()` ile doğrudan Python'a çevrilir (bkz. 1.8.2). XML ise ağacı gezen bir ayrıştırıcı (parser) ister.

#collab[
  Webex ve çoğu yeni API JSON kullanır. AXL, RIS ve birçok CUCM ve Unity API'si XML ile cevap verir; ikisine de ihtiyacınız olacak.
]

#topic[Reading XML with ElementTree]

Standart kütüphanedeki `ElementTree`, XML metnini bir *element ağacına* çevirir. Her element'in bir `tag`'ı, isteğe bağlı *attribute*'ları ve bir *text*'i vardır. Ağaçta `"user/userName"` gibi basit yollarla arama yaparsınız.

#diagram("xml-anatomy", width: 78%, caption: [Bir XML element'i: tag, attribute ve text.])

```python
import xml.etree.ElementTree as ET

root = ET.fromstring(xml_text)     # str → ağaç
root.get("totalCount")             # '2' (attribute)

for user in root.findall("user"):
    print(user.findtext("userName"),
          user.findtext("phoneNumber"))
# alice.smith 1001
# bob.jones 1002

[e.text for e in root.iter("phoneNumber")]
```

#walk(
  ("1", [`ElementTree`'yi `ET` takma adıyla getiriyoruz.]),
  ("3", [`fromstring()` XML metnini ayrıştırır ve *kök* (root) element'i döndürür.]),
  ("4", [`get()` bir *attribute* değerini okur. Attribute'lar `<users totalCount="2">` gibi etiketin içinde yazılır.]),
  ("6", [`findall("user")` kökün altındaki *bütün* `<user>` element'lerini bir list olarak verir.]),
  ("7–8", [`findtext()` bir alt element'in metnini döndürür.]),
  ("12", [`iter("phoneNumber")` ağacın *herhangi bir derinliğindeki* bütün `<phoneNumber>`'ları bulur. Burada bir comprehension ile metinlerini topluyoruz.]),
)

#methods(
  [`ET.fromstring(s)`], [metni ayrıştırır, kök element'i döndürür],
  [`el.find(path)`], [ilk eşleşen alt element; yoksa `None`],
  [`el.findall(path)`], [bütün eşleşenlerin `list`'i],
  [`el.findtext(path)`], [ilk eşleşenin metni],
  [`el.get(name)`], [bir attribute değeri],
  [`el.iter(tag)`], [bu tag'e sahip her element, her derinlikte],
)

#collab[
  CUCM UDS kullanıcıları böyle bir XML olarak döndürür: her kullanıcı için bir `<user>` element'i ve içinde `<userName>` ile `<phoneNumber>`.
]

#topic[Namespaces and the SOAP envelope]

Bir *namespace*, tag isimlerini benzersiz yapan bir URL'dir: `soapenv:Body` aslında `{http://…/envelope/}Body` anlamına gelir. Kısa önek (`soapenv:`, `ns:`) yalnızca `xmlns:` ile tanımlanan bir takma addır.

Bir SOAP cevabı, veriyi katmanlar halinde sarar: `Envelope`, `Body`, operasyonun cevabı, sonra `return`. Bu sarmalayıcıları atlayıp doğrudan veriye gitmek için `.//` yolu kullanılır: *herhangi bir derinlikte ara*.

#diagram("soap-envelope", width: 66%, caption: [Bir SOAP cevabı: zarf (Envelope), gövde (Body) ve asıl veri.])

```python
SOAP = "http://schemas.xmlsoap.org/soap/envelope/"

root = ET.fromstring(axl_reply)
root.tag                        # '{' + SOAP + '}Envelope'
root.find(".//phone/name").text # 'SEP0A1B2C3D4E5F'

# önekli tag'ler namespace sözlüğü ister
root.find("soapenv:Body", {"soapenv": SOAP})
```

#walk(
  ("1", [Namespace URL'si bir variable'da tutulur.]),
  ("3", [AXL'den gelen cevabı ayrıştırıyoruz.]),
  ("4", [Kök element'in `tag`'ı kısa bir isim değil, namespace dahil uzun bir isimdir: `{http://schemas.xmlsoap.org/soap/envelope/}Envelope`.]),
  ("5", [`.//phone/name`: zarfın ve gövdenin hepsini atlayıp doğrudan `phone` altındaki `name`'e iner.]),
  ("7–8", [Önekli bir tag'i aramak için, öneki namespace URL'sine bağlayan bir *sözlük* verilir.]),
)

#collab[
  AXL cevapları SOAP zarflarıdır ve AXL istekleri de aynı şekilde kurulmalıdır. Bunları elle yazmak yavaştır ve hataya açıktır. `zeep` onları sizin için kurar ve açar; bir sonraki bölümün konusu bu.
]

#recap[
  - JSON ve XML aynı ağaç yapısını anlatır. JSON `dict` / `list`'e doğrudan çevrilir; XML için `ElementTree` kullanılır.
  - `find`, `findall`, `findtext` ve `iter` ile XML ağacında gezinirsiniz.
  - SOAP cevapları namespace'li zarflardır. `.//` yolu zarfı atlayıp doğrudan veriye gider.
]

#exercise[
  Küçük bir XML metni yazın: iki `<user>` element'i, her birinde `<userName>` ve `<phoneNumber>`. `ET.fromstring` ile ayrıştırıp kullanıcı adlarını ve numaralarını yazdırın.
]
