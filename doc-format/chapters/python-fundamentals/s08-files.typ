#import "../../template.typ": *

#section[Files]

#topic[Working with files]

Otomasyon script'lerinin çoğu bir dosyayla başlar ve bir dosyayla biter: bir CSV'den okunan kullanıcılar, bir rapor dosyasına yazılan sonuçlar. `open()`, script'inizi diskteki bir dosyaya bağlar ve bir *file object* döndürür.

#diagram("file-with", width: 72%, caption: [`with` bloğu bittiğinde dosya, bir exception olsa bile otomatik kapanır.])

```python
f = open("phones.txt", encoding="utf-8")
text = f.read()
f.close()                  # unutması kolay

with open("phones.txt", encoding="utf-8") as f:
    text = f.read()        # otomatik kapanır

from pathlib import Path
path = Path("data") / "phones.txt"
path.exists()              # True / False
```

#walk(
  ("1", [`open()` dosyayı açar. `encoding="utf-8"` metnin hangi kodlamayla okunacağını söyler; Türkçe karakterler için şarttır.]),
  ("2", [`read()` bütün içeriği tek bir string olarak okur.]),
  ("3", [`close()` dosyayı kapatır. Unutursanız dosya açık kalır.]),
  ("5–6", [`with` kalıbı aynı işi *güvenle* yapar: blok bittiğinde, içeride bir exception olsa bile dosya kapanır. Her zaman bunu kullanın.]),
  ("8–10", [`pathlib.Path` yolları kurmak içindir. `/` operatörü yol parçalarını birleştirir ve macOS, Linux ve Windows'ta doğru çalışır.]),
)

#methods(
  header: ([Mod], [Anlamı]),
  [`"r"`], [okuma (varsayılan); dosya yoksa hata],
  [`"w"`], [yazma; mevcut içeriği *siler*],
  [`"a"`], [sona ekleme],
  [`"x"`], [yeni dosya yarat; zaten varsa hata],
  [`"rb"` `"wb"`], [ikili (binary): `str` yerine bytes],
)

#topic[Reading and writing text files]

Bir file object, *satır satır* dolaşılabilir. Her satırın sonunda hâlâ `"\n"` vardır; o yüzden önce `strip()` edin. Satır satır okumak, çok büyük dosyalarda bile belleği düşük tutar.

#diagram("text-lines", width: 64%, caption: [Dosya satır satır okunur; her satırın sonunda bir satır sonu karakteri bulunur.])

```python
with open("phones.txt", encoding="utf-8") as f:
    for line in f:             # her turda bir satır
        name = line.strip()    # "\n"'i at
        if not name:
            continue           # boş satırları atla
        print(name)

with open("report.txt", "w", encoding="utf-8") as f:
    f.write("Phone report\n")
    f.write(f"{name}\n")       # "\n"'i kendiniz ekleyin
```

