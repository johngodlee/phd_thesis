#!/usr/bin/env bash

path="./chapters/*/img"

echo -n "\\graphicspath{{img/}" > snippets/graphics_path.tex

for i in $path; do
	echo -n "{$i/}" >> snippets/graphics_path.tex
done

echo "}" >> snippets/graphics_path.tex
