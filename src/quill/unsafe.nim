## Unsafe interface for the raw DOM elements of the Quill object. **NOT AN INTERNAL API**
##
## See `qdom.nim` for internal api.

  
import std/dom

var uDocumentElement* {.importc: "document.documentElement"}: Element