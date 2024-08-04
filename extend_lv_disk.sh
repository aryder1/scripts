#!/bin/bash

# Ubuntu uses Logical Volume Manager (LVM) for managing space on storage devices.
# LVM allows for resizing of partitions.
# After allocating additional hard drive space in ESXi, the below commands will 
# will add that new space to the logical volume.

# Get LV Path with command: sudo lvdisplay

# The OS parition is mounted at /dev/ubuntu-vg/os-lv
# The DATA partition is mounted at /dev/vg0/data-lv
#
#   --- Logical volume ---
#   LV Path                /dev/vg0/data-lv
#   LV Name                data-lv
#   VG Name                vg0
#   LV UUID                5F1IE3-Nazm-efyR-z2aF-yKo1-Q4hi-6sTDTE
#   LV Write Access        read/write
#   LV Creation host, time ubuntu-server, 2024-05-07 23:29:20 +0000
#   LV Status              available
#   # open                 1
#   LV Size                <25.00 GiB
#   Current LE             6399
#   Segments               1
#   Allocation             inherit
#   Read ahead sectors     auto
#   - currently set to     256
#   Block device           252:0

#   --- Logical volume ---
#   LV Path                /dev/ubuntu-vg/os-lv
#   LV Name                os-lv
#   VG Name                ubuntu-vg
#   LV UUID                F2AyJc-oxjw-6MI8-qYGC-2F2W-jbcy-IIKtco
#   LV Write Access        read/write
#   LV Creation host, time ubuntu-server, 2024-05-07 23:29:19 +0000
#   LV Status              available
#   # open                 1
#   LV Size                <14.25 GiB
#   Current LE             3647
#   Segments               1
#   Allocation             inherit
#   Read ahead sectors     auto
#   - currently set to     256
#   Block device           252:1

# On this VM, everything in the /opt directory is mounted to the data-lv
# If you need more space for Wiki.js, Redmine, or Mattermost, extend the data-lv

sudo lvextend -l +100%FREE /dev/vg0/data-lv
sudo resize2fs /dev/vg0/data-lv
