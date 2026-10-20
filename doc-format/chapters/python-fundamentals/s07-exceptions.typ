#import "../../template.typ": *

#section[Exceptions]

#topic[What is an exception?]

Programlar hata verir. Bu kaçınılmazdır ve kötü bir şey değildir: hata mesajı, Python'un size neyin ters gittiğini söylemesidir. Bir *exception* (istisna), Python'un "burada devam edemiyorum" deme biçimidir. Hiçbir şey onu yakalamazsa script durur ve bir *traceback* yazdırır.

#analogy[
  Bir SIP çağrısında `404 Not Found` ya da `503 Service Unavailable` cevabı gördüğünüzde çağrı kurulamaz ama sistemin neden vazgeçtiğini cevap kodundan anlarsınız. Exception da aynı: her tipin bir adı vardır ve ne olduğunu söyler.
]

#diagram("exception-flow", width: 76%, caption: [Bir hata oluşursa ve hiçbir şey onu yakalamazsa, script durur ve traceback yazdırılır.])

```python
phone = {"name": "SEP0A1B2C3D4E5F"}
phone["css"]
```

```output
Traceback (most recent call last):
  File "audit.py", line 2, in <module>
    phone["css"]
KeyError: 'css'
```

Traceback'i *aşağıdan yukarıya* okuyun. *Son satır* hatanın tipini ve mesajını söyler: burada `KeyError: 'css'`, yani "`css` diye bir key yok". Üstündeki satırlar hatanın *nerede* olduğunu gösterir: hangi dosya, hangi satır, hangi kod.

