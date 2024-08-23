cd ./src
nim doc -d:nimsuggest --project --index:on --outdir:../docs quill.nim
mv ../docs/theindex.html ../docs/index.html