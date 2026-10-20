#import "../../template.typ": *

#section[zeep and AXL]

#topic[SOAP, WSDL and zeep]

*AXL* (Administrative XML Web Service), CUCM'in konfigürasyon API'sidir. Yönetim arayüzünde yapabildiğiniz hemen her şeyi AXL ile de yapabilirsiniz: phone eklemek, line atamak, partition ve CSS oluşturmak, kullanıcıları listelemek. AXL bir *SOAP* API'sidir, yani istekler ve cevaplar XML zarfları olarak taşınır.

Bu zarfları elle yazmak yavaş ve hataya açıktır. İşte `zeep` kütüphanesi bunun için vardır. Her SOAP API'nin bir *WSDL* dosyası bulunur: bu dosya API'nin sözleşmesidir; her operasyonu, her alanı ve alanın tipini tarif eder. `zeep` WSDL'yi bir kere okur ve her operasyonu bir Python method'una çevirir. Siz `axl.getPhone(name=...)` yazarsınız; `zeep` SOAP zarfını kurar, gönderir ve cevabı bir object'e çevirir.

#analogy[
  WSDL, bir cihazın *komut referansı* gibidir: hangi komutlar var, her birinin hangi parametreleri alır, hangi tiplerde. `zeep` bu referansı okuyup size her komut için hazır bir function verir.
]

#diagram("zeep-flow", width: 72%, caption: [`zeep` WSDL'yi okur; siz bir Python method'u çağırırsınız, o SOAP zarfını kurup gönderir.])

```text
schema/
└── 15.0/                 her CUCM sürümü için bir klasör
    ├── AXLAPI.wsdl
    ├── AXLSoap.xsd
    └── AXLEnums.xsd
```

```bash
pip install zeep
```

