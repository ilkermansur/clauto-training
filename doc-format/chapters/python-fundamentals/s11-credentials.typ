#import "../../template.typ": *

#section[Credentials]

#topic[Keep secrets out of your code]

Kodun içine yazılan bir parola, script ile birlikte yolculuk eder: git'e, bir iş arkadaşına e-postayla gönderdiğiniz dosyaya, paylaşılan ekrana. Bir kere repo'ya giren parola, silseniz bile git geçmişinde kalır. Altın kural şudur: *gizli bilgileri kodun dışında tutun* ve script çalışırken okuyun.

#diagram("secrets-flow", width: 76%, caption: [Parola koda değil, script'in dışındaki bir kaynağa yazılır ve çalışırken okunur.])

```python
password = "Cisco123!"          # asla böyle yapmayın

from getpass import getpass
password = getpass("AXL password: ")   # ekranda görünmez

import os
user = os.environ["AXL_USER"]   # yoksa KeyError
password = os.environ.get("AXL_PASSWORD")  # ya da None
```

```bash
export AXL_USER=axl_svc         # terminalde
```

#walk(
  ("1", [*Kötü örnek*: parola doğrudan kodda. Dosyayı gören herkes parolayı görür.]),
  ("3–4", [`getpass()` script her çalıştığında parolayı sorar ve yazdıklarınızı ekranda göstermez. Elle yapılan çalıştırmalar için idealdir.]),
  ("6–7", [`os.environ`, ortam değişkenlerine (environment variables) erişim sağlar. Bir `dict` gibi davranır: `[...]` olmayan bir isimde hata verir.]),
  ("8", [`.get()` ise olmayan bir isimde `None` döndürür.]),
  ("10", [Ortam değişkeni terminalde `export` ile tanımlanır.]),
)

#methods(
  header: ([Kaynak], [Ne için iyi]),
  [`getpass()`], [elle çalıştırma: sorar, hiçbir şey göstermez],
  [`os.environ`], [kabukta ya da bir zamanlayıcıda tanımlanan değerler],
  [`.env` dosyası], [laptop'unuzdaki proje başına ayarlar],
)

#collab[
  Kendi admin hesabınızı değil, yalnızca *Standard AXL API Access* ve *Standard CCM Admin Users* rollerine sahip, ayrılmış bir AXL application user (`axl_svc`) kullanın. Sızarsa zarar sınırlı kalır ve tek bir hesabı iptal edersiniz.
]

#topic[.env files and a safe setup]

Ortam değişkenlerini her seferinde elle tanımlamak yorucudur. `python-dotenv` paketi bir `.env` dosyasını okur ve her satırı `os.environ`'a koyar. Script'in kodu laptop'unuzda, bir jump host'ta ve bir zamanlayıcıda aynı kalır; yalnızca `.env` dosyası değişir.

#diagram("dotenv-flow", width: 76%, caption: [`.env` dosyası repo'ya girmez; `load_dotenv()` onu ortama yükler.])

```text
# .env  (.gitignore'da)
CUCM_HOST=cucm-pub.clauto.lab
AXL_USER=axl_svc
AXL_PASSWORD=change-me
```

```python
# pip install python-dotenv
import os
from dotenv import load_dotenv

load_dotenv()                    # .env → os.environ
missing = [k for k in ("AXL_USER", "AXL_PASSWORD")
           if k not in os.environ]
if missing:
    raise SystemExit(f"missing settings: {missing}")
```

#walk(
  ("2", [`python-dotenv` standart kütüphanede yoktur; önce `pip install python-dotenv` gerekir.]),
  ("5", [`load_dotenv()` `.env` dosyasını okur ve içindekileri `os.environ`'a yükler.]),
  ("6–7", [Bir list comprehension: gerekli ayarlardan *ortamda olmayanları* toplar.]),
  ("8–9", [Eksik varsa, script'i erkenden ve *anlaşılır bir mesajla* durdurur (`SystemExit`).]),
)

Gerekli bütün ayarları *en başta* kontrol etmek, 300 phone'luk bir işin ortasında anlaşılmaz bir hatayla düşmek yerine tek bir net mesaj verir.

#methods(
  header: ([Yap], [Neden]),
  [`.env`'i `.gitignore`'a ekle], [gizli bilgiler repo'ya hiç girmez],
  [`.env.example` dosyasını commit et], [başkaları hangi isimlerin gerektiğini görür],
  [araç başına bir AXL kullanıcısı], [denetlemesi ve iptali kolay],
  [bir parolayı asla `print` etme], [loglar ve ekranlar paylaşılır],
)

#recap[
  - Parolayı koda yazmayın. `getpass()`, `os.environ` ya da bir `.env` dosyası kullanın.
  - `.env` her zaman `.gitignore`'da olmalı; repo'ya yalnızca isimleri gösteren `.env.example` girer.
  - Gerekli ayarları script'in başında kontrol edin ve eksik varsa net bir mesajla durun.
  - İşe özel, yetkisi sınırlı bir AXL kullanıcısı (`axl_svc`) kullanın.
]

#exercise[
  Bir `.env` dosyası oluşturup `CUCM_HOST` ve `AXL_USER` tanımlayın, `.gitignore`'a ekleyin. Script'te `load_dotenv()` ile okuyup değerleri yazdırın. Sonra `AXL_USER` satırını silip script'in `SystemExit` ile nasıl durduğunu gözlemleyin.
]
