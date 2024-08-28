when defined(nimdoc):
  # import quill/ext/gutters
  discard
else:
  when not (defined(js) or defined(nimsuggest)):
    {.error: "Please use js with quill".}

when defined(quillDebug):
  {.warning: "Quill debug is for devs!".}



import quill/[types, jsutils, domutils]



import quill/legacy
export toJsStr, createRawText, toCstr, legacy, types