#import "../../template.typ": *

#section[Classes]

#topic[Classes and objects]

Şimdiye kadar bir phone'u bir `dict` ile temsil ettik. Bu iş görür, ama dict'in kuralları yoktur: `"nmae"` diye yanlış yazılmış bir key'i kimse engellemez, "bu phone video destekliyor mu?" sorusunun cevabı ise başka bir yerde bir function'da yaşar. *Class* (sınıf), bir şeyin *verisini* ve ona ait *davranışı* tek bir yerde toplamanın yoludur.

#analogy[
  CUCM'deki bir *phone template*, ya da bir *device pool*'u düşünün: tipi tanımlar (hangi alanlar var, hangi varsayılanlar) ve ondan istediğiniz kadar phone türetirsiniz. Class bir *şablondur*; ondan türetilen her bir phone bir *object* (nesne, ya da *instance*) olur. Her objenin kendi değerleri vardır.
]

#diagram("class-blueprint", width: 72%, caption: [Class bir şablondur; ondan türetilen her object kendi değerlerini taşır.])

```python
class Phone:
    def __init__(self, name, model, dn):
        self.name = name        # attributes
        self.model = model
        self.dn = dn

desk = Phone("SEP0A1B2C3D4E5F", "Cisco 8851", "1001")
lobby = Phone("SEP0A1B2C3D4E60", "Cisco 8865", "1002")

desk.dn          # '1001'
lobby.model      # 'Cisco 8865'
```

