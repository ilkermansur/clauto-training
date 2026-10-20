#import "../../template.typ": *

#section[Variables and Objects]

#topic[İlk adım: print ve yorumlar]

Variable'lara geçmeden önce kodlarda sürekli göreceğiniz iki küçük aracı tanıyalım.

`print()` ekrana bir şey yazdırır. Parantezin içine yazdırmak istediğiniz değeri koyarsınız. `#` işaretinden sonra gelen her şey *yorumdur* (comment): Python onu görmezden gelir, yalnızca sizin ve kodu okuyacak kişilerin içindir. Router konfigürasyonundaki `!` açıklama satırlarına benzer.

```python
# bu bir yorum: Python bu satırı atlar
print("Merhaba, clauto.lab")     # ekrana yazdırır
print(1001)                      # sayıları da yazdırabilir
print("DN:", 1001)               # virgülle birden fazla değer
```

```output
Merhaba, clauto.lab
1001
DN: 1001
```

#walk(
  ("1", [Tamamen yorum. Çalışma üzerinde hiçbir etkisi yok.]),
  ("2", [Tırnak içindeki yazı *metindir*. `print` onu olduğu gibi ekrana yazar. Satır sonundaki yorum da serbesttir.]),
  ("3", [Tırnaksız `1001` bir *sayıdır*. Ekranda aynı görünür, ama Python için farklı bir şeydir. Bu farkı "Data Types" bölümünde göreceğiz.]),
  ("4", [Virgülle ayrılan değerler, aralarına boşluk konularak yan yana yazılır.]),
)

#tip[
  Etkileşimli modda (REPL) `print()` yazmanıza gerek yoktur. Bir ifadeyi yazıp Enter'a bastığınızda sonucu zaten görürsünüz. Dosyadan çalışan script'lerde ise sonucu görmek için `print()` şarttır.
]

#topic[Variables are labels, not boxes]

Bir script çalışırken hatırlaması gereken şeyler olur: bir DN, bir device adı, bir hostname. Bunları isimlendirip saklamamızı sağlayan yapıya *variable* (değişken) denir. Ama Python'un variable'ı, çoğu insanın sandığından farklı çalışır ve bu farkı baştan anlamak, ileride yaşayacağınız birçok şaşkınlığı önler.

Değeri bir *kutu* (box) olarak düşünün. Kutunun içinde bir değer vardır (`"1001"` metni gibi) ve kutunun bir tipi vardır (metin, sayı...). Python'da bu kutuya *object* (nesne) denir. Variable ise kutunun kendisi değildir: kutuya *yapıştırılmış bir etikettir*. Python'da işaretçi (pointer) kavramını ayrıca öğrenmeniz gerekmez. Her isim zaten bir object'e işaret eder.

#analogy[
  Bir phone'a bağlı DN'i düşünün. Phone (kutu) CUCM'de durur; `1001` ise ona yapıştırılmış bir etikettir. Aynı phone'a ikinci bir DN (ikinci etiket) eklenebilir, o zaman iki etiket aynı phone'u gösterir. Bir etiketi başka bir phone'a taşırsanız, eski phone yerinde durmaya devam eder, yalnızca etiket yer değiştirmiştir.
]

#diagram("variables-labels", width: 76%, caption: [`backup = dn` ikinci bir etiket ekler. `dn = "1002"` ise etiketi yeni bir kutuya taşır.])

```python
dn = "1001"
backup = dn           # ikinci etiket, aynı kutu
id(dn), id(backup)    # (4372019504, 4372019504)
dn is backup          # True

dn = "1002"           # dn yeni bir kutuya taşınır
backup                # '1001'
```

#walk(
  ("1", [`=` işareti Python'da "eşittir" değil, *"bağla"* anlamına gelir. `"1001"` metninden bir kutu yaratılır ve `dn` etiketi ona yapıştırılır.]),
  ("2", [`backup = dn` değeri *kopyalamaz*. `dn`'in gösterdiği kutuya ikinci bir etiket yapıştırır.]),
  ("3", [`id(x)` kutunun kimlik numarasını verir: object'in ömrü boyunca değişmeyen benzersiz bir sayı. İki etiketin kimliği aynı çıktı, çünkü kutu aynı. (Sizdeki sayı farklı olacaktır.)]),
  ("4", [`a is b` iki etiketin *aynı kutuyu* gösterip göstermediğini sorar. Değerlerin eşit olup olmadığını ise `a == b` sorar. İkisi farklı sorulardır.]),
  ("6", [`dn` etiketi eski kutudan çözülür ve `"1002"` metnini içeren yeni bir kutuya yapıştırılır. Eski kutuya dokunulmaz.]),
  ("7", [`backup` hâlâ eski kutuyu gösterdiği için `'1001'` verir.]),
)

#collab[
  AXL'den gelen bir phone `dict`'i için `new = phone` yazmak ikinci bir *etiket* yaratır, kopya değil. `new["description"]` değerini değiştirirseniz `phone` da değişir, çünkü ikisi aynı kutuyu gösterir. Gerçek bir kopya için `phone.copy()` kullanın.
]

#recap[
  - Variable bir kutu değil, bir objeye yapıştırılmış *etikettir*.
  - `=` hiçbir zaman kopyalamaz; etiketi bir object'e bağlar.
  - `id()` object'in kimliğini, `is` iki etiketin aynı object'i gösterip göstermediğini, `==` ise değerlerin eşit olup olmadığını söyler.
]

#exercise[
  REPL'de `a = "SEP0A1B2C3D4E5F"` ve `b = a` yazın. `a is b` ne verir? Sonra `a = "SEP0A1B2C3D4E60"` yazıp `b`'nin değerine bakın. Neden değişmedi?
]
