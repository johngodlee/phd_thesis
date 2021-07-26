#!/usr/bin/env sh

# Define usage function
usage() {
	echo "Usage: $0 [-c (clean) -p (chapter) -t (thesis)]" 
	exit 1
}

# If no flags, quit
if [ "$#" == 0 ]; then
	usage
fi

# Define chapter compilation function
chp_compile() {
	# Create temp dir
	tmpdir=$(mktemp -d)

	# Define Chapter name
	chpbase="${1##*/}"

	# Define chapter title and main tex file
	defbase="${chpbase}_defin.tex"
	texbase="${chpbase}.tex"

	# Copy chapter title and main tex file
	cp $1/$defbase $tmpdir
	cp $1/$texbase $tmpdir

	# Copy images and includes
	test -d $1/inc && cp -r $1/inc $tmpdir
	test -d $1/img && cp -r $1/img $tmpdir

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
}

# Ensure out dir exists
mkdir -p out

# Parse flags
while getopts ":cpts:" opt; do 
  case "${opt}" in                         
    t)
    	echo "Compiling thesis"
		latexmk -pdf -pdflatex="pdflatex -interaction=nonstopmode" -jobname=out/main -bibtex main.tex 
		;;
	s)
		echo "Compiling a chapter"
		chapter=$(echo $OPTARG)
		chp_compile $chapter
		;;
    p)
    	echo "Compiling all chapters"
		chapters="$(find chapters -type d -depth 1)"
		for i in $chapters ; do
			chp_compile $i
		done
		;;
	c)
    	echo "Cleaning intermediate tex files"
		cd out
		latexmk -c *.pdf
		;;
	\?)
		echo "Invalid option: -$OPTARG" 
		usage
		;;
    *) 
    	usage
		;;
  esac
done

# If script fails, remove any temp directories 
trap 'rm -rf -- "$tmpdir"' EXIT
