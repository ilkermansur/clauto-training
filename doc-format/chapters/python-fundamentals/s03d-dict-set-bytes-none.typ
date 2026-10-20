#import "../../template.typ": *

#subsection[dict]

#topic[dict · key → value]

#mutable

List'te elemanları sıra numarasıyla bulursunuz: "3. eleman". Ama bir phone'un bilgilerini düşünün: adı, modeli, device pool'u, description'ı. "3. bilgi" demek anlamsızdır, "model" demek anlamlıdır. İşte `dict` (dictionary, sözlük) bilgiyi *isimle* tutar: her *key* (anahtar) bir *value*'ya (değere) bağlanır.

#analogy[
  Bir telefon rehberi gibi düşünün: isme bakarsınız, numarayı bulursunuz. İsim *key*, numara *value*'dur. Rehberde aynı isim iki kere yer almaz: dict'te de key'ler benzersizdir.
]

#diagram("dict-map", width: 66%, caption: [`dict` her key'i bir value'ya bağlar: soldaki isimler key, sağdakiler value.])

```python
phone = {"name": "SEP0A1B2C3D4E5F",
         "model": "Cisco 8851"}
phone["model"]                  # 'Cisco 8851'
phone["devicePool"] = "DP_HQ"   # key ekle
phone.get("css")                # None, hata yok
"name" in phone                 # True
```

