#!/bin/bash -e

check_mmc () {
        FDISK=$(LC_ALL=C fdisk -l 2>/dev/null | grep "Disk ${media}:" | awk '{print $2}')

        if [ "x${FDISK}" = "x${media}:" ] ; then
                echo ""
                echo "I see..."
                echo ""
                echo "lsblk:"
                lsblk | grep -v sr0
                echo ""
                unset response
                echo -n "Are you 100% sure, on selecting [${media}] (y/n)? "
                read response
                if [ "x${response}" != "xy" ] ; then
                        exit
                fi
                echo ""
        else
                echo ""
                echo "Are you sure? I Don't see [${media}], here is what I do see..."
                echo ""
                echo "lsblk:"
                lsblk | grep -v sr0
                echo ""
                echo "Permission Denied. Run with sudo"
                exit
        fi                                                                                      
                                                                                        
}

unmount_all_drive_partitions () {
        echo ""
        echo "Unmounting Partitions"
        echo "-----------------------------"

        NUM_MOUNTS=$(mount | grep -v none | grep "${media}" | wc -l)

	for ((i=1;i<=${NUM_MOUNTS};i++))
        do
                DRIVE=$(mount | grep -v none | grep "${media}" | tail -1 | awk '{print $1}')
                umount ${DRIVE} >/dev/null 2>&1 || true
        done
}


MLO_uboot_copy_sd()
{

        echo "Zeroing out Drive"
        echo "-----------------------------"
        	dd if=/dev/zero of=${media} bs=1M count=100 || drive_error_ro
        	sync
        	dd if=${media} of=/dev/null bs=1M count=100
      		sync
	echo Using dd to place bootloader on drive

echo -----------------------------
echo "MLO: dd if=MLO of=/dev/sdc count=2 seek=1 bs=128k"
	dd if=MLO of=${media} count=2 seek=1 bs=128k
echo -----------------------------

echo -----------------------------
echo "u-boot.img: dd if=u-boot.img of=/dev/sdc count=4 seek=1 bs=384k"
	dd if=u-boot.img of=${media} count=4 seek=1 bs=384k
echo -----------------------------
echo -----------------------------

sudo sfdisk --version


sudo sfdisk ${media} <<-__EOF__
4M,,L,*
__EOF__

sync


        echo "Partition Setup:"
        echo "-----------------------------"
        LC_ALL=C fdisk -l "${media}"
        echo "-----------------------------"


	 echo "Formating with: "
	#   sudo mkfs.ext4 -L rootfs ${media}1
	sudo  mkfs.ext4  ${media}1 -L rootfs 
	# sudo mkfs.ext4 -L rootfs ${DISK}1
        echo "-----------------------------"
        
        sync
	unmount_all_drive_partitions
        sync

}

debian_fs_copy_sd()
{
        echo "-----------------------------"
	echo "Minimal File System Copy to SDCARD:$2"
        echo "-----------------------------"

	sudo mkdir -p /mnt/rootfs
	sudo mount ${media}1 /mnt/rootfs
	wget http://142.93.218.33/elinux/km-bbb-debian10.1.tar.gz
	sudo tar -xvf km-bbb-debian10.1.tar.gz -C /mnt/rootfs/
	sync
	unmount_all_drive_partitions
}

usage()
{
        echo "usage: sudo $(basename $0) --mmc /dev/sdX "
	cat <<-__EOF__

		CAUTION:mightbe your harddisk FORMAT. Give proper Device name	
		Find sd card parition name with lsblk command and it replace with X.

	__EOF__
	
	exit
}

if [ -z "$1" ]; then
	usage
fi
# parse commandline options
while [ ! -z "$1" ] ; do
        case $1 in
        -h|--help)
                usage
                ;;
	 --mmc)
                media="$2"
	    	echo $media
                check_mmc
                ;;
	esac
        shift
done



unmount_all_drive_partitions
MLO_uboot_copy_sd
debian_fs_copy_sd
#
