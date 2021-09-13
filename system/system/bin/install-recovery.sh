#!/system/bin/sh
if ! applypatch -c EMMC:/dev/block/platform/bootdevice/by-name/recovery:15278080:ae9940811ae2ab71433f71171bcc3aa1409bff7e; then
  applypatch  EMMC:/dev/block/platform/bootdevice/by-name/boot:9863168:6612522744c4ee756d089f3e7bb7c132eff51c9a EMMC:/dev/block/platform/bootdevice/by-name/recovery 363eee2a058e2e15a7d166c7cb4e8912b9af21d9 15276032 6612522744c4ee756d089f3e7bb7c132eff51c9a:/system/recovery-from-boot.p && installed=1 && log -t recovery "Installing new recovery image: succeeded" || log -t recovery "Installing new recovery image: failed"
  [ -n "$installed" ] && dd if=/system/recovery-sig of=/dev/block/platform/bootdevice/by-name/recovery bs=1 seek=15276032 && sync && log -t recovery "Install new recovery signature: succeeded" || log -t recovery "Installing new recovery signature: failed"
else
  log -t recovery "Recovery image already installed"
fi
