#import "../../template.typ": *

#section[requests]

#topic[Your first request]

`requests`, bir HTTP çağrısını tek bir function çağrısına çevirir. Her method için bir function vardır: `get`, `post`, `put`, `patch`, `delete`. Her biri bir `Response` object'i döndürür.

#diagram("requests-call", width: 76%, caption: [`requests.get()` bir `Response` object'i döndürür: durum, header'lar ve body.])

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
r.raise_for_status()     # 4xx / 5xx ise hata
```

#walk(
  ("1–2", [`os` ve `requests` getirilir. `requests` standart kütüphanede değildir: `pip install requests` gerekir.]),
  ("4", [Token'ı koda yazmıyoruz; ortam değişkeninden okuyoruz (1.11 numaralı bölümdeki kural).]),
  ("5–9", [`requests.get(...)` bir GET isteği gönderir. İlk argument URL'dir. `headers=` bir dict ile header'ları verir. `timeout=10` en fazla 10 saniye beklemesini söyler.]),
  ("10", [`status_code` cevabın kodudur: `200`.]),
  ("11", [`r.json()` cevabın body'sini bir Python `dict`'ine çevirir.]),
  ("12", [`raise_for_status()` cevap 4xx ya da 5xx ise bir `HTTPError` yükseltir.]),
)

#methods(
  header: ([Response], [Verir]),
  [`r.status_code` `r.ok`], [kod; 2xx ise `True`],
  [`r.json()`], [body'yi `dict` / `list`'e çevirir],
  [`r.text` `r.content`], [body `str` / `bytes` olarak],
  [`r.headers`], [cevap header'ları (bir dict)],
  [`r.raise_for_status()`], [4xx / 5xx ise `HTTPError` yükseltir],
)

#collab[
  `GET /v1/people/me`, Webex API'sinin "hello world"üdür: adınızı döndürüyorsa token çalışıyor demektir.
]

#topic[Parameters, headers and JSON bodies]

`requests`'in keyword argument'ları HTTP isteğinin parçalarına birebir karşılık gelir. Kodlamayı `requests` yapar: query string'i kurar, `dict`'i JSON'a çevirir ve `Content-Type` header'ını ayarlar.

#diagram("requests-args", width: 76%, caption: [Her keyword argument, isteğin bir parçasını oluşturur.])

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

#walk(
  ("1–2", [Ortak parçalar variable'lara konur: taban URL ve header'lar. Her çağrıda tekrar yazmazsınız.]),
  ("4–6", [`params=` bir dict alır ve URL'ye `?email=alice.smith%40clauto.lab` olarak ekler. Özel karakterleri de doğru kodlar.]),
  ("7", [Cevaptaki `items` bir list'tir; ilk elemanın `displayName` alanını okuruz. (Bu, 1.3.8 numaralı dict bölümündeki iç içe veri okumanın aynısı.)]),
  ("9–10", [Gönderilecek mesaj bir `dict` olarak hazırlanır.]),
  ("11–12", [`json=msg` dict'i JSON'a çevirir, body'ye koyar ve `Content-Type: application/json` ekler.]),
)

- `params=`: URL'deki filtreler için. Elle birleştirmeyin.
- `json=`: JSON body için (`POST`, `PUT`, `PATCH`).
- `headers=`: token ve formatlar için.

#pitfall[
  `timeout=` olmadan, sunucu cevap vermezse bir istek *sonsuza kadar* bekleyebilir ve script asılı kalır. Her zaman bir `timeout` verin, 10 ile 30 saniye arası.
]

#topic[Auth, sessions and certificates]

Basic auth için `auth=(user, password)` yeterlidir: CUCM UDS ve Unity CUPI bunu kullanır. Aynı server'a çok sayıda istek göndereceğinizde bir `Session` kullanın: header'ları, kimlik bilgisini ve TCP bağlantısını çağrılar arasında saklar. Daha az kod, ve loop'larda çok daha hızlı.

#diagram("requests-session", width: 76%, caption: [`Session` ayarları ve bağlantıyı çağrılar arasında yeniden kullanır.])

```python
r = requests.get(                       # Basic auth
    "https://cuc-pub.clauto.lab/vmrest/users",
    auth=("axl_svc", password),
    headers={"Accept": "application/json"},
    params={"query": "(alias is alice.smith)"},
    verify="certs/clauto-ca.pem",       # lab CA'sine güven
    timeout=10)

