#import "../../template.typ": *

#section[Netmiko]

#topic[CLI automation over SSH]

Her cihazın bir API'si yoktur. CUBE ve IOS voice gateway'ler *CLI* üzerinden yapılandırılır. *Netmiko*, bir SSH session'ı açar, bir komut gönderir, prompt'u bekler ve çıktıyı bir `str` olarak döndürür. Elle SSH'a girip komut yazıp çıktıyı kopyalamanın Python karşılığıdır.

#diagram("netmiko-ssh", width: 66%, caption: [Netmiko SSH ile bağlanır, komutu gönderir ve çıktıyı metin olarak döndürür.])

```python
import os
from netmiko import ConnectHandler   # pip install netmiko

cube = {
    "device_type": "cisco_xe",
    "host": "cube-01.clauto.lab",
    "username": os.environ["CUBE_USER"],
    "password": os.environ["CUBE_PASSWORD"],
}

with ConnectHandler(**cube) as conn:     # SSH girişi
    print(conn.send_command("show version | include uptime"))
# cube-01 uptime is 12 weeks, 3 days, 4 hours
```

#walk(
  ("2", [`ConnectHandler`, bağlantıyı kuran sınıftır. `pip install netmiko` ile kurulur.]),
  ("4–9", [Bağlantı bilgileri bir `dict`'te tutulur: cihaz tipi, host adı, kullanıcı ve parola. Kullanıcı ve parola, koda değil ortam değişkenlerinden okunur (1.11).]),
  ("11", [`ConnectHandler(**cube)`: `**` dict'i isimli argument'lara açar (1.6.1). `with` ile bağlanılır; blok bitince oturum kapanır.]),
  ("12", [`send_command()` tek bir `show` komutu çalıştırır ve çıktıyı metin olarak döndürür.]),
)

#methods(
  header: ([Parça], [Anlamı]),
  [`device_type`], [CLI türü: IOS-XE üzerindeki CUBE için `cisco_xe`],
  [`ConnectHandler(**d)`], [giriş yapar; `**` dict'i açar (1.6.1)],
  [`with … as conn`], [bitince otomatik çıkış yapar],
  [`send_command(cmd)`], [bir `show` komutu çalıştırır, metni verir],
)

#pitfall[
  `with` kullanmıyorsanız `conn.disconnect()` çağırmayı kendiniz hatırlayın. Unutulan oturumlar, router'ın VTY hatları tükenene kadar açık kalır.
]

#topic[Turning show output into data]

CLI çıktısı, insanlar için üretilmiş bir metindir. Bir değeri satır ve sütun numarasıyla seçmek (`splitlines()[13].split()[4]`), bir yazılım güncellemesi bir satır eklediği anda bozulur.

- *Regex* (`re`), bir değeri *etiketiyle* bulur: `Total call-legs:` satırı nereye kayarsa kaysın çalışır.
- *TextFSM* (`use_textfsm=True`), bilinen komutları ntc-templates koleksiyonuyla bir dict list'ine ayrıştırır.

#diagram("netmiko-parse", width: 66%, caption: [Ham CLI metninden regex ya da TextFSM ile yapılandırılmış veri çıkarılır.])

```python
import re

out = conn.send_command("show call active voice brief")
m = re.search(r"Total call-legs:\s*(\d+)", out)
legs = int(m.group(1)) if m else 0
calls = legs // 2          # CUBE'da bir call = iki leg

rows = conn.send_command("show ip interface brief",
                         use_textfsm=True)
rows[0]   # {'interface': 'GigabitEthernet1', 'status': 'up', …}
```

