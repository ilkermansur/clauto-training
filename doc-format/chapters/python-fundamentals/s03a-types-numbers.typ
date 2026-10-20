#import "../../template.typ": *

#topic[Why do we need data types?]

Bilgisayarın belleği yalnızca byte tutar. Tek başına bakıldığında `1001` bir sayı mıdır, bir DN midir, yoksa dört karakterlik bir yazı mıdır? Bellek bunu bilemez. *Data type* (veri tipi), ham veriye anlam kazandıran etikettir ve üç soruyu cevaplar:

+ *Bu nedir?* Metin, tam sayı, evet/hayır bilgisi, bir koleksiyon...
+ *Bununla ne yapabilirim?* Sayıları toplarsınız, metinleri birleştirirsiniz, bir list üzerinde dolaşırsınız.
+ *Nasıl gösterilir ve saklanır?* `"0012"` baştaki sıfırları korur, `12` korumaz.

#analogy[
  CUCM'de bir *pattern* ile bir *hostname* aynı alana yazılabilir gibi görünür ama sistem ikisine farklı davranır: pattern'de `X` ve `!` joker karakterdir, hostname'de değildir. Python'da tip de böyledir: aynı görünen iki değer, tipine göre farklı şeyler yapar.
]

#diagram("why-types", width: 72%, caption: [Aynı görünen `1001`, tipine göre sayı da olabilir, metin de.])

```python
"1001" + "1"     # '10011'
1001 + 1         # 1002
"1001" + 1       # TypeError: can only
                 # concatenate str to str
int("0012")      # 12  ← baştaki sıfırlar kayboldu
```

#walk(
  ("1", [İki *metin* `+` ile birleştirilir (yan yana yazılır). Sonuç yine bir metindir: `'10011'`.]),
  ("2", [İki *sayı* `+` ile toplanır: `1002`. Aynı `+` işareti, tipe göre farklı bir iş yaptı.]),
  ("3–4", [Metin ile sayıyı toplamaya çalışmak hata verir. Python tahmin yürütmez.]),
  ("5", [`int()` metni sayıya çevirir, ama sayılarda baştaki sıfır anlamsızdır: `"0012"` olarak yazılan DN `12` olur ve bilgi kaybolur.]),
)

Python bu açıdan *strongly typed* (güçlü tipli) bir dildir: tipleri kendi kendine karıştırmaz. `"1001" + 1` yazdığınızda iki yorumdan birini sessizce seçmek yerine `TypeError` verir. Bu iyi bir şeydir: hata, sorun üretime çıkmadan, daha ilk çalıştırmada ortaya çıkar.

#collab[
  Bir DN, sayıya benzese de *`str`*'dir (metin). `0012`, `+905551112233` ve `\+90XXX` gibi değerler `int` olarak saklanırsa bozulur. `int`'i yalnızca saydığınız ya da karşılaştırdığınız şeyler için kullanın: ring sayısı, maksimum call sayısı, timeout gibi.
]

#topic[Built-in data types]

Python'un hazır gelen (built-in) tipleri bellidir. Aşağıdaki diyagram hepsini tek bakışta gösteriyor, tablo ise her tipin collaboration dünyasındaki tipik kullanımını. Bu bölümün geri kalanında sırayla her birini ayrıntılı göreceğiz, şimdi sadece haritaya bakın.

#diagram("data-types-map", width: 80%, caption: [Python'un built-in veri tipleri: sayılar, metin, koleksiyonlar ve "değer yok".])

#table(
  columns: (auto, auto, 1fr),
  [Tip], [Örnek], [Collab'da kullanımı],
  [`int`],   [`4`],                    [ring sayısı, maksimum call sayısı],
  [`float`], [`0.25`],                 [paket kaybı oranı],
  [`str`],   [`"1001"`],               [DN, device adı, MAC adresi],
  [`bool`],  [`True`],                 [phone register mı?],
  [`list`],  [`["1001", "1002"]`],     [bir phone'un line'ları],
  [`tuple`], [`("cucm-pub", 8443)`],   [host + port çifti],
  [`range`], [`range(1001, 1100)`],    [bir DN bloğu üretmek],
  [`dict`],  [`{"dn": "1001"}`],       [tek bir AXL / REST kaydı],
  [`set`],   [`{"PT_Internal"}`],      [benzersiz partition'lar],
  [`bytes`], [`b"INVITE sip:..."`],    [ham SIP mesajı],
  [`None`],  [`None`],                 [cevaptaki boş alan],
)

#topic[Mutable vs immutable]

Tipleri iki büyük gruba ayırmak, kitabın geri kalanında karşınıza çıkacak birçok davranışı açıklar: *immutable* (değiştirilemez) ve *mutable* (değiştirilebilir) tipler.

#analogy[
  Bir *CDR kaydını* düşünün: yazıldıktan sonra üzerinde oynanmaz. Bir hata varsa kaydı düzeltmezsiniz, yeni bir kayıt oluşturursunuz. Bu *immutable*. Bir device'ın *description* alanı ise aynı kayıt üzerinde güncellenir: kayıt aynı kalır, içeriği değişir. Bu da *mutable*.
]

