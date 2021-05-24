#!/system/bin/sh
if ! applypatch -c EMMC:/dev/block/platform/bootdevice/by-name/recovery:15276032:0e5d03c51ecb82dce173e4e181e60b1fee4a6722; then
  applypatch  EMMC:/dev/block/platform/bootdevice/by-name/boot:9863168:9291e87c72416227be122d11f33807ae730ef3a2 EMMC:/dev/block/platform/bootdevice/by-name/recovery 7664d97a261c34413262c9afafa8d8b9871cabaf 15273984 9291e87c72416227be122d11f33807ae730ef3a2:/system/recovery-from-boot.p && installed=1 && log -t recovery "Installing new recovery image: succeeded" || log -t recovery "Installing new recovery image: failed"
  [ -n "$installed" ] && dd if=/system/recovery-sig of=/dev/block/platform/bootdevice/by-name/recovery bs=1 seek=15273984 && sync && log -t recovery "Install new recovery signature: succeeded" || log -t recovery "Installing new recovery signature: failed"
else
  log -t recovery "Recovery image already installed"
fi
