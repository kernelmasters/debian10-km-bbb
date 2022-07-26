#!/bin/bash -e

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

# Bold
NC='\033[0m'              # No Color
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White

BRedU='\033[4;31m'         # Underline


check_mmc () {
        FDISK=$(LC_ALL=C fdisk -l 2>/dev/null | grep "Disk ${media}:" | awk '{print $2}')

        if [ "x${FDISK}" = "x${media}:" ] ; then
                echo ""
                echo -e "${Green}I see...${NC}"
                echo ""
                echo "lsblk:"
                lsblk | grep -v sr0
                echo ""
                unset response
                echo -en "${Green}Are you 100% sure, on selecting [${media}] (y/n)? ${NC}"
                read response
                if [ "x${response}" != "xy" ] ; then
                        exit
                fi
                echo ""
        else
                echo ""
                echo -e "${Red}Are you sure? I Don't see [${media}], here is what I do see...${NC}"
                echo ""
                echo "lsblk:"
                lsblk | grep -v sr0
                echo ""
                echo -e "${Green}Permission Denied. Run with sudo"
                exit
        fi                                                                                      
                                                                                        
}

unmount_all_drive_partitions () {
        echo ""
        echo -e "${Red}Unmounting Partitions"
        echo -e "${Green}-----------------------------${NC}"

        NUM_MOUNTS=$(mount | grep -v none | grep "${media}" | wc -l)

	for ((i=1;i<=${NUM_MOUNTS};i++))
        do
                DRIVE=$(mount | grep -v none | grep "${media}" | tail -1 | awk '{print $1}')
                umount ${DRIVE} >/dev/null 2>&1 || true
        done
}


MLO_uboot_copy_sd()
{

        echo -e "${Green}-----------------------------${NC}"
        echo "Zeroing out Drive"
        echo -e "${Green}-----------------------------${NC}"
  #      	dd if=/dev/zero of=${media} bs=1M count=100 || drive_error_ro
  #      	sync
        	dd if=${media} of=/dev/null bs=1M count=100
      		sync
	echo Using dd to place bootloader on drive

        echo -e "${Green}-----------------------------${NC}"
	echo -e "${Red}MLO: dd if=MLO of=/dev/sdc count=2 seek=1 bs=128k${NC}"
		dd if=MLO of=${media} count=2 seek=1 bs=128k
        echo -e "${Green}-----------------------------${NC}"

	echo -e "${Green}-----------------------------${NC}"
	echo -e "${Red}u-boot.img: dd if=u-boot.img of=/dev/sdc count=4 seek=1 bs=384k${NC}"
	dd if=u-boot.img of=${media} count=4 seek=1 bs=384k
	echo -e "${Green}-----------------------------${NC}"
	sudo sfdisk --version

sudo sfdisk ${media} <<-__EOF__
4M,,L,*
__EOF__
sync


        echo -e "${Red}Partition Setup:${NC}"
	echo -e "${Green}-----------------------------${NC}"
	echo ""
	echo ""
	echo -e "${Green}-----------------------------${NC}"
        LC_ALL=C fdisk -l "${media}"
	echo -e "${Green}-----------------------------${NC}"


	 echo -e "${Red}Formating with:${NC} "
	#   sudo mkfs.ext4 -L rootfs ${media}1

	if [ $media == "/dev/mmcblk0" ]; then
		sudo  mkfs.ext4  ${media}p1 -L rootfs
	else
		sudo  mkfs.ext4  ${media}1 -L rootfs
	fi
	# sudo mkfs.ext4 -L rootfs ${DISK}1
	echo -e "${Green}-----------------------------"
	echo -e "-----------------------------${NC}"
	sync
	unmount_all_drive_partitions
	sync
}

debian_fs_copy_sd()
{
        echo -e "${Green}-----------------------------${NC}"
	echo -e "${Red}Debian File System Copy to SDCARD:$2${NC}"
        echo -e "${Green}-----------------------------${NC}"

	sudo mkdir -p /mnt/rootfs
        if [ $media == "/dev/mmcblk0" ]; then
		sudo mount ${media}p1 /mnt/rootfs
	else
		sudo mount ${media}1 /mnt/rootfs
	fi
	if [ -f km-bbb-debian10.4.tar.gz ] ;then
		echo "km-bbb-debian10.4.tar.gz found"
	else
		echo "km-bbb-debian10.3.tar.gz not found and download from kmserver"
		echo -e "${Red}wget http://142.93.218.33/elinux/km-bbb-debian10.3.tar.gz${NC}${Purple}"
		wget http://142.93.218.33/elinux/km-bbb-debian10.3.tar.gz
	fi
	echo -e "${Red}sudo tar -xvf km-bbb-debian10.4.tar.gz  ---- wait ---${NC}"
	sudo tar -xvf km-bbb-debian10.4.tar.gz
	echo -e "${Red}sudo tar -xvf km-bbb-debian10.4.tar -C /mnt/rootfs/${NC}"
	sudo tar -xvf km-bbb-debian10.4.tar -C /mnt/rootfs/
        
	echo -e "${Red}sudo cp ./MLO ./u-boot.img  /mnt/rootfs/opt/backup/uboot/${NC}"
        sudo rm  /mnt/rootfs/opt/backup/uboot/MLO
        sudo rm  /mnt/rootfs/opt/backup/uboot/u-boot.img

	sudo cp ./MLO   /mnt/rootfs/opt/backup/uboot/ 
	sudo cp ./u-boot.img   /mnt/rootfs/opt/backup/uboot/ 
	sudo cp ./MLO   /mnt/rootfs/boot/uboot 
	sudo cp ./u-boot.img   /mnt/rootfs/boot/uboot/ 
	echo -e "${Red}syncing${NC}"
	sync
	echo -e "${Red}sudo rm km-bbb-debian10.4.tar${NC}"
	sudo rm km-bbb-debian10.4.tar
	unmount_all_drive_partitions
}

usage()
{
        echo -e "${BRed}usage: ${Green} sudo ./$(basename $0) --mmc /dev/[drive] ${NC}${Red}"
        echo "       drive is 'sdb', 'mmcblk0'"

	cat <<-__EOF__

		CAUTION:mightbe your harddisk FORMAT. Give proper Device name	
		Find sd card parition name with lsblk command and it replace with drive.

	__EOF__
	
	exit
}

if [ -z "$1" ]; then
	usage
fi
if [ $# -ne 2 ]; then
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