s = requests.Session()
s.headers.update({"Authorization": f"Bearer {token}"})
s.get(f"{url}/people/me", timeout=10)   # yeniden kullanılır
```

#walk(
  ("1–2", [Unity Connection'ın CUPI adresine bir GET.]),
  ("3", [`auth=(kullanıcı, parola)` Basic auth header'ını sizin yerinize kurar.]),
  ("4", [JSON cevap istiyoruz.]),
  ("5", [CUPI'ye özgü bir sorgu: alias'ı `alice.smith` olan kullanıcı.]),
  ("6", [`verify=` TLS sertifika kontrolünü belirler. Kendi CA sertifikanızın yolunu verirseniz kontrol çalışmaya devam eder.]),
  ("9", [Bir `Session` yaratılır.]),
  ("10", [Session'a bir kere header eklenir; bundan sonraki her çağrıda otomatik gider.]),
  ("11", [Çağrıda artık `headers=` yazmaya gerek yok.]),
)

#warn[
  `verify=False` sertifika kontrolünü kapatır ve bir `InsecureRequestWarning` yazdırır. İlk lab denemesi için kabul edilebilir, ama üretim script'lerinde *asla*.
]

#topic[Errors and timeouts]

Bir istek üç farklı yerde başarısız olabilir ve `requests` her biri için farklı bir exception yükseltir. Hepsi `requests.exceptions` içindedir. (Exception mantığını 1.7'de gördünüz.)

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

#walk(
  ("4–5", [İstek gönderilir ve hemen `raise_for_status()` ile cevap kodu kontrol edilir.]),
  ("6–7", [Sunucu `timeout` içinde cevap vermedi: `Timeout`.]),
  ("8–9", [Sunucuya hiç ulaşılamadı: DNS, VPN ya da firewall sorunu: `ConnectionError`.]),
  ("10–12", [Sunucu cevap verdi ama 4xx ya da 5xx: `HTTPError`. `e`, hatanın mesajını taşır.]),
  ("13–14", [`else`: hiç hata olmadıysa cevap kullanılır.]),
)

#methods(
  header: ([Durum], [Yönetim]),
  [zamanında cevap yok], [`timeout=` + `except Timeout`],
  [host'a ulaşılamıyor], [`except ConnectionError`],
  [cevap 4xx / 5xx], [`raise_for_status()` + `except HTTPError`],
)

4xx ya da 5xx bir cevap kendi başına bir exception *değildir*: `r.status_code` sadece `401` olur. Onu bir exception'a çevirmek için `raise_for_status()` çağırın.

#collab[
  Toplu işte bunları loop'un içinde yakalayın (bkz. 1.7) ve device'ı ile hatayı `failed.csv`'ye yazın.
]

#topic[Rate limits and paging]

API'ler kendilerini korur. *Rate limit* göndereceğiniz istek sayısını sınırlar: sınırı aşarsanız `429 Too Many Requests` alırsınız ve `Retry-After` header'ı ne kadar bekleyeceğinizi söyler.

*Paging* uzun listeleri parçalara böler: her cevap tek bir sayfa taşır ve `rel="next"` içeren bir `Link` header'ı sonraki sayfayı gösterir. Sonraki link kalmayana kadar onu takip edersiniz.

#diagram("requests-paging", width: 72%, caption: [Her cevap bir sayfa taşır; `next` bağlantısı bitene kadar sayfalar gezilir.])

```python
import time

people, next_url = [], f"{url}/people?max=100"
while next_url:
    r = s.get(next_url, timeout=10)
    if r.status_code == 429:           # yavaşla
        wait = int(r.headers.get("Retry-After", 5))
        time.sleep(wait)
        continue                       # aynı sayfa
    r.raise_for_status()
    people += r.json()["items"]
    next_url = r.links.get("next", {}).get("url")
```

#walk(
  ("3", [`people` boş bir list, `next_url` ilk sayfanın adresi. İkisi tek satırda tanımlanır (unpacking).]),
  ("4", [`while next_url:`: bir sonraki sayfa adresi var olduğu sürece devam. Adres `None` olunca `False` sayılır ve loop biter.]),
  ("5", [Mevcut sayfa istenir.]),
  ("6–9", [`429` geldiyse: `Retry-After` kadar (yoksa 5 sn) bekle ve `continue` ile *aynı sayfayı* yeniden dene.]),
  ("10", [Diğer hatalar `raise_for_status()` ile exception'a dönüşür.]),
  ("11", [Bu sayfanın `items` list'i `people`'a eklenir (`+=` ile).]),
  ("12", [`r.links` `Link` header'ını ayrıştırır. `next` yoksa `.get` boş dict verir ve `next_url` `None` olur: sonraki tur olmaz.]),
)

#collab[
  Bir Webex organizasyonunun bütün kullanıcılarını listelemek bir paging loop'udur. `r.links`, `Link` header'ını sizin için ayrıştırır: `r.links["next"]["url"]`.
]

#recap[
  - `requests.get/post/...` bir `Response` döndürür. `r.json()` body'yi `dict`'e çevirir.
  - `params=`, `json=`, `headers=` ve `auth=` isteğin parçalarını kurar. Her zaman `timeout=` verin.
  - Çok çağrı için `Session` kullanın. Sertifika kontrolünü kapatmak yerine CA dosyasını `verify=` ile gösterin.
  - Hataları üç kategoride yakalayın: `Timeout`, `ConnectionError`, `HTTPError`. `429` ve paging için bir loop yazın.
]

#exercise[
  `https://webexapis.com/v1/people/me` isteğini bir `try / except` bloğuyla sarın. Önce yanlış bir token ile çalıştırıp `401 HTTPError`'ı yakalayın. Sonra `timeout=0.001` ile `Timeout` hatasını tetikleyin.
]