#walk(
  ("1", [Dosyayı okumak için açıyoruz.]),
  ("2", [Bir `for` loop'u dosyada satır satır dolaşır.]),
  ("3", [`strip()` baştaki ve sondaki boşlukları, satır sonunu atar.]),
  ("4–5", [Boş satırlar falsy'dir; `continue` onları atlar.]),
  ("6", [Temiz bir isim yazdırılır.]),
  ("8", [`"w"` modu yazmak için açar. *Dosya açıldığı anda içeriği silinir.*]),
  ("9–10", [`write()` bir string yazar. Satır sonunu *otomatik eklemez*: `\n`'i kendiniz koyun.]),
)

#methods(
  [`f.read()`], [bütün dosya tek bir `str` olarak],
  [`for line in f`], [her seferinde bir satır],
  [`f.readlines()`], [bütün satırların `list`'i],
  [`f.write(text)`], [bir `str` yazar; satır sonu eklemez],
  [`Path(p).read_text()`], [açar, okur ve kapatır; tek çağrıda],
)

#pitfall[
  `"w"` dosyayı açtığınız anda boşaltır. Raporu girdi dosyanızın üzerine yazarsanız onu yok edersiniz. Yeni bir dosya adı kullanın ya da `"a"` ile sona ekleyin.
]

#subsection[CSV]

#topic[Reading CSV files]

CSV, toplu işlerin en yaygın girdisidir: her Excel sayfası CSV olarak kaydedilebilir. `csv.DictReader` her satırı bir `dict`'e çevirir ve başlık satırını key olarak kullanır; böylece sütunları *isimle* okursunuz.

#diagram("csv-dict", width: 72%, caption: [`DictReader` başlık satırını key, her satırı bir dict yapar.])

```python
import csv

with open("users.csv", newline="",
          encoding="utf-8") as f:
    for row in csv.DictReader(f):
        print(row["user"], row["dn"])
# alice.smith 1001
# bob.jones 1002
```

#walk(
  ("1", [`csv` standart kütüphane modülüdür.]),
  ("3–4", [Dosyayı açıyoruz. `newline=""`, `csv` modülünün satır sonlarını kendisinin yönetmesi için gereklidir.]),
  ("5", [`DictReader(f)` dosyanın başlık satırını okur ve her satır için bir `dict` döndürür.]),
  ("6", [Sütunlara başlıklarıyla ulaşırız: `row["user"]`, `row["dn"]`.]),
)

Her değer bir `str`'dir. Sayıları kendiniz çevirin. `users.csv` dosyası şöyle görünür:

```output
user,dn
alice.smith,1001
bob.jones,1002
```

#warn[
  Türkçe ya da Almanca ayarlı Excel, dosyayı ayraç olarak `;` ve gizli bir BOM (byte order mark) ile kaydeder. Bu dosyaları `delimiter=";"` ve `encoding="utf-8-sig"` ile okuyun, yoksa ilk key `"﻿user"` olur ve `row["user"]` `KeyError` verir.
]

#topic[Writing CSV files]

`csv.DictWriter` bir dict list'ini satırlar halinde yazar. `fieldnames` sütun sırasını belirler, `writeheader()` ilk satırı yazar.

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

```output
device,status
SEP0A1B2C3D4E5F,added
SEP0A1B2C3D4E60,failed
```

#walk(
  ("3–6", [Sonuçlar dict'lerden oluşan bir list: her dict bir satır.]),
  ("8", [Dosya yazma modunda (`"w"`) açılır.]),
  ("9", [`DictWriter`, hangi key'lerin hangi sütun olacağını `fieldnames` ile öğrenir.]),
  ("10", [`writeheader()` başlık satırını yazar.]),
  ("11", [`writerows()` list'in bütün dict'lerini satır satır yazar.]),
)

#methods(
  header: ([Araç], [Neyle çalışır]),
  [`csv.DictReader`], [satırlar `dict`; key'ler başlıktan],
  [`csv.DictWriter`], [`dict` satırlar yazar],
  [`csv.reader`], [satırlar `list`; konuma göre],
  [`csv.writer`], [`list` satırlar yazar],
)

#collab[
  `users.csv` dosyasını okuyun, her satırı provision edin, device ve durumla birlikte `result.csv` yazın. Aynı dosya müşteri için Excel'de açılır.
]

#subsection[JSON]

#topic[JSON · load and dump]

JSON, REST API'lerinin metin biçimidir. Yapısı Python'la neredeyse birebir örtüşür; bu yüzden `json` modülü iki yönde de çevirir. `dumps` / `loads` içindeki `s` *string* demektir; `s` olmayanlar dosyayla çalışır.

#diagram("json-map", width: 72%, caption: [JSON ↔ Python: nesne `dict`, dizi `list`; `dumps`/`loads` string, `dump`/`load` dosya ile çalışır.])

```python
import json

with open("phone.json", "w", encoding="utf-8") as f:
    json.dump(phone, f, indent=2)   # dict → dosya

with open("phone.json", encoding="utf-8") as f:
    data = json.load(f)             # dosya → dict

text = json.dumps(phone)            # dict → str
json.loads(text)["lines"]           # str → dict
```

#walk(
  ("3–4", [`json.dump()` bir Python objesini dosyaya yazar. `indent=2` çıktıyı okunur kılar.]),
  ("6–7", [`json.load()` bir dosyayı okuyup Python objesine çevirir.]),
  ("9", [`dumps` objeyi dosya yerine *string* olarak verir.]),
  ("10", [`loads` bir string'i objeye çevirir; sonra normal bir dict gibi kullanabilirsiniz.]),
)

#methods(
  header: ([Python], [JSON]),
  [`dict`], [nesne `{}`],
  [`list` (ve `tuple`)], [dizi `[]`],
  [`str`], [string `""`],
  [`int` `float`], [sayı],
  [`True` `False` `None`], [`true` `false` `null`],
)

#collab[
  Webex API'leri JSON gönderir ve alır. Bir değişiklikten önce mevcut konfigürasyonu `json.dump(..., indent=2)` ile kaydetmek, okunabilir bir yedek verir.
]

#recap[
  - Dosyaları her zaman `with open(...)` ile açın ve `encoding="utf-8"` yazın.
  - CSV için `DictReader` ve `DictWriter`: sütunlara isimle ulaşırsınız. Türkçe Excel'in `;` ve BOM tuzağına dikkat.
  - JSON, `dict` ve `list`'lere doğrudan çevrilir: `load` / `dump` dosya, `loads` / `dumps` string için.
]

#exercise[
  Küçük bir `users.csv` dosyası oluşturun (`user,dn` sütunları). `DictReader` ile okuyup her kullanıcının DN'ini `int`'e çevirerek bir list'e koyun, sonra bu list'i `json.dump` ile `users.json` dosyasına yazın.
]
