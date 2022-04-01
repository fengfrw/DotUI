#!/bin/sh

TMP_UPDATE_DIR="/mnt/SDCARD/.tmp_update"
INSTALL_ZIP="/mnt/SDCARD/MiniUI.zip"
SYSTEM_PATH="/mnt/SDCARD/.system"

progressui &

progress 0 Installing update
sleep 1

NUM=0
PERCENT=0
TOTAL=`unzip -l ${INSTALL_ZIP} | grep -o -E '[0-9]+\s+files$' | grep -o -E '[0-9]+'`
unzip -l $INSTALL_ZIP | awk -F" " '{print $4}' | grep -o -E '.*\/.*' | while read FILE_PATH
do
	NUM=`expr $NUM + 1`
	PERCENT=`expr $NUM \* 99 \/ $TOTAL`
	BASENAME=$(basename $FILE_PATH)
	progress $PERCENT Unzipping $BASENAME
	unzip -q -o "$INSTALL_ZIP" "$FILE_PATH" -d "$TMP_UPDATE_DIR" 
done

progress 99 Cleaning up
sleep 1

mv "$SYSTEM_PATH" "$TMP_UPDATE_DIR/.system-old"
mv "$TMP_UPDATE_DIR/.system" "$SYSTEM_PATH"
rm -f "$INSTALL_ZIP"

# perform post-update actions if present in updated .system folder
if [ -f "$SYSTEM_PATH/post-update.sh" ]; then
	"$SYSTEM_PATH/post-update.sh"
	rm -f "$SYSTEM_PATH/post-update.sh"
fi

progress 100 Update complete
sleep 1

progress quit

killall keymon
killall lumon
rm -rf "$TMP_UPDATE_DIR/.system-old"

killall launch.sh