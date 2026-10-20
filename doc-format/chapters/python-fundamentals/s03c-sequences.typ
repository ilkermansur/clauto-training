#import "../../template.typ": *

#subsection[list]

#topic[list · ordered collection]

#mutable

Şimdiye kadar tek değerlerle çalıştık: bir DN, bir device adı. Gerçek işlerde ise hep *çoğul* şeylerle uğraşırsınız: bir phone'un line'ları, bir CSV'deki satırlar, bir cluster'daki bütün phone'lar. Bunları tutan en temel yapı `list`'tir (liste).

#analogy[
  Bir *hunt list*'i düşünün: sıralı üyeleri vardır, aynı üye iki kere yer alabilir ve üye ekleyip çıkarabilirsiniz. Python'un `list`'i de budur: sıralı, değiştirilebilir bir elemanlar topluluğu.
]

#diagram("list-index", width: 68%, caption: [list elemanlarına index ile ulaşılır: baştan `0, 1, 2...`, sondan `-1, -2...`])

```python
lines = ["1001", "1002", "1003"]
lines[0]              # '1001'
lines[-1]             # '1003'
lines.append("1004")  # sona ekle
lines[1] = "1099"     # yerinde değiştir
len(lines)            # 4
```

#walk(
  ("1", [Köşeli parantez ve virgüllerle üç elemanlı bir list kurulur.]),
  ("2", [İlk elemana `0` index'iyle ulaşılır. Bilgisayarlarda sayma çoğu zaman `0`'dan başlar.]),
  ("3", [`-1` sondan birinci demektir: list ne kadar uzun olursa olsun son elemanı verir.]),
  ("4", [`append()` list'in sonuna bir eleman ekler. list şimdi dört elemanlıdır.]),
  ("5", [Index'e atama yaparak bir elemanı *yerinde* değiştirirsiniz: `lines[1]` artık `"1099"`'dur.]),
  ("6", [`len()` eleman sayısını söyler.]),
)

`list` her tipten eleman tutabilir, farklı tipleri bir arada barındırabilir ve tekrar eden değerlere izin verir. Sıra korunur. Bu yüzden "bir şeyin çoğulu" olan her yerde ilk akla gelen kaptır.

#collab[
  `listPhone` bir phone listesi döndürür, bir CSV import'u satır listesidir, bir phone'un line'ları da DN listesidir. Otomasyon script'lerinin çoğu bir list üzerinde dolaşır.
]

#topic[list methods · add and remove]

Aşağıdaki method'ların hepsi list'i *yerinde* değiştirir; list'in `id`'si aynı kalır. Bu method'ların çoğu bir değer döndürmez, doğrudan list'i değiştirir.

#diagram("list-ops", width: 76%, caption: [Ekleme ve çıkarma method'ları list'in kendisini değiştirir.])

```python
lines = ["1001", "1002"]
lines.append("1003")          # bir tane, sona
lines.extend(["1004", "1005"])  # birçok tane
lines.insert(0, "1000")       # 0. index'e
lines.remove("1002")          # değere göre
lines.pop()                   # '1005' sonuncu
lines.pop(0)                  # '1000' index'e göre
lines         # ['1001', '1003', '1004']
```