#walk(
  ("1", [`class Phone:` yeni bir tip tanımlar. Class isimleri `CamelCase` ile yazılır.]),
  ("2", [`__init__` özel bir method'dur: bir object *yaratıldığında* çalışır. Parameter'lar, yaratırken verilen değerlerdir.]),
  ("3–5", [`self.name = name` değeri objenin üzerinde saklar. Bu satırlar objenin *attribute*'larını (özelliklerini) kurar.]),
  ("7", [`Phone(...)` yeni bir object yaratır ve `__init__`'i çağırır. `desk` bu object'e bağlanır.]),
  ("8", [İkinci bir `Phone`, tamamen bağımsız değerlerle.]),
  ("10–11", [Attribute'lara nokta ile ulaşılır.]),
)

#methods(
  header: ([Parça], [Anlamı]),
  [`class Phone:`], [yeni bir tip tanımlar (CamelCase isim)],
  [`__init__`], [object yaratılınca çalışır],
  [`self.name = …`], [object'in üzerinde bir attribute saklar],
  [`Phone(...)`], [yeni bir object yaratır],
  [`desk.dn`], [nokta ile bir attribute okur],
)

#collab[
  Bir `dict` bir phone'un verisini tutar. Bir class ise veriyi *ve ona ait kuralları* tutar: böylece her script bir phone'a aynı şekilde davranır.
]

#topic[Methods and self]

Class'ın içinde tanımlanan bir function'a *method* denir. İlk parameter'ı her zaman `self`'tir: method'un çağrıldığı object'in kendisi. Python onu sizin yerinize doldurur: `desk.mac()` perde arkasında `Phone.mac(desk)` olarak çalışır.

#diagram("class-self", width: 80%, caption: [`desk.mac()` çağrısında `desk` otomatik olarak `self` olur.])

```python
class Phone:
    VIDEO_MODELS = ("Cisco 8845", "Cisco 8865")  # ortak

    def __init__(self, name, model, dn):
        self.name, self.model, self.dn = name, model, dn
        self.status = "Unknown"

    def mac(self):
        return self.name[3:]

    def is_video(self):
        return self.model in self.VIDEO_MODELS

desk = Phone("SEP0A1B2C3D4E5F", "Cisco 8851", "1001")
desk.mac()                   # '0A1B2C3D4E5F'
desk.is_video()              # False
desk.status = "Registered"   # attribute'lar değişebilir
```

#walk(
  ("2", [`VIDEO_MODELS` bir *class attribute*'tur: class'ın içinde, `self`'siz tanımlanır. Bütün object'ler tarafından ortak kullanılır.]),
  ("4–6", [`__init__`: üç değer atanır ve bir başlangıç durumu (`status`) eklenir.]),
  ("8–9", [İlk method: `self.name` objenin kendi device adıdır; `[3:]` ile `SEP` öneki atılır.]),
  ("11–12", [İkinci method: objenin modeli, ortak `VIDEO_MODELS` tuple'ı içinde mi?]),
  ("14", [Object yaratılır.]),
  ("15", [`desk.mac()`: method'a `desk` otomatik olarak `self` olarak geçer. Sonuç `'0A1B2C3D4E5F'`.]),
  ("16", [8851 video destekli listede değil: `False`.]),
  ("17", [Attribute'ları dışarıdan da değiştirebilirsiniz.]),
)

`self` üzerinden bir method, objenin kendi attribute'larını okur ve değiştirir. `VIDEO_MODELS` gibi bir *class attribute* ise bütün object'ler tarafından ortak kullanılır.

Çift alt çizgili isimler özeldir: `__init__` objeyi kurar, `__repr__` ise `print(desk)` çağrısının nasıl görüneceğine karar verir.

#pitfall[
  `def mac():` yazıp `self`'i unutursanız `TypeError` alırsınız: "takes 0 positional arguments but 1 was given". Python objeyi otomatik olarak geçirir; method'un onu alacak bir parameter'ı olmalı.
]

#topic[Classes in the libraries you will use]

Çoğu zaman class yazmazsınız, *kullanırsınız*. Her kütüphane size object'ler verir; siz onların attribute'larını okur ve method'larını nokta ile çağırırsınız.

#diagram("response-object", width: 76%, caption: [`requests.get()` bir `Response` object'i döndürür: `.status_code`, `.json()` gibi attribute ve method'lar taşır.])

```python
class AxlClient:
    def __init__(self, host, user, password):
        self.url = f"https://{host}:8443/axl/"
        self.auth = (user, password)

    def get_phone(self, name):
        ...        # AXL isteğini burada gönder

axl = AxlClient("cucm-pub.clauto.lab",
                "axl_svc", password)
axl.get_phone("SEP0A1B2C3D4E5F")
```

#walk(
  ("1–4", [Bir AXL istemcisi: host, kullanıcı ve parolayı *bir kere* saklar.]),
  ("6–7", [`get_phone` method'u `self.url` ve `self.auth`'u kullanarak isteği gönderirdi. `...` gövdenin burada bilerek boş bırakıldığını söyler.]),
  ("9–10", [İstemci yaratılırken bağlantı bilgileri verilir.]),
  ("11", [Sonra her çağrı yalnızca phone adını ister: host ve parolayı tekrar yazmak gerekmez.]),
)

#methods(
  header: ([Object], [Nereden]),
  [`Response`], [`requests.get()`: `.status_code`, `.json()`],
  [`Session`], [`requests.Session()`: oturumu ve bağlantıyı yeniden kullanır],
  [`Client`], [`zeep.Client(wsdl)`: `.service.getPhone()`],
)

Aynı ayarları paylaşan birden çok function olduğunda, host ve kimlik bilgisi gibi, küçük bir class yazmak karşılığını verir.

#collab[
  Bir `AxlClient`, CUCM host'unu ve girişi bir kere saklar. Sonra her script yalnızca `axl.get_phone(...)` ya da `axl.add_line(...)` çağırır.
]

#recap[
  - Class, verisi (attribute) ve davranışı (method) olan yeni bir tiptir; ondan istediğiniz kadar object türetirsiniz.
  - `__init__` object'i kurar; method'ların ilk parameter'ı `self`'tir ve Python onu otomatik doldurur.
  - Çoğu zaman class'ları yazmazsınız, kütüphanelerden gelen object'leri kullanırsınız.
]

#exercise[
  `Phone` class'ına `describe()` adında bir method ekleyin: `"SEP0A1B2C3D4E5F (Cisco 8851) - 1001"` biçiminde bir metin döndürsün. Sonra iki farklı `Phone` objesi yaratıp ikisinde de çağırın.
]
