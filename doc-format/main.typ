#import "template.typ": *

#show: kitap.with(
  title: [Cisco Collaboration Automation],
  subtitle: [Ses ve collaboration mühendisleri için sıfırdan Python],
  tagline: [Eğitim kitabı],
  author: [Ilker Mansur - CCIE 63555],
  date: [2026],
  image: image("/diagrams/cover.svg", width: 80%),
)

#include "front.typ"

// Bölüm sırası = bölüm numaraları (slayt kitabıyla aynı).
#include "chapters/python-fundamentals.typ"
#include "chapters/apis-and-libraries.typ"

// kapanış sayfası (numarasız), en sonda kalmalı
#include "chapters/closing.typ"