#walk(
  ("schema/15.0/", [WSDL dosyalarını CUCM *sürümüne göre* bir klasörde tutun.]),
  ("AXLAPI.wsdl", [Ana sözleşme dosyası: operasyonların listesi.]),
  ("AXLSoap.xsd", [Veri tiplerinin şeması: her alan ve tipi.]),
  ("AXLEnums.xsd", [Sabit değer listeleri (enumeration'lar).]),
  ("pip install", [`zeep`, standart kütüphanede yoktur; kurulması gerekir.]),
)

Başlamadan önce dört şeyin hazır olması gerekir:

#methods(
  header: ([Ön koşul], [Nerede]),
  [Cisco AXL Web Service aktif], [Serviceability, Publisher üzerinde],
  [AXL application user], [roller: Standard AXL API Access, Standard CCM Admin Users],
  [*Sizin* sürümünüzün WSDL'si], [CM Admin: Application → Plugins → AXL Toolkit],
  [Tomcat CA sertifikası], [OS Admin: Certificate Management],
)

#warn[
  WSDL, cluster'ın sürümüyle eşleşmelidir. Eski bir şema "çoğunlukla çalışır" ama yeni alanları sessizce kaçırır. Her upgrade sonrası yeniden test edin.
]

#topic[Connecting to AXL]

Bağlantı katmanlar halinde kurulur. `requests`'in bir `Session`'ı giriş bilgisini ve sertifika kontrolünü taşır. Bir `Transport` cache ve timeout ekler. `Client` WSDL'yi okur ve `create_service` onu sizin Publisher'ınıza yöneltir.

```python
from requests import Session
from zeep import Client, Settings
from zeep.cache import SqliteCache
from zeep.transports import Transport

BINDING = "{http://www.cisco.com/AXLAPIService/}AXLAPIBinding"
URL = "https://cucm-pub.clauto.lab:8443/axl/"

session = Session()
session.auth = (user, password)       # os.environ'dan (1.11)
session.verify = "certs/clauto-ca.pem"
transport = Transport(session=session, timeout=30,
                      cache=SqliteCache())
settings = Settings(strict=False, xml_huge_tree=True)
client = Client("schema/15.0/AXLAPI.wsdl",
                transport=transport, settings=settings)
axl = client.create_service(BINDING, URL)

axl.getCCMVersion()["return"]["componentVersion"]["version"]
# '15.0.1.11900-23'
```

#walk(
  ("1–4", [Gerekli sınıflar getirilir: `Session` (requests), `Client`, `Settings`, `SqliteCache` ve `Transport` (zeep).]),
  ("6", [`BINDING`: AXL servisinin WSDL içindeki adı. Her AXL bağlantısında aynıdır.]),
  ("7", [`URL`: Publisher'ın AXL adresi. İsim kullanıyoruz, IP değil.]),
  ("9–11", [`Session` kimlik bilgisini ve CA sertifika yolunu taşır. Parola koda yazılmaz: `user` ve `password`, 1.11'deki gibi ortam değişkenlerinden gelir.]),
  ("12–13", [`Transport` bu session'ı kullanır, 30 saniyelik timeout ve diske yazılan bir cache ekler.]),
  ("14", [`Settings` zeep'in davranışını ayarlar. `strict=False` Cisco şemasındaki küçük kusurları hoş görür.]),
  ("15–16", [`Client` WSDL dosyasını okur.]),
  ("17", [`create_service` client'ı belirli bir adrese bağlar. `axl` artık CUCM ile konuşabilen bir nesnedir.]),
  ("19", [Deneme çağrısı: CUCM sürümünü sorar. Cevap `["return"]` içindedir.]),
)

`SqliteCache`, ayrıştırılmış WSDL'yi diskte tutar: AXL şeması büyüktür ve her çalıştırmada yeniden ayrıştırmak yavaştır.

İlk iş olarak `getCCMVersion` çağırın. Bir sürüm dönerse dört şey aynı anda kanıtlanmış olur: *ağ, kimlik bilgisi, roller ve sertifika.*

#collab[
  Bu satırları tek bir `get_axl()` function'ına ya da 1.10'daki `AxlClient` class'ına sarın. Böylece her script tek bir satırla başlar.
]

#topic[Reading one phone · getPhone]

AXL operasyonları iki gruba ayrılır. `get` operasyonları, *tek bir* object'i *bütün alanlarıyla* döndürür. `list` operasyonları ise *birçok* object'i, yalnızca istediğiniz alanlarla döndürür. Önce `get`'e bakalım.

#diagram("get-vs-list", width: 78%, caption: [`get` tek bir object'i bütün alanlarıyla, `list` birçok object'i seçilen alanlarla döndürür.])

```python
from zeep.helpers import serialize_object

resp = axl.getPhone(name="SEP0A1B2C3D4E5F")
phone = resp["return"]["phone"]

phone.name               # 'SEP0A1B2C3D4E5F'
phone.devicePoolName     # {'_value_1': 'DP_HQ',
                         #  'uuid': '{…}'}
def axl_text(value):     # güvenle aç
    return getattr(value, "_value_1", value)

axl_text(phone.devicePoolName)   # 'DP_HQ'
serialize_object(phone, dict)    # düz dict
```

#walk(
  ("3", [`getPhone(name=...)` bir phone'u adıyla ister. Operasyonun parameter'ları isimli argument'lardır (keyword argument).]),
  ("4", [Veri her zaman `resp["return"]` içinde, object'in adı altındadır: `phone`, `line`, `user`. `zeep` object'leri hem nokta hem köşeli parantezle çalışır.]),
  ("6", [Basit bir alan nokta ile okunur: `phone.name`.]),
  ("7–8", [Başka bir object'e işaret eden alanlar (device pool, CSS, location), düz bir metin değil, `{'_value_1': isim, 'uuid': ...}` biçiminde gelir.]),
  ("9–10", [Küçük bir yardımcı function: değer `_value_1` içeriyorsa onu, yoksa değerin kendisini verir.]),
  ("12", [`axl_text()` ile `'DP_HQ'` düz metin olarak çıkar.]),
  ("13", [`serialize_object(phone, dict)` tüm zeep object'ini normal bir Python `dict`'ine çevirir; `json.dump` ile kaydetmek gibi işler için.]),
)

Bu `_value_1` şeklini kodun her yerine yaymayın: AXL sürümleri arasında şekil değişebilir. Tek bir yardımcı function üzerinden okuyun.

#pitfall[
  Var olmayan bir isim için `getPhone`, `None` döndürmez, bir `Fault` yükseltir. Bir sonraki konularda göreceğimiz gibi `try` / `except Fault` ile sarın.
]

#topic[Reading many phones · listPhone]

`list` operasyonları *birçok* object döndürür, ama yalnızca `returnedTags`'te adını verdiğiniz alanlarla. Publisher'ın sağlıklı kalması için üç kural vardır.

#diagram("axl-paging", width: 72%, caption: [Sonuçlar sayfa sayfa alınır; bir sayfa kısa gelirse liste bitmiştir.])

```python
def list_all(method, criteria, tags, page=500):
    skip = 0
    while True:
        resp = method(searchCriteria=criteria,
                      returnedTags=tags,
                      first=page, skip=skip)
        rows = resp["return"]
        batch = rows["phone"] if rows else []
        yield from batch
        if len(batch) < page:
            return
        skip += page

tags = {"name": "", "description": ""}
for p in list_all(axl.listPhone, {"name": "SEP%"},
                  tags):
    print(p.name, p.description)
```

#walk(
  ("1", [Genel bir function: hangi `list` operasyonu, hangi arama kriteri, hangi alanlar, sayfa boyutu kaç.]),
  ("2", [`skip`, kaç kayıt atlanacağını tutar; sayfalama için.]),
  ("3", [`while True`: bitene kadar dön (1.5'teki polling kalıbı).]),
  ("4–6", [`method(...)` seçilen `list` operasyonunu çağırır. `first` sayfa boyutu, `skip` atlanacak kayıt sayısıdır.]),
  ("7–8", [Sonuç boşsa `rows` `None` olabilir. Bu yüzden önce kontrol edilir; sonra bu sayfanın phone'ları `batch`'e alınır.]),
  ("9", [`yield from batch` bu sayfadaki phone'ları *tek tek dışarı verir*. Bu, function'ı bir *generator* yapar.]),
  ("10–11", [Sayfa dolu gelmediyse (`< page`) başka kayıt kalmamıştır: `return` ile bitirilir.]),
  ("12", [Sonraki sayfaya geç.]),
  ("14", [`returnedTags`: yalnızca bu alanlar istenir. Değer olarak boş string verilir.]),
  ("15–17", [`list_all` bir loop içinde kullanılır: her turda tek bir phone gelir.]),
)

`yield from` ile `list_all` bir *generator* olur: phone'ları tek tek, sayfa sayfa dağıtır ve hepsini bellekte tutmaz. Bir comprehension'daki `(x for ...)` ile aynı fikirdir.

#methods(
  header: ([Kural], [Neden]),
  [her zaman `returnedTags` verin], [her alan × 5000 phone = aşırı yük],
  [`searchCriteria`'yı daraltın], [tek başına `%` bütün cluster'ı eşler],
  [`first` / `skip` ile sayfalayın], [sayfa kısa gelince durun],
)

#collab[
  `list_all`, `listLine`, `listUser` ve diğer `list` operasyonlarıyla da çalışır: yalnızca sonuç anahtarı (`"phone"`) değişir.
]

#topic[Adding objects · nested data]

`add` operasyonları, object'in adını taşıyan *tek bir* argument alır (`phone=`, `user=`, `css=`, `sipTrunk=`). Değeri, AXL XML'ini yansıtan iç içe bir `dict`'tir. `zeep` onu element element isteğe çevirir.

#diagram("axl-nested-write", width: 56%, caption: [`dict`'in yapısı AXL XML'inin yapısını yansıtır.])

```python
phone = {
    "name": "CSFALICE",
    "product": "Cisco Unified Client Services Framework",
    "class": "Phone", "protocol": "SIP", "protocolSide": "User",
    "commonPhoneConfigName": "Standard Common Phone Profile",
    "locationName": "Hub_None", "devicePoolName": "DP_HQ",
    "phoneTemplateName": "Standard Client Services Framework",
    "ownerUserName": "alice.smith",
    "lines": {"line": [
        {"index": "1", "label": "1001",
         "dirn": {"pattern": "1001",
                  "routePartitionName": "PT_Internal"}},
    ]},
}
axl.addPhone(phone=phone)      # yeni uuid'yi döndürür
```

#walk(
  ("2–4", [Phone'un kimliği: device adı, ürün tipi, sınıf ve protokol. Bunlar Jabber (CSF) için zorunlu alanlardır.]),
  ("5–7", [Phone'un bağlı olduğu diğer object'ler: common phone config, location, device pool ve phone template. Hepsi *isimle* verilir.]),
  ("8", [Phone'un sahibi olan kullanıcı.]),
  ("9–13", [Line'lar: `"lines"` altında `"line"` anahtarı bir *list* tutar. Her line bir dict'tir: `"index"` sıra numarası, `"dirn"` altında DN (`pattern`) ve partition.]),
  ("15", [`addPhone(phone=phone)` isteği gönderir. Başarılırsa yeni kaydın `uuid`'si döner.]),
)

Her tekrar eden element aynı kalıbı izler: *çoğul* bir sarmalayıcı anahtar (`"lines"`), onun içinde *tekil* anahtar (`"line"`) altında bir *list*.

#pitfall[
  `updatePhone(name=…, lines={"line": […]})` bütün line listesini *değiştirir*. Yalnızca yeni line'ı değil, phone'un *tutmasını istediğiniz her line'ı* gönderin; yoksa eskileri silinir.
]

#collab[
  Aynı şekil, bir loop içinde partition eklemek (`addRoutePartition`), CSS üyeleri (`members/member`) ya da trunk destination'ları için de geçerlidir.
]

#topic[Writing data and handling faults]

`add`, `update` ve `remove` operasyonları veritabanını değiştirir. Her yazmaya aynı şekilde davranın: `Fault`'u yakalayın, sonucu *doğrulamak için tekrar okuyun* ve yazmalar arasında bekleyin.

#diagram("axl-write-verify", width: 76%, caption: [Yaz → hata yakala → tekrar oku ve doğrula → bekle.])

```python
import time
from zeep.exceptions import Fault

for name, desc in updates.items():
    try:
        axl.updatePhone(name=name, description=desc)
    except Fault as e:
        failed.append((name, e.message))
        continue
    now = axl.getPhone(name=name)["return"]["phone"]
    if now.description != desc:
        failed.append((name, "not applied"))
    time.sleep(0.2)          # Publisher'ı zorlama
```

#walk(
  ("2", [`Fault`, AXL'in bir isteği reddettiğinde `zeep`'in yükselttiği exception'dır.]),
  ("4", [`updates` bir dict: `{device adı: yeni description}`. `items()` ile çiftleri geziyoruz.]),
  ("5–6", [Güncelleme `try` içinde.]),
  ("7–9", [Hata olursa device ve hata mesajı kaydedilir, sonraki phone'a geçilir (1.7'deki toplu iş kalıbı).]),
  ("10", [Güncelleme sonrası phone tekrar okunur. `now` güncel veridir.]),
  ("11–12", [Description beklenen değer değilse, "uygulanmadı" olarak kaydedilir. İstek hatasız dönse de değişiklik uygulanmamış olabilir; bu yüzden doğrularız.]),
  ("13", [Yazmalar arasında kısa bir bekleme.]),
)

#methods(
  header: ([Fault metni (sürüme göre değişir)], [Genellikle nedeni]),
  [`Item not valid … not found`], [bir isim, pool ya da CSS'te yazım hatası],
  [`duplicate value`], [object zaten var],
  [`User not authorized`], [AXL rolü eksik],
  [HTTP `503`], [yazma kısıtlaması: bekleyin, sonra yeniden deneyin],
)

#warn[
  Yazmaları yalnızca *Publisher*'a gönderin. AXL gerçek zamanlı değildir ve ani yük artışlarını kısıtlar. Ayrıca register durumunu bilmez: o bilgi RisPort70'te yaşar.
]

#topic[Seeing the raw XML · HistoryPlugin]

AXL bir `Fault` ile cevap verdiğinde, tek başına mesaj çoğu zaman yeterli olmaz. `HistoryPlugin`, son isteği ve son cevabı XML olarak saklar; böylece `zeep`'in tam olarak ne gönderdiğini ve CUCM'in ne döndürdüğünü görebilirsiniz.

#diagram("axl-history", width: 66%, caption: [`HistoryPlugin` giden isteği ve gelen cevabı ham XML olarak saklar.])

```python
from lxml import etree
from zeep.plugins import HistoryPlugin

history = HistoryPlugin()
client = Client(wsdl, transport=transport, plugins=[history])

def show_history():
    for item in (history.last_sent, history.last_received):
        print(etree.tostring(item["envelope"], encoding="unicode",
                             pretty_print=True))

try:
    axl.addPhone(phone=phone)
except Fault as f:
    print(f.message)
    show_history()          # tam olarak ne gönderildi?
```

#walk(
  ("1–2", [`lxml` XML'i güzel biçimde yazdırmak için; `HistoryPlugin` ise `zeep`'ten.]),
  ("4", [Bir `HistoryPlugin` object'i yaratılır.]),
  ("5", [`Client` yaratılırken `plugins=[history]` ile eklenir.]),
  ("7–10", [`show_history()` son gönderilen ve son alınan zarfı güzel biçimde yazdırır.]),
  ("12–16", [Hata olunca önce Fault mesajı, sonra ham XML yazdırılır.]),
)

Gönderilen XML'i AXL şema referansıyla ya da SoapUI'de çalışan bir istekle karşılaştırın: eksik alanlar, yanlış iç içe geçme ya da bir element adındaki yazım hatası hemen ortaya çıkar.

#tip[
  Script yeniyken her `except Fault` içinde `show_history()` çağırın. Script oturunca kaldırın ya da bir dosyaya loglayın.
]

#topic[SQL queries · executeSQLQuery]

*Thick AXL*, CUCM veritabanında salt-okunur bir SQL sorgusu çalıştırır ve her sonuç satırı için bir `row` döndürür. Her satır bir XML element listesidir: `el.tag` sütun adı, `el.text` değerdir. Bir sorgu, onlarca `list` çağrısı gerektirecek tabloları birleştirebilir; bu da cluster geneli raporlar için idealdir.

```python
sql = """
select d.name, n.dnorpattern
from device d
join devicenumplanmap m on m.fkdevice = d.pkid
join numplan n on n.pkid = m.fknumplan
where d.name like 'SEP%'
"""
resp = axl.executeSQLQuery(sql=sql)
rows = resp["return"]["row"] if resp["return"] else []

for row in rows:              # row = XML element listesi
    print({el.tag: el.text for el in row})
# {'name': 'SEP0A1B2C3D4E5F', 'dnorpattern': '1001'}
# {'name': 'SEP0A1B2C3D4E60', 'dnorpattern': '1002'}
```

#walk(
  ("1–7", [Üç tırnaklı bir metin, birden çok satıra yayılan SQL sorgusunu tutar. Sorgu `device`, `devicenumplanmap` ve `numplan` tablolarını birleştirir: her phone'un adını ve DN'ini getirir.]),
  ("8", [`executeSQLQuery(sql=sql)` sorguyu çalıştırır.]),
  ("9", [Sonuç boşsa `None` gelebilir: kontrol edilir.]),
  ("11–12", [Her satır için bir dict comprehension: sütun adı → değer.]),
  ("13–14", [Her satır, bir phone ve onun DN'ini içeren küçük bir dict'tir.]),
)

#warn[
  Mümkünse normal AXL method'larını tercih edin: tablo ve sütun adları sürümler arasında değişir (kendi sürümünüzün *Data Dictionary*'sine bakın). `executeSQLUpdate`'i *asla* kullanmayın: CUCM'in iş mantığını atlar.
]

#topic[A safe AXL workflow]

Yalnızca yazan bir script tehlikelidir. Önce kontrol eden, planı gösteren, yazan, tekrar kontrol eden ve kaydeden bir script ise bir change window'da güvenebileceğiniz bir araçtır.

#diagram("axl-workflow", width: 78%, caption: [Güvenli iş akışı: oku → planla → göster → (onaylanırsa) yedekle → yaz → doğrula.])

```python
import argparse

p = argparse.ArgumentParser()
p.add_argument("--input-file", required=True)
p.add_argument("--apply", action="store_true")
args = p.parse_args()

changes = plan(axl, read_input(args.input_file))
print_plan(changes)
if not args.apply:
    raise SystemExit("DRY RUN: use --apply to write")
write_rollback(changes)          # önce eski değerler
apply_and_verify(axl, changes)
```

#walk(
  ("1", [`argparse`, komut satırı seçeneklerini okuyan standart kütüphane modülüdür.]),
  ("3–6", [İki seçenek tanımlanır: zorunlu `--input-file` ve bayrak gibi çalışan `--apply`. `parse_args()` komut satırını okur.]),
  ("8", [Girdi dosyası okunur ve bir *değişiklik planı* üretilir. Henüz hiçbir şey yazılmadı.]),
  ("9", [Plan ekrana yazdırılır.]),
  ("10–11", [`--apply` verilmediyse script burada *durur*. Varsayılan davranış, hiçbir şeye dokunmamaktır.]),
  ("12", [Yazmadan önce *eski değerler* kaydedilir; bir şey ters giderse geri dönülebilir.]),
  ("13", [Değişiklikler uygulanır ve her biri tekrar okunarak doğrulanır.]),
)

*Dry run varsayılandır.* Yazmak açık bir `--apply` ister ve ilk yazmadan önce eski değerler kaydedilir.

#methods(
  header: ([Kullan], [Ne zaman]),
  [BAT], [tek tip değişiklik, BAT şablonuna uyuyor],
  [Python + AXL], [her object için karar, kontrol ya da başka bir sistemden veri gerekiyor],
)

#collab[
  Çalışan örnekler: `github.com/ilkermansur/collab_automation` (AXL, RIS, CMS, Expressway, Netmiko). Daha fazlası için: "Automating Cisco Voice Administration (CUCM) with Python", Cisco Community, 2026.
]

#recap[
  - `zeep`, WSDL'den her AXL operasyonunu bir Python method'una çevirir. Bağlantı: `Session` → `Transport` → `Client` → `create_service`.
  - `get` tek bir object'i okur (`resp["return"]["phone"]`), `list` birçok object'i seçilen alanlarla ve sayfa sayfa okur.
  - `add` ve `update`, AXL XML'ini yansıtan iç içe `dict` ister. Her yazmayı `Fault` yakalayarak yapın ve sonucu tekrar okuyarak doğrulayın.
  - `HistoryPlugin` ham XML'i gösterir. Güvenli iş akışı: dry run varsayılan, eski değerleri kaydet, yaz, doğrula.
]

#exercise[
  `getCCMVersion` ile bağlantıyı doğrulayın. Sonra `list_all` ile `SEP%` ile başlayan ilk 10 phone'u listeleyin ve `name` ile `description` yazdırın. Son olarak var olmayan bir phone için `getPhone` çağırıp `Fault`'u `try` / `except` ile yakalayın.
]
