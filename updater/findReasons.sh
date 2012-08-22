#!/bin/sh
# This grep regex easily shows just the lines in a codespell dictionary
# that have been disabled for automatic fixing by providing a "reason".

# It will also highlight any lines where the last suggestion is being
# ignored (considered a "reason" not a suggestion) due to a missing
# trailing comma.

grep ",.*[^,]$" $@
