#!/usr/bin/env sh

clean=false

# If no flags, quit
if [ "$#" == 0 ]; then
	echo "Usage: $0 [-c (clean) -p (chapter) -t (thesis)]" 
	exit 1
fi

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
			# Create temp dir
			tmpdir=$(mktemp -d)
			
			# Define Chapter name
			chpbase="${i##*/}"

			# Define chapter title and main tex file
			defbase="${chpbase}_defin.tex"
			texbase="${chpbase}.tex"

			# Copy chapter title and main tex file
			cp $i/$defbase $tmpdir
			cp $i/$texbase $tmpdir

			# Copy images and includes
			test -d $i/inc && cp -r $i/inc $tmpdir
			test -d $i/img && cp -r $i/img $tmpdir

			# Copy common snippets and frontmatter
			cp -r snippets $tmpdir
			cp snippets/chapter.tex $tmpdir
			cp -r frontmatter $tmpdir

			# Copy bib file 
			cp main.bib $tmpdir

			# Insert includes into chapter template
			sed -i "7s|{.*}|{${defbase}}|" $tmpdir/chapter.tex
			sed -i "20s|{.*}|{${chpbase}}|" $tmpdir/chapter.tex

			# Remove chapter title 
			sed -i '/^\\chapter\[\\chaptertitle\]{\\chaptertitle}/d' $tmpdir/${texbase}

			# Create output directory
			mkdir -p $tmpdir/out

			# Run latex
			latexmk -cd -pdf -pdflatex="pdflatex -interaction=nonstopmode" -jobname=out/${chpbase} -bibtex $tmpdir/chapter.tex

			# Copy output to out directory
			mv $tmpdir/out/* out 

			# Remove tmp file
			rm -r $tmpdir
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
    echo "Cleaning intermediate tex files"
	cd out
	latexmk -c *.pdf
fi

# If script fails, remove any temp directories 
trap 'rm -rf -- "$tmpdir"' EXIT
