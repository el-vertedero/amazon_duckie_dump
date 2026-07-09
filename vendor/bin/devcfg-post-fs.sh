#!/vendor/bin/sh

# place logics depending on file system mounted in this file.

# set ro.odm.version.number
tvconfig_ota_version=`/vendor/bin/cat /vendor/tvconfig/config/tvconfig_ota_version.ini`
/vendor/bin/setprop ro.odm.version.number "$tvconfig_ota_version"

i="0"
# check if exists and timeout till 2s
while [ $i -lt 200 ] ;
do
    if [[ -f /sys/kernel/debug/is_support_dolby_vision ]] && \
    [[ -f /sys/kernel/debug/is_support_av1ex ]] ; then
         echo "is_support_dolby_vision and is_support_av1ex are ready in devcfg" > /dev/kmsg
         break
    fi
    /vendor/bin/sleep 0.01
    i=$(($i+1))
done

# Check the SOC capability
is_support_dolby_vision=`/vendor/bin/cat /sys/kernel/debug/is_support_dolby_vision`
if [ -z "$is_support_dolby_vision" ]; then
    # if can not find 'DOVI' info.
    is_support_dolby_vision="1"
fi
is_support_av1ex=`/vendor/bin/cat /sys/kernel/debug/is_support_av1ex`
if [ -z "$is_support_av1ex" ]; then
    # if can not find 'AV1EX' info.
    is_support_av1ex="0"
fi

codecPopValue=0
# set modelgroup for netflix testing
if [ $is_support_dolby_vision == "1" ] ; then
    codecPopValue=$(($codecPopValue+1))
    echo "Set modelgroup for dovi model" > /dev/kmsg
    if [ $is_support_av1ex == "0" ]; then
        /vendor/bin/setprop ro.vendor.nrdp.modelgroup FTVET31DOVI2020
    else
        codecPopValue=$(($codecPopValue+1))
        /vendor/bin/setprop ro.vendor.nrdp.modelgroup FTVET31DOVIAV12020
    fi
elif [ $is_support_dolby_vision == "0" ] ; then
    echo "Set modelgroup for non-dovi model" > /dev/kmsg
    if [ $is_support_av1ex == "0" ]; then
        /vendor/bin/setprop ro.vendor.nrdp.modelgroup FTVET31HDR2020
    else
        /vendor/bin/setprop ro.vendor.nrdp.modelgroup FTVET31HDRAV12020
    fi
fi

if [ $codecPopValue != "0" ] ; then
    codecPopValueHex=`printf "%x" $codecPopValue`
    /vendor/bin/setprop ro.vendor.media.codecs.fosext "$codecPopValueHex"
fi
echo "devcfg: ro.vendor.media.codecs.fosext $codecPopValue" > /dev/kmsg

/vendor/bin/setprop ro.vendor.media.codecs.fosext.ready true

# fix in-field provision key backup issue on duckie MP devices
config_name=`/vendor/bin/cat /proc/idme/config_name`
echo "key backup fix: config name $config_name" > /dev/kmsg
if [[ $config_name == *"duckie"* ]]; then
    scontext=`/vendor/bin/ls -dZ /vendor/tvcertificate/lost+found`
    echo "key backup fix:  scontext $scontext" > /dev/kmsg
    if [[ $scontext == *"unlabeled"* ]]; then
        echo "key backup fix: correct scontext" > /dev/kmsg
        /vendor/bin/chcon u:object_r:tv_certificate_file:s0 /vendor/tvcertificate/lost+found
        # re-do key backup if it has been done
        if [ -f /vendor/tvcertificate/key_backup.bin ]; then
            echo "key backup fix: re-do key backup" > /dev/kmsg
            /vendor/bin/rm /vendor/tvcertificate/key_backup.bin
            /vendor/bin/setprop vendor.amzn_drm.backup.trigger 1
        fi
    fi
fi

echo "disable acr for $config_name first" > /dev/kmsg
/vendor/bin/setprop audio.amazon.acr.enabled 0
config_name_trimmed=${config_name%%_*}
if [[ $config_name_trimmed == "corleone" ]] \
    || [[ $config_name_trimmed == "duckie" ]]; then
    echo "enable acr for $config_name" > /dev/kmsg
    /vendor/bin/setprop audio.amazon.acr.enabled 1
fi
