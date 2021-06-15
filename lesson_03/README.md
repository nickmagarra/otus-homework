# Lesson 3: LVM

## Content description

  - **Vagrantfile** - Vagrantfile that creating new disks and attachs them to VM, installing some tools (including xfsdump) and performing non-critical lvm actions. 
  - **lesson_03.txt** - Full console output logged with ***script*** util.
  - **lvm_config.txt** - List of commands to perform root fs migration with reducing lv size.

## Fixes

In PDF with hometask I've found some mistakes and fix them:
  1. Author creates LV mirror using /dev/sd{c,d}, but it's wrong according to final lvm configuration, the right way is:
      - /dev/sd***b*** for **lv_root** (single 10G)
      - /dev/sd***c*** for **lv_home** (single 2G)
      - /dev/sd{***d,e***} for **lv_var** (mirror 1G)
  2. In command ```bash for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done``` values of **$i** would be like ***/proc/*** and when it comes to ```bash /mnt/$i``` it becomes ***/mnt//proc/***.
  Can't say for everyone, but I've faced issue **mount error: can't find directory /mnt//proc**, then change command to ```bash for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt$i; done``` and it runs correctly.
  3. Not mistake but can by optimized: instead of removing basic root lv and then recreate it with smaller size I'd preffer to use **lvreduce** command end then just format new volume.

## Note
Command ```bash grub2-mkconfig -o /boot/grub2/grub.cfg``` doesn't work on CentOS 8 - returns ***device-mapper: reload ioctl on <vol_name> failed: Device or resource busy***, it can be interesting quest to defeat it.
