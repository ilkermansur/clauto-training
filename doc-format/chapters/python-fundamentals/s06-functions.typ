#import "../../template.typ": *

#section[Functions]

#topic[What is a function?]

Aynı işi ikinci kez yazdığınızı fark ettiğinizde, bir *function* yazma zamanı gelmiştir. Function (fonksiyon), belirli bir işi yapan, *isim verilmiş* bir kod bloğudur. Bir kere `def` ile *tanımlarsınız* (define), sonra istediğiniz kadar, her seferinde farklı girdiyle ismiyle *çağırırsınız* (call).

#analogy[
  CUCM'deki bir *translation pattern* ya da bir CUBE *voice translation-profile* düşünün: kuralı bir yere yazarsınız, sonra onlarca dial-peer o kurala başvurur. Kuralı değiştirirseniz hepsi etkilenir. Function da böyledir: kuralı tek yerde yazarsınız, her script onu kullanır.
]

#diagram("function-machine", width: 80%, caption: [Function bir makine gibidir: girdiyi alır, işler ve sonucu geri verir.])

```python
def build_device_name(mac):
    """Turn a raw MAC into a CUCM device name."""
    clean = mac.strip().upper().replace(":", "")
    return "SEP" + clean

name = build_device_name("0a:1b:2c:3d:4e:5f")
print(name)        # SEP0A1B2C3D4E5F
```

