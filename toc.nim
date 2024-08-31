import std/dom
import std/sequtils
import std/strutils
import std/strformat

type NestingLevel = range[0..5]

type HeaderInfo = object
  label: cstring
  href: cstring
  level: NestingLevel

const headersSelector = ".hash-header"
const jumpToValue = "__jump-to"

func toHref(label: cstring): cstring =
  # TODO: filter out everything not matching regex a-zA-Z0-9
  let labelString = fmt"{label}".replace(".", "").replace(",", "").replace("?", "")
  let slug = labelString.toLower.replace(" ", "-")[0..labelString.len - 2]
  return fmt"#{slug}"

proc createTocElement(): Element =
  let toc = document.createElement "select"

  toc.style.position = "sticky"
  toc.style.top = "8px"
  toc.style.cssFloat = "right"
  toc.style.zIndex = "100"
  toc.style.maxWidth = "min(100%, 240px)"
  toc.style.padding = "4px"
  toc.style.background = "var(--pub-detail_tab-background-color)"
  toc.style.border = "none"
  toc.style.color = "var(--pub-detail_tab-text-color)"
  toc.style.cursor = "pointer"
  toc.style.fontSize = "14px"
  toc

proc createDefaultOption(): Element =
  let defaultOption = document.createElement "option"
  defaultOption.innerText = "Jump to"
  defaultOption.value = jumpToValue
  defaultOption.disabled = true
  defaultOption

func indent(nestingLevel: NestingLevel): string = 
  var indent = ""
  for i in countup(0, nestingLevel - 1):
    indent.add " "
  indent

proc createSelectableOption(header: HeaderInfo): Element =
  let option = document.createElement "option"
  option.textContent = @[header.level.indent, fmt"{header.label}"].join
  option.value = header.href
  option

func toNestingLevel(elementType: cstring): NestingLevel =
  case elementType:
    of "H1": 0
    of "H2": 1
    of "H3": 2
    of "H4": 3
    of "H5": 4
    else: 0

proc generateToc() =
  let readmeHeaderElements = document.querySelectorAll headersSelector
  let headers = readmeHeaderElements.map proc (e: Element): HeaderInfo =
    return HeaderInfo(label: e.innerText, href: toHref e.innerText, level: e.nodeName.toNestingLevel)

  if headers.len == 0: # skip, there are no headers to jump to
    return

  let toc = createTocElement()
  toc.onchange = proc (e: Event) =
    window.location.href = toc.value
    toc.value = jumpToValue

  toc.appendChild createDefaultOption()
  toc.value = jumpToValue

  let options = headers.map(proc (header: HeaderInfo): Element =
    createSelectableOption(header)
  )

  for option in options:
    toc.appendChild option

  let markdownContentWrapper = document.querySelector(".markdown-body")
  markdownContentWrapper.insertBefore(toc, markdownContentWrapper.firstChild)

generateToc()