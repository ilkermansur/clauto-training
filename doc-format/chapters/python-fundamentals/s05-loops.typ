#import "../../template.typ": *

#section[Loops]

#topic[What is a loop?]

Otomasyonun gerçek gücü burada başlar. Bir *loop* (döngü), bir kod bloğunu tekrar tekrar çalıştırır. İşi bir kere yazarsınız, Python onu ihtiyaç kadar çalıştırır: 3 phone için de, 3000 için de. Otomasyonun zaman kazandırdığı yer burasıdır.

#analogy[
  BAT'ta bir CSV yüklediğinizde, sistem her satır için aynı "phone ekle" işlemini tekrarlar. Loop tam olarak budur: *tek bir iş tarifi, birçok kayıt.*
]

#diagram("loop-kinds", width: 74%, caption: [Python'da iki loop vardır: `for` her eleman için bir tur, `while` koşul doğru olduğu sürece tur atar.])

```python
# loop olmadan: phone başına bir satır
print("reset", "SEP0A1B2C3D4E5F")
print("reset", "SEP0A1B2C3D4E60")
# ... 498 satır daha

# loop ile: kaç tane olursa olsun iki satır
for name in phones:
    print("reset", name)
```

#walk(
  ("1–4", [Loop olmadan her phone için ayrı bir satır yazmanız gerekir. 500 phone için 500 satır, ve her satırda bir yazım hatası riski.]),
  ("6–8", [Loop ile *aynı iş iki satıra* sığar. `phones` bir list'tir ve `name` her turda sıradaki phone'un adını alır.]),
)

Şu terimlere alışın, loop'ları anlatırken sürekli geçecekler:

#methods(
  header: ([Terim], [Anlamı]),
  [body], [tekrar edilen, içeri girintili blok],
  [iteration], [body'nin bir kez çalışması (bir "tur")],
  [loop variable], [o anki elemanı tutan isim],
  [condition], [devam edilip edilmeyeceğine karar veren `True` / `False` testi],
)

Python'un iki loop'u vardır. `for` bir koleksiyonun *her elemanı için bir kez* tekrarlar. `while` ise bir *koşul* doğru olduğu sürece tekrarlar.

#collab[
  500 phone'u reset etmek, denetlemek ya da güncellemek: tek bir phone için gereken kod body'ye yazılır, geri kalan 499'u loop halleder.
]

#subsection[for]

#topic[for · repeat for every item]

`for` loop'u bir koleksiyonun *her elemanı için body'yi bir kez* çalıştırır. Her turda loop variable'ı (`dn`) bir sonraki elemanı alır. Eleman kalmayınca loop biter ve loop'un altındaki kod çalışır.

#diagram("for-flow", width: 72%, caption: [Her turda sıradaki eleman loop variable'ına bağlanır. Eleman bitince loop sona erer.])

```python
dns = ["1001", "1002", "1003"]

for dn in dns:
    print(f"Adding line {dn}")

print("done")          # loop'tan sonra
```

