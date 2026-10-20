#import "../../template.typ": *

#subsection[str]

#topic[str · text]

#immutable

`str` (string), bir karakter dizisidir: yani metin. Tek tırnak (`'...'`), çift tırnak (`"..."`) ya da üç tırnak (`"""..."""`) içine yazılır. Çift ve tek tırnak aynı işi yapar; yeter ki açtığınız tırnakla kapatın. Üç tırnak ise birden çok satıra yayılan metinler içindir.

Collaboration işlerinde string'leri her yerde görürsünüz: DN, device adı, MAC adresi, kullanıcı kimliği, SIP URI. Bunların hepsi metindir.

#diagram("str-index", width: 84%, caption: [Her karakterin bir *index*'i (sıra numarası) vardır. Sayma `0`'dan başlar; sondan sayarken `-1` kullanılır.])

```python
name = "SEP0A1B2C3D4E5F"
len(name)        # 15
name[:3]         # 'SEP'
name[3:]         # '0A1B2C3D4E5F'
name.lower()     # yeni str, name değişmedi
name[0] = "X"    # TypeError: immutable
```

#walk(
  ("1", [Bir phone'un device adını `name` etiketine bağlıyoruz.]),
  ("2", [`len()` uzunluğu verir: `SEP` (3) + MAC (12) = `15` karakter.]),
  ("3", [*Slicing* (dilimleme): `[:3]` "baştan 3'e kadar, 3 *dahil değil*" demektir. Sonuç `'SEP'`: device tipini veren önek.]),
  ("4", [`[3:]` "3. index'ten sona kadar" demektir: phone'un MAC adresi.]),
  ("5", [`.lower()` küçük harfli *yeni bir* string döndürür. `name` olduğu gibi kalır.]),
  ("6", [String immutable olduğu için tek bir karakteri yerinde değiştiremezsiniz.]),
)

String'ler yerinde değiştirilemediği için `.lower()` ya da `.replace()` gibi method'lar her zaman *yeni bir* string döndürür. Sonucu saklamak istiyorsanız yeniden atayın: `name = name.lower()`.

#collab[
  Phone'un MAC adresi, `SEP` öneki çıkarılmış device adıdır: `name[3:]`. Aynı şekilde `name[:3]` device'ın cinsini söyler (`SEP` masa telefonu, `CSF` Jabber).
]

#topic[str methods · clean up]

Gerçek dünyadaki veri temiz gelmez. Excel'den kopyalanan bir MAC adresinde baştaki boşluklar, küçük harfler, iki nokta üst üste işaretleri vardır. String method'ları bu veriyi temizlemek içindir. Hepsi *yeni bir string* döndürür; bu yüzden soldan sağa zincirlenebilir.

#diagram("str-clean", width: 82%, caption: [Method zinciri: her adım bir önceki adımın sonucu üzerinde çalışır.])

```python
raw = "  sep0a1b2c3d4e5f \n"   # CSV hücresi
raw.strip()             # 'sep0a1b2c3d4e5f'
raw.strip().upper()     # 'SEP0A1B2C3D4E5F'
"alice smith".title()   # 'Alice Smith'
"0A:1B:2C:3D:4E:5F".replace(":", "")
                        # '0A1B2C3D4E5F'
"12".zfill(4)           # '0012'
"sip:1001".removeprefix("sip:")  # '1001'
```

#walk(
  ("1", [`\n` bir *satır sonu* karakteridir. CSV ya da dosyadan okunan metinlerin sonunda genellikle görünmez olarak bulunur.]),
  ("2", [`strip()` iki uçtaki boşluk, tab ve satır sonlarını siler.]),
  ("3", [Zincir: önce temizle, sonra büyük harfe çevir.]),
  ("4", [`title()` her kelimenin ilk harfini büyütür.]),
  ("5–6", [`replace(eski, yeni)` her `eski`'yi `yeni` ile değiştirir. Burada iki nokta üst üste silinir.]),
  ("7", [`zfill(4)` sola sıfır ekleyerek uzunluğu `4`'e tamamlar. DN'lerde baştaki sıfırı geri kazandırır.]),
  ("8", [`removeprefix()` baştaki sabit bir parçayı atar.]),
)

#methods(
  [`strip()`], [iki uçtaki boşluk, tab, satır sonunu siler],
  [`lstrip()` `rstrip()`], [yalnızca sol / yalnızca sağ taraf],
  [`lower()` `upper()` `title()`], [harf büyüklüğünü değiştirir],
  [`replace(eski, yeni)`], [her `eski`'yi `yeni` ile değiştirir],
  [`zfill(n)`], [sola sıfır ekleyerek `n` uzunluğuna tamamlar],
  [`removeprefix(p)` `removesuffix(s)`], [sabit başlangıcı / sonu atar],
)

#collab[
  Excel'den yapıştırılan MAC'ler boşluklu, küçük harfli ve iki nokta üst üstelidir. `"SEP" + mac.strip().upper().replace(":", "")` ifadesi, AXL'in kabul ettiği geçerli bir device adı üretir.
]

#topic[str methods · search and test]

Bir sonraki grup method, metnin *içinde bir şey olup olmadığını* ya da *nerede olduğunu* söyler. Hiçbiri string'i değiştirmez, sadece soru sorar.

#diagram("device-prefix", width: 66%, caption: [Device adının ilk üç harfi cihazın cinsini belirler.])

```python
name = "SEP0A1B2C3D4E5F"
name.startswith("SEP")     # True
"cucm-pub.clauto.lab".endswith(".lab")
                           # True
"A1" in name               # True
name.find("A1")            # 4  (yoksa -1)
name.index("ZZ")           # ValueError
"G711u,G711a,G722".count("G711")   # 2
"1001".isdigit()           # True
```

#walk(
  ("2", [`startswith()` metin bu parçayla *başlıyor mu* diye sorar: `True` ya da `False`.]),
  ("3–4", [`endswith()` metin bu parçayla *bitiyor mu* diye sorar.]),
  ("5", [`in` bir operatördür: "bu parça metnin herhangi bir yerinde var mı?"]),
  ("6", [`find()` parçanın *ilk bulunduğu index'i* verir. Bulamazsa `-1` döner, hata vermez.]),
  ("7", [`index()` `find()` gibidir, ama bulamazsa `ValueError` verir.]),
  ("8", [`count()` parçanın kaç kere geçtiğini sayar.]),
  ("9", [`isdigit()` metnin yalnızca rakamlardan oluşup oluşmadığını söyler.]),
)

#methods(
  [`startswith(p)` `endswith(s)`], [bu parçayla başlıyor / bitiyor mu?],
  [`x in s`], [`x` metnin herhangi bir yerinde var mı? (operatör)],
  [`find(x)`], [ilk konum; yoksa `-1`],
  [`index(x)`], [`find` gibi, ama yoksa `ValueError`],
  [`count(x)`], [`x` kaç kere geçiyor],
  [`isdigit()` `isalpha()` `isalnum()`], [yalnızca rakam / harf / ikisi mi?],
)

#collab[
  Device adının ilk üç harfi cihaz tipini söyler. `name.startswith("CSF")` ile bir phone listesindeki bütün Jabber client'ları bulabilirsiniz.
]

#topic[str methods · split, join, format]

`split` bir string'i parçalara ayırıp bir *list* yapar. `join` ise bir list'i tek bir string'e yapıştırır. İkisi birbirinin tersidir ve veri ayrıştırma (parsing) işlerinin çoğu bu ikilinin karışımıdır.

#diagram("str-split-join", width: 84%, caption: [`split` metni keser ve list yapar, `join` list'i tekrar metne yapıştırır.])

```python
row = "alice.smith,1001,DP_HQ"
user, dn, pool = row.split(",")
uri = "sip:1001@cucm-pub.clauto.lab"
uri.split("@")     # ['sip:1001', 'cucm-pub…']
uri.partition("@") # ('sip:1001', '@', 'cucm…')
", ".join(["1001", "1002"])  # '1001, 1002'
f"{user:<12}{dn:>6}"  # 'alice.smith   1001'
```

#walk(
  ("1", [Bir CSV satırı: virgüllerle ayrılmış üç alan.]),
  ("2", [`split(",")` üç parçalı bir list döndürür. Soldaki üç isim, parçaları sırayla alır (*unpacking*).]),
  ("4", [`@` işaretinden kesince iki parça çıkar: kullanıcı kısmı ve host kısmı.]),
  ("5", [`partition()` metni *bir kere* keser ve `(önce, ayraç, sonra)` verir. Ayracın kendisi de sonuçtadır.]),
  ("6", [`join()` ayracı `", "` olarak kullanarak list'in elemanlarını yapıştırır.]),
  ("7", [`:<12` "sola yasla, 12 genişlikte", `:>6` "sağa yasla, 6 genişlikte" demektir. Rapor sütunlarını hizalamak için kullanılır.]),
)

#methods(
  [`split(sep)`], [her `sep` yerinden keser → list (`sep` verilmezse boşluktan)],
  [`split(sep, 1)` `rsplit(sep, 1)`], [yalnızca bir kere keser: soldan / sağdan],
  [`partition(sep)`], [bir kere keser → `(önce, sep, sonra)`],
  [`sep.join(items)`], [bir list'in string'lerini `sep` ile yapıştırır],
  [`f"{x:<10}"` `f"{x:>6}"`], [sabit genişlikte sola / sağa yaslar],
)

#collab[
  Bir SIP URI'yi kullanıcı ve host olarak ayırmak için `uri.partition("@")` yeterlidir. `join` ise geri gönderdiğiniz CSV satırlarını ve rapor satırlarını kurar.
]

