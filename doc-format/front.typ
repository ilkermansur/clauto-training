#import "template.typ": *

#frontmatter([Bu Kitap Hakkında])[

Bu kitap, *ses ve collaboration mühendisleri* için yazıldı: CUCM'de partition ve CSS tasarlayan, CUBE üzerinde dial-peer yazan, Webex Calling organizasyonlarını yöneten ama hayatında hiç Python yazmamış kişiler için. Programcı olmanız gerekmiyor. Python'dan önce başka bir dil bilmenize de gerek yok. Tek ön koşul, kendi alanınızı bilmeniz: DN nedir, bir phone CUCM'e nasıl register olur, AXL'in ne işe yaradığı gibi şeyler sizin için zaten tanıdık.

Bu kitabın temel fikri şu: *tekrar eden her işi bir bilgisayara yaptırabilirsiniz.* 500 phone eklemek, 3000 DN'in partition'ını kontrol etmek, her sabah hangi cihazların register olmadığını raporlamak. Bunları tek tek tıklayarak yapmak yerine kısa bir Python script'i yazarsınız ve script bunu saniyeler içinde, hatasız ve her seferinde aynı şekilde yapar.

#subhead[Kitap nasıl ilerliyor?]

Kitap iki bölümden oluşuyor ve ikisi de bir önceki üzerine kurulu:

+ *Python Fundamentals:* dilin kendisi. Veri tipleri, karar vermek (`if`), tekrar etmek (loop), kod parçalarını isimlendirmek (function), hata yönetimi, dosyalar ve parolaların güvenli saklanması. Her konu, collaboration dünyasından bir örnekle anlatılıyor.
+ *APIs and Libraries:* Python'u Cisco sistemlerine bağlamak. HTTP, JSON ve XML, `requests` ve `zeep` kütüphaneleri, CUCM'in AXL API'si, RisPort70 ile cihaz durumu, Netmiko ile CLI, CMS REST API'si ve uzaktan phone kontrolü.

Birinci bölümü atlamayın. İkinci bölümdeki her örnek, birinci bölümde öğrendiğiniz parçalardan oluşuyor. Bir AXL isteğinin neden bir `dict` ile hazırlandığını, cevabın neden iç içe geçmiş list ve dict'lerden oluştuğunu ancak o parçaları bildiğinizde rahatça okuyabilirsiniz.

#subhead[Her konu aynı yolu izler]

Kitaptaki her konu başlığı aynı sırayla ilerler, böylece ne bekleyeceğinizi bilirsiniz:

+ *Önce neden?* Konunun hangi probleme çözüm olduğu ve çoğu zaman ses dünyasından tanıdık bir benzetme.
+ *Sonra ne?* Kavramın sade bir anlatımı ve bir diyagram.
+ *Kod.* Kısa, çalıştırılabilir bir örnek. Satır numaraları solda durur.
+ *Satır satır okuma.* Kodun her satırının ne yaptığı, sırayla.
+ *Tuzaklar ve gerçek hayat.* Sık yapılan hatalar ve konunun CUCM, Webex ya da CUBE tarafındaki karşılığı.

Her section'ın sonunda kısa bir *Özetle* kutusu ve bir *Kendin dene* alıştırması bulunur. Okumak yetmez: kodu kendi bilgisayarınızda yazıp çalıştırın, değerlerini değiştirin, bozun ve düzeltin. Programlama izleyerek değil, deneyerek öğrenilir.

#subhead[Dil hakkında bir not]

Metin Türkçe, ama *teknik terimler İngilizce kalıyor*: variable, list, loop, function, exception gibi. Bunun iki nedeni var. Birincisi, internetteki dokümanlar, hata mesajları ve Cisco DevNet örnekleri İngilizce; terimi bildiğiniz gibi görürsünüz. İkincisi, bu terimlerin Türkçe karşılıkları kafa karıştırıcı olabiliyor. Her terim ilk geçtiği yerde *kalın* yazılır ve Türkçe karşılığı parantez içinde verilir: *variable* (değişken). Sonrasında yalnızca İngilizcesi kullanılır ve Türkçe ekler kesme işaretiyle eklenir: list'in, loop'u, function'ı.

#subhead[Kutuların anlamı]

#analogy[Ses ve telefoni dünyasından bir benzetme. Yeni bir kavramı, zaten bildiğiniz bir şeye bağlar.]
#collab[Konunun CUCM, CUBE, Webex ya da başka bir Cisco collaboration ürünündeki karşılığı.]
#tip[Zaman kazandıran bir kısayol ya da iyi bir alışkanlık.]
#warn[Dikkat edilmezse sürpriz yaratabilecek bir ayrıntı.]
#pitfall[Yeni başlayanların neredeyse hepsinin yaptığı bir hata ve nasıl düzeltileceği.]

