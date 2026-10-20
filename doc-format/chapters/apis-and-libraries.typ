#import "../template.typ": *

#chapter([APIs and Libraries], intro: [
  Her Cisco collaboration ürünü bir API üzerinden yönetilebilir: CUCM
  AXL ve UDS ile, Unity Connection CUPI ile, Webex kendi REST API'siyle.
  Bu bölümde hepsinin arkasındaki web temellerini, konuştukları veri
  formatlarını ve işin ağır kısmını yapan iki Python kütüphanesini
  öğreniyoruz: REST için `requests`, SOAP için `zeep`.
], goals: [
  - Bir HTTP isteğinin ve cevabının nasıl okunacağını anlamak (SIP'e çok benzer)
  - JSON ve XML verisini Python'da ayrıştırmak
  - `requests` ile REST API çağırmak: kimlik doğrulama, hata yönetimi, paging
  - `zeep` ile AXL üzerinden CUCM'i okumak ve yazmak
  - RISPort70 ile cihaz register durumunu sorgulamak
  - Netmiko ile CLI'dan komut çalıştırmak, CMS REST API'sini ve phone'ları uzaktan kontrol etmeyi görmek
])

#include "apis-and-libraries/a01-http.typ"
#include "apis-and-libraries/a02-json-xml.typ"
#include "apis-and-libraries/a03-requests.typ"
#include "apis-and-libraries/a04-zeep-axl.typ"
#include "apis-and-libraries/a05-risport.typ"
#include "apis-and-libraries/a06-netmiko.typ"
#include "apis-and-libraries/a07-cms.typ"
#include "apis-and-libraries/a08-phone-control.typ"
#include "apis-and-libraries/a09-wrapup.typ"