#subsection[bool]

#topic[bool · True or False]

#immutable

`bool` yalnızca iki değer alabilir: `True` (doğru) ve `False` (yanlış). Karşılaştırmalar (`==`, `>`, `in`) bir `bool` üretir ve `if` deyimleri bu değerleri tüketir. Bir sonraki bölümlerin (`if`, loop'lar) temelinde bu iki değer vardır.

```python
status = "Registered"
is_reg = status == "Registered"   # True
type(is_reg)              # <class 'bool'>

bool(""), bool("1001")    # (False, True)
bool([]), bool(["1001"])  # (False, True)
True + True               # 2  (bool bir int'tir)

bool("false")             # True  ← dikkat!
```

#walk(
  ("1", [`status` etiketine bir metin bağlanır.]),
  ("2", [`==` karşılaştırmasının sonucu `True`'dur ve `is_reg` etiketine bağlanır. Dikkat: tek `=` bağlar, çift `==` karşılaştırır.]),
  ("3", [`type()` bir değerin tipini söyler.]),
  ("5–6", [Her object'in bir *truth value*'su (doğruluk değeri) vardır. *Boş* ya da *sıfır* olan her şey `False` sayılır (*falsy*): `""`, `0`, `[]`, `{}`, `None`. Geri kalan her şey `True` sayılır (*truthy*).]),
  ("7", [Perde arkasında `bool`, `int`'in bir alt tipidir: `True` aslında `1`, `False` ise `0`'dır.]),
  ("9", [`"false"` yazısı boş olmayan bir metindir. Bu yüzden truthy sayılır.]),
)

#pitfall[
  AXL boolean değerleri *metin* olarak gönderir: `"true"` ya da `"false"`. Boş olmayan her metin truthy olduğu için `bool("false")` değeri `True`'dur ve bu hatayla bol bol karşılaşırsınız. Bunun yerine karşılaştırın: `enabled = value == "true"`.
]

#exercise[
  `"  Sep0a1b2c3d4e5f \n"` string'ini tek bir ifadeyle `SEP0A1B2C3D4E5F` haline getirin. Sonra bu sonucun `"SEP"` ile başladığını ve uzunluğunun `15` olduğunu `startswith` ve `len` ile doğrulayın.
]
