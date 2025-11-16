#!/bin/sh

. tests/env.sh
set -e

if test -z "$LUA"; then
	echo "Unable to find lua interpreter"
	exit 1
fi

set -e
BASE=$(pwd)
REPORT=$BASE/tests/luacheck/report.log
PASS_LIST=$BASE/tests/luacheck/passed.lst

mkdir -p ./luacheck-tmp
TMPDIR=$BASE/luacheck-tmp
FAILED=$TMPDIR/failed

echo > $PASS_LIST

(
	find ./mods -name mod.conf
	echo EOF
) | $LUA tests/luacheck/test.lua | while read MODDATA; do
	NAME=$(echo "$MODDATA" | cut -d'|' -f1)
	OPTS=$(echo "$MODDATA" | cut -d'|' -f2)
	DIR=$( echo "$MODDATA" | cut -d'|' -f3)

	LOG=$TMPDIR/log
	touch $LOG
	(
		SHOULD_PASS=false
		if grep -q "$DIR$FILE" $BASE/tests/luacheck/check.lst; then
			SHOULD_PASS=true
		fi

		cd $DIR
		for FILE in *.lua; do
			if luacheck $FILE $OPTS 2>&1 >$LOG; then
				PASSED=true
			else
				PASSED=false
			fi

			if ! $PASSED; then
				MARKING="WARNING"
				if $SHOULD_PASS; then
					MARKING="ERROR  "
					touch $FAILED
				fi

				cat $LOG | grep "  $FILE" | sed 's/\x1B\[[0-9;]*m//g' \
				| sed "s#$FILE#$DIR$FILE#" \
				| sed "s/ *//" \
				| sed "s/^/[$MARKING]  /"
			else
				echo "[PASSED ]  $DIR$FILE"
				echo "$DIR$FILE" >> $BASE/luacheck-passed.lst
			fi
		done
	)
done

if test -f $FAILED; then
	rm -Rvf $TMPDIR
	echo "luacheck test failed"
	exit 1
fi

rm -Rvf $TMPDIR

cp tests/luacheck/check.lst tests/luacheck/check.lst.orig
cat luacheck-passed.lst tests/luacheck/check.lst.orig | sort | uniq > tests/luacheck/check.lst
rm tests/luacheck/check.lst.orig
rm luacheck-passed.lst