#diagram("mutability", width: 62%, caption: [Immutable tipte her "değişiklik" yeni bir kutu yaratır. Mutable tipte kutu aynı kalır, içi değişir.])

```python
dn = "1001"
before = id(dn)
dn += "0"
id(dn) == before       # False → yeni object

lines = ["1001"]
before = id(lines)
lines.append("1002")
id(lines) == before    # True → aynı object
```

#walk(
  ("1–2", [`dn` etiketi bir `str` kutusuna bağlanır ve kutunun kimliği saklanır.]),
  ("3", [`dn += "0"` kısaca `dn = dn + "0"` demektir. `str` immutable olduğu için `"10010"` değeriyle *yeni bir kutu* yaratılır ve `dn` ona taşınır.]),
  ("4", [Kimlik değişti: `False`. Eski kutu hiç değişmedi.]),
  ("6–7", [Bu kez `list` kullanıyoruz. Kimliğini saklıyoruz.]),
  ("8", [`append` list'in kendisini değiştirir. Yeni kutu yok.]),
  ("9", [Kimlik aynı: `True`.]),
)

#immutable #h(4pt) Değer, object yaratıldıktan sonra asla değişemez. Her "değişiklik" aslında yeni bir object yaratır ve etiketi oraya taşır. Bu gruptakiler: `int`, `float`, `str`, `bool`, `tuple`, `range`, `bytes`, `None`.

#mutable #h(4pt) Object *yerinde* değiştirilir. Kimliği aynı kalır. Bu gruptakiler: `list`, `dict`, `set` ve `bytearray`.

Bu ayrım iki yüzden önemlidir:

- Mutable bir kutuya iki etiket bağlıysa, birinden yapılan değişiklik diğerinde de görünür.
- Yalnızca immutable değerler `dict` anahtarı (key) ya da `set` elemanı olabilir.

#collab[
  Bir phone şablonu `dict`'ini loop içinde tekrar tekrar kullanıp düzenlerseniz, o şablondan türettiğiniz *bütün phone'lar* değişir; çünkü hepsi aynı kutuyu gösterir. Her phone için taze bir `dict` kurun.
]

#subsection[int]

#topic[int · whole numbers]

#immutable

`int` (integer), tam sayıları tutar: pozitif ya da negatif, boyut sınırı olmadan. Saydığınız ya da hesapladığınız her şey için kullanın: call sayısı, port, zamanlayıcı, deneme sayısı.

```python
max_calls = 4
max_calls + 1          # 5
7 // 2, 7 % 2          # (3, 1)  tam bölme, kalan
7 / 2                  # 3.5  ← "/" her zaman float verir
2 ** 100               # taşma yok, her boyutta
1_000_000              # okunabilirlik için alt çizgi

int("8443")            # 8443
int("1001A")           # ValueError
```

#walk(
  ("1–2", [`max_calls` etiketine `4` bağlanır; `+ 1` ile bir fazlası hesaplanır: `5`.]),
  ("3", [`//` bölmenin *tam kısmını*, `%` *kalanını* verir. `7` içinde `2` üç kere vardır ve `1` artar. Aynı satırda virgülle iki işlem yazınca sonuç bir çift (tuple) olarak gelir.]),
  ("4", [Normal bölme `/` her zaman `float` döndürür, sonuç tam sayı olsa bile (`4 / 2` → `2.0`).]),
  ("5", [`**` üs alma işlemidir. Python'da `int`'in büyüklük sınırı yoktur.]),
  ("6", [Uzun sayılarda `_` yalnızca okunabilirlik içindir: Python onu yok sayar.]),
  ("8–9", [`int()` metni sayıya çevirir. Metin geçerli bir sayı değilse `ValueError` hatası verir.]),
)

#methods(
  header: ([İşlem], [Anlamı]),
  [`+` `-` `*`], [toplama, çıkarma, çarpma],
  [`/`], [bölme, sonuç her zaman `float`],
  [`//` `%`], [tam bölme ve kalan],
  [`**`], [üs alma],
  [`int(x)`], [metni ya da `float`'ı tam sayıya çevirir],
)

#collab[
  AXL her değeri *metin* olarak döndürür: `"maxNumCalls": "4"`. Karşılaştırmadan önce çevirin: metin olarak `"10" > "9"` değeri `False`'tur (karakter karakter karşılaştırılır), ama `int("10") > int("9")` değeri `True`'dur.
]

#subsection[float]

#topic[float · decimal numbers]

#immutable

`float`, ondalık noktası olan sayıları tutar. `/` ile yaptığınız her bölme bir `float` üretir; `4 / 2` bile `2.0` verir.

