#import "../../template.typ": *

#section[Remote Phone Control]

#topic[The phone's own web server]

Bazı işlerin hiç API'si yoktur: ITL dosyasını silmek, bir menü ayarını sıfırlamak, ekranın fotoğrafını çekmek. Ama her Cisco IP phone küçük bir web server çalıştırır ve `/CGI/Execute`, bir script'in sanki phone'un başında biri duruyormuş gibi *tuşlara basmasına* ya da *numara çevirmesine* izin verir.

#analogy[
  Bir phone'un kendi web server'ı, cihazın üzerindeki *tuş takımının* ağdan erişilebilir bir kopyası gibidir. Script, parmaklarınızın yerine geçer: Settings'e basar, menüde yürür, tuşa basar.
]

#diagram("phone-web", width: 76%, caption: [Script, phone'un `/CGI/Execute` adresine bir XML gönderir; phone onu tuş basması gibi uygular.])

```text
POST http://<phone>/CGI/Execute
Content-Type: application/x-www-form-urlencoded

XML=<CiscoIPPhoneExecute>
      <ExecuteItem URL="Key:Settings"/>
    </CiscoIPPhoneExecute>
```

#walk(
  ("POST", [Phone'un kendi adresine, `/CGI/Execute` yoluna bir istek.]),
  ("Content-Type", [Form data olarak gönderilir.]),
  ("XML=...", [Body'de `XML` adlı tek bir alan vardır. İçindeki `ExecuteItem`, tek bir eylemdir: burada `Settings` tuşuna bas.]),
)

Phone'un adresini elle yazmak yerine RIS'ten alırsınız. `ris_status` function'ının (2.5) bir benzeri, durum yerine IP adresini de saklar:

```python
def phone_hosts(names):     # ris_status (2.5), ama
    ...                     # adresi de saklar
    for dev in devs:
        ip = dev["IPAddress"]["item"][0]["IP"]
        hosts[dev["Name"]] = ip
    return hosts
```

#walk(
  ("1–2", [RIS sorgusu aynıdır; `...` yer tutucudur.]),
  ("3", [RIS cevabındaki her device için...]),
  ("4", [...device'ın IP adresini alır: `IPAddress` bir list'in içinde bir `item` listesi, ilk elemanın `IP` alanı.]),
  ("5", [`{device adı: IP adresi}` sözlüğüne ekler.]),
  ("6", [Sözlük geri verilir.]),
)

#methods(
  header: ([Ön koşul], [Nerede]),
  [Web Access etkin], [CUCM'de phone konfigürasyonu],
  [phone'a sahip bir end user], [kullanıcının *Controlled Devices* listesi],
  [phone adresi], [RIS'ten (`IPAddress`), asla elle yazılmaz],
)

Phone, girişi kontrol etmesi için CUCM'e sorar; bu yüzden phone'a sahip normal bir end user yeterlidir. Cevap küçük bir XML belgesidir: `<ResponseItem … Status="0"/>` başarı demektir.

#topic[Pressing keys remotely]

Her `ExecuteItem` tek bir eylemdir. Bir tuş dizisi bir list'tir; sırayla, kısa bekleme araları vererek, her biri ayrı bir `POST` ile gönderilir: tam olarak bir insanın menüde yürümesi gibi.

#diagram("phone-keys", width: 70%, caption: [Bir tuş dizisi: her eleman ayrı bir istek; aralarda kısa bir bekleme.])

```python
import time
import xml.etree.ElementTree as ET
import requests

def press(host, item, wait=1):
    xml = f'<CiscoIPPhoneExecute><ExecuteItem URL="{item}"/>' \
          '</CiscoIPPhoneExecute>'
    r = requests.post(f"http://{host}/CGI/Execute",
                      data={"XML": xml}, auth=auth, timeout=10)
    r.raise_for_status()
    time.sleep(wait)                     # menü açılsın
    return ET.fromstring(r.content).find("ResponseItem") \
             .get("Status") == "0"

ITL_88XX = ["Key:Applications", "Key:KeyPad6", "Key:KeyPad4",
            "Key:KeyPad4", "Key:Soft3", "Key:Soft1"]
for name, host in phone_hosts(phones).items():   # RIS'ten
    ok = all(press(host, key) for key in ITL_88XX)
    print(name, "done" if ok else "check manually")
```

#walk(
  ("5", [`press()` tek bir tuşa basar. `wait` basıştan sonra beklenecek saniye; menünün açılması için.]),
  ("6–7", [İstek XML'i bir f-string ile kurulur. Sondaki `\` satırın devam ettiğini söyler.]),
  ("8–9", [XML, `XML` form alanı olarak gönderilir. `auth` phone'a sahip end user'ın kimlik bilgisidir.]),
  ("10", [HTTP hatası varsa exception.]),
  ("11", [Menünün açılması için bekleme.]),
  ("12–13", [Cevap XML'ini ayrıştırır, `ResponseItem`'ı bulur ve `Status` değeri `"0"` ise (başarı) `True` döndürür.]),
  ("15–16", [Bir 88xx phone'da belirli bir menü yolunu (ITL silme) tarif eden tuş sırası.]),
  ("17", [RIS'ten alınan her phone için...]),
  ("18", [`all(...)`: dizideki *her* tuş başarıyla basılırsa `True`. Biri başarısız olursa daha fazla denemez.]),
  ("19", [Sonuç: `done` ya da elle kontrol edilmesi gereken phone.]),
)

#methods(
  header: ([Eleman], [Eylem]),
  [`Key:Settings` `Key:Applications`], [sabit tuşlar],
  [`Key:KeyPad0` … `Key:KeyPad9`], [tuş takımı],
  [`Key:Soft1` … `Key:Soft4`], [ekranın altındaki soft key'ler],
  [`Dial:1002`], [bir call başlat],
)

#warn[
  Menü yolları model ve firmware'e göre değişir: her model için ayrı bir tuş listesi tutun ve önce tek bir phone'da deneyin. Script ekranı göremediği için kaçırılan bir adım fark edilmez (sonraki konu).
]

#topic[Screenshots · CGI/Screenshot]

`/CGI/Screenshot` adresine bir `GET`, o anki ekranı bir resim olarak döndürür. `r.content` ham `bytes`'ı tutar ve doğrudan bir `.png` dosyasına yazılır. Tuşlara basmanın ne yaptığını *doğrulamak* için ya da bir sorunu masaya gitmeden belgelemek için kullanın: "line register mı?", "ekranda hangi hata var?"

```python
from pathlib import Path

def screenshot(name, host):
    r = requests.get(f"http://{host}/CGI/Screenshot",
                     auth=auth, timeout=10)
    r.raise_for_status()
    out = Path("shots") / f"{name}.png"
    out.parent.mkdir(exist_ok=True)
    out.write_bytes(r.content)     # bytes, 1.3.10
    return out

for name, host in phone_hosts(phones).items():
    try:
        print(screenshot(name, host))
    except requests.exceptions.RequestException as e:
        print(name, "failed:", e)
# shots/SEP0A1B2C3D4E5F.png
```

#walk(
  ("1", [`pathlib.Path` yol işlemleri için (1.8).]),
  ("3–6", [Ekran görüntüsü istenir ve hata kontrol edilir.]),
  ("7", [Dosya yolu `shots/<phone adı>.png` olarak kurulur. `/` operatörü yol parçalarını birleştirir.]),
  ("8", [`mkdir(exist_ok=True)`: `shots` klasörü yoksa yaratır, varsa hata vermez.]),
  ("9", [`write_bytes()` ham byte'ları dosyaya yazar. Resim *metin değil, bytes*'tır (1.3.10).]),
  ("12–16", [Her phone için bir `try`: bir phone başarısız olursa diğerleri devam eder. `RequestException`, `requests`'in bütün hatalarının ortak atasıdır.]),
)

#collab[
  Toplu bir ITL silme işleminden sonra her phone'un ekran görüntüsünü alın ve klasörü gözden geçirin: tek bakışta hangi phone'ların beklenen menüye ulaşamadığını görürsünüz.
]

#tip[
  Çalışan bir referans: kurs repository'sindeki `erase_itl.py`, 69xx, 78xx, 88xx ve 99xx modelleri için test edilmiş tuş dizilerini içerir.
]

#recap[
  - Her Cisco IP phone, `/CGI/Execute` ile tuşlara basmaya ve `/CGI/Screenshot` ile ekran görüntüsü almaya izin veren bir web server çalıştırır.
  - Phone adreslerini RIS'ten alın. Her tuş bir `POST`; aralarda bekleyin.
  - Script ekranı göremez: sonucu bir screenshot ile doğrulayın.
]

#exercise[
  `press(host, "Key:Settings")` çağrısını tek bir lab phone'unda deneyin. Ardından bir screenshot alıp phone ekranının gerçekten değiştiğini kontrol edin.
]