#walk(
  ("1", [`re` standart kütüphanenin düzenli ifade (regular expression) modülüdür.]),
  ("3", [Aktif call'ları gösteren komutun çıktısı alınır.]),
  ("4", [`re.search()` metinde bir *desen* arar. `Total call-legs:` sabit etikettir; `\s*` "sıfır ya da daha fazla boşluk"; `(\d+)` "bir ya da daha fazla rakam, parantezle yakala" demektir. Başındaki `r` metni *ham string* yapar: `\` karakterleri olduğu gibi kalır.]),
  ("5", [Bulunduysa (`m` `None` değilse), yakalanan rakamlar `m.group(1)` ile alınır ve `int`'e çevrilir; bulunamadıysa `0`.]),
  ("6", [CUBE'da her call iki leg'den oluşur: yarısı call sayısıdır.]),
  ("8–9", [`use_textfsm=True` çıktıyı bilinen bir şablonla otomatik olarak dict'lerin list'ine çevirir.]),
  ("10", [Her satır bir dict: sütun adı → değer.]),
)

#warn[
  ntc-templates birçok routing komutunu kapsar ama sesle ilgili komutları neredeyse hiç kapsamaz (bugün için yalnızca `show isdn status`). CUBE için regex'i planlayın.
]

#topic[Changing configuration]

`send_config_set`, bir *list* olarak config satırları alır: configuration moduna girer, her satırı gönderir ve çıkar. `save_config()` ise running config'i startup'a yazar (`write memory`).

#diagram("netmiko-config", width: 66%, caption: [`send_config_set` config moduna girer, satırları gönderir ve çıkar.])

```python
def alternate_announcement(conn, enable):
    commands = [
        "dial-peer voice 9000 voip",
        "no shutdown" if enable else "shutdown",
    ]
    out = conn.send_config_set(commands)
    if "% Invalid" in out:
        raise RuntimeError(out)
    conn.save_config()             # write memory

with ConnectHandler(**cube) as conn:
    alternate_announcement(conn, enable=True)
    print(conn.send_command("show dial-peer voice summary"))
```

#walk(
  ("1", [Alternatif anons dial-peer'ini açan ya da kapatan bir function. `enable` bir `bool`.]),
  ("2–5", [Gönderilecek komutlar bir list'te: önce dial-peer `9000`'e gir, sonra `enable`'a göre `no shutdown` ya da `shutdown` yaz. Tek satırlık `x if koşul else y` kalıbı (1.4).]),
  ("6", [Komutlar gönderilir; Netmiko config moduna girip çıkar. Router'ın cevabı `out`'ta toplanır.]),
  ("7–8", [Router yanlış bir komutta bir *exception yükseltmez*; `% Invalid input` ile cevap verir. Bu yüzden çıktıyı kendimiz kontrol eder ve hata varsa `raise` ile bir exception yükseltiriz.]),
  ("9", [Her şey yolundaysa konfigürasyon kaydedilir.]),
  ("11–13", [Bağlan, değişikliği uygula ve sonucu bir `show` komutuyla *doğrula*.]),
)

Router yanlış bir komuta exception ile değil metinle cevap verdiği için, dönen metni kontrol edin ve sonucu bir `show` komutuyla doğrulayın.

#pitfall[
  Listeye `"conf t"` koymayın: Netmiko zaten config moduna girdi; fazladan satır yalnızca gürültü ya da hata ekler.
]

#topic[Scheduled checks · RIS + CUBE]

Script'ler, kaynakları birleştirdiğinde en yararlı hale gelir: RIS contact-center agent'larının register olup olmadığını bilir, CUBE ise çağrıların nereye gideceğine karar verir. `time.sleep()` ile bir loop (ya da `schedule` paketi) bu kontrolü her dakika çalıştırır.

#diagram("netmiko-monitor", width: 68%, caption: [RIS'ten agent durumu okunur; sonuca göre CUBE'daki dial-peer açılır ya da kapatılır.])

```python
import time
from netmiko import (NetmikoTimeoutException,
                     NetmikoAuthenticationException)

agents = ["CSFAGENT01", "CSFAGENT02"]

while True:
    status = ris_status(agents)                  # 2.5
    up = any(s == "Registered" for s, _ in status.values())
    try:
        with ConnectHandler(**cube) as conn:
            alternate_announcement(conn, enable=not up)
    except (NetmikoTimeoutException,
            NetmikoAuthenticationException) as e:
        print(time.asctime(), "CUBE not reachable:", e)
    time.sleep(60)
```

#walk(
  ("2–3", [Netmiko'nun kendi iki exception'ı: cihaz cevap vermezse `NetmikoTimeoutException`, giriş yanlışsa `NetmikoAuthenticationException`.]),
  ("5", [İzlenecek iki agent Jabber client'ı.]),
  ("7", [`while True`: sonsuza kadar kontrol et.]),
  ("8", [RIS'ten (2.5) agent'ların durumu sorulur: `{ad: (durum, node)}`.]),
  ("9", [`any(...)`: agent'lardan *en az biri* `Registered` ise `up` `True` olur. Generator içinde `for s, _ in ...` tuple'ı açar; `_` "bu değer işime yaramıyor" demenin gelenekselidir.]),
  ("10–12", [CUBE'a bağlanıp dial-peer'i ayarlarız: hiçbir agent online değilse (`not up`) alternatif anons *açılır*.]),
  ("13–15", [CUBE'a ulaşılamazsa ya da giriş başarısız olursa loop'u öldürmek yerine hata zaman damgasıyla yazılır.]),
  ("16", [60 saniye bekle, sonra yeniden kontrol et.]),
)

Netmiko, cevap vermeyen bir host ve yanlış bir giriş için kendi exception'larını yükseltir. Onları yakalayın, loglayın ve loop'u hayatta tutun.

#collab[
  Hiçbir agent'ın Jabber'ı register değilse, arayanları alternatif bir anonsa gönderen dial-peer'i açın. Bir agent geri dönünce yeniden kapatın.
]

#recap[
  - Netmiko, API'si olmayan cihazlarda CLI'ı otomatikleştirir: `ConnectHandler` ile bağlan, `send_command` ile oku, `send_config_set` ile yaz.
  - CLI çıktısını satır numarasıyla değil, etiketiyle ayrıştırın: regex ya da TextFSM.
  - Router yanlış komuta hata fırlatmaz: çıktıyı kontrol edin ve sonucu `show` ile doğrulayın.
]

#exercise[
  `send_command("show version | include uptime")` çıktısından regex ile "weeks" önündeki sayıyı yakalayıp yazdırın. (Lab ortamınız yoksa örnek çıktıyı bir string olarak yazıp `re.search`'ü onun üzerinde deneyin.)
]
