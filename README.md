---
title: "PhD thesis template - The University of Edinburgh"
author: John L. Godlee
date: 2020-09-19
---

This directory contains a directory structure and associated styling files for a University of Edinburgh PhD thesis, created by the author, in the School of GeoSciences.

# Directory structure

`compile.sh` is a shell script to generate the thesis and chapters. Takes 1:3 arguments: `-c` (clean), `-t` (thesis), `-p` (chapters)

`graphics_path.sh` is a shell script to generate the paths to `img/` directories for each chapter and the common image directory.

`main.tex` contains the top-level `.tex` skeleton file which calls all other files.

`frontmatter/` contains various `.tex` snippets used in the main thesis: title page (`ttl.tex`), acknowledgements (`ack.tex`), etc.

`img/` contains common images used in the thesis.

`chapters/` contains subdirectories each referring to a thesis chapter or an appendix. Each chapter should have a `*_defin.tex` named similarly to the chapter .tex file which defines LaTeX variables, at the very least the chapter name. Chapters can have their own `img/` directories which will be incorporated into the thesis and standalone chapters on compilation. If possible, keep any external tex files for each chapter in the chapter root directory, to avoid potential conflicts with directory or file names during compilation.

`out/` contains all compiled `.pdf` files.

`snippets/` contains bits of code used to compile the thesis:

* `preamble.tex` contains all the preamble material used for the thesis. It is also called by `chapter.tex`.
* `chapter.tex` contains a skeleton file to create individually formatted chapters. 
* `definitions.tex` contains thesis-level LaTeX variables: thesis title, author name, thesis date, etc.

![Directory and dependency structure for `main.tex`](struc.pdf)

# Packages

Various packages are used to create this template:

`inputenc`, `babel` and `csquotes` set English language rules.

`geometry` sets page margins.

`pdflscape` allows landscape pages with `\begin{landscape}`.

`setspace` sets line spacing to 1.5.

`fancyhdr` sets page headers for chapters with the following settings:

```tex
\pagestyle{fancy}
\lhead[\leftmark]{}
\rhead[]{\leftmark}
```

`framed` allows for framed text boxes with `\begin{minipage}{\linewidth}\begin{framed}`.

`float` and `subfig` allow for compound figures:

```tex
\begin{figure}[H]
	\subfloat[]{{\includegraphics[width=0.3\textwidth]{img_file_a}}
	\label{img_label_a}}%
    \qquad
	\subfloat[]{{\includegraphics[width=0.4\textwidth]{img_file_b}}
	\label{img_label_b}}%
	\caption{Caption text}
	\label{img_label_all}
\end{figure}
```

`multirow` and `longtable` allow for more flexible table formatting

`biblatex` handles referencing.

`textcomp`, `siunitx`, and `amsmath` provide many symbols and extended text characters.

`appendix` handles appendices better than the basic `\appendix{}`

`hyperref` provides hyperlinks between sections, to references, to DOIs and URLs.

# Usage

`main.tex` can be altered to include new chapters, or to change the order of chapters.

Each chapter should reside in its own directory within `chapters`. Each chapter `*.tex` file should be accompanied by a `*_defin.tex` which defines at least one LaTeX variable: `\chaptertitle` which defines the title of the chapter.

Chapter `.tex` files should be wrapped in `\begin{refsection} ... \end{refsection}` to ensure that references come at the end of the chapter, rather than the end of the thesis.

# Notable mentions

Inspiration for this template came from other projects:

* [uoe-gits / EdThesis LaTeX template · GitLab](https://git.ecdf.ed.ac.uk/uoe-gits/edthesis) - Created by Magnus Hagdorn back in 2003.
* [Writing a PhD Thesis in LaTeX | Johannes Miocic](https://jojomio.wordpress.com/2014/02/14/writing-a-phd-thesis-in-latex/) - A more recent attempt, from 2015, also with links to other PhD thesis LaTeX projects.
