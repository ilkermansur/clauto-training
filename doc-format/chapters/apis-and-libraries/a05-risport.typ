#import "../../template.typ": *

#section[RisPort70]

#topic[Real-time status with RisPort70]

AXL yalnızca *konfigürasyonu* bilir: bir phone vardır, DN'i `1001`'dir, `DP_HQ` device pool'undadır. O phone'un *şu an register olup olmadığı* ise başka bir servisin işidir: *Real-time Information Service* (RIS). RisPort70, RIS'in SOAP API'sidir.

#analogy[
  AXL, bir *dial plan dokümanı* gibidir: ne olması gerektiğini söyler. RIS ise bir *canlı monitör* gibidir: şu an ne olduğunu söyler. Bir mühendis ikisini de kullanır: dokümanda var olan ama monitörde görünmeyen bir cihaz, bir sorundur.
]

#diagram("axl-vs-ris", width: 76%, caption: [AXL konfigürasyonu (olması gerekeni), RIS durumu (şu an olanı) bilir.])

`RisPort70`, AXL ile aynı araçlarla çalışır: bir `requests` `Session`, bir `zeep` `Transport` ve `create_service`. WSDL'yi CUCM'in kendisi sunar, yani indirmeniz gereken bir toolkit yoktur.

```python
HOST = "https://cucm-pub.clauto.lab:8443"
RIS = HOST + "/realtimeservice2/services/RISService70"
NS = "{http://schemas.cisco.com/ast/soap}"

client = Client(RIS + "?wsdl", transport=transport)
ris = client.create_service(NS + "RisBinding", RIS)
```

