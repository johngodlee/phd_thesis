#!/usr/bin/env sh

drawio() {
	/Applications/draw.io.app/Contents/MacOS/./draw.io --crop -x -o $2 $1 \;
}

drawio drawio/befr_theory.drawio img/befr_theory.pdf
drawio drawio/saf_theory.drawio img/saf_theory.pdf

/Applications/Inkscape.app/Contents/MacOS/inkscape --export-pdf=img/befr_graph.pdf drawio/graph.eps
