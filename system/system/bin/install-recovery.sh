#!/system/bin/sh
if ! applypatch -c EMMC:/dev/block/platform/bootdevice/by-name/recovery:15276032:aea41bc328ce0d6119e683d812ae123b49b84804; then
  applypatch  EMMC:/dev/block/platform/bootdevice/by-name/boot:9865216:49ac8cc6703bd26ed52adda4b05d5ed719ad71e3 EMMC:/dev/block/platform/bootdevice/by-name/recovery e48deea9c8d70174ccf6646eec3458e8906da1d9 15273984 49ac8cc6703bd26ed52adda4b05d5ed719ad71e3:/system/recovery-from-boot.p && installed=1 && log -t recovery "Installing new recovery image: succeeded" || log -t recovery "Installing new recovery image: failed"
  [ -n "$installed" ] && dd if=/system/recovery-sig of=/dev/block/platform/bootdevice/by-name/recovery bs=1 seek=15273984 && sync && log -t recovery "Install new recovery signature: succeeded" || log -t recovery "Installing new recovery signature: failed"
else
  log -t recovery "Recovery image already installed"
fi
