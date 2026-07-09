#!/system/bin/sh
if ! applypatch -c EMMC:/dev/block/platform/mstar_mci.0/by-name/recovery:19728384:ae42b4492b0f3197b871c2f6f51d71ad03146fee; then
  applypatch  EMMC:/dev/block/platform/mstar_mci.0/by-name/boot:13512704:eed1d5c5207535e51e0d84ebc3514b03c11ee7c3 EMMC:/dev/block/platform/mstar_mci.0/by-name/recovery 9ec5c6553147e132cd68fba35b8fc109355e4635 19726336 eed1d5c5207535e51e0d84ebc3514b03c11ee7c3:/system/recovery-from-boot.p && installed=1 && log -t recovery "Installing new recovery image: succeeded" || log -t recovery "Installing new recovery image: failed"
  [ -n "$installed" ] && dd if=/system/recovery-sig of=/dev/block/platform/mstar_mci.0/by-name/recovery bs=1 seek=19726336 && sync && log -t recovery "Install new recovery signature: succeeded" || log -t recovery "Installing new recovery signature: failed"
else
  log -t recovery "Recovery image already installed"
fi
