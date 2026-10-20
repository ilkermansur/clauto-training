#import "../../template.typ": *

#section[Why Python?]

#topic[Python for collaboration engineers]

Bir collaboration mühendisinin iş günü büyük ölçüde tekrar eden işlerden oluşur. Yeni başlayan bir çalışan için phone, line, voicemail box ve Webex hesabı açmak. Her sabah hangi cihazların register olmadığına bakmak. Bir CSS değişikliğini kırk device pool'a uygulamak. Bunların her biri tek başına küçüktür, ama 500 kez tekrarlanınca saatler alır ve her tıklamada bir yazım hatası yapma riski vardır.

Bu tür işleri bilgisayara yaptırmanın yolu *program* (ya da *script*) yazmaktır. Bir program, bilgisayara adım adım yazılmış bir talimat listesidir: tıpkı bir call flow diyagramı gibi. "Şunu al, bunu kontrol et, şuna göre şunu yap." Aradaki tek fark, bu talimatları bir insanın değil bilgisayarın uygulamasıdır: 3 phone için de, 3000 phone için de aynı titizlikle.

#analogy[
  CUCM'de *BAT* (Bulk Administration Tool) kullandıysanız mantığı zaten biliyorsunuz: bir şablon, bir CSV dosyası ve tek tıkla toplu iş. Python, BAT'ın sınırlarını kaldırır. Yalnızca CUCM ile değil; Unity Connection, CUBE, CMS ve Webex ile de aynı dilde konuşursunuz. Üstelik BAT'ın yapamadığı şeyleri de ekleyebilirsiniz: "önce kontrol et, sonra karar ver, hata olursa rapora yaz."
]

#diagram("python-collab-hub", width: 78%, caption: [Python, collaboration dünyasının bütün API'lerine tek bir dille bağlanır.])

*Python*, okunması kolay, neredeyse İngilizce gibi akan bir sözdizimi (syntax) olan, genel amaçlı (general-purpose) bir programlama dilidir. İki özelliği sizi hemen ilgilendirir:

- *Interpreted* (yorumlanan): Kodu yazarsınız ve çalıştırırsınız, sonucu hemen görürsünüz. Ayrı bir derleme (compile) adımı yoktur.
- *Dynamically typed* (dinamik tipli): Bir değerin ne olduğunu (sayı mı, metin mi) önceden bildirmeniz gerekmez; Python bunu değerden anlar. Bu konuya "Data Types" bölümünde ayrıntılı döneceğiz.

#subhead[Collaboration'da neden önemli?]

- *Ölçek:* 500 kullanıcı ve phone eklemek, 500 ayrı GUI formu yerine tek bir loop'tur.
- *Tutarlılık:* Her seferinde aynı partition, CSS ve device pool atanır. Yazım hatası olmaz.
- *Görünürlük:* Register durumu, envanter ve CDR verisi saniyeler içinde tek bir raporda toplanır.
- *Entegrasyon:* Tek bir dil AXL, RIS, CUPI ve Webex REST API'sinin hepsini konuşabilir.

#collab[
  Cisco DevNet'teki AXL ve Webex örneklerinin çoğu Python ile yazılmıştır. Yani Python öğrendiğiniz günden itibaren bu örnekleri okuyabilir ve kendi ortamınıza uyarlayabilirsiniz.
]

#topic[Python neye benziyor?]

Henüz hiçbir şey öğrenmeden, küçük bir örneğe bakalım. Bir phone'un register durumunu kontrol eden kısa bir script:

```python
status = "UnRegistered"

if status != "Registered":
    print("UYARI: SEP0A1B2C3D4E5F kapalı")
```

Bunu şimdi tam olarak anlamanız gerekmiyor. Yine de yüksek sesle okuyun: "status, 'UnRegistered' olsun. Eğer status 'Registered' değilse, bir uyarı yazdır." Python'un okunabilirliği bu: kod, bir mühendisin kendi kendine söylediği cümleye çok yakın.

#walk(
  ("1", [`status` adında bir isim yaratır ve içine `"UnRegistered"` metnini koyar.]),
  ("3", [Koşul: `status`, `"Registered"`'a eşit *değilse*...]),
  ("4", [...ekrana uyarı yazdır. Bu satır içeri girintili (indented) olduğu için yalnızca koşul doğruysa çalışır.]),
)

Bu kitabın sonunda, bu küçük kontrolü 500 phone'a uygulayıp sonucu bir CSV dosyasına yazan script'leri kendiniz yazabileceksiniz.

#recap[
  - Script, bilgisayara yazılmış adım adım bir talimat listesidir.
  - Python okunması kolay, genel amaçlı bir dildir; CUCM, Webex ve diğer Cisco sistemleriyle aynı dilde konuşur.
  - Tekrar eden iş, bir loop'a dönüşür: ölçek, tutarlılık ve hız kazanırsınız.
]