Kod örneklerinde program çıktısı iki şekilde gösterilir. Kısa sonuçlar, satırın sonunda `#` işaretinden sonra yazılır:

```python
2 + 3        # 5
```

Birkaç satırlık çıktılar ise ayrı bir `ÇIKTI` kutusunda gösterilir:

```output
alice.smith 1001
bob.jones 1002
```

#subhead[Lab dünyası: örneklerdeki isimler]

Kitaptaki bütün örnekler aynı hayali ortamı kullanır. *Hiçbir örnekte IP adresi yoktur*, her zaman isim kullanılır; bu hem okumayı kolaylaştırır hem de gerçek bir sisteme yanlışlıkla bağlanmanızı önler. Bu tabloyu bir kenarda tutun, örneklerde karşınıza çıkacak:

#table(
  columns: (auto, 1fr),
  [Öğe], [Değer],
  [Domain], [`clauto.lab` (e-posta ve SIP URI: `alice.smith@clauto.lab`)],
  [CUCM publisher / subscriber], [`cucm-pub.clauto.lab`, `cucm-sub1.clauto.lab`],
  [Unity Connection / IM&P], [`cuc-pub.clauto.lab`, `imp-pub.clauto.lab`],
  [CUBE], [`cube-01.clauto.lab`],
  [CMS], [`cms-01.clauto.lab` (API port 445, API kullanıcısı `api_svc`)],
  [Expressway C / E], [`expc-01.clauto.lab`, `expe-01.clauto.lab`],
  [CUCM sürümü], [15],
  [Webex organizasyonu], [`Clauto Lab` (Webex Calling)],
  [DN aralığı], [`1001`–`1999` (kullanıcılar), `2000`–`2099` (hunt / CTI)],
  [Phone'lar], [`SEP0A1B2C3D4E5F` (8851), `SEP0A1B2C3D4E60` (8865), `SEP0A1B2C3D4E61` (7841)],
  [Jabber], [`CSFALICE` (alice.smith), agent'lar `CSFAGENT01`, `CSFAGENT02`],
  [Kullanıcılar], [`alice.smith` → 1001, `bob.jones` → 1002, `carol.white` → 1003],
  [Partition / CSS], [`PT_Internal`, `CSS_Internal`],
  [Device pool], [`DP_HQ`, `DP_Branch`],
  [Hunt pilot], [`2000` (Sales)],
  [Codec'ler], [`G722`, `G711u`, `G711a`, `OPUS`],
  [AXL application user], [`axl_svc`],
)

#subhead[Python'u çalıştırmak]

Kitabı okurken kodları denemek için kendi bilgisayarınızda Python 3 kurulu olmalı (3.10 ya da üstü yeterli). Kurulu olup olmadığını terminalde şöyle kontrol edersiniz:

```bash
python3 --version
```

Python ile kod çalıştırmanın iki yolu vardır. Bu kitapta ikisini de kullanacağız.

#subhead[1. Etkileşimli mod (REPL)]

Terminalde sadece `python3` yazarsanız, `>>>` işaretiyle bir komut satırı açılır. Buraya yazdığınız her satır hemen çalışır ve sonucu görürsünüz. Bu, bir CUCM ya da CUBE CLI'ında komut yazmaya çok benzer. Küçük şeyleri denemek için idealdir:

```output
$ python3
>>> 2 + 3
5
>>> "SEP" + "0A1B2C3D4E5F"
'SEP0A1B2C3D4E5F'
>>> exit()
```

Kitaptaki kısa kod parçalarını (özellikle `# sonuç` yorumu olanları) REPL'e satır satır yazarak deneyebilirsiniz. REPL, bir satırın sonucunu otomatik yazdırır. Bu yüzden kitaptaki bazı örneklerde `print()` yoktur: sonuç yorumda gösterilir.

#subhead[2. Script dosyası]

Birkaç satırdan uzun işler için kodu bir dosyaya yazarsınız. Python dosyalarının uzantısı `.py`'dir. Örneğin `hello.py` adlı bir dosyaya şunu yazın:

```python
print("Merhaba, clauto.lab")
```

Ve terminalde çalıştırın:

```bash
python3 hello.py
```

Bu, CLI'a tek tek komut yazmakla, aynı komutları bir dosyaya yazıp tek seferde çalıştırmak arasındaki farka benzer. Bir script'i bir kez yazarsınız, istediğiniz kadar çalıştırırsınız. Dosya yönteminde sonucu görmek için `print()` kullanmanız gerekir.

#tip[
  Kodu *kopyalamak yerine kendiniz yazın*. Parmaklarınızla yazdığınızda hataları fark etmek, sözdizimini (syntax) öğrenmek çok daha kolay olur. Hata mesajı almanız kötü bir şey değil: Python'un neyin yanlış gittiğini size söylemesidir ve 1.7 numaralı bölümde bu mesajları okumayı öğreneceksiniz.
]

]
