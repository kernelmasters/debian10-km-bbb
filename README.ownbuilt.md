## Setup Embedded Linux Development Environment 
`[create own built images]`

### Configure & Build u-boot 2019.04 source code
1. Download u-boot source code
```sh
$ cd ~/KM_GITHUB/
$ git clone git@github.com:kernel-masters/beagleboneblack-uboot.git
$ cd beagleboneblack-uboot
```
2. Configure u-boot source code for KM-BBB and build using the below scirpt. It takes 3 to 5 minutes.
```sh
$ km-bbb-uboot-build.sh
```
3. After succesfully build u-boot source code and current folder X-loader image "MLO" and "u-boot.img" generated.
  > **u-boot.bin:** *is the binary compiled U-Boot bootloader.*
  
  > **u-boot.img:** *contains u-boot.bin along with an additional header to be used by the boot ROM to determine how and where to load and execute U-Boot.*
   
   
### Install u-boot 2019.04 source code
#### Using Sd card
Install MLO and u-boot.img images in to sdcard using the below script.

`$ ./km-bbb-uboot-install.sh --mmc /dev/sdX `

where 'X' indicates sd card device name. find out using dmesg command after inserting sd card.

#### Using Network (TFTP)

`$ ./km-bbb-uboot-install.sh --board X `

Where 'x' indicates KM-BBB board number.


### Configure & Build Kernel 4.19.94 source code
1. Download kernel source code from github
```sh
$ cd ~/KM_GITHUB/
$ git clone git@github.com:kernel-masters/beagleboneblack-kernel.git
$ cd beagleboneblack-kernel
```
2. Configure kernel source code for KM-BBB and build using the below scirpt. It takes 3 to 5 minutes.
```sh
$ km-bbb-kernel-build.sh
```
3. After succesfully build kernel source code and current folder vmlinux image generated.
   
### Install kernel source code
#### Using Sd card
Install vmlinuz, dtbs, modules images in to sdcard using the below script.

`$ ./km-bbb-kernel-install.sh --mmc /dev/sdX `

where 'X' indicates sd card device name. find out using dmesg command after inserting sd card.

#### Using Network (TFTP)

`$ ./km-bbb-kernel-install.sh --board X `

Where 'x' indicates KM-BBB board number.