#walk(
  ("1", [CUCM Publisher'ın temel adresi. Yine isim, IP değil.]),
  ("2", [RIS servisinin tam adresi.]),
  ("3", [WSDL'deki namespace.]),
  ("5", [`RIS + "?wsdl"`: WSDL dosyasını CUCM'in kendisinden alıyoruz. `transport` AXL bölümünde kurduğumuzla aynıdır.]),
  ("6", [`create_service` client'ı RIS adresine bağlar. `ris` artık RIS çağrıları yapabilir.]),
)

#methods(
  header: ([AXL], [RisPort70]),
  [`/axl/`], [`/realtimeservice2/services/RISService70`],
  [WSDL, AXL Toolkit'ten], [WSDL, `…/RISService70?wsdl` adresinden],
  [konfigürasyon: ne *olmalı*], [durum: şu an ne *var*],
)

#collab[
  Application user'ın *Standard CCM Admin Users* ve *Standard RealtimeAndTraceCollection* rollerine sahip olması gerekir.
]

#topic[Asking for device status · selectCmDevice]

`selectCmDevice` bir *seçim kriteri* alır: hangi device sınıfı, hangi durum ve bir isim listesi (`SEP*` gibi joker karakterler de çalışır). Cevap *CUCM node'una göre gruplanmış* gelir: bir phone, register olduğu node'un altında görünür. Bu yüzden her node üzerinde dönmek gerekir.

#diagram("ris-tree", width: 52%, caption: [RIS cevabı: her CUCM node'unun altında o node'a register olan device'lar.])

```python
def ris_status(names):
    criteria = {
        "MaxReturnedDevices": 1000, "DeviceClass": "Phone",
        "Model": 255, "Status": "Any",   # 255 = her model
        "SelectBy": "Name",
        "SelectItems": {"item": [{"Item": n} for n in names]},
    }
    resp = ris.selectCmDevice(StateInfo="",
                              CmSelectionCriteria=criteria)
    status = {}
    for node in resp["SelectCmDeviceResult"]["CmNodes"]["item"]:
        found = node["CmDevices"]    # node'da yoksa None
        for dev in (found["item"] if found else []):
            status[dev["Name"]] = (dev["Status"], node["Name"])
    return status
```

#walk(
  ("1", [Device adlarının listesini alıp, her biri için `(durum, node)` veren bir function.]),
  ("2–7", [Seçim kriteri bir `dict`: en fazla 1000 device, sınıf `Phone`, her model (`255`), her durum, *isme göre* seç. `SelectItems` içinde bir comprehension, her isim için bir `{"Item": isim}` kurar.]),
  ("8–9", [`selectCmDevice` kriterle çağrılır.]),
  ("10", [Sonuçlar bir dict'te toplanacak: `{device adı: (durum, node adı)}`.]),
  ("11", [Dış loop, cevaptaki *her CUCM node'unu* gezer.]),
  ("12", [Bir node'da hiç device yoksa `CmDevices` `None` olur; bu yüzden önce kontrol edilir.]),
  ("13–14", [İç loop, node'daki her device için `(durum, node)` kaydeder.]),
  ("15", [Toplanan sözlük geri verilir.]),
)

#methods(
  header: ([Durum], [Anlamı]),
  [`Registered`], [o node'da online],
  [`UnRegistered`], [register olmuştu, şimdi yok],
  [`Rejected`], [CUCM register'ı reddetti],
)

#pitfall[
  Yalnızca `CmNodes["item"][0]` okumak sadece Publisher'ı kontrol eder. Subscriber'a register olan phone'lar *sessizce* kaçırılır.
]

#topic[Limits and an unregistered-phone report]

RIS, cluster'ı sert limitlerle korur: istek başına en fazla *1000 device* ve varsayılan olarak dakikada yaklaşık *15 istek*. Daha büyük envanterler parçalar halinde, aralarda bekleyerek gönderilir.

Son CUCM restart'ından beri register olmayı hiç denememiş bir phone, RIS'te hiç yer almaz. Onu yalnızca AXL envanteriyle birleştirerek bulabilirsiniz: konfigüre edilmiş ama "görülmemiş".

#diagram("ris-join", width: 42%, caption: [AXL envanteri ile RIS durumu birleştirilir; RIS'te hiç görünmeyenler de yakalanır.])

```python
def chunks(items, size=1000):        # istek başına maks.
    for i in range(0, len(items), size):
        yield items[i:i + size]

phones = list_all(axl.listPhone, {"name": "SEP%"},
                  {"name": ""})               # AXL
names = [p.name for p in phones]
status = {}
for part in chunks(names):
    status.update(ris_status(part))           # RIS
    time.sleep(5)                             # limit

for name in names:
    state, node = status.get(name, ("not seen", "-"))
    if state != "Registered":
        print(name, state, node)
```

#walk(
  ("1–3", [`chunks()` bir list'i 1000'erli parçalara böler. `range(0, len(items), size)` adım adım ilerler; `yield` her parçayı tek tek verir (generator).]),
  ("5–6", [AXL ile envanter alınır: `SEP%` ile başlayan bütün phone'lar.]),
  ("7", [Bir comprehension yalnızca isimleri toplar.]),
  ("9–11", [Her parça için RIS sorulur; sonuçlar `status` sözlüğüne eklenir. Her istekten sonra 5 saniye beklenir: RIS'in dakikada 15 istek sınırına uymak için.]),
  ("13", [*Her* konfigüre edilmiş phone için döngü.]),
  ("14", [`status.get(name, ...)`: phone RIS cevabında yoksa varsayılan `("not seen", "-")` kullanılır. Tuple *unpacking* ile `state` ve `node` ayrılır.]),
  ("15–16", [Durum `Registered` değilse (kayıtsız, reddedilmiş ya da hiç görülmemiş), phone raporlanır.]),
)

#collab[
  Bu raporu her sabah çalıştırın: AXL listesi *ne online olması gerektiğini*, RIS *ne olduğunu* söyler. Aradaki fark, saha ekibine gidecek listedir.
]

#recap[
  - AXL konfigürasyonu, RIS canlı durumu bilir. İkisini birleştirmek "olması gereken ve olan" farkını verir.
  - `selectCmDevice` sonuçları node'a göre gruplar: *bütün* node'ları gezin.
  - RIS'in limitleri: istek başına 1000 device, dakikada ~15 istek. Parçalayın ve bekleyin.
]

#exercise[
  `ris_status` function'ını iki phone adıyla (`["SEP0A1B2C3D4E5F", "SEP0A1B2C3D4E60"]`) çağırın. Dönen sözlüğü bir `for` loop'u ile `ad: durum (node)` biçiminde yazdırın.
]
