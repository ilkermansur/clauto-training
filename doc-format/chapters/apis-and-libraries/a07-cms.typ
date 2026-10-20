#import "../../template.typ": *

#section[CMS REST API]

#topic[Cisco Meeting Server API]

CMS'in, *Web Admin* portunda (genellikle 445) bir REST API'si vardır. Basic auth kullanır, yazma işlemlerinde *form data* gönderir ve JSON değil *XML* ile cevap verir. `xmltodict` kütüphanesi XML'i iç içe `dict`'lere çevirir; böylece geri kalanı Webex'ten gelen JSON ile çalışmak gibi hissettirir.

#diagram("cms-flow", width: 66%, caption: [Script CMS'e Basic auth ile bağlanır; cevap XML olarak gelir ve `xmltodict` ile dict'e çevrilir.])

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

#walk(
  ("3", [`xmltodict` bir üçüncü parti pakettir: `pip install xmltodict`.]),
  ("5", [CMS API'sinin taban adresi (API portu `445`).]),
  ("6–8", [Bir `Session` yaratılır; kullanıcı, parola ve CA sertifikası bir kere ayarlanır. Yine kimlik bilgisi ortam değişkeninden gelir.]),
  ("10–11", [Sistem durumu istenir; hata varsa exception yükseltilir.]),
  ("12", [`r.content` ham XML (bytes'tır). `xmltodict.parse()` onu iç içe bir dict'e çevirir. `["status"]` kök element'in içine iner.]),
  ("13", [Yazılım sürümü ve aktif call leg sayısı. XML'deki değerler her zaman *metin* olarak gelir.]),
)

#methods(
  header: ([Object], [Endpoint]),
  [space'ler], [`/coSpaces`, `/coSpaces/<id>`],
  [aktif toplantılar], [`/calls`],
  [katılımcılar], [`/calls/<id>/callLegs`],
  [sunucu sağlığı], [`/system/status`],
)

#collab[
  Script'ler için, admin girişinden ayrı, CMS'te bir *API user* oluşturun (`api_svc`) ve onu `.env` içinde tutun (1.11).
]

#topic[Example 1 · list all spaces]

CMS listeleri küçük sayfalar halinde döndürür. Kök element, toplam sayıyı (`total`) taşır. `total` kadar kayıt toplayana kadar `offset`'i sayfa sayfa ilerletirsiniz. `filter` aramayı sunucuda isme göre yapar: bir space'i bulmak için hepsini indirmezsiniz.

#diagram("cms-xmltodict", width: 66%, caption: [XML'deki `@` ile başlayan anahtarlar attribute'lardır; diğerleri alt element'lerdir.])

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

#walk(
  ("1", [`name_filter` varsayılan olarak boş: filtre yok.]),
  ("2", [Toplanan space'ler ve sayfalama konumu (`offset`).]),
  ("4–5", [Her sayfada 20 kayıt iste, isteğe bağlı bir isim filtresiyle.]),
  ("6–7", [İstek gönderilir ve hata kontrol edilir.]),
  ("8", [`force_list=("coSpace",)`: tek bir sonuç gelse bile `coSpace` *her zaman bir list* olsun. Bu konunun altındaki uyarıya bakın.]),
  ("9", [Kök element: toplam sayıyı ve sayfayı taşır.]),
  ("10", [Bu sayfadaki space'ler. Sonuç yoksa boş list.]),
  ("11–12", [Sayfa `spaces`'e eklenir ve `offset` sayfa boyutu kadar ilerler.]),
  ("13–14", [Sayfa boşsa ya da toplam sayıya ulaşıldıysa, bitir.]),
  ("16–17", [Sonuçlar bir loop ile yazdırılır: `@id` bir attribute, `name` bir alt element.]),
)

#pitfall[
  Tek bir sonuç olduğunda `xmltodict` bir `list` yerine *tek bir `dict`* döndürür ve `for` loop'u onun key'lerini gezer. Her zaman bir list almak için `force_list=("coSpace",)` verin.
]

#topic[Example 2 · create spaces from a CSV]

CMS'e yazma işlemleri *form data* gönderir: `requests`'te `json=` değil `data=` kullanılır. Başarılı bir `POST` boş bir body döndürür; yeni objenin kimliği `Location` header'ındadır.

#diagram("cms-create", width: 58%, caption: [CSV'deki her satır için bir `POST`; yeni space'in kimliği `Location` header'ından okunur.])

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

#walk(
  ("3–4", [CSV 1.8.1'deki gibi `DictReader` ile satır satır okunur.]),
  ("5–7", [Her satırdan bir *form* sözlüğü kurulur: space adı, URI ve passcode. f-string içinde dict'e erişirken *tek tırnak* kullanılır (`row['name']`), çünkü dış tırnak çifttir.]),
  ("8", [`data=form` ile form olarak gönderilir.]),
  ("9–11", [Başarısızsa satırı ve hata metnini yazdır, sonraki satıra geç (`continue`).]),
  ("12", [`Location` header'ı yeni objenin adresidir: `.../coSpaces/<id>`. `split("/")[-1]` adresin son parçasını, yani kimliği alır.]),
  ("13", [Başarı mesajı.]),
  ("15", [`PUT`: yalnızca gönderdiğiniz alanları değiştirir; burada passcode.]),
  ("16", [`DELETE`: space'i siler.]),
)

#methods(
  header: ([Çağrı], [Etkisi]),
  [`POST /coSpaces`], [bir space yaratır],
  [`PUT /coSpaces/<id>`], [yalnızca gönderdiğiniz alanları değiştirir],
  [`DELETE /coSpaces/<id>`], [space'i siler],
)

Hatalar `400` kodu ve bir `<failureDetails>` element'iyle gelir; örneğin `duplicateCoSpaceUri`. Loglayın ve devam edin (1.7).

#topic[Example 3 · who is in which meeting]

Aktif bir toplantı bir *call*'dur; içindeki her katılımcı bir *call leg*'dir. İç içe iki istek, canlı bir toplantı raporu verir. `get_xml()` gibi küçük bir yardımcı, ayrıştırmayı tek bir yerde tutar; böylece her yeni rapor birkaç satır olur.

#diagram("cms-calls", width: 60%, caption: [Her call'ın altında katılımcıları (call leg'leri) tutan ikinci bir istek yapılır.])

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

#walk(
  ("1–4", [Yardımcı function: bir adrese GET atar, hatayı kontrol eder, XML'i ayrıştırır ve verilen `key`'in altını döndürür. `force_list` ile liste olması garanti edilir.]),
  ("6", [Aktif bütün call'lar (toplantılar) alınır.]),
  ("7", [Her call için döngü. Aktif toplantı yoksa `.get("call", [])` boş list verir ve loop hiç dönmez.]),
  ("8–9", [Her call'ın katılımcıları (`callLegs`) ayrı bir istekle alınır. `call['@id']` call'ın kimliğidir.]),
  ("10", [Toplantı adını ve katılımcı sayısını yazdır.]),
  ("11–12", [İç loop: her katılımcının adını ve uzak tarafı (kim olduğu) yazdır.]),
)

#collab[
  Bakımdan önce çalıştırın: aktif call yoksa, CMS bir toplantıyı düşürmeden yeniden başlatılabilir. Tek bir sabah özeti için bunu günlük RIS raporuna (2.5) ekleyin.
]

#recap[
  - CMS REST API'si XML ile konuşur. `xmltodict` onu dict'lere çevirir: `@` attribute, diğerleri alt element'tir.
  - Listeler sayfalıdır: `offset` ve `total` ile gezin. Tek sonuç sorununu `force_list` ile çözün.
  - Yazmalarda `data=` (form data) kullanın. Yeni kimlik `Location` header'ındadır.
]

#exercise[
  `list_spaces()` function'ını `name_filter="Sales"` ile çağırın. Sonuç boş olduğunda ve tek bir space döndüğünde `for sp in list_spaces(...)` loop'unun nasıl davrandığını, `force_list` olmadan ve onunla gözlemleyin.
]
