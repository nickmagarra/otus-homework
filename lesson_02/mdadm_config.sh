#!/bin/bash
echo " "
echo "==============================================================="
echo " "
echo "This script will configure mdadm with predefined settings:"
echo "  - RAID10 of 4 disks with 4 partitions (ext4)"
echo "  - RAID1 of 2 disks with 1 partition (ext4)"
echo "  - Save mdadm config to /etc/mdadm/mdadm.conf"
echo "  - Add lines to fstab for new partitions"
echo " "
echo "==============================================================="
echo "1. Checking current RAID configuration..."

# Check that raid doesn't exist
if [[ -z "$(ls /dev | grep md)" ]]
then
  echo "Result: No mdadm devices found"
  echo " "

  echo "2. Clear disks and create raid"
  mdadm --quiet --zero-superblock --force /dev/sd{b,c,d,e,f,g}
  mdadm --quiet --create /dev/md0 -l 10 -n 4 /dev/sd{b,c,d,e}
  echo "y" | mdadm --quiet --create --force /dev/md1 -l 1 -n 2 /dev/sd{f,g} > /dev/null 2>&1

  echo "3. Create config file at /etc/mdadm/mdadm.conf"
  mkdir /etc/mdadm
  echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
  mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf

  echo "4. Create partitions"
  parted -s /dev/md0 mklabel gpt
  parted -s /dev/md1 mklabel gpt
  parted /dev/md0 mkpart primary ext4 0% 25%  > /dev/null 2>&1
  parted /dev/md0 mkpart primary ext4 25% 50%  > /dev/null 2>&1
  parted /dev/md0 mkpart primary ext4 50% 75%  > /dev/null 2>&1
  parted /dev/md0 mkpart primary ext4 75% 100%  > /dev/null 2>&1
  parted /dev/md1 mkpart primary ext4 0% 100%  > /dev/null 2>&1

  echo "5. Create FS on new partitions"
  for i in $(seq 1 4); do mkfs.ext4 -F -q /dev/md0p$i > /dev/null 2>&1; done
  mkfs.ext4 -F -q /dev/md1p1 > /dev/null 2>&1

  echo "6. Mount new partitions"
  mkdir -p /raid/part{1,2,3,4,5}
  for i in $(seq 1 4); do mount /dev/md0p$i /raid/part$i; done
  mount /dev/md1p1 /raid/part5

  echo "7. Add new partitions to fstab"
cat >> /etc/fstab <<EOL
# Automount /dev/md* partitions
/dev/md0p1    /raid/part1    ext4    defaults  0 0
/dev/md0p2    /raid/part2    ext4    defaults  0 0
/dev/md0p3    /raid/part3    ext4    defaults  0 0
/dev/md0p4    /raid/part4    ext4    defaults  0 0
/dev/md1p1    /raid/part5    ext4    defaults  0 0
EOL

  echo " "
  echo "All tasks are finished!"
  echo "==============================================================="
  echo " "
  echo "1. Current mdadm state:"
  echo "----------------------"
  mdadm --detail --scan --brief
  echo " "
  echo "2. Mounted partitons:"
  echo "---------------------"
  df -hT | grep md
  echo " "
  echo "3. Lines added to /etc/fstab:"
    echo "---------------------"
  cat /etc/fstab | grep md
else
  echo " "
  echo "Result: Found that mdadm already configured, finishing script"
  echo "==============================================================="
  echo " "
  echo "Current mdadm state:"
  mdadm --detail --scan --brief
fi
echo " "
