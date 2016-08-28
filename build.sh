#! /bin/bash

elm make src/Main.elm --output=dist/Main.js && \
    ltext "index-param.html dist/Main.js init.js style.css" \
          --raw="dist/Main.js" --raw="init.js" --raw="style.css" > index.html
