#import "../../template.typ": *

#section[Comprehensions]

#topic[List comprehension]

Bir list'ten başka bir list üretmek, programlamanın en sık yapılan işlerinden biridir: "phone listesinden yalnızca masa telefonlarını al", "her cihaz adından `SEP` önekini at". Bunu şimdiye kadar öğrendiklerinizle yapabilirsiniz: boş bir list, bir loop, bir `if` ve bir `append`. *List comprehension* aynı işi tek bir ifadeyle yapar ve neredeyse bir cümle gibi okunur.

#diagram("comp-anatomy", width: 80%, caption: [Comprehension üç parçadan oluşur: ne tutulacak, loop ve isteğe bağlı bir filtre.])

```python
phones = ["SEP0A1B2C3D4E5F", "CSFALICE",
          "SEP0A1B2C3D4E60"]

desk = []                         # loop sürümü
for p in phones:
    if p.startswith("SEP"):
        desk.append(p[3:])

desk = [p[3:] for p in phones if p.startswith("SEP")]
# ['0A1B2C3D4E5F', '0A1B2C3D4E60']

dns = [str(n) for n in range(1001, 1004)]
```

#walk(
  ("1–2", [İki masa telefonu ve bir Jabber client'ı içeren bir list.]),
  ("4–7", [*Loop sürümü*: boş bir list, bir `for`, bir `if`, bir `append`. Dört satır, tek bir amaç: `SEP` ile başlayanların MAC'lerini toplamak.]),
  ("9", [*Comprehension sürümü*: aynı iş tek satırda. Köşeli parantez "yeni bir list kur" der.]),
  ("10", [Orijinal `phones` değişmez; sonuç yeni bir list'tir.]),
  ("12", [Filtre olmadan da çalışır: `range`'den gelen her sayıyı `str`'e çevirip `dns` list'ini kurar.]),
)

Bir comprehension en fazla üç parçadan oluşur ve *her zaman* şu sırayla yazılır:

+ *Ne tutulacak:* elemanın kendisi ya da dönüştürülmüş hali (`p[3:]`).
+ *Loop:* `for eleman in koleksiyon`.
+ *Filtre* (isteğe bağlı): `if koşul`.

#collab[
  Tek satır, bir phone listesini bir Webex device onboarding sayfasının ihtiyaç duyduğu MAC listesine çevirir, ya da bir site'ın yalnızca masa telefonlarını tutar.
]

#topic[Dict and set comprehensions]

Aynı fikir her koleksiyon için çalışır. Hangisini elde edeceğinizi *parantez türü* belirler.

```python
rows = [{"user": "alice.smith", "dn": "1001"},
        {"user": "bob.jones",   "dn": "1002"},
        {"user": "carol.white", "dn": "1003"}]

dn_of = {r["user"]: r["dn"] for r in rows}    # dict
dn_of["bob.jones"]                            # '1002'

dns = ["1001", "1002", "2000"]
{dn[:2] for dn in dns}                        # set
# {'10', '20'}  kullanımdaki DN aralıkları

statuses = ["Registered", "UnRegistered", "Registered"]
["up" if s == "Registered" else "down" for s in statuses]
# ['up', 'down', 'up']

sum(1 for s in statuses if s != "Registered")    # 1 kapalı
all(p.startswith("SEP") for p in desk)           # True
```

#walk(
  ("1–3", [CSV'den okunmuş üç satır, her biri bir dict.]),
  ("5", [*Dict comprehension*: süslü parantez ve `anahtar: değer`. Her satır için kullanıcı → DN ilişkisi kurulur.]),
  ("6", [Sonuç, bir arama tablosudur: kullanıcıyı verin, DN'i alın. Loop yok.]),
  ("9", [*Set comprehension*: süslü parantez ama `anahtar: değer` yok. Her DN'in ilk iki hanesini toplar, tekrarlar otomatik gider.]),
  ("13", [Bir comprehension'ın "tutulacak" kısmında `if ... else ...` kullanabilirsiniz: durumları `"up"` ya da `"down"` olarak çevirir.]),
  ("16", [Köşeli parantez *olmadan* bir *generator* kullanılır: `sum()` içinde her kapalı phone için `1` üretir ve toplar.]),
  ("17", [`all()` bütün elemanlar için koşul doğruysa `True` verir.]),
)

#methods(
  header: ([Biçim], [Sonuç]),
  [`[x for …]`], [`list`],
  [`{k: v for …}`], [`dict`],
  [`{x for …}`], [`set`; tekrarlar silinir],
  [`(x for …)`], [generator: elemanları tek tek üretir],
)

`sum()`, `any()` ya da `all()` içindeki bir generator için ek parantez gerekmez.

#collab[
  `{r["user"]: r["dn"] for r in rows}` bir CSV'yi arama tablosuna çevirir: bir loop yazmadan herhangi bir kullanıcının DN'ini anında bulursunuz.
]

#topic[lambda and key functions]

`lambda`, ismi olmayan küçük bir function'dır: bir parameter listesi, tek bir ifade ve sonuç otomatik döner. Bir function'a yalnızca *bir an* için ihtiyaç duyduğunuz yerlerde kullanılır.

En yaygın işi `key=` argument'ıdır. `sorted`, `min` ve `max`, elemanların kendisini değil, key function'ın *her eleman için ürettiği değeri* karşılaştırır.

#diagram("lambda-anatomy", width: 80%, caption: [`lambda` parametre alır ve tek bir ifade döndürür.])

```python
phones = [{"name": "SEP0A1B2C3D4E60", "dn": "1002"},
          {"name": "SEP0A1B2C3D4E5F", "dn": "1001"}]
sorted(phones, key=lambda p: p["dn"])  # DN'e göre

cdrs = [{"caller": "1001", "duration": 125},
        {"caller": "1002", "duration": 410}]
max(cdrs, key=lambda c: c["duration"])
# {'caller': '1002', 'duration': 410}
```

#walk(
  ("1–2", [İki phone dict'i, DN sırası ters.]),
  ("3", [`lambda p: p["dn"]` şöyle okunur: "`p` verilince `p["dn"]`'i döndür". `sorted` her phone için bu değeri hesaplar ve ona göre sıralar: önce `"1001"`, sonra `"1002"`.]),
  ("5–6", [İki CDR kaydı.]),
  ("7–8", [`max` en uzun süreli kaydı bulur: `key` süreyi seçer, sonuç yalnızca süre değil, *kaydın tamamıdır*.]),
)

#pitfall[
  Bir comprehension ya da lambda tek bir okunur satıra sığmıyorsa, normal bir loop ya da `def` yazın. Kısa ve anlaşılır, akıllıca ve kafa karıştırıcı olandan iyidir.
]

#collab[
  Rapor için phone'ları DN'e göre sıralayın ya da bir CDR export'unda en uzun call'ı `max(cdrs, key=…)` ile bulun.
]

#recap[
  - Comprehension, "boş list + loop + if + append" kalıbını tek ifadeye sıkıştırır: `[ne for eleman in koleksiyon if filtre]`.
  - Parantez türü sonucu belirler: `[]` list, `{k: v}` dict, `{x}` set, `()` generator.
  - `lambda`, `key=` ile `sorted`, `min`, `max` için kısa bir kural verir.
  - Okunmaz hale gelirse, normal loop'a dönün.
]

#exercise[
  `phones = ["SEP0A1B2C3D4E5F", "CSFALICE", "SEP0A1B2C3D4E60", "CSFAGENT01"]` list'inden iki comprehension yazın: biri yalnızca `CSF` ile başlayanları (Jabber), diğeri her device adının uzunluğunu içeren bir dict (`{ad: uzunluk}`).
]
