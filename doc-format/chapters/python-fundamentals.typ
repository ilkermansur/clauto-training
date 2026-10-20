#import "../template.typ": *

#chapter([Python Fundamentals], intro: [
  CUCM ve Webex ile konuşmadan önce Python'un kendisini öğreniyoruz: veri
  tipleri, karar verme, tekrar etme, function'lar, dosyalar. Bütün örnekler
  collaboration dünyasından geliyor, böylece sözdizimini ve onun ne işe
  yaradığını aynı anda öğreniyorsunuz.
], goals: [
  - Bir değeri bir variable'a bağlamak ve verinin tipini tanımak
  - `if` ile karar vermek, loop ile yüzlerce cihaz üzerinde aynı işi yapmak
  - Kendi function'larınızı yazmak, hazır modülleri `import` etmek
  - Hata mesajlarını (exception) okumak; toplu işte tek bir satırın tüm işi durdurmasını engellemek
  - CSV ve JSON dosyalarını okuyup yazmak
  - Parolaları koddan ayırıp güvenli saklamak
])

#include "python-fundamentals/s01-why-python.typ"
#include "python-fundamentals/s02-variables.typ"
#include "python-fundamentals/s03-data-types.typ"
#include "python-fundamentals/s04-if.typ"
#include "python-fundamentals/s05-loops.typ"
#include "python-fundamentals/s06-functions.typ"
#include "python-fundamentals/s07-exceptions.typ"
#include "python-fundamentals/s08-files.typ"
#include "python-fundamentals/s09-comprehensions.typ"
#include "python-fundamentals/s10-classes.typ"
#include "python-fundamentals/s11-credentials.typ"
