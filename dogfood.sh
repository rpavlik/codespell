#!/bin/sh

BASE=$(cd $(dirname $0) && pwd)

(
	cd $BASE
	./codespell.py -i 2 -w data/dictionary.txt --summary \
		codespell.py \
		dogfood.sh \
		README \
		TODO \
		updater/findReasons.sh \
		updater/README.markdown \
		updater/grabLatest.sh \
		updater/updateData.lua \
		updater/preprocessWikipediaContent.sh \
		updater/modules/UniqueList.lua \
		updater/modules/bininsert.lua \
		updater/modules/CorrectionUtils.lua \
		updater/modules/HandleArgs.lua \
		updater/modules/CorrectionDatabase.lua
)
