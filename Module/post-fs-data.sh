#!/system/bin/sh

MODPATH="${0%/*}"

check_reset_prop() {
local NAME=$1
local EXPECTED=$2
local VALUE=$(resetprop $NAME)
[ -z $VALUE ] || [ $VALUE = $EXPECTED ] || resetprop -n $NAME $EXPECTED
}

contains_reset_prop() {
local NAME=$1
local CONTAINS=$2
local NEWVAL=$3
[[ "$(resetprop $NAME)" = "$CONTAINS" ]] && resetprop -n $NAME $NEWVAL
}

empty_reset_prop() {
local NAME=$1
local NEWVAL=$2
local VALUE=$(getprop "$NAME")
[ -z "$VALUE" ] && resetprop -n $NAME $NEWVAL
}

check_reset_prop "ro.boot.vbmeta.device_state" "locked"
check_reset_prop "ro.boot.verifiedbootstate" "green"
check_reset_prop "ro.boot.flash.locked" "1"
check_reset_prop "ro.boot.veritymode" "enforcing"
check_reset_prop "ro.boot.warranty_bit" "0"
check_reset_prop "ro.warranty_bit" "0"
check_reset_prop "ro.debuggable" "0"
check_reset_prop "ro.force.debuggable" "0"
check_reset_prop "ro.secure" "1"
check_reset_prop "ro.adb.secure" "1"
check_reset_prop "ro.build.type" "user"
check_reset_prop "ro.build.tags" "release-keys"
check_reset_prop "ro.vendor.boot.warranty_bit" "0"
check_reset_prop "ro.vendor.warranty_bit" "0"
check_reset_prop "vendor.boot.vbmeta.device_state" "locked"
check_reset_prop "vendor.boot.verifiedbootstate" "green"
check_reset_prop "sys.oem_unlock_allowed" "0"

#MIUI
check_reset_prop "ro.secureboot.lockstate" "locked"

#Realme
check_reset_prop "ro.boot.realmebootstate" "green"
check_reset_prop "ro.boot.realme.lockstate" "1"

contains_reset_prop "ro.bootmode" "recovery" "unknown"
contains_reset_prop "ro.boot.bootmode" "recovery" "unknown"
contains_reset_prop "vendor.boot.bootmode" "recovery" "unknown"

if [ -f "/data/adb/boot_hash" ]; then
hash_value=$(grep -v '^#' "/data/adb/boot_hash" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
[ -z "$hash_value" ] && rm -f /data/adb/boot_hash || resetprop -n ro.boot.vbmeta.digest "$hash_value"
fi

empty_reset_prop "ro.boot.vbmeta.device_state" "locked"
empty_reset_prop "ro.boot.vbmeta.invalidate_on_error" "yes"
empty_reset_prop "ro.boot.vbmeta.avb_version" "1.0"
empty_reset_prop "ro.boot.vbmeta.hash_alg" "sha256"
empty_reset_prop "ro.boot.vbmeta.size" "4096"

resetprop_if_diff() {
local NAME=$1
local EXPECTED=$2
local VALUE=$(resetprop $NAME)
[ -z "$VALUE" ] || [ "$VALUE" = "$EXPECTED" ] || resetprop -n $NAME $EXPECTED
}

#Samsung
resetprop_if_diff ro.boot.warranty_bit 0
resetprop_if_diff ro.vendor.boot.warranty_bit 0
resetprop_if_diff ro.vendor.warranty_bit 0
resetprop_if_diff ro.warranty_bit 0

#Realme
resetprop_if_diff ro.boot.realmebootstate green

#OnePlus
resetprop_if_diff ro.is_ever_orange 0

#Microsoft
for PROP in $(resetprop | grep -oE 'ro.*.build.tags'); do
resetprop_if_diff "$PROP" release-keys
done

#Other
for PROP in $(resetprop | grep -oE 'ro.*.build.type'); do
resetprop_if_diff "$PROP" user
done

resetprop_if_diff ro.adb.secure 1
resetprop_if_diff ro.debuggable 0
resetprop_if_diff ro.force.debuggable 0
resetprop_if_diff ro.secure 1

if [ -n "$(resetprop ro.aospa.version)" ]; then
for PROP in persist.sys.pihooks.first_api_level persist.sys.pihooks.security_patch; do
resetprop | grep -q "$PROP" || resetprop -n -p "$PROP" ""
done
fi

if [ -n "$(resetprop persist.sys.pixelprops.pi)" ]; then
resetprop -n -p persist.sys.pixelprops.pi false
resetprop -n -p persist.sys.pixelprops.gapps false
resetprop -n -p persist.sys.pixelprops.gms false
fi

if [ -f /data/system/gms_certified_props.json ] && [ ! "$(resetprop persist.sys.spoof.gms)" = "false" ]; then
resetprop persist.sys.spoof.gms false
fi