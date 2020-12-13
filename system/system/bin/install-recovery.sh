#!/system/bin/sh
if ! applypatch -c EMMC:/dev/block/platform/bootdevice/by-name/recovery:15259648:3a91ebd7678985fe382a3300ba17e90b4ca5a5c8; then
  applypatch  EMMC:/dev/block/platform/bootdevice/by-name/boot:9850880:0c66e3e61d4604aac109750f5cc8126af30f1744 EMMC:/dev/block/platform/bootdevice/by-name/recovery 7a8ac77679c7d6db800333cad7f80f548c591110 15257600 0c66e3e61d4604aac109750f5cc8126af30f1744:/system/recovery-from-boot.p && installed=1 && log -t recovery "Installing new recovery image: succeeded" || log -t recovery "Installing new recovery image: failed"
  [ -n "$installed" ] && dd if=/system/recovery-sig of=/dev/block/platform/bootdevice/by-name/recovery bs=1 seek=15257600 && sync && log -t recovery "Install new recovery signature: succeeded" || log -t recovery "Installing new recovery signature: failed"
else
  log -t recovery "Recovery image already installed"
fi
