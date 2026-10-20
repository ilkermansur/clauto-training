#import "template.typ": *

#show: clauto.with(
  title: [Cisco Collaboration Automation],
  subtitle: [Python fundamentals for voice & collaboration engineers],
  author: [Ilker Mansur - CCIE 63555],
  date: [2026],
  image: image("diagrams/cover.svg", width: 100%),
)

// Chapter order = chapter numbers. Insert / reorder freely.
#include "chapters/python-fundamentals.typ"
#include "chapters/apis-and-libraries.typ"

// closing page (not numbered), keep it last
#include "chapters/closing.typ"
