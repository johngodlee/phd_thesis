---
title: "PhD thesis template - The University of Edinburgh"
author: John L. Godlee
date: 2021-07-25
---

This directory contains a directory structure and associated styling files for a University of Edinburgh PhD thesis, created by the author, in the School of GeoSciences.

# Directory structure

`compile.sh` is a shell script to generate the thesis and chapters. Takes 1:3 arguments: 

* `-c` - clean intermediate LaTeX files
* `-t` - compile thesis
* `-p` - compile individual chapters

`main.tex` contains the top-level `.tex` skeleton file which calls all other files. Can be altered to include new chapters, or to change the order of chapters.

`frontmatter/` contains various `.tex` snippets used in the frontmatter of the main thesis: title page (`ttl.tex`), acknowledgements (`ack.tex`), etc.

`img/` contains common images used in the thesis.

`chapters/` contains subdirectories each referring to a thesis chapter or an appendix. The directory name of each chapter should match the name of the main `.tex` file for that chapter. Each chapter directory should have a `*_defin.tex` where the asterisk expands to the directory name, which defines the `\chaptertitle{}` variable for that chapter. Chapters can have their own `img/` (images) and `inc/` (included `.tex` files) directories which will be incorporated into the thesis and standalone chapters. Chapter `.tex` content should be wrapped in the following boilerplate, to ensure that references come at the end of the chapter, rather than the end of the thesis:

```tex
\begin{refsection}

\input{chaptername_defin.tex}
\chapter{\chaptertitle}
\label{ch:chaptername}

% CONTENT HERE

\newpage{}
\begingroup
\setstretch{1.0}
\printbibliography[heading=subbibintoc]
\endgroup

\end{refsection}
```

`out/` contains all compiled `.pdf` files.

`snippets/` contains bits of code used to compile the thesis:

* `preamble.tex` contains all the preamble material used for the thesis. It is also called by `chapter.tex`.
* `geometry.tex` defines page geometry for the thesis
* `geometry_nice.tex` defines page geometry for the standalone chapters
* `chapter.tex` contains a skeleton to create individually formatted chapters. 
* `definitions.tex` contains thesis-level LaTeX variables: thesis title, author name, thesis date, etc.

![Directory and dependency structure for `main.tex`](drawio/struc.png)

# Packages

Various packages are used to create this template:

`import` to make nested linking of `.tex` files per chapter easier. Uses `import` when sourcing chapters in `main.tex`

`inputenc`, `babel` and `csquotes` set English language rules.

`geometry` sets page margins.

`pdflscape` allows landscape pages with `\begin{landscape}`.

`setspace` sets line spacing to 1.5 with `\onehalfspacing{}`

`fancyhdr` sets page headers for chapters with the following settings:

```tex
\pagestyle{fancy}
\lhead[\leftmark]{}
\rhead[]{\leftmark}
```

`graphicx` for including images

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

`multirow` and `longtable` allow for more flexible table formatting.

`biblatex` handles referencing.

`textcomp`, `siunitx`, and `amsmath` provide many symbols and extended text characters.

`fmtcount` converts numbers into text, useful for including variable output from R scripts.

`appendix` handles appendices better than the basic `\appendix{}`.

`hyperref` provides hyperlinks between sections, to references, to DOIs and URLs.

`xcolor` allows using colours to highlight text.

`appendix` improves handling of appendices per chapter


# Notable mentions

Inspiration for this template came from other projects:

* [uoe-gits / EdThesis LaTeX template · GitLab](https://git.ecdf.ed.ac.uk/uoe-gits/edthesis) - Created by Magnus Hagdorn back in 2003.
* [Writing a PhD Thesis in LaTeX | Johannes Miocic](https://jojomio.wordpress.com/2014/02/14/writing-a-phd-thesis-in-latex/) - A more recent attempt, from 2015, also with links to other PhD thesis LaTeX projects.
* [ryklith/ue-phd-thesis: Template for a PhD thesis at the University of Edinburgh](https://github.com/ryklith/ue-phd-thesis)
* [maxbiostat/PhD_Thesis: My PhD Thesis - Institute of Evolutionary Biology, University of Edinburgh, 2018](https://github.com/maxbiostat/PhD_Thesis)