```python
lost, received = 12, 4800
loss = lost / received   # 0.0025
f"{loss:.2%}"            # '0.25%'

mos = float("4.1")       # metin → float
mos >= 4.0               # True

0.1 + 0.2                # 0.30000000000000004
round(0.1 + 0.2, 2)      # 0.3
int(4.9)                 # 4  (keser, yuvarlamaz)
```

#walk(
  ("1", [Virgülle iki variable birden tanımlanır: `lost = 12` ve `received = 4800`. Buna *unpacking* diyeceğiz.]),
  ("2", [Kayıp oranı: `12 / 4800`. Bölme sonucu bir `float`'tır.]),
  ("3", [`f"..."` bir *f-string*'dir: süslü parantez içine değer koyup biçimlendirirsiniz. `:.2%` "yüzde olarak göster, iki basamak" demektir.]),
  ("5", [`float()` metni ondalık sayıya çevirir.]),
  ("6", [Karşılaştırma `bool` verir.]),
  ("8", [Sürpriz: `0.1 + 0.2` tam `0.3` değildir.]),
  ("9", [Gösterirken yuvarlayın: `round(x, 2)` iki basamak bırakır.]),
  ("10", [`int(4.9)` ondalık kısmı *atar*, yuvarlamaz: `4`.]),
)

Float'lar bilgisayarda ikili (binary) sistemde saklanır; bu yüzden bazı ondalık sayılar tam olarak ifade edilemez, tıpkı üçte birin ondalık yazılışının `0.333...` diye bitmemesi gibi. Kural basittir: *gösterirken yuvarlayın, iki float'ı asla `==` ile karşılaştırmayın.*

#collab[
  CMR (call management record) verisi, kaybolan ve alınan paket sayılarını verir. Bunlardan hesapladığınız kayıp oranı, jitter ve MOS değerleri `float`'tır.
]

#topic[Working with numbers]

Sayıların kendi method'ları azdır. İşin çoğunu *built-in function*'lar ve *f-string biçimleri* yapar. Aşağıdaki örnek, bir CDR süre listesinden rapor çıkarmaya yetecek araçları gösteriyor.

```python
durations = [125, 340, 62, 410]  # saniye
sum(durations) / len(durations)  # 234.25
min(durations), max(durations)   # (62, 410)
divmod(3725, 60)       # (62, 5) → 62 dk 5 sn
round(234.567, 1)      # 234.6
round(2.5), round(3.5) # (2, 4) çifte yuvarlar!
abs(-3)                # 3
int("1F", 16), hex(31) # (31, '0x1f')
(4.0).is_integer()     # True
f"{1234567:,}"         # '1,234,567'
f"{0.0025:.2%}"        # '0.25%'
```

#methods(
  [`sum` `min` `max`], [bir list'in toplamı, en küçüğü, en büyüğü],
  [`divmod(a, b)`], [bölümü ve kalanı tek çağrıda verir],
  [`round(x, n)`], [`n` basamağa yuvarlar (eşitlikte çifte gider)],
  [`abs(x)`], [sıfıra uzaklık (mutlak değer)],
  [`int(s, 16)` `hex(n)`], [16'lık tabandaki metin ↔ sayı],
  [`float.is_integer()`], [ondalık kısmı yok mu?],
  [`f"{x:.2f}"` `f"{x:,}"`], [yalnızca gösterim için biçimlendirme],
)

#walk(
  ("1", [Dört call'ın süresini tutan bir list. Köşeli parantez içinde virgülle ayrılmış değerler.]),
  ("2", [Toplam bölü eleman sayısı, yani ortalama süre.]),
  ("3", [En kısa ve en uzun call.]),
  ("4", [`3725` saniyeyi `60`'a böler: `62` dakika ve `5` saniye. Rapor için okunabilir bir süre.]),
  ("5–6", [Yuvarlama. Dikkat: `2.5` ve `3.5` yuvarlanınca `2` ve `4` çıkar; Python eşitlikte *en yakın çift sayıya* gider.]),
  ("8", [`int("1F", 16)` 16'lık tabandaki metni sayıya çevirir. Cihaz kimliklerini ve MAC'leri çözerken işe yarar.]),
  ("10–11", [Gösterim biçimleri: binlik ayırıcı ve yüzde.]),
)

#collab[
  CDR'larda süreler saniyedir. `divmod(duration, 60)` ile `3725` değerini "62 dk 5 sn" olarak göstermek, call raporlarını insanlar için okunur kılar.
]

#exercise[
  Bir call'ın süresi `3725` saniye. `divmod` kullanarak saat, dakika ve saniyeyi hesaplayın (ipucu: `divmod`'u iki kez kullanın). Sonra `1001` ve `"1001"` için `type(...)` yazın: `type(x)` bir değerin tipini söyler. Farkı görün.
]