#walk(
  ("1", [`def` function tanımını başlatır. `build_device_name` function'ın adı, parantez içindeki `mac` ise *parameter*'dir (girdinin adı). Satır `:` ile biter.]),
  ("2", [Üç tırnaklı satır bir *docstring*'dir: function'ın ne yaptığını anlatan tek satırlık bir açıklama.]),
  ("3", [Temizlik: boşlukları sil, büyük harfe çevir, iki nokta üst üsteleri kaldır. `clean` yalnızca function'ın içinde yaşar.]),
  ("4", [`return` sonucu *geri verir* ve function'dan çıkar.]),
  ("6", [Function'ı çağırıyoruz. Parantez içine verdiğimiz `"0a:1b:..."` değerine *argument* denir. Dönen sonuç `name` etiketine bağlanır.]),
  ("7", [Function bir değer döndürdü; biz yazdırdık.]),
)

Parameter ile argument karıştırılır: *parameter* tanımdaki isimdir (`mac`), *argument* çağrıda verdiğiniz gerçek değerdir (`"0a:1b:..."`).

#methods(
  header: ([Parça], [Anlamı]),
  [`def name(...):`], [function'ı tanımlar; body altında girintili],
  [parameter], [tanımdaki girdi adı (`mac`)],
  [argument], [çağrıda verilen gerçek değer],
  [`return`], [sonucu geri verir ve function'dan çıkar],
  [`"""docstring"""`], [ne yaptığını anlatan tek satır],
)

#collab[
  Birden fazla yerde uyguladığınız her kural (isimlendirme, temizleme, doğrulama) bir function'a aittir. Tek yerde düzeltirsiniz, bütün script'ler yararlanır.
]

#topic[Parameters, defaults and return]

Function'lar birden fazla parameter alabilir ve bazı parameter'lara varsayılan (default) değer verilebilir. Bir function ayrıca birden fazla değer döndürebilir.

```python
def line_label(dn, user, site="HQ"):
    return f"{user} ({dn}) - {site}"

line_label("1001", "alice.smith")    # alice.smith (1001) - HQ
line_label("1002", "bob.jones", "Branch")      # sıraya göre
line_label(user="carol.white", dn="1003")      # isme göre

def check(status):
    if status == "Registered":
        return True, "ok"
    return False, f"status is {status}"

ok, msg = check("UnRegistered")    # iki değer döner (tuple)
```

#walk(
  ("1", [`site="HQ"` bir *varsayılan değerdir*: bu parameter verilmezse `"HQ"` kullanılır.]),
  ("2", [Function'ın sonucu bir f-string'dir.]),
  ("4", [`site` verilmediği için varsayılan `"HQ"` devreye girer.]),
  ("5", [Üç argument, tanımdaki *sıraya göre* eşleşir. Buna *positional* argument denir.]),
  ("6", [Argument'ları *isimle* verebilirsiniz (`user="..."`). Bu durumda sıra önemli değildir. Buna *keyword* argument denir.]),
  ("8–11", [Bu function iki farklı noktada `return` kullanıyor: birincisi koşul doğruysa, ikincisi aksi halde.]),
  ("10", [`return a, b` aslında bir *tuple* döndürür: `(True, "ok")`.]),
  ("13", [Dönen iki değeri tek satırda iki isme açmak (*unpacking*): `ok` bir `bool`, `msg` bir mesaj.]),
)

- *Positional* argument'lar sıraya göre, *keyword* argument'lar isme göre eşleşir.
- *Varsayılan değer* (`site="HQ"`) bir parameter'ı isteğe bağlı yapar.
- `return a, b` bir tuple döndürür. `return` yazılmayan bir function `None` döndürür.
- Function içinde yaratılan isimler *local*'dir: function bitince yok olurlar.

#pitfall[
  Asla mutable bir varsayılan değer kullanmayın: `def add(dn, lines=[])` bütün çağrılar arasında *tek bir* list paylaşır. Önceki çağrıdan kalan eleman bir sonrakinde görünür. Bunun yerine `lines=None` yazın, içeride `if lines is None: lines = []` ile taze bir list yaratın.
]

#topic[Function vs method]

Şimdiye kadar iki tür çağrı gördünüz: `len(name)` ve `name.upper()`. İkisi de bir iş yapar ama aralarında bir fark var.

*Method*, bir object'in *tipine ait* function'dır. Objenin üzerinde nokta ile çağırırsınız ve obje method'a otomatik olarak geçirilir. Düz bir *function* ise tek başına durur ve objeyi argument olarak alır.

#diagram("function-vs-method", width: 76%, caption: [Function'a object'i siz verirsiniz; method'u ise object'in üzerinde nokta ile çağırırsınız.])

```python
name = "sep0a1b2c3d4e5f"

len(name)              # function: object içeri girer
name.upper()           # method: object üzerinde çağrılır
str.upper(name)        # aynı method, function biçiminde

lines = ["1001"]
lines.append("1002")   # list method'u
len(lines)             # her tip için tek bir len()

name.append("x")       # AttributeError: str'de
                       # böyle bir method yok
```

#walk(
  ("3", [`len()` bir function'dır; üzerinde çalışacağı object'i *argument* olarak alır. Birçok tipte çalışır.]),
  ("4", [`upper()` bir method'dur; nokta, "bu object'in `upper`'ını çağır" demektir.]),
  ("5", [Aynı method'u tipin adı üzerinden de çağırabilirsiniz; bu, perde arkasında olanı gösterir.]),
  ("7–8", [`append` yalnızca `list`'te vardır.]),
  ("9", [`len()` ise her koleksiyon tipinde aynı çalışır.]),
  ("11–12", [`str`'de `append` diye bir method yoktur: `AttributeError`.]),
)

#methods(
  header: ([Function], [Method]),
  [`len(name)`], [`name.upper()`],
  [bir modülde `def` ile tanımlanır], [bir class'ın içinde `def` ile tanımlanır],
  [birçok tipte çalışır], [yalnızca kendi tipinde bulunur],
  [object argument olarak verilir], [object otomatik geçer (`self`)],
)

#warn[
  Her nokta bir method çağrısı değildir. `requests.get(url)` ya da `json.loads(text)` çağrılarında nokta yalnızca bir *module*'ü açar: `get` ve `loads` düz function'lardır.
]

#subsection[args and kwargs]

#topic[\*args · any number of positional arguments]

Bazen bir function'a kaç argument verileceğini önceden bilemezsiniz: bir phone mu, on phone mu? Tek yıldızlı bir parameter, *fazladan gelen bütün positional argument'ları* bir `tuple` içinde toplar.

#diagram("args-pack", width: 76%, caption: [`*names` bütün fazla argument'ları bir tuple içinde toplar.])

```python
def reset_phones(*names):
    print(type(names))     # <class 'tuple'>
    for name in names:
        print("reset", name)

reset_phones("SEP0A1B2C3D4E5F")
reset_phones("SEP0A1B2C3D4E5F", "SEP0A1B2C3D4E60")
reset_phones(*phones)      # bir list'i aç
```

#walk(
  ("1", [`*names`: yıldız, "gelen bütün positional argument'ları `names` isimli bir tuple'a topla" demektir.]),
  ("2", [İçeride `names` gerçekten bir `tuple`'dır.]),
  ("3–4", [Tuple üzerinde bir `for` loop'u ile her birini işleriz.]),
  ("6", [Tek argument: `names` bir elemanlı tuple olur.]),
  ("7", [İki argument: iki elemanlı tuple.]),
  ("8", [*Çağrıda* yıldız ters yönde çalışır: `*phones` bir list'i ayrı ayrı argument'lara *açar*.]),
)

Yıldızdan sonraki isim serbesttir; daha iyi bir isim yoksa gelenek `*args`'tır. Normal parameter'lar önce gelebilir: `def reset(site, *names)`.

#collab[
  Tek bir `reset_phones()` yardımcısı hem komut satırından tek bir phone'a hem de bir CSV'den gelen koca bir listeye hizmet eder; function'ın iki sürümünü yazmanız gerekmez.
]

#topic[\*\*kwargs · any number of keyword arguments]

İki yıldızlı parameter, *fazladan gelen bütün keyword argument'ları* bir `dict` içinde toplar: isimler key, değerler value olur.

#diagram("kwargs-pack", width: 76%, caption: [`**fields` isimli bütün fazla argument'ları bir dict içinde toplar.])

```python
def add_phone(name, model, **fields):
    phone = {"name": name, "model": model}
    phone.update(fields)       # fields bir dict
    return phone

add_phone("SEP0A1B2C3D4E5F", "Cisco 8851",
          devicePoolName="DP_HQ",
          description="Alice desk")

defaults = {"devicePoolName": "DP_HQ"}
add_phone("SEP0A1B2C3D4E60", "Cisco 8865",
          **defaults)          # dict'i aç
```

#walk(
  ("1", [`name` ve `model` zorunlu. `**fields` bunların dışında gelen *bütün isimli* argument'ları toplar.]),
  ("2", [Zorunlu alanlarla başlayan bir `dict`.]),
  ("3", [`update()` fazladan gelen alanları dict'e ekler.]),
  ("6–8", [Çağrıda `devicePoolName` ve `description` isimleriyle iki fazladan argument verilir. Bunlar `fields` dict'ine girer.]),
  ("10–12", [Çağrıda `**` bir dict'i isimli argument'lara *açar*. Ortak varsayılanları bir kere tanımlayıp her çağrıya geçirmenin yolu.]),
)

#methods(
  header: ([Sözdizimi], [Anlamı]),
  [`def f(*args)`], [fazladan positional → `tuple`],
  [`def f(**kwargs)`], [fazladan keyword → `dict`],
  [`f(*lst)`], [list'i positional argument'lara aç],
  [`f(**d)`], [dict'i keyword argument'lara aç],
)

Tanımda sıra: normal parameter'lar, `*args`, keyword-only parameter'lar, `**kwargs`.

#collab[
  Bir AXL phone'unun onlarca isteğe bağlı alanı vardır. `**fields` ile tek bir yardımcı function, hepsini tek tek listelemeden bunların herhangi birini kabul eder.
]

#subsection[Modules and import]

#topic[Modules · use code from another file]

Script'leriniz büyüdükçe bütün kodu tek dosyaya yazmak sürdürülemez hale gelir. Python'un çözümü *module*'dür: her `.py` dosyası bir module'dür. `import` başka bir dosyayı bir kere yükler ve onun function'larını ve variable'larını kullanmanıza izin verir. Böylece kodu bir yerde yazarsınız, her yerde kullanırsınız.

#analogy[
  Bir CUCM cluster'ında her şeyi tek bir partition'a koymazsınız; sorumluluğa göre ayırırsınız ve bir CSS ile erişim verirsiniz. Module'ler de böyledir: kodu konularına göre ayırır, ihtiyacı olan script'in o module'e erişmesine `import` ile izin verirsiniz.
]

#diagram("modules-import", width: 80%, caption: [`main.py`, `cucm_tools.py` dosyasındaki kodu `import` ile kullanır.])

```python
# main.py
import cucm_tools
cucm_tools.build_device_name("0a:1b:2c:3d:4e:5f")

from cucm_tools import build_device_name, CUCM_HOST
build_device_name("0a:1b:2c:3d:4e:60")

import cucm_tools as ct     # kısa takma ad
ct.CUCM_HOST                # 'cucm-pub.clauto.lab'
```

#walk(
  ("2–3", [`import cucm_tools` bütün module'ü getirir. Function'ı `cucm_tools.` önekiyle çağırırsınız: nereden geldiği açıktır.]),
  ("5–6", [`from ... import ...` yalnızca istediğiniz isimleri alır; önek olmadan kullanırsınız. Daha kısadır, ama isim nereden geldi unutulabilir.]),
  ("8–9", [`import ... as ct` uzun bir isme kısa bir takma ad (alias) verir.]),
)

#methods(
  header: ([Biçim], [Sonra kullanım]),
  [`import m`], [`m.func()`: nereden geldiği net],
  [`from m import func`], [`func()`: daha kısa, isim seçilir],
  [`import m as x`], [`x.func()`: uzun isimler için takma ad],
)

Python, module'leri şu sırayla arar: önce script'in kendi klasörü, sonra standart kütüphane, sonra kurulu paketler.

#pitfall[
  Kendi dosyanıza asla gerçek bir module'ün adını vermeyin: klasörünüzdeki bir `json.py` ya da `requests.py` gerçeğini gizler ve `import json` kendi dosyanızı yükler. Beklenmedik hatalar buradan çıkar.
]

#topic[Standard library and packages]

Hazır kod üç katmandan gelir:

- *Built-in*'ler (`print`, `len`) için hiçbir `import` gerekmez.
- *Standart kütüphane*, Python ile birlikte gelir: `import json`.
- *Üçüncü parti paketler* (third-party packages), PyPI'den gelir: `pip install requests`, sonra `import requests`.

#diagram("python-layers", width: 72%, caption: [Üç katman: built-in'ler, standart kütüphane, PyPI'den kurulan paketler.])

```python
import json, time               # standart kütüphane
from datetime import datetime

json.loads('{"dn": "1001"}')    # str → dict
time.sleep(2)                   # 2 saniye bekle
datetime.now().strftime("%Y-%m-%d")

import requests                 # pip install requests
```

#walk(
  ("1", [Virgülle iki module birden getirilebilir. İkisi de Python ile gelir; kurmanız gerekmez.]),
  ("2", [`datetime` module'ünden yalnızca `datetime` adını alıyoruz.]),
  ("4", [`json.loads()` bir JSON metnini Python `dict`'ine çevirir.]),
  ("5", [`time.sleep()` verilen saniye kadar bekler.]),
  ("6", [Bugünün tarihini `2026-10-20` biçiminde verir.]),
  ("8", [`requests` standart kütüphanede *yoktur*: önce `pip install requests` ile kurulması gerekir.]),
)

Paketleri proje başına bir *virtual environment* (sanal ortam) içine kurun. Böylece her projenin kendi sürümleri olur ve projeler birbirini bozmaz:

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install requests zeep
```

#collab[
  REST için (Webex, CUPI) `requests`, SOAP için (AXL, RIS) `zeep`, bunların etrafındaki veri için ise `json` ve `csv` kullanacaksınız.
]

#topic[Scripts vs modules · \_\_name\_\_]

Aynı dosya hem doğrudan çalıştırılabilir hem de başka bir dosyadan `import` edilebilir. Python bunları ayırt etmek için `__name__` isimli özel bir variable kullanır: dosyayı doğrudan çalıştırırsanız `__name__` değeri `"__main__"` olur; başka bir dosyadan import ederseniz module'ün adı olur.

#diagram("name-main", width: 76%, caption: [Dosya doğrudan çalıştırılırsa `__name__` `"__main__"` olur; import edilirse module adı.])

```python
# cucm_tools.py
def build_device_name(mac):
    return "SEP" + mac.replace(":", "").upper()

if __name__ == "__main__":
    # yalnızca doğrudan çalıştırınca
    print(build_device_name("0a:1b:2c:3d:4e:5f"))
```

#walk(
  ("2–3", [Normal bir function tanımı. Dosya `import` edildiğinde de, doğrudan çalıştırıldığında da tanımlanır.]),
  ("5", [`__name__ == "__main__"` yalnızca dosya *doğrudan çalıştırıldığında* doğrudur.]),
  ("6–7", [Bu blok bir kendi kendine test gibidir: `import` edildiğinde çalışmaz.]),
)

Module'lerden oluşan bir klasör bir *package*'dır. Noktalarla import edersiniz:

```text
clauto/
├── main.py          from cucm.axl import add_phone
└── cucm/
    ├── __init__.py  (klasörü package yapar)
    ├── axl.py
    └── ris.py
```

#collab[
  AXL, RIS ve Webex yardımcılarını kendi module'lerinde tutun. Her yeni script copy-paste yerine iki `import` satırıyla başlar.
]

#recap[
  - Function, tekrar eden işe isim verir: `def`, parameter'lar ve `return`.
  - Argument'lar positional ya da keyword olabilir. `*args` ve `**kwargs` istenen sayıda argument'ı toplar.
  - Module her `.py` dosyasıdır; `import` ile kullanılır. Standart kütüphane hazırdır, üçüncü parti paketler `pip` ile kurulur.
  - Proje başına bir virtual environment kullanın.
]

#exercise[
  `to_extension(dn, prefix="+90")` adında bir function yazın: DN'in başına prefix ekleyip döndürsün. Hem varsayılanla (`to_extension("1001")`) hem de `prefix="+1"` ile çağırın. Sonra function'ı `cucm_tools.py` dosyasına taşıyıp `main.py`'den `import` edin.
]
