#!/system/bin/sh
if ! applypatch -c EMMC:/dev/block/platform/bootdevice/by-name/recovery:15247360:cbc15f36df15a32931c3e1e142244d984567ea88; then
  applypatch  EMMC:/dev/block/platform/bootdevice/by-name/boot:9857024:b88909cdfa082b1f82f0250c3f97194f4583fa81 EMMC:/dev/block/platform/bootdevice/by-name/recovery d6927ecec247b4f402088ed5c6f50e790cf437d2 15245312 b88909cdfa082b1f82f0250c3f97194f4583fa81:/system/recovery-from-boot.p && installed=1 && log -t recovery "Installing new recovery image: succeeded" || log -t recovery "Installing new recovery image: failed"
  [ -n "$installed" ] && dd if=/system/recovery-sig of=/dev/block/platform/bootdevice/by-name/recovery bs=1 seek=15245312 && sync && log -t recovery "Install new recovery signature: succeeded" || log -t recovery "Installing new recovery signature: failed"
else
  log -t recovery "Recovery image already installed"
fi