#walk(
  ("1", [Üç DN'li bir list.]),
  ("3", [`for dn in dns:` şöyle okunur: "`dns` içindeki her `dn` için". Satır `if` gibi `:` ile biter.]),
  ("4", [Girintili body, her tur çalışır. `f"..."` içindeki `{dn}` yerine o turdaki DN yazılır.]),
  ("6", [Girintisiz satır loop'un dışındadır; yalnızca bir kere, en sonda çalışır.]),
)

```output
Adding line 1001
Adding line 1002
Adding line 1003
done
```

`for`, üzerinde adım adım dolaşabilen her şeyle çalışır: `list`, `tuple`, `str`, `dict`, `set`, `range` ve ilerleyen bölümlerde dosyalar ve API cevapları.

#collab[
  Toplu provisioning'in kalbi budur: bir CSV'den 500 satır okuyun, sonra `for row in rows:` ile her satır için bir AXL `addLine` ya da `addPhone` isteği kurup gönderin.
]

#topic[for · common patterns]

Otomasyon script'lerindeki loop'ların çoğu beş kalıptan biridir. Bunları ezberlemeniz gerekmez ama tanımanız, kod okumayı çok kolaylaştırır.

```python
for n in range(1001, 1004):            # sayılar
    print(str(n))

for i, dn in enumerate(dns, start=1):  # sıra + eleman
    print(i, dn)                       # 1 1001 …

for key, value in phone.items():       # dict çiftleri
    print(key, value)

for dn, user in zip(dns, users):       # iki list yan yana
    print(dn, "->", user)              # 1001 -> alice.smith

total = 0
for d in durations:                    # biriktirme
    total += d                         # 937
```

#walk(
  ("1–2", [`range` ile bir sayı bloğu üzerinde tekrarlanır: DN'leri üretmek için ideal.]),
  ("4–5", [`enumerate()` iki şey birden verir: *sıra numarasını* ve *elemanı*. Soldaki iki isim bunları alır.]),
  ("7–8", [`dict.items()` her turda bir `(key, value)` çifti verir.]),
  ("10–11", [`zip()` iki list'i yan yana yürütür: birinci turda iki list'in ilk elemanları, ikinci turda ikinci elemanlar...]),
  ("13–15", [*Biriktirme* kalıbı: boş bir başlangıç değeri (`0`), her turda eklenen bir şey (`+=`). Loop bittiğinde toplam hazırdır.]),
)

#methods(
  header: ([Kalıp], [Ne için]),
  [`range(a, b)`], [bir sayı bloğu için tekrarla],
  [`enumerate(seq)`], [sıra numarasını ve elemanı al],
  [`d.items()`], [bir dict'i key key gez],
  [`zip(a, b)`], [iki list'i yan yana gez],
  [`total += x`], [toplam, sayaç ya da yeni list biriktir],
)

#collab[
  `zip(dns, users)` bir Excel sayfasındaki DN sütununu ve kullanıcı sütununu eşleştirir, böylece her line'ı sahibiyle ilişkilendirebilirsiniz.
]

#topic[break and continue]

Loop'un normal akışını iki anahtar kelime değiştirir. `continue` o turun geri kalanını atlayıp *sonraki tura* geçer. `break` ise loop'tan *hemen çıkar*, kalan elemanlara bakılmaz.

#diagram("break-continue", width: 72%, caption: [`continue` yalnızca bu turu atlar. `break` loop'un tamamını bitirir.])

```python
phones = ["SEP0A1B2C3D4E5F", "CSFALICE",
          "SEP0A1B2C3D4E60"]

for name in phones:
    if name.startswith("CSF"):
        continue          # atla, sonraki elemana geç
    if name == "SEP0A1B2C3D4E60":
        print("found", name)
        break             # loop'tan hemen çık
    print("checking", name)
```

#walk(
  ("1–2", [Üç device: iki masa telefonu ve bir Jabber client'ı.]),
  ("4", [Her `name` için aşağıdaki body çalışır.]),
  ("5–6", [Device adı `CSF` ile başlıyorsa (Jabber), `continue` o turun kalanını atlar. `print("checking", ...)` çalışmaz.]),
  ("7–9", [Aranan device bulunduysa, mesaj yazdırılır ve `break` ile loop'tan çıkılır.]),
  ("10", [Yukarıdaki iki koşulun hiçbiri geçerli değilse buraya gelinir.]),
)

```output
checking SEP0A1B2C3D4E5F
found SEP0A1B2C3D4E60
```

İkisi de genellikle bir `if`'in içinde kullanılır ve `for` ile `while`'da aynı şekilde çalışır.

#collab[
  Masa telefonu denetiminde Jabber client'larını (`CSF…`) `continue` ile atlayın. Aradığınız device'ı bulur bulmaz `break` yapın, böylece script geriye kalan binlerce phone'u gezmez.
]

#subsection[while]

#topic[while · repeat while true]

`while` loop'u koşulu `True` olduğu sürece body'yi tekrarlar. Koşul *her turdan önce* kontrol edilir. `False` olduğu anda loop biter. `for`'dan farkı: kaç tur atacağınızı önceden bilmediğiniz durumlarda kullanılır, ör. "phone register olana kadar", "iş bitene kadar".

#diagram("while-flow", width: 72%, caption: [Koşul her turdan önce sınanır. Koşul `False` olunca loop biter.])

```python
replies = ["Unknown", "Unknown", "Registered"]
attempts = 0
status = ""

while status != "Registered" and attempts < 5:
    status = replies[attempts]   # RIS cevabı
    attempts += 1
    print(f"try {attempts}: {status}")
```

#walk(
  ("1", [Bir phone reset sonrası RIS'ten gelecek üç cevabı taklit eden bir list.]),
  ("2–3", [Sayaç ve başlangıç durumu.]),
  ("5", [İki şart birden: phone henüz register *değil* ve deneme sayısı 5'in altında. İkisi birden doğru olduğu sürece devam.]),
  ("6", [Sıradaki cevap alınır.]),
  ("7", [Sayaç artar. Bunu unutursanız `attempts` hiç değişmez ve loop sonsuza kadar sürebilir.]),
  ("8", [Her turda durum yazdırılır.]),
)

```output
try 1: Unknown
try 2: Unknown
try 3: Registered
```

#pitfall[
  Body'nin içinde koşulu değiştiren hiçbir şey yoksa loop *hiç bitmez* (sonsuz loop). Her zaman `attempts < 5` gibi bir sınır koyun. Takılan bir script'i `Ctrl+C` ile durdurursunuz.
]

#topic[while True · poll until done]

`while True` bilerek sonsuza kadar döner. Çıkış kurallarını body'nin içine `break` ile yazarsınız. Birden fazla çıkış şartı olduğunda bu yazım çok okunurdur. *Polling* (bir şeyin bitmesini tekrar tekrar sorarak beklemek) için en yaygın kalıptır.

```python
import time

attempts = 0
while True:
    attempts += 1
    status = get_status("SEP0A1B2C3D4E5F")  # sizin RIS çağrınız
    if status == "Registered":
        print("phone is back")
        break
    if attempts == 10:
        print("giving up after 10 tries")
        break
    time.sleep(30)          # tekrar sormadan önce bekle
```

#walk(
  ("1", [`time` standart kütüphane modülüdür; `import` konusunu ilerleyen bölümde göreceğiz.]),
  ("4", [`while True` koşulu her zaman doğrudur: loop kendi kendine bitmez, çıkışı biz yazarız.]),
  ("6", [Cevabı kendi yazacağınız `get_status` function'ından alıyoruz. (Function'ları birazdan öğreneceğiz.)]),
  ("7–9", [*Birinci çıkış*: phone register oldu, mesaj yaz ve `break`.]),
  ("10–12", [*İkinci çıkış*: 10 deneme yapıldı, vazgeç.]),
  ("13", [`sleep(30)` 30 saniye bekler. İstekler arasında bekleme koymazsanız sunucuyu boğarsınız.]),
)

#methods(
  header: ([Loop], [Ne zaman]),
  [`for`], [elinizde bir koleksiyon ya da bilinen bir sayı varsa],
  [`while koşul`], [bir koşul değişene kadar tekrarlamak istiyorsanız],
  [`while True` + `break`], [birden fazla çıkış kuralı, polling],
)

#collab[
  Bir phone'u reset ettikten sonra tekrar register olana kadar RIS'i sorgulayın. RIS'in istek sınırı vardır; bu yüzden istekler arasında *her zaman* `sleep` kullanın ve deneme sayısını sınırlayın.
]

#recap[
  - Loop, bir kod bloğunu tekrar eder: `for` bir koleksiyonun her elemanı için, `while` bir koşul doğru olduğu sürece.
  - `enumerate`, `zip`, `items()` ve `range` en yaygın `for` kalıplarıdır.
  - `continue` turu atlar, `break` loop'tan çıkar.
  - `while` loop'larında *her zaman* bir çıkış yolu ve bir deneme sınırı olmalı.
]

#exercise[
  `dns = ["1001", "1002", "1003"]` ve `users = ["alice.smith", "bob.jones", "carol.white"]` list'lerini `zip` ile gezip `"alice.smith -> 1001"` biçiminde yazdırın. Sonra `continue` ile `"1002"` DN'ini atlayın.
]
