#!/vendor/bin/sh

fos_flags_path='/proc/idme/fos_flags'
dev_flags_path='/proc/idme/dev_flags'
FOS_DEV_FLAGS_NO_STR=256
FOS_DEV_FLAGS_USB_MODE_PHERIPHERAL=0x1
FOS_FLAGS_ADB_ROOT=2
FOS_DEV_FLAGS_STR_LESS_DELAY=0x8

# set ir protocol
/vendor/bin/setprop ro.odm.ir.protocol nec

# set ro.product.region based on idme region
idme_region=`/vendor/bin/cat /proc/idme/region`
/vendor/bin/setprop ro.product.region "$idme_region"

# set locale property based on region,
# only do it once after full flash or factory reset
if [[ ! -f /data/vendor/storemode_flag ]]; then
   if [ "$idme_region" == "CA" ] ; then
      /vendor/bin/setprop odm.locale "en-CA";
   fi
fi

# set product model
idme_prod_model=`/vendor/bin/cat /proc/idme/product_model`
/vendor/bin/setprop ro.product.model_trigger "$idme_prod_model"
/vendor/bin/setprop ro.product.model.ready yes

#set ro.poweron.src and sys.poweron.src based on wakeup reason
power_on_reason=`/vendor/bin/cat /proc/Mstar-poweron-reason`
/vendor/bin/setprop ro.poweron.src "$power_on_reason"
/vendor/bin/setprop sys.poweron.src "$power_on_reason"

# populate ro.nrdp.oemmodel
idme_mfr_name=`/vendor/bin/cat /proc/idme/mfr_name`
idme_mfr_model=`/vendor/bin/cat /proc/idme/mfr_model`
prop_oem_model=$idme_mfr_name"_"$idme_mfr_model
# for settings use
/vendor/bin/setprop ro.product.oemmodel "$prop_oem_model"
/vendor/bin/setprop ro.nrdp.oemmodel "$prop_oem_model"
# for netflix use
/vendor/bin/setprop ro.vendor.nrdp.oemmodel "$prop_oem_model"

config_name=`/vendor/bin/cat /proc/idme/config_name`
config_name_trimmed=${config_name%%_*}
if [ $config_name_trimmed == "duckie" ]; then
    echo "Set dbc_name for duckie" > /dev/kmsg
    /vendor/bin/setprop ro.vendor.mstar.dbc_name dynamic_backlight_F
elif [ $config_name_trimmed == "corleone" ]; then
    echo "Set dbc_name for corleone" > /dev/kmsg
    /vendor/bin/setprop ro.vendor.mstar.dbc_name dynamic_backlight
else
    echo "config name $config_name_trimmed" for dbc_name > /dev/kmsg
fi

# set suspend blocker per FOS_DEV_FLAGS_NO_STR
dev_flags=`/vendor/bin/cat $dev_flags_path`
dev_flags=0x$dev_flags
if [ $(($dev_flags & $FOS_DEV_FLAGS_NO_STR)) != "0" ] ; then
    /vendor/bin/setprop odm.hold.wakelock.idme y
fi

if [ $(($dev_flags & $FOS_DEV_FLAGS_STR_LESS_DELAY)) != "0" ] ; then
    /vendor/bin/setprop sys.str.delay_before_str 10000
fi

# enable USB device mode if ADB is enabled
if [ $(($dev_flags & $FOS_DEV_FLAGS_USB_MODE_PHERIPHERAL)) != "0" ] ; then
    /vendor/bin/setprop vendor.usb.debugging.init y
else
    /vendor/bin/setprop vendor.usb.debugging.init n
fi

# set USB PID
idme_device_type_id=`/vendor/bin/cat /proc/idme/device_type_id`
echo "devcfg: device_type_id: $idme_device_type_id" > /dev/kmsg

case "$idme_device_type_id" in
         "A3SUJTTQGF9GNF" | "ATQGSQRPDYO9Z" | "ARJHEDRXLP6DM")
	     /vendor/bin/setprop odm.usb.pid.adb 0x531
	     ;;
         "A93SQJNJQLDSS" )
	     /vendor/bin/setprop odm.usb.pid.adb 0x541
	     ;;
         "A2WJI2JG7UW2O1")
	     /vendor/bin/setprop odm.usb.pid.adb 0x551
	     ;;
	 *)
	     echo "devcfg: unknown device_type_id - $idme_device_type_id" > /dev/kmsg
	     ;;
esac

echo "devcfg: odm.usb.pid.adb: `/vendor/bin/getprop odm.usb.pid.adb`" > /dev/kmsg

# set dvbs property
product_name=`/vendor/bin/cat /proc/idme/product_name`
oem_data=`/vendor/bin/cat /proc/idme/oem_data`
if [ $product_name == "greta" ] || [ $product_name == "clara" ] || \
   [[ $oem_data == *"dvbs=1"* ]]; then
   /vendor/bin/setprop ro.vendor.mtk.system.dvbs.existed 1
   /vendor/bin/setprop ro.vendor.mtk.system.ci.existed 1
   /vendor/bin/setprop ro.vendor.fos.dvbs.existed 1
   /vendor/bin/setprop ro.vendor.fos.ci.existed 1
else
   /vendor/bin/setprop ro.vendor.mtk.system.dvbs.existed 0
   /vendor/bin/setprop ro.vendor.mtk.system.ci.existed 0
   /vendor/bin/setprop ro.vendor.fos.dvbs.existed 0
   /vendor/bin/setprop ro.vendor.fos.ci.existed 0
fi

# set model_name and memc property
idme_model_name=`/vendor/bin/cat /proc/idme/model_name`
idme_memc=`/vendor/bin/cat /proc/idme/memc`
/vendor/bin/setprop ro.vendor.mstar.idme.model_name "$idme_model_name"
/vendor/bin/setprop ro.vendor.mstar.idme.memc "$idme_memc"
