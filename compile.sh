#!/usr/bin/env sh

clean=false

# If no flags, quit
if [ "$#" == 0 ]; then
	echo "Usage: $0 [-c (clean) -p (chapter) -t (thesis)]" 
	exit 1
fi

# Create graphics path
./graphics_path.sh

# Ensure out dir exists
mkdir -p out

# Check flags
while getopts "cpt" opt; do 
  case "${opt}" in                         
    t)
    	echo "Compiling thesis"
		latexmk -pdf -pdflatex="pdflatex -interaction=nonstopmode" -jobname=out/main -bibtex main.tex 
		;;
    p)
    	echo "Compiling chapters"
		chapters="$(find chapters -type d -depth 1)"
		for i in $chapters ; do
			chpbase="${i##*/}"
			defbase="${chpbase}_defin"
			inputs="$(find $i -type f -depth 1)"
			snippets="$(find snippets -type f -depth 1)"
			cp $snippets .
			cp $inputs .
			cp -r $i/includes .
			sed -i "5s|{.*}|{${defbase}}|" chapter.tex
			sed -i "18s|{.*}|{${chpbase}}|" chapter.tex
			latexmk -pdf -pdflatex="pdflatex -interaction=nonstopmode" -jobname=out/${chpbase} -bibtex chapter.tex
			inputsbase="$(for i in $inputs ; do echo ${i##*/} ; done)"
			snippetsbase="$(for i in $snippets; do echo ${i##*/} ; done)"
			rm ${inputsbase##*/}
			rm ${snippetsbase##*/}
			rm includes
		done
		;;
	c)
		clean=true
		;;
    *) 
		echo "Usage: $0 [-c (clean) -p (chapter) -t (thesis)]" 
		exit 1
		;;
  esac
done

# Optionally clean intermediary files 
if [ $clean = true ] ; then
	cd out
	latexmk -c *.pdf
fi
