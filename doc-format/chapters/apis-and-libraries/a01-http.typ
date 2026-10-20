#import "../../template.typ": *

#section[HTTP Basics]

#topic[What is an API?]

Bir CUCM yöneticisi bir phone eklemek için tarayıcıda *Cisco Unified CM Administration* arayüzünü açar, formu doldurur ve Save'e basar. Arkada tarayıcı, CUCM'e bir istek gönderir. Script'ler de aynı isteği, arayüze hiç uğramadan doğrudan gönderebilir. Programların kullanması için açılmış bu kapıya *API* (application programming interface) denir.

Bugünkü API'lerin neredeyse hepsi *HTTP(S)* üzerinden çalışır. Mantık çok basittir: istemci (client) bir *request* (istek) gönderir, sunucu bir *response* (cevap) ile yanıt verir.

#analogy[
  SIP'i biliyorsunuz: bir `INVITE` gönderirsiniz, bir `200 OK` ya da `404 Not Found` dönülür. İkisi de düz metin, ikisinde de bir ilk satır, bir dizi header ve isteğe bağlı bir body vardır. *HTTP aynı fikirdir*, sadece çağrı kurmak yerine veri okur ve yazar. SIP'te ezberlediğiniz şeylerin çoğu burada da işe yarar.
]

#diagram("http-cycle", width: 78%, caption: [Client bir request gönderir, server bir response ile cevap verir. İkisi de düz metindir.])

```text
GET /v1/people?email=alice.smith@clauto.lab HTTP/1.1
Host: webexapis.com
Authorization: Bearer <token>
Accept: application/json
```

```text
HTTP/1.1 200 OK
Content-Type: application/json

{"items": [{"displayName": "Alice Smith", ...}]}
```

#walk(
  ("İstek satırı", [`GET` ne yapılacağını, `/v1/people?...` neyle yapılacağını, `HTTP/1.1` protokol sürümünü söyler. Bu satır, SIP'teki `INVITE sip:... SIP/2.0` satırının karşılığıdır.]),
  ("Header'lar", [`Host` hangi sunucuya gittiğini, `Authorization` kim olduğunuzu, `Accept` hangi formatta cevap istediğinizi söyler.]),
  ("Durum satırı", [`200 OK`: işlem başarılı. Sayı bir *status code*'dur.]),
  ("Body", [Boş satırdan sonra gelen asıl veri. Burada bir JSON.]),
)

Hem request hem response aynı yapıdadır: *ilk satır, header'lar ve isteğe bağlı bir body*. Bir API'yi öğrenmek, aslında hangi isteği gönderince hangi cevabın geldiğini öğrenmektir.

#methods(
  header: ([API], [Stil]),
  [CUCM AXL, RISPort], [SOAP: HTTPS üzerinden XML],
  [CUCM UDS, Unity CUPI], [REST: XML ya da JSON],
  [Webex], [REST: JSON],
)

#topic[Methods and URLs]

Her HTTP isteğinin ilk satırı iki şeyden oluşur: *method* (ne yapılacağı) ve *URL* (neyle yapılacağı). Method'lar fiildir, URL ise nesnedir.

#diagram("url-anatomy", width: 78%, caption: [Bir URL: protokol, host, path ve `?`'den sonra query string.])

```text
GET    /v1/people?email=…    kullanıcı bul
POST   /v1/messages          mesaj gönder
PUT    /v1/people/{id}       kullanıcı kaydını değiştir
DELETE /v1/people/{id}       kullanıcıyı sil
```

#methods(
  header: ([Method], [Anlamı]),
  [`GET`], [veri oku, hiçbir şeyi değiştirmez],
  [`POST`], [yeni bir şey yarat ya da bir işlem çalıştır],
  [`PUT`], [var olan bir kaydı tamamen değiştir],
  [`PATCH`], [bir kaydın bir kısmını değiştir],
  [`DELETE`], [bir kaydı sil],
)

*Query string*, `?`'den sonra gelen kısımdır ve sonucu filtreler ya da sayfalar: `?email=…`, `?max=100`. Birden fazla parametre `&` ile ayrılır.

#analogy[
  `GET`'i CUCM'de bir phone'a *bakmak*, `POST`'u *eklemek*, `PUT`'u üzerine yazarak *güncellemek*, `DELETE`'i *silmek* olarak düşünün. AXL'deki `getPhone`, `addPhone`, `updatePhone`, `removePhone` operasyonları tam bu dört işin SOAP'taki karşılıklarıdır.
]

#collab[
  AXL gibi SOAP API'leri her şey için `POST` kullanır, okuma için bile. Operasyon (`getPhone`, `addLine`) XML body'nin içine yazılır. REST API'lerinde ise yapılacak işi method ve URL söyler.
]

#topic[Status codes, headers and auth]

Cevabın ilk satırındaki *status code*, isteğin işe yarayıp yaramadığını hemen söyler. *Header*'lar iki taraf için ek bilgi taşır; en önemlileri format ve kimliktir.

#analogy[
  Status code'ları SIP'ten tanıyorsunuz: `2xx` başarı, `4xx` istemci hatası, `5xx` sunucu hatası. `401 Unauthorized` her iki dünyada da "kim olduğunu kanıtla" demektir.
]

#diagram("http-status", width: 66%, caption: [Status code sınıfları: 2xx başarı, 4xx istemci hatası, 5xx sunucu hatası.])

```text
Content-Type: application/json    # ben ne gönderiyorum
Accept: application/json          # ne geri istiyorum
Authorization: Basic YXhsX3N2YzpwYXNzd29yZA==
Authorization: Bearer <access token>
```

#walk(
  ("Content-Type", [Body'de ne gönderdiğimi söyler.]),
  ("Accept", [Cevabı hangi formatta istediğimi söyler.]),
  ("Basic", [`user:password` metninin base64 ile kodlanmış hali. Her istekte gönderilir. CUCM AXL ve UDS bunu kullanır.]),
  ("Bearer", [Bir *access token*. Webex gibi API'ler önce bir token verir, sonraki her isteğe bu token eklenir.]),
)

#methods(
  header: ([Kod], [Sizin için genellikle anlamı]),
  [`401`], [kullanıcı / parola yanlış ya da token süresi dolmuş],
  [`403`], [giriş doğru ama gerekli rol eksik],
  [`404`], [URL yanlış ya da kayıt yok],
  [`429`], [çok fazla istek: `Retry-After` saniye bekleyin],
  [`500` `503`], [sunucu hatası ya da servis kapalı],
)

#collab[
  AXL *Basic* kimlik doğrulama (`user:password`'ün base64'ü) kullanır. Webex ise *Bearer* token kullanır. Lab ortamındaki CUCM'lerin sertifikaları kendinden imzalıdır (self-signed), bu yüzden sertifika kontrolü ek dikkat ister; bunu `requests` bölümünde göreceğiz.
]

#recap[
  - API, programlar için açılmış bir kapıdır. HTTP bir request / response döngüsüdür ve SIP'e çok benzer.
  - Method ne yapılacağını, URL neyle yapılacağını söyler. Status code'un ilk rakamı sonucun sınıfını verir.
  - `Authorization` header'ı kimliği taşır: *Basic* (kullanıcı / parola) ya da *Bearer* (token).
]
