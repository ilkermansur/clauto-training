#import "../../template.typ": *

#section[if Statements]

#topic[if · run code only when]

Şimdiye kadar yazdığımız script'ler yukarıdan aşağıya, her satırı sırayla çalıştırıyordu. Gerçek işlerde ise *karar vermek* gerekir: "phone register değilse uyarı ver", "DN `2000`'le başlıyorsa hunt pilot'tur". Python'da bunun yolu `if` deyimidir.

#analogy[
  CUBE üzerinde bir *dial-peer* eşleştirmesini düşünün: "çağrının hedefi `9000` ise bu peer'e gönder, değilse bir sonrakine bak." `if` da aynı mantıkla çalışır: *koşul doğruysa* bir blok çalışır, yanlışsa atlanır.
]

#diagram("if-flow", width: 76%, caption: [Koşul `True` ise blok çalışır; `False` ise Python bloğu atlayıp devam eder.])

```python
status = "UnRegistered"

if status != "Registered":
    print("ALERT: SEP0A1B2C3D4E5F is down")

print("check finished")   # her zaman çalışır
```

#walk(
  ("1", [`status` etiketine bir durum metni bağlanır.]),
  ("3", [*Koşul*: `status`, `"Registered"`'a eşit *değil* mi? `!=` "eşit değil" demektir. Satır `:` ile biter.]),
  ("4", [İçeri girintili (indented) satır *bloktur*. Yalnızca koşul `True` ise çalışır. Burada koşul doğru, o yüzden uyarı yazdırılır.]),
  ("6", [Girintisiz satır bloğun *dışındadır*: koşul ne olursa olsun çalışır.]),
)

İki şeye dikkat edin. Birincisi, `if` satırı bir *iki nokta* (`:`) ile biter. İkincisi, bloğu parantezler değil *girinti* belirler: bloktaki her satır aynı miktarda (geleneksel olarak 4 boşluk) içeri girer ve girintiye geri dönüldüğünde blok biter. Python'da girinti bir süs değil, sözdiziminin kendisidir.

#methods(
  header: ([Operatör], [Ne zaman `True`]),
  [`==` `!=`], [eşit / eşit değil],
  [`<` `>` `<=` `>=`], [küçük / büyük (ya da eşit)],
  [`in` `not in`], [eleman bir koleksiyonun içinde / dışında],
  [`is` `is not`], [aynı object, ör. `x is None`],
)

#collab[
  RISPort her device için bir durum döndürür. `if status != "Registered"`, her "phone kapandı" alarmının kalbidir.
]

#topic[if / elif / else · choose one path]

Bazen iki değil, çok yol vardır. `elif` ("else if", yani "değilse ve şu doğruysa") istediğiniz kadar ek koşul ekler. `else` ise hiçbir koşula uymayan her şeyi yakalar. İkisi de isteğe bağlıdır.

#diagram("elif-flow", width: 72%, caption: [Python koşulları yukarıdan aşağı sırayla sınar ve ilk `True` olan dalı çalıştırır.])

```python
mos = 3.8

if mos >= 4.0:
    quality = "good"
elif mos >= 3.6:
    quality = "fair"
else:
    quality = "poor"

print(f"MOS {mos}: {quality}")  # MOS 3.8: fair
```

#walk(
  ("1", [Bir call'ın MOS skoru.]),
  ("3–4", [İlk koşul: `3.8 >= 4.0` yanlış, dal atlanır.]),
  ("5–6", [İkinci koşul: `3.8 >= 3.6` doğru. `quality` `"fair"` olur. Kalan dallar *sınanmaz bile*.]),
  ("7–8", [`else` yalnızca yukarıdaki hiçbiri doğru çıkmadıysa çalışırdı.]),
  ("10", [Her durumda çalışan, bloğun dışındaki satır: sonucu yazdırır.]),
)

Python koşulları *yukarıdan aşağıya* kontrol eder ve yalnızca *ilk* `True` olan dalı çalıştırır. Diğer dallar atlanır, hatta onlar da `True` olacak olsa bile.

#pitfall[
  Sıra önemlidir. `mos >= 3.6` koşulunu en üste koyarsanız, `4.5` MOS'u da `"fair"` olarak etiketlenir, çünkü o dal ilk eşleşendir. *En katı koşulu en üste koyun.*
]

#collab[
  CMR verisinden call kalitesi not edebilirsiniz: MOS 4.0 ve üstü iyi, 3.6 ile 4.0 arası orta, 3.6'nın altı inceleme gerektirir.
]

#topic[Combining conditions]

Koşullar birleştirilebilir. Üstelik her değer bir koşul olabilir: boş değerler (`""`, `[]`, `{}`, `0`, `None`) `False` sayılır. Bu, "liste boş mu?" sorusunu çok kısa yazmanızı sağlar.

```python
status = "UnRegistered"
model = "Cisco 8851"
lines = []                        # henüz DN yok

if status != "Registered" and "88" in model:
    print("8800 series phone is down")

if not lines:                     # boş → falsy
    print("phone has no line")

if model in ("Cisco 8845", "Cisco 8865"):
    print("video capable")

label = "OK" if status == "Registered" else "DOWN"
```

#walk(
  ("1–3", [Üç variable: durum, model ve boş bir line listesi.]),
  ("5–6", [`and` *iki koşulun da* doğru olmasını ister: phone register değil *ve* modeli `"88"` içeriyor.]),
  ("8–9", [`not lines`: `lines` boş bir list olduğu için falsy'dir, `not` onu `True`'ya çevirir. "Line yoksa" demenin kısa yoludur.]),
  ("11–12", [`in` ile bir değeri birden fazla seçenekle karşılaştırın. Model bu iki video destekli modelden biri değil, o yüzden bu blok çalışmaz.]),
  ("14", [*Tek satırlık seçim*: `x if koşul else y`. Koşul doğruysa `x`, değilse `y` değerini alır.]),
)

#methods(
  header: ([Operatör], [Ne zaman `True`]),
  [`a and b`], [ikisi de doğru],
  [`a or b`], [en az biri doğru],
  [`not a`], [`a` yanlış],
  [`x if c else y`], [tek satırlık seçim: `c` doğruysa `x`, değilse `y`],
)

#pitfall[
  `if model == "Cisco 8845" or "Cisco 8865":` ifadesi *her zaman* `True`'dur: boş olmayan `"Cisco 8865"` metni zaten kendi başına truthy'dir. `or`'un iki tarafı ayrı ayrı koşuldur. Doğrusu: `if model in ("Cisco 8845", "Cisco 8865"):`.
]

#recap[
  - `if` koşul doğruysa bir blok çalıştırır. Blok `:` ile başlar ve girintiyle belirlenir.
  - `elif` ve `else` ile birden fazla yol kurulur. Python ilk doğru olan dalı seçer, bu yüzden en katı koşul üste yazılır.
  - `and`, `or`, `not` koşulları birleştirir. Boş değerler falsy'dir.
]

#exercise[
  Bir `jitter` değişkeni (milisaniye) tanımlayın. `20`'nin altı `"good"`, `20` ile `50` arası `"fair"`, üstü `"poor"` yazdırsın. Sonra aynı kodu `elif` yerine hep `if` kullanarak yazmayı deneyin ve fark ne olduğunu gözlemleyin.
]
