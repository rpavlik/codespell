#!/bin/sh

PAGETITLE="Wikipedia:Lists_of_common_misspellings/For_machines"

SCRIPTDIR=$(cd $(dirname $0) && pwd)
TMPFILE=`mktemp`
trap "rm -rf $TMPFILE" EXIT

echo
echo "Fetching Wikipedia page $PAGETITLE"
echo

wget --quiet "http://en.wikipedia.org/w/api.php?format=txt&action=query&titles=${PAGETITLE}&prop=revisions&rvprop=content|ids" -O $TMPFILE

REVISION=$(sed -n -r -e "s_\s*.*revid[^0-9]*([0-9]+).*_\1_p" $TMPFILE)

echo "Got revision $REVISION"
echo

OUTFILE="$SCRIPTDIR/wikipedia-$REVISION.txt"
$SCRIPTDIR/preprocessWikipediaContent.sh $TMPFILE > $OUTFILE

echo "Saved $(cat $OUTFILE | wc -l) data rows in codespell format to file"
echo "$OUTFILE"
echo
