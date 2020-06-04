#!/system/bin/sh
if ! applypatch -c EMMC:/dev/block/platform/bootdevice/by-name/recovery:15218688:a6ed8cc17ae4a75188bc850367ed799bafa27ad9; then
  applypatch  EMMC:/dev/block/platform/bootdevice/by-name/boot:9820160:715a2ef4b711d1c10dcff330eff4fb5141c23286 EMMC:/dev/block/platform/bootdevice/by-name/recovery c56a690e473bd75958129dff02c85e7c73d24347 15216640 715a2ef4b711d1c10dcff330eff4fb5141c23286:/system/recovery-from-boot.p && installed=1 && log -t recovery "Installing new recovery image: succeeded" || log -t recovery "Installing new recovery image: failed"
  [ -n "$installed" ] && dd if=/system/recovery-sig of=/dev/block/platform/bootdevice/by-name/recovery bs=1 seek=15216640 && sync && log -t recovery "Install new recovery signature: succeeded" || log -t recovery "Installing new recovery signature: failed"
else
  log -t recovery "Recovery image already installed"
fi
