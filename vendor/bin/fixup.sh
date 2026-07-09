#!/vendor/bin/sh

PEACH_EVT_ID="00A6000200010021"
KEY_PATH="/vendor/tvcertificate/hashkey.sign"
KEY_PATH_BACKUP="/vendor/tvcertificate/hashkey_backup"
BOARD_ID=`cat /proc/idme/board_id`


if [ $BOARD_ID == $PEACH_EVT_ID ]; then
    if [ -f $KEY_PATH_BACKUP ]; then
        exit 0
    else
        cp $KEY_PATH $KEY_PATH_BACKUP
        rm $KEY_PATH
        cp $KEY_PATH_BACKUP $KEY_PATH
    fi
fi