#walk(
  ("1–2", [Süslü parantez içinde `key: value` çiftleri virgülle ayrılır. İki satıra bölmek sadece okunabilirlik içindir.]),
  ("3", [Köşeli parantez içinde *key* verirsiniz, value'yu alırsınız. Key yoksa `KeyError` hatası alırsınız.]),
  ("4", [Var olmayan bir key'e atama yapmak, onu *ekler*. Var olan bir key'e atama yapmak değerini *değiştirir*.]),
  ("5", [`get()` ise daha hoşgörülüdür: key yoksa hata vermez, `None` döndürür.]),
  ("6", [`in` bir *key* olup olmadığını sorar (value'ya bakmaz).]),
)

Key'ler benzersizdir ve immutable olmalıdır (çoğunlukla `str`). Value ise her şey olabilir: başka dict'ler, list'ler. Python eklenme sırasını korur.

#collab[
  Her AXL ya da REST kaydı bir dict'tir: bir phone, bir line, bir Webex kullanıcısı. Webex API'sinden gelen JSON, doğrudan iç içe dict ve list'lere dönüşür.
]

#topic[dict methods · read and update]

`phone["css"]` *katı* davranır: key yoksa program hata verip durur. `get` ise *hoşgörülüdür*: `None` ya da sizin verdiğiniz varsayılan değeri döndürür. Hangisini seçeceğiniz, verinin eksik gelip gelmeyeceğine bağlıdır.

#diagram("dict-get", width: 68%, caption: [Köşeli parantez key yoksa hata verir, `get` ise `None` ya da varsayılan değer döndürür.])

```python
phone = {"name": "SEP0A1B2C3D4E5F",
         "model": "Cisco 8851"}
phone.get("css")                  # None
phone.get("css", "CSS_Internal")  # varsayılan
phone.update({"devicePool": "DP_HQ",
              "description": "Alice desk"})
phone.pop("description")    # 'Alice desk'
phone.setdefault("css", "CSS_Internal")
del phone["css"]
```

#walk(
  ("3", [`get("css")` key yok, bu yüzden `None`.]),
  ("4", [İkinci argüman *varsayılan değerdir*: key yoksa onu döndürür.]),
  ("5–6", [`update()` başka bir dict'in bütün çiftlerini ekler ya da üzerine yazar. Birçok key'i tek çağrıda değiştirmenin yoludur.]),
  ("7", [`pop(key)` çifti siler ve value'yu size *geri verir*.]),
  ("8", [`setdefault()` key *yoksa* ekler, varsa dokunmaz.]),
  ("9", [`del` bir method değil, bir deyimdir: çifti siler, geri bir şey vermez.]),
)

#methods(
  [`d[k]`], [`k`'nin değeri; yoksa `KeyError`],
  [`get(k, default)`], [`k`'nin değeri; yoksa `default` ya da `None`],
  [`update(other)`], [birçok key'i birden ekler ya da üzerine yazar],
  [`pop(k)`], [`k`'yi siler ve değerini geri verir],
  [`setdefault(k, v)`], [yalnızca `k` yoksa `v`'yi atar],
  [`del d[k]`], [`k`'yi siler (deyim, method değil)],
)

#collab[
  AXL cevabında isteğe bağlı alanlar eksik gelebilir. Onları `phone.get("css")` ile okuyun: böylece tek bir eksik kayıt, 500 phone'u gezen script'i durdurmaz.
]

#topic[dict methods · loop and nest]

Bir dict'in içeriği üç *görünüm* (view) ile dışarı verilir. Bunlar loop'larda ve testlerde kullanılır. İç içe dict ve list'lerde ise bir seferde bir seviye aşağı inersiniz.

#diagram("axl-nested", width: 62%, caption: [AXL cevabı iç içe dict ve list'lerdir. Her adımda bir seviye aşağı inilir.])

```python
for key, value in phone.items():
    print(f"{key:<12} {value}")

list(phone.keys())     # ['name', 'model']
"SEP0A1B2C3D4E5F" in phone.values()  # True

line = reply["phone"]["lines"]["line"][0]
line["dirn"]["pattern"]   # '1001'
copy = phone.copy()       # yeni bir dict
```

#walk(
  ("1–2", [`items()` her turda bir `(key, value)` çifti verir. Bu, dict üzerinde dolaşmanın en yaygın yoludur.]),
  ("4", [`keys()` bütün key'leri verir. `list()` ile sarmalayınca görünür olur.]),
  ("5", [`values()` bütün value'ları verir. `in` ile value'da arama yapılabilir.]),
  ("7", [İç içe veri: `reply` içindeki `"phone"`'a, onun içindeki `"lines"`'a, sonra `"line"` list'inin ilk elemanına inilir.]),
  ("8", [Bir seviye daha: line'ın `"dirn"` alanındaki `"pattern"`.]),
  ("9", [`copy()` yüzeysel (shallow) bir kopya yapar: dict yeni, içindeki objeler hâlâ aynı.]),
)

#methods(
  [`keys()`], [bütün key'ler],
  [`values()`], [bütün value'lar],
  [`items()`], [`(key, value)` çiftleri; en yaygın loop kalıbı],
  [`k in d`], [`k` bir key mi? (key'lere bakar, value'lara değil)],
  [`d[a][b][0]`], [iç içe verinin içine adım adım inmek],
  [`copy()`], [yüzeysel kopya: yeni dict, aynı iç objeler],
)

#collab[
  `getPhone` derin iç içe bir veri döndürür. Her adımı kısa ve okunur tutmak için bir iç seviyeyi bir variable'a atayın (`line = …`).
]

#subsection[set]

#topic[set · unique items]

#mutable

`set` (küme), *benzersiz* ve immutable elemanlardan oluşan, *sırasız* bir koleksiyondur. Zaten var olan bir değeri eklemek hiçbir şey yapmaz. Index'i yoktur ve sıra garantisi yoktur. Set'in asıl gücü iki iştir: "bu eleman içinde mi?" sorusunu çok hızlı cevaplar ve iki grubun farkını tek satırda çıkarır.

#analogy[
  İki ayrı partition listesi düşünün: biri CUCM'de gerçekte olanlar, diğeri tasarım dokümanında olması gerekenler. "Eksik olanlar hangileri, fazla olanlar hangileri?" sorusu, kümeler arası bir farktır.
]

#diagram("set-venn", width: 66%, caption: [İki set'in farkı ve kesişimi: eksik, fazla ve ortak olanlar tek satırda çıkar.])

```python
cucm = {"PT_Internal", "PT_Local", "PT_Old"}
need = {"PT_Internal", "PT_Local", "PT_Intl"}
need - cucm    # {'PT_Intl'}  eksik
cucm - need    # {'PT_Old'}   fazla
cucm & need    # ikisinde de var
set(["1001", "1001", "1002"])  # tekrarlar gider
```

#walk(
  ("1–2", [Süslü parantez içinde tek tek değerler (key yok): bu bir set.]),
  ("3", [`-` fark demektir: tasarımda olup CUCM'de *olmayan* partition: `PT_Intl`. Bu, *eksik* olandır.]),
  ("4", [Ters yönde fark: CUCM'de olup tasarımda olmayan, yani *fazla* olan: `PT_Old`.]),
  ("5", [`&` kesişim: ikisinde de bulunanlar.]),
  ("6", [`set()` bir list'i set'e çevirir ve tekrar edenleri otomatik temizler.]),
)

Üç operatörü hatırlayın: `-` fark, `&` kesişim, `|` birleşim.

#collab[
  Config denetimi (audit): CUCM'deki partition'ları tasarım dokümanındaki partition'larla karşılaştırın. Eksik ve fazla olanlar tek satırda ortaya çıkar.
]

#topic[set methods]

Set method'ları eleman ekler ve çıkarır, bütün grupları karşılaştırır. Önceki konudaki `| & -` operatörlerinin method karşılıkları da vardır ve onlar list gibi başka koleksiyonları da kabul eder.

#diagram("set-subset", width: 64%, caption: [`issubset()`: bir set'in bütün elemanları öbürünün içinde mi?])

```python
pts = {"PT_Internal"}
pts.add("PT_Local")       # bir tane ekle
pts.add("PT_Local")       # etkisiz, zaten var
pts.update(["PT_Intl", "PT_Old"])  # birçok ekle
pts.discard("PT_None")    # yoksa: hata yok
pts.remove("PT_None")     # yoksa: KeyError

required = {"PT_Internal", "PT_Local"}
required.issubset(pts)    # True
pts.isdisjoint({"PT_Blocked"})  # True
```

#walk(
  ("2–3", [`add()` ekler. İkinci çağrı hiçbir şeyi değiştirmez çünkü eleman zaten vardır.]),
  ("4", [`update()` bir list'teki bütün elemanları ekler.]),
  ("5–6", [`discard()` sessizce siler, eleman yoksa bir şey olmaz. `remove()` ise eleman yoksa `KeyError` verir.]),
  ("8–9", [`issubset()` "`required`'ın bütün elemanları `pts` içinde mi?" diye sorar.]),
  ("10", [`isdisjoint()` iki set'in hiç ortak elemanı olmadığını sorar.]),
)

#methods(
  [`add(x)` `update(items)`], [bir / birçok eleman ekler (tekrarlar yok sayılır)],
  [`discard(x)` `remove(x)`], [siler: sessizce / yoksa `KeyError` ile],
  [`union` `intersection` `difference`], [`|`, `&`, `-` ile aynı],
  [`issubset(b)` `issuperset(b)`], [hepsi `b` içinde mi / `b`'nin hepsini içeriyor mu],
  [`isdisjoint(b)`], [hiç ortak eleman yok mu?],
)

#collab[
  Bir CSS'in gerekli bütün partition'ları içerdiğini `required.issubset(css_partitions)` ile kontrol edin: tek satır, tek bir `True` ya da `False`.
]

#subsection[bytes]

#topic[bytes · raw binary data]

#immutable #h(2pt) `bytes` #h(6pt) #mutable #h(2pt) `bytearray`

Ağlar ve dosyalar *metin* değil, *byte* taşır. Bir `bytes`, 0 ile 255 arasındaki değerlerden oluşan ham bir byte dizisidir ve `b"..."` biçiminde yazılır. Metin `.encode()` ile bytes'a, `.decode()` ile tekrar metne çevrilir. `bytearray` ise bytes'ın değiştirilebilir sürümüdür.

#analogy[
  Bir RTP paketinin içindeki ses, bir *metin* değil, ham byte'lardır. Onu bir insanın okuyabileceği hale getirmek için bir codec gerekir. `encode` / `decode` de aynen bu iş için vardır: metin ↔ byte dönüşümü.
]

```python
msg = "INVITE sip:1001@cucm-pub.clauto.lab SIP/2.0"
raw = msg.encode()     # str → bytes (UTF-8)
raw[:6]                # b'INVITE'
raw[0]                 # 73  ← bir byte aslında bir sayı
raw.decode()           # bytes → str

buf = bytearray(raw)   # değiştirilebilir kopya
buf[0:6] = b"CANCEL"   # yerinde değiştir
```

#walk(
  ("1", [Bir SIP INVITE satırı: sıradan bir metin.]),
  ("2", [`.encode()` metni byte dizisine çevirir. Varsayılan kodlama UTF-8'dir.]),
  ("3", [Dilimleme `bytes`'ta da çalışır; sonuç yine bytes'tır (`b'INVITE'`).]),
  ("4", [Tek bir byte'a indexle erişirseniz bir *sayı* alırsınız: `73`, `"I"` harfinin sayısal karşılığıdır.]),
  ("5", [`.decode()` bytes'ı tekrar metne çevirir.]),
  ("7–8", [`bytearray` mutable bir kopyadır: `INVITE`'ı `CANCEL` ile değiştirmek mümkündür.]),
)

#collab[
  `requests` ile bir cevap aldığınızda `r.text` bir `str`, `r.content` ise `bytes`'tır. CDR dosyası ya da sertifika gibi indirmeler ve ham SIP mesajları için `bytes` kullanın.
]

#topic[bytes methods]

`bytes`, `str`'nin method'larının çoğunu paylaşır (`split`, `find`, `startswith`, `strip`), ama bütün argümanların da `bytes` olması gerekir: `b"..."`. Asıl önemli adım, ikisi arasında dönüşüm yapmaktır.

#diagram("encode-decode", width: 64%, caption: [`encode()` metni byte'a, `decode()` byte'ı metne çevirir.])

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

#walk(
  ("1", [Bir SIP cevabının ham hali. `\r\n` satır sonudur.]),
  ("2", [Karşılaştırmada argüman da `bytes` olmalı: `b"..."`.]),
  ("3", [Satırlara bölüp ilkini al, sonra metne çevir: cevabın durum satırı.]),
  ("4", [`find()` bir parçanın konumunu verir.]),
  ("5–6", [`hex()` byte'ları onaltılık metne, `fromhex()` tersine çevirir.]),
  ("7", [Türkçe karakterler, `é` gibi, UTF-8'de *birden fazla byte* tutar.]),
  ("8", [Geçersiz byte'ları çözmeye çalışırken `errors="replace"` programın çökmesini önler: bozuk karakter yerine `�` yazar.]),
)

#methods(
  [`s.encode()`], [`str` → `bytes` (varsayılan UTF-8)],
  [`b.decode()`], [`bytes` → `str`],
  [`decode(errors="replace")`], [bozuk byte'larda çökme],
  [`hex()` `bytes.fromhex(s)`], [bytes ↔ onaltılık metin],
  [`split` `find` `startswith`], [`str` ile aynı, `b"..."` argümanlarıyla],
)

#collab[
  AXL, HTTP Basic kimlik doğrulaması kullanır. Başlık `base64.b64encode(b"axl_svc:password")` ile üretilir. `requests` bunu sizin yerinize yapar ama altında yatan şey bytes'tır.
]

#subsection[None]

#topic[None · no value]

#immutable

`None`, "burada değer yok" demektir. `NoneType` tipinin tek objesidir. `return` içermeyen bir function `None` döndürür; `dict.get()` olmayan bir key için `None` döndürür. `None` falsy'dir: yani `if` içinde `False` gibi davranır.

```python
phone = {"name": "SEP0A1B2C3D4E5F",
         "description": None}
desc = phone["description"]
desc is None              # True
phone.get("css")          # None, key yok

result = print("hi")      # print None döndürür
desc or "no description"  # yedek değer
desc.upper()              # AttributeError
```

#walk(
  ("1–2", [Description alanı boş: AXL'de bu alan genellikle `None` olarak gelir.]),
  ("3–4", [`None`'ı `is None` ile kontrol edin, `== None` ile değil. `None` tek bir objedir, kimlik karşılaştırması yeterlidir.]),
  ("5", [`get()` var olmayan key için `None` verir.]),
  ("7", [`print()` ekrana yazar ama değer döndürmez; bu yüzden `result` `None` olur.]),
  ("8", [`x or default` kalıbı: `x` falsy ise (`None`, `""`, `0`...) yedek değeri kullanır.]),
  ("9", [`None` üzerinde string method'u çağırmak `AttributeError` verir.]),
)

#pitfall[
  AXL'deki boş alanlar `None` olarak gelir. Üzerlerinde `desc.upper()` gibi bir string method'u çağırırsanız `AttributeError` alırsınız. Önce `None` olup olmadığını kontrol edin ya da yedek değer kullanın: `(desc or "").upper()`.
]

#recap[
  - Tip seçimi, verinin anlamını belirler: DN `str`, ring sayısı `int`, register durumu `bool`.
  - Koleksiyonlar: sıralı ve değiştirilebilir `list`, sabit `tuple`, bir sayı aralığı `range`, isimle erişilen `dict`, benzersiz elemanlı `set`.
  - Immutable tipleri (`int`, `str`, `tuple`...) değiştiremezsiniz; mutable tipler (`list`, `dict`, `set`) yerinde değişir ve iki etiket aynı object'i gösteriyorsa ikisinde de görünür.
  - AXL'den gelen her şey genelde `str`'dir ve boş alanlar `None` olabilir: dönüştürün, kontrol edin.
]

#exercise[
  Bir `dict` kurun: `{"name": "SEP0A1B2C3D4E5F", "model": "Cisco 8851"}`. Önce `phone["css"]` yazın ve `KeyError`'ı görün. Sonra `phone.get("css", "CSS_Internal")` ile aynı soruyu hatasız sorun. Son olarak `setdefault` ile `css` key'ini ekleyin.
]
