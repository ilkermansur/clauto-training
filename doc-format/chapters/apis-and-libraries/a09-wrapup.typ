#import "../../template.typ": *

#section[Wrap-up]

#topic[What you can do now]

İlk `print`'ten başlayıp bir collaboration cluster'ını baştan sona okuyan, değiştiren ve kontrol eden script'lere geldiniz. Şimdi yapabildikleriniz üç başlıkta toplanıyor:

#diagram("course-map", width: 80%, caption: [Kitabın haritası: Python dili, kapılar (API'ler) ve güvenli çalışma biçimi.])

- *Dil olarak Python:* veri, kararlar, loop'lar, function'lar, dosyalar ve hatalar.
- *Kapılar olarak API'ler:* CUCM'de AXL ve RIS, Webex ve CMS'te REST, CUBE'ta SSH, her phone'daki web server.
- *Güvenli bir çalışma biçimi:* gizli bilgiler kodun dışında, önce dry run, her değişiklikten sonra doğrulama, bir kayıt tutmak.

#collab[
  Küçük başlayın: her sabah çalışan salt-okunur bir rapor. Sonraki her script aynı bağlantıyı, aynı loop'u ve aynı hata yönetimini yeniden kullanır.
]

#recap(title: [Kitabın özeti])[
  - Python'da her şey bir object'tir; variable bir etikettir. Tipi bilmek, davranışı bilmektir.
  - Loop ve function, tekrar eden işi bir kere yazmanızı sağlar. Hataları yakalayın, toplu işte durmayın.
  - Her API aynı üç adımı ister: bağlan, iste, cevabı ayrıştır. `requests` REST için, `zeep` SOAP için, Netmiko CLI için.
  - Yazmadan önce oku, yazarken kaydet, yazdıktan sonra doğrula.
]
