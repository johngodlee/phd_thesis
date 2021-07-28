#!/usr/bin/env bash

# Define usage function
usage() {
	echo "Usage: $0 [-c (clean) -p (all chapters) -s (single chapter) -t (thesis) -f (formatting, 0=submission, 1=nice)]" 
	exit 1
}

# If no flags, quit
if [ "$#" == 0 ]; then
	usage
fi

# Define latexmk function
pdf () {
	latexmk -cd -pdf -bibtex -pdflatex="pdflatex --shell-escape -interaction=nonstopmode" -jobname=$2 -pretex="\def\nicefmt{$3}" -usepretex $1
}

# Define chapter compilation function
chp_compile() {
	# Create temp dir
	tmpdir=$(mktemp -d)

	# Define Chapter name
	dir=${1%/}
	chpbase="${dir##*/}"

	# Define chapter title and main tex file
	defbase="${chpbase}_defin.tex"
	texbase="${chpbase}.tex"

	# Copy chapter title and main tex file
	cp $dir/$defbase $tmpdir
	cp $dir/$texbase $tmpdir

	# Copy images and includes
	test -d $dir/inc && cp -r $dir/inc $tmpdir
	test -d $dir/img && cp -r $dir/img $tmpdir

	# Copy common snippets and frontmatter
	cp -r snippets $tmpdir
	cp snippets/chapter.tex $tmpdir
	cp -r frontmatter $tmpdir

	# Copy bib file 
	cp main.bib $tmpdir

	# Insert includes into chapter template
	sed -i "5s|{.*}|{${defbase}}|" $tmpdir/chapter.tex
	sed -i "18s|{.*}|{${chpbase}}|" $tmpdir/chapter.tex

	# Remove chapter title 
	sed -i '/^\\chapter\[\\chaptertitle\]{\\chaptertitle}/d' $tmpdir/${texbase}

	# Create output directory
	mkdir -p $tmpdir/out

	# Run latex
	pdf $tmpdir/chapter.tex out/${chpbase} $2

	# Copy output to out directory
	mv $tmpdir/out/* out 

	# Remove tmp file
	rm -r $tmpdir
}

# Ensure out directory exists
mkdir -p out

# Default flag values
fmt=0
thesis=0
chapters=0
single="0"
clean=0

# Parse flags
while getopts ":f:tps:c" opt; do
	case "${opt}" in
  	f) 
  		fmt=$OPTARG
  		;;
	t)
		thesis=1
		;;
	p)
		chapters=1
		;;
	s)
		single=$OPTARG
		;;
	c)
		clean=1
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

# Run compilation functions based on flags

# Clean intermediate
if [ "$clean" -eq 1 ]; then
	echo "Cleaning intermediate tex files"
	cd out
	latexmk -c *.pdf
fi

# Thesis
if [ "$thesis" -eq 1 ]; then
	echo "Compiling thesis"
	pdf main.tex out/main $fmt
fi

# All chapters
if [ "$chapters" -eq 1 ]; then
	echo "Compiling all chapters"
	chapters="$(find chapters -type d -depth 1)"
	for i in $chapters ; do
		chp_compile $i $fmt
	done
fi

# Single chapter
if [ "$single" != "0" ]; then
	echo "Compiling a single chapter"
	chp_compile $single $fmt
fi

# Clean intermediate
if [ "$clean" -eq 1 ]; then
	echo "Cleaning intermediate tex files"
	cd out
	latexmk -c *.pdf
fi

# If script fails, remove any temp directories 
trap 'rm -rf -- "$tmpdir"' EXIT
