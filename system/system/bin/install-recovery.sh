#!/system/bin/sh
if ! applypatch -c EMMC:/dev/block/platform/bootdevice/by-name/recovery:15245312:83e9f05264c8ef01efe85ea63678ac9bd0f8c2b8; then
  applypatch  EMMC:/dev/block/platform/bootdevice/by-name/boot:9850880:edc2713c89b722ea78e9f09f547c7bb2c2acf451 EMMC:/dev/block/platform/bootdevice/by-name/recovery 02ce82a2d0fbf5030cef4366141f4410948e08f1 15243264 edc2713c89b722ea78e9f09f547c7bb2c2acf451:/system/recovery-from-boot.p && installed=1 && log -t recovery "Installing new recovery image: succeeded" || log -t recovery "Installing new recovery image: failed"
  [ -n "$installed" ] && dd if=/system/recovery-sig of=/dev/block/platform/bootdevice/by-name/recovery bs=1 seek=15243264 && sync && log -t recovery "Install new recovery signature: succeeded" || log -t recovery "Installing new recovery signature: failed"
else
  log -t recovery "Recovery image already installed"
fi