#walk(
  ("1", [Başlangıç: iki elemanlı bir list.]),
  ("2", [`append()` tek bir eleman ekler.]),
  ("3", [`extend()` başka bir list'in *bütün elemanlarını* tek tek ekler.]),
  ("4", [`insert(0, ...)` elemanı baştan `0.` konuma koyar, diğerleri kayar.]),
  ("5", [`remove()` *değere göre* siler: ilk `"1002"` gider. Böyle bir değer yoksa `ValueError` verir.]),
  ("6–7", [`pop()` son elemanı (ya da verdiğiniz index'tekini) listeden çıkarır *ve size geri verir*. Bu çıkarılan değeri kullanabileceğiniz anlamına gelir.]),
  ("8", [Sonuçta list'te `'1001'`, `'1003'`, `'1004'` kalır.]),
)

#methods(
  [`append(x)`], [sona bir eleman ekler],
  [`extend(items)`], [başka bir list'in bütün elemanlarını ekler],
  [`insert(i, x)`], [`i` konumundan önce `x` ekler],
  [`remove(x)`], [ilk `x`'i siler (yoksa `ValueError`)],
  [`pop()` `pop(i)`], [sonuncuyu / `i` numaralıyı siler ve *geri verir*],
  [`clear()`], [her şeyi siler],
)

#pitfall[
  `lines.append(["1002", "1003"])` *tek bir* eleman ekler: iç içe bir list. Sonuç `["1001", ["1002", "1003"]]` olur. Birçok eleman eklemek için `extend` kullanın.
]

#topic[list methods · order and search]

Sıralama ve arama her list üzerinde çalışır. Burada kritik olan, sıralamanın iki farklı yolu olduğunu bilmektir: *yeni bir list* döndüren `sorted()` ve list'i *yerinde* sıralayan `.sort()`.

#diagram("sort-vs-sorted", width: 66%, caption: [`sorted()` yeni bir list verir, `.sort()` var olan list'i değiştirir.])

```python
dns = ["1003", "1001", "1002"]
sorted(dns)           # yeni sıralı list
dns.sort(reverse=True)  # yerinde
dns.index("1002")     # 1
dns.count("1001")     # 1
"1004" in dns         # False
backup = dns.copy()   # gerçek bir kopya
sorted(names, key=str.lower)  # harf büyüklüğünü yok say
```

#walk(
  ("2", [`sorted()` orijinal list'e dokunmaz; sıralı *yeni* bir list döner.]),
  ("3", [`.sort()` list'in kendisini sıralar ve hiçbir şey döndürmez. `reverse=True` ile sıra tersine çevrilir.]),
  ("4", [`index()` bir elemanın konumunu verir. Sıralamadan sonra `"1002"` artık `1` numaralı konumdadır.]),
  ("5", [`count()` elemanın kaç kere geçtiğini sayar.]),
  ("6", [`in` ile üyelik sorulur.]),
  ("7", [`copy()` list'in yeni bir kopyasını yapar. Hatırlayın: `backup = dns` kopya değil, ikinci bir etikettir.]),
  ("8", [`key=` bir sıralama kuralı verir. Burada `names` başka bir list'tir ve karşılaştırma küçük harfe çevirilerek yapılır.]),
)

#methods(
  [`sorted(lst)`], [*yeni* sıralı list; orijinal değişmez],
  [`lst.sort()`], [yerinde sıralar; `None` döndürür],
  [`reverse=True` `key=...`], [azalan sıra / bir kurala göre sıra],
  [`reverse()`], [sırayı yerinde ters çevirir],
  [`index(x)` `count(x)`], [`x`'in konumu / kaç tane `x` var],
  [`copy()`], [yüzeysel (shallow) kopya: yeni list, aynı elemanlar],
)

#pitfall[
  `dns = dns.sort()` yazarsanız `dns` `None` olur, çünkü `sort()` hiçbir şey döndürmez. Ya yalnızca `dns.sort()` yazın ya da `dns = sorted(dns)`.
]

#subsection[tuple]

#topic[tuple · fixed sequence]

#immutable

`tuple`, list'e çok benzer ama yuvarlak parantezle yazılır ve *oluşturulduktan sonra değiştirilemez*. Birbirine ait sabit bir değer grubu için kullanılır: bir host ve onun portu gibi.

```python
server = ("cucm-pub.clauto.lab", 8443)
server[0]             # 'cucm-pub.clauto.lab'
host, port = server   # unpacking
server[1] = 443       # TypeError: immutable

codecs = ("G722", "G711u", "G711a")
"G722" in codecs      # True

nodes = {("cucm-pub.clauto.lab", 8443): "pub"}
```

#walk(
  ("1", [Host ve port tek bir tuple içinde.]),
  ("2", [Elemanlara list gibi index ile ulaşılır.]),
  ("3", [*Unpacking* (açma): tuple'ın her elemanı kendi ismine tek satırda atanır. `host` artık hostname'i, `port` ise `8443`'ü tutar.]),
  ("4", [Tuple immutable olduğu için eleman değiştirilemez.]),
  ("6–7", [Codec tercih sırası değişmeyecek bir bilgidir; tuple bunu garanti eder. `in` ile üyelik sorulabilir.]),
  ("9", [Tuple'lar immutable olduğu için `dict` anahtarı (key) olabilir. list olamaz.]),
)

#collab[
  Bir sunucu adresi `(host, port)`, sabit bir codec tercih sırası ya da bir AXL çağrısından sonra dönen `(ok, mesaj)` sonucu, tuple için güzel örneklerdir.
]

#subsection[range]

#topic[range · number sequence]

#immutable

`range(start, stop, step)` bir tam sayı dizisini *tarif eder*. `start` dahildir, `stop` *dahil değildir*. Varsayılan adım (step) `1`'dir.

#diagram("range-line", width: 84%, caption: [`range(1001, 1011)` 1001'den 1010'a kadar sayıları tarif eder. `stop` dahil değildir.])

```python
block = range(1001, 1011)
len(block)                 # 10
1005 in block              # True
list(range(1001, 1011, 3)) # [1001, 1004, 1007, 1010]

for n in range(1001, 1004):
    print("DN", str(n))    # DN 1001 … DN 1003
```

#walk(
  ("1", [1001'den 1010'a kadar 10 sayı. `1011` dahil değil.]),
  ("2", [`len()` kaç sayı olduğunu söyler.]),
  ("3", [`in` ile üyelik çok hızlı sorulur.]),
  ("4", [`range` sayıları saklamaz, ihtiyaç olunca hesaplar. Değerleri görmek için `list()` ile sarmalayın. Üçüncü argüman adımdır: 3'er 3'er atlar.]),
  ("6–7", [Bir `for` loop'u `range` üzerinde dolaşabilir. Loop'ları ilerleyen bölümde ayrıntılı göreceğiz. Her turda `n`, sıradaki sayıyı alır.]),
)

Bir range sayıları belleğe doldurmadığı için `range(1, 1_000_000)` neredeyse hiç bellek kullanmaz.

#collab[
  Yeni bir site için DN bloğu üretmek `range(1001, 1100)` kadar kolaydır. Ama unutmayın: DN'ler *string*'tir. AXL'e göndermeden önce her sayıyı `str(n)` ile çevirin.
]

#topic[tuple and range · useful operations]

Tuple'ın yalnızca iki method'u vardır. Geri kalan her şey, bütün *sequence*'lerin (sıralı koleksiyonların) ortak operasyonlarından gelir: `len`, `in`, index ile erişim, slicing ve unpacking. `range` de bunları destekler, ayrıca `start`, `stop` ve `step` özelliklerini sunar.

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

#walk(
  ("2–3", [Tuple'ın iki method'u: `count()` bir değerin kaç kere geçtiğini, `index()` ilk konumunu verir.]),
  ("4", [`len` ve slicing, tuple'da da list ile aynı çalışır.]),
  ("6–8", [Bir `range`'in başlangıcı ve sonu özellik (attribute) olarak okunur. `block[-1]` son sayıyı verir.]),
  ("9", [Negatif adım *geriye doğru* sayar: `1003`'ten `1001`'e.]),
  ("11–13", [`zip(a, b)` iki sequence'i eleman eleman eşleştirir. `dict()` ile birleşince DN ve kullanıcı listesinden bir arama tablosu çıkar.]),
  ("14", [`enumerate()` her elemana sıra numarası ekler. `start=1` numaralamayı `1`'den başlatır.]),
)

#methods(
  [`count(x)` `index(x)`], [kaç tane `x` / `x`'in konumu],
  [`len` `in` `[i]` `[a:b]`], [boyut, üyelik, index, dilim],
  [`range(a, b, -1)`], [negatif adımla geriye say],
  [`zip(a, b)`], [iki sequence'in elemanlarını eşleştirir],
  [`enumerate(seq, start=1)`], [her elemana sıra numarası verir],
)

#collab[
  Excel'deki iki sütun, DN'ler ve kullanıcı kimlikleri, `dict(zip(dns, users))` ile tek bir arama tablosuna dönüşür.
]
