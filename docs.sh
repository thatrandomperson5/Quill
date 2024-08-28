cd ./src
nim doc -d:nimsuggest --project --index:only --outdir:../docs quill.nim
nim doc -d:nimsuggest --project --outdir:../docs quill.nim
mv ../docs/theindex.html ../docs/index.html