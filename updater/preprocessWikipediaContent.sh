#!/bin/sh
# Pipe in or pass in the filename with content from the Wikipedia page
# http://en.wikipedia.org/wiki/Wikipedia:Lists_of_common_misspellings/For_machines
# and it will be filtered to the appropriate format for use with codespell
# and the scripts in this directory. You probably want to redirect the output
# to a file

preprocessCorrectionLines() {
# Remove leading and trailing whitespace
# On all lines with a comma after the -> but without a trailing comma, add a trailing comma.
sed -r \
	-e 's/^[	 ]*//' \
	-e 's/[	 ]*$//' \
	-e 's/^(.*->[^,]*,.*[^,])$/\1,/'
}


# Only those lines that include -> are actually lines with corrections.
egrep -e "->" $@ | preprocessCorrectionLines

