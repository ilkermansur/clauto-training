# doc-format — clauto eğitim kitabı (Türkçe)

`../chapters` altındaki slayt serisinin, Python bilmeyen ses / collaboration
mühendisleri için **kitaba dönüştürülmüş** hâli. Aynı Typst mantığı, aynı
bölüm sırası ve numaraları, aynı Excalidraw diyagramları.

## Derleme

```bash
./doc-format/build.sh          # → doc-format/main.pdf
```

Gerekenler: Typst ≥ 0.13; Fira Sans, Source Sans 3 ve JetBrains Mono (sistemde
kurulu). `build.sh`, `--root ..` ile derler; böylece diyagramlar
`../diagrams/*.svg` klasöründen **doğrudan** çekilir (kopyalanmaz, yeniden
çizilmez). Excalifont `../fonts` içinden yüklenir.

> Slayt projesindeki bir diyagramı güncelleyip (`cd tools && npm run diagrams`)
> kitabı yeniden derlemeniz yeterli: kitapta da güncel hâli görünür.

## Yapı

```
doc-format/
├── main.typ                 kapak bilgisi + bölüm sırası
├── template.typ             kitap tasarımı (renkler, kutular, başlıklar)
├── front.typ                "Bu Kitap Hakkında" (içindekilerde görünmez)
├── build.sh
└── chapters/
    ├── python-fundamentals.typ        bölüm açılışı + section dosyaları
    ├── python-fundamentals/s01-…s11-*.typ
    ├── apis-and-libraries.typ
    ├── apis-and-libraries/a01-…a09-*.typ
    └── closing.typ
```

Bölüm numaraları `main.typ` içindeki `#include` sırasından gelir.
Section ve subsection numaraları, slayt serisindekiyle birebir aynıdır
(`1.3.8 dict`, `2.5 RisPort70` …).

## Yazım kuralları

| Fonksiyon | Ne yapar |
|---|---|
| `#chapter(title, intro:, goals:)` | bölüm açılış sayfası |
| `#section[…]` `#subsection[…]` | numaralı başlıklar (içindekiler) |
| `#topic[…]` | slayt başlığının karşılığı; numarasız, içindekilerde yok |
| `#diagram("ad", width:, caption:)` | `diagrams/ad.svg` → numaralı Şekil |
| `#walk(("1", [..]), ("2–3", [..]))` | kodu satır satır açıklama |
| `#analogy` `#collab` `#tip` `#warn` `#pitfall` | bilgi kutuları |
| `#recap` `#exercise` | section sonu özet ve alıştırma |

- Kod blokları `python` / `xml` / `json` dilinde **satır numaralıdır**;
  `#walk` içindeki numaralar bu satırlara karşılık gelir.
- Program çıktısı için dil olarak `output` kullanın (`ÇIKTI` kutusu).
- Teknik terimler İngilizce kalır; ilk geçtiğinde *kalın* yazılıp Türkçe
  karşılığı parantezle verilir. Ekler kesme işaretiyle eklenir: list'in, loop'u.
- Metinde `$`, `@`, `<`, `~` karakterlerine dikkat: kod için ters tırnak kullanın.