#walk(
  ("1", [Yalnızca bir `name` key'i olan bir dict.]),
  ("2", [Olmayan bir key'i okumaya çalışıyoruz. Python bunu yapamaz ve exception yükseltir (*raise*).]),
)

#methods(
  header: ([Exception], [Tipik neden]),
  [`KeyError`], [dict'te olmayan bir key],
  [`IndexError`], [list'te olmayan bir konum],
  [`ValueError`], [doğru tip, yanlış değer: `int("84x3")`],
  [`TypeError`], [yanlış tip: `"1001" + 1`],
  [`AttributeError`], [olmayan bir method: `None.upper()`],
  [`FileNotFoundError`], [CSV yolu yanlış],
)

#collab[
  Kütüphaneler kendi exception'larını ekler: `requests` bir `Timeout` yükseltir, `zeep` ise AXL bir isteği reddettiğinde `Fault` yükseltir (aynı isimde bir kayıt var, olmayan bir CSS gibi).
]

#topic[try / except / else / finally]

Riskli kodu `try` içine yazarsınız. Belirttiğiniz tipte bir exception olursa, Python durmak yerine ilgili `except` bloğuna atlar.

#diagram("try-flow", width: 64%, caption: [`try` hatasız biterse `else`, hata olursa `except` çalışır. `finally` her durumda çalışır.])

```python
def to_int(text):
    try:
        value = int(text)
    except ValueError:
        print(f"not a number: {text!r}")
        value = None
    else:
        print("converted", value)
    finally:
        print("checked", text)
    return value

to_int("8443")    # converted 8443, checked 8443
to_int("84x3")    # not a number: '84x3', checked 84x3
```

#walk(
  ("1", [Bir metni sayıya çeviren bir function. Metin geçersizse `int()` `ValueError` yükseltir.]),
  ("2–3", [`try` bloğu: riskli iş burada. Hata olmazsa blok sonuna kadar çalışır.]),
  ("4–6", [`except ValueError` bloğu: yalnızca `ValueError` olduğunda çalışır. Programı durdurmak yerine bir mesaj yazdırıp `value`'yu `None` yaparız. `!r` değeri tırnaklarıyla gösterir; boşluk gibi gizli karakterleri yakalamak için işe yarar.]),
  ("7–8", [`else` bloğu *yalnızca hiç hata olmadığında* çalışır.]),
  ("9–10", [`finally` hata olsa da olmasa da *her zaman* çalışır: temizlik işleri için.]),
  ("11", [Sonuç döndürülür.]),
  ("13", [`"8443"` geçerli: `try` biter, sonra `else`, sonra `finally`.]),
  ("14", [`"84x3"` geçersiz: `except` çalışır, `else` atlanır, `finally` yine çalışır.]),
)

#methods(
  header: ([Blok], [Ne zaman çalışır]),
  [`try:`], [her zaman ilk: riskli kod],
  [`except Error:`], [`try` içinde o tipte hata olursa],
  [`except (A, B) as e:`], [birkaç tipten biri; `e` hatanın kendisi],
  [`else:`], [`try` hatasız bittiyse],
  [`finally:`], [her zaman: temizlik],
)

#pitfall[
  Çıplak bir `except:` ya da `except Exception: pass` *bütün hataları gizler*, yazım hataları dahil. Beklediğiniz *belirli* hatayı yakalayın ve neyin yanlış gittiğini her zaman yazdırın ya da loglayın.
]

#topic[Errors in bulk jobs · raise]

Toplu işte tek bir bozuk satır, diğerlerini durdurmamalıdır. `try`'ı loop'un *içine* koyarsınız: hatayı kaydedin, `continue` ile bir sonraki elemana geçin, bütün hataları en sonda raporlayın.

#diagram("bulk-errors", width: 72%, caption: [Her eleman kendi `try`'ında çalışır: hata olursa kaydedilir, loop devam eder.])

```python
failed = []
for name in phones:
    try:
        add_phone_axl(name)     # sizin AXL çağrınız
    except Exception as e:
        failed.append((name, str(e)))
        continue
    print("added", name)
print(f"{len(failed)} failed")

def build_device_name(mac):
    mac = mac.replace(":", "").upper()
    if len(mac) != 12:
        raise ValueError(f"bad MAC: {mac!r}")
    return "SEP" + mac
```

#walk(
  ("1", [Başarısız olanların listesi. Loop boyunca doldurulacak.]),
  ("2–4", [Her phone için `try` içinde AXL çağrısı yapılır.]),
  ("5", [Her türlü hata yakalanır. Burada geniş bir `except Exception` *kabul edilebilir*, çünkü hata saklanıyor ve en sonda gösteriliyor.]),
  ("6", [`(name, hata mesajı)` çifti `failed`'a eklenir.]),
  ("7", [`continue` ile bir sonraki phone'a geçilir.]),
  ("8", [Hata olmazsa buraya gelinir.]),
  ("9", [Loop bittikten sonra kaç tanesinin başarısız olduğu yazdırılır.]),
  ("11–15", [Bu function kendi hatasını *yükseltir* (`raise`): MAC 12 karakter değilse `ValueError` fırlatır.]),
)

`raise` bir exception'ı sizin yaratmanızı sağlar. Girdi yanlışsa, CUCM'e ulaşmadan *önce* durdurmak için kullanın: net bir `ValueError("bad MAC")`, daha sonra gelecek kafa karıştırıcı bir AXL fault'undan çok daha kolay çözülür.

#collab[
  500 phone import edersiniz: 499'u eklenir, 1 tekrar eden kayıt AXL hata mesajıyla birlikte `failed.csv` dosyasına yazılır ve ikinci bir çalıştırmayla düzeltilir.
]

#recap[
  - Exception, Python'un "devam edemiyorum" demesidir. Traceback'i *aşağıdan* okuyun: son satır hatanın tipi ve mesajıdır.
  - `try` / `except` hatayı yakalar; `else` hatasız bitince, `finally` her durumda çalışır.
  - Toplu işte `try`'ı loop'un içine koyun: hatayı kaydedin, devam edin, sonda raporlayın.
  - Bozuk girdiyi `raise` ile erkenden durdurun.
]

#exercise[
  `ports = ["8443", "443", "abc", "5061"]` list'indeki değerleri `int()` ile çevirin. `try` / `except ValueError` kullanarak geçersizleri atlayın ve çevrilemeyenleri ayrı bir list'te toplayın.
]
