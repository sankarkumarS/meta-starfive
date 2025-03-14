#!/bin/bash
# Bootstrapper for buildbot slave

DIR="build"
MACHINE="starfive-dubhe"
CONFFILE="conf/auto.conf"
BITBAKEIMAGE="virtual/kernel"

# clean up the output dir
#echo "Cleaning build dir"
#rm -rf $DIR

# make sure sstate is there
#echo "Creating sstate directory"
#mkdir -p ~/sstate/$MACHINE

# fix permissions set by buildbot
#echo "Fixing permissions for buildbot"
#umask -S u=rwx,g=rx,o=rx
#chmod -R 755 .

# Reconfigure dash on debian-like systems
which aptitude > /dev/null 2>&1
ret=$?
if [ "$(readlink /bin/sh)" = "dash" -a "$ret" = "0" ]; then
  sudo aptitude install expect -y
  expect -c 'spawn sudo dpkg-reconfigure -freadline dash; send "n\n"; interact;'
elif [ "${0##*/}" = "dash" ]; then
  echo "dash as default shell is not supported"
  return
fi
# bootstrap OE
if [[ ":$PATH:" != *":$PWD/meta-starfive:"* ]]; then
  export PATH=$PATH:$PWD/meta-starfive
fi
echo "Init OE"
export BASH_SOURCE="poky/oe-init-build-env"
source poky/oe-init-build-env

# Symlink the cache
#echo "Setup symlink for sstate"
#ln -s ~/sstate/${MACHINE} sstate-cache

# add the missing layers
echo "Adding layers"
bitbake-layers add-layer ../meta-openembedded/meta-oe
bitbake-layers add-layer ../meta-openembedded/meta-python
bitbake-layers add-layer ../meta-openembedded/meta-multimedia
bitbake-layers add-layer ../meta-openembedded/meta-filesystems
bitbake-layers add-layer ../meta-openembedded/meta-networking
bitbake-layers add-layer ../meta-openembedded/meta-gnome
bitbake-layers add-layer ../meta-openembedded/meta-xfce
bitbake-layers add-layer ../meta-openembedded/meta-webserver
bitbake-layers add-layer ../meta-starfive
bitbake-layers add-layer ../meta-clang

# fix the configuration
echo "Creating auto.conf"

if [ -e $CONFFILE ]; then
	rm -rf $CONFFILE
fi
cat <<EOF > $CONFFILE
MACHINE ?= "${MACHINE}"
#IMAGE_FEATURES += "tools-debug"
#IMAGE_FEATURES += "tools-tweaks"
#IMAGE_FEATURES += "dbg-pkgs"
# rootfs for debugging
#IMAGE_GEN_DEBUGFS = "1"
#IMAGE_FSTYPES_DEBUGFS = "tar.gz"
#EXTRA_IMAGE_FEATURES:append = " ssh-server-dropbear"
EXTRA_IMAGE_FEATURES:append = " package-management"
PACKAGECONFIG:append:pn-qemu-native = " sdl"
PACKAGECONFIG:append:pn-nativesdk-qemu = " sdl"
USER_CLASSES ?= "buildstats buildhistory buildstats-summary"

INHERIT += "uninative"

DISTRO_FEATURES:append = " largefile opengl ptest multiarch wayland pam systemd "
#DISTRO_FEATURES:append = " largefile opengl ptest multiarch wayland pam "
DISTRO_FEATURES_BACKFILL_CONSIDERED += "sysvinit"
VIRTUAL-RUNTIME_init_manager = "systemd"
##VIRTUAL-RUNTIME_initscripts = ""
##VIRTUAL-RUNTIME_syslog = ""
HOSTTOOLS_NONFATAL:append = " ssh"

DISTRO_NAME = "StarFive Linux SDK"
#DISTRO_VERSION = ""
#DISTRO_CODENAME = ""
EOF

echo "---------------------------------------------------"
echo "Example: MACHINE=${MACHINE} bitbake ${BITBAKEIMAGE}"
echo "---------------------------------------------------"
echo ""
echo "Buildable machine info"
echo "---------------------------------------------------"
echo "* qemuriscv64  : The 64-bit RISC-V machine"
echo "* starfive-dubhe  : The StarFive Dubhe machine"
echo "---------------------------------------------------"

# start build
#echo "Starting build"
#bitbake $BITBAKEIMAGE

# Launch build script
# Terminal Style
PURPLE='\E[1;35m'
YELLOW='\E[1;33m'
GREEN='\E[0;32m'
RED='\E[0;31m'
NC='\E[0m'
MARK="\033[0;32m\xE2\x9C\x94\033[0m"

#Function
runprog(){
read -p "Do you want to runqemu?[Y/n]:" RES

case $RES in
 [Yy])
   MACHINE=starfive-dubhe runqemu nographic $1;;
 [Nn])
   return;;
 *)
   echo "Invalid option $RES , [Y/n] only.";;
esac
}

dubhe(){
# Menu script
echo ""
echo -e "${PURPLE}*******************************************************************"
echo "*                                                                 *"
echo "*                     StarFive Dubhe Build Menu                   *"
echo "*                                                                 *"
echo -e "*******************************************************************${NC}"
echo "";
echo -e "${YELLOW}Description : ";
echo "";
echo "This build script can build three types of image.";
echo "";
echo "1) core-image-minimal";
echo "   - QSPI boot firmware with that boots image via TFTP and NFS";
echo "   - Generated output : ";
echo "     starfive-dubhe-qspi-firmware.bin";
echo "     Image";
echo "     Image-initramfs-starfive-dubhe.bin";
echo "     Image-nfs-starfive-dubhe.tar.gz";
echo "     Image-sd-starfive-dubhe.img";
echo -e "     dubhe_fpga.dtb${NC}";
echo "";

PS3="Select your action : "
options=("Build core-image-minimal" "Quit")

select opt in "${options[@]}"
do
    case $opt in
        "Build core-image-minimal")
            cur_ter=$(tty);
            output=$(MACHINE=starfive-dubhe bitbake core-image-minimal | tee $cur_ter);
            if [[ $output != *"ERROR"* ]]; then
                echo -e "\U0002705 ${GREEN}Build Complete${NC}"
            else echo -e "\U000274C ${RED}Build Failed${NC}"
            fi;;
	"Quit")
            break;;
        *)
            echo "Invalid option $REPLY. Kindly select choice between menu range."
    esac
    REPLY=
done
}

vf2(){
# Menu script
echo ""
echo -e "${PURPLE}*******************************************************************"
echo "*                                                                 *"
echo "*                 StarFive Visionfive2 Build Menu                 *"
echo "*                                                                 *"
echo -e "*******************************************************************${NC}"
echo "";
echo -e "${YELLOW}Description : ";
echo "";
echo "This build script can build two types of image.";
echo "";
echo "1) core-image-minimal";
echo "   - Minimal image with ext4 support.";
echo "   - Generated output : ";
echo "     starfive-visionfive2-core-image-minimal.img";
echo "2) core-image-minimal-xfce";
echo "   - Minimal image with XFCE desktop environment.";
echo "   - Generated output : ";
echo "     starfive-visionfive2-core-image-minimal-xfce.img";
echo -e "3) Quit${NC}";
echo "";

PS3="Select your action : "
options=("Build core-image-minimal" "Build core-image-minimal-xfce" "Quit")

select opt in "${options[@]}"
do
    case $opt in
        "Build core-image-minimal")
                cur_ter=$(tty);
                output_min=$(MACHINE=starfive-visionfive2 bitbake core-image-minimal | tee $cur_ter);
                if [[ $output_min != *"ERROR"* ]]; then
                	echo -e "\U0002705 ${GREEN}Build Complete${NC}"
                else echo -e "\U000274C ${RED}Build Failed${NC}"
            	fi;;
        "Build core-image-minimal-xfce")
                cur_ter=$(tty);
                output_min=$(MACHINE=starfive-visionfive2 bitbake core-image-minimal-xfce | tee $cur_ter);
                if [[ $output_min != *"ERROR"* ]]; then
                        echo -e "\U0002705 ${GREEN}Build Complete${NC}"
                else echo -e "\U000274C ${RED}Build Failed${NC}"
                fi;;
        "Quit")
            break;;
        *)
            echo "Invalid option $REPLY. Kindly select choice between menu range."
    esac
    REPLY=
done
}

jh8100(){
# Menu script
echo ""
echo -e "${PURPLE}*******************************************************************"
echo "*                                                                 *"
echo "*                 StarFive JH8100 Build Menu                      *"
echo "*                                                                 *"
echo -e "*******************************************************************${NC}"
echo "";
echo -e "${YELLOW}Description : ";
echo "";
echo "This build script can build two types of image.";
echo "";
echo "1) core-image-minimal";
echo "   - Minimal image with ext4 support.";
echo "   - Generated output : ";
echo "     starfive-jh8100-core-image-minimal.img";
echo -e "2) Quit${NC}";
echo "";

PS3="Select your action : "
options=("Build core-image-minimal" "Quit")

select opt in "${options[@]}"
do
    case $opt in
        "Build core-image-minimal")
                cur_ter=$(tty);
                output_min=$(MACHINE=starfive-jh8100 bitbake core-image-minimal | tee $cur_ter);
                if [[ $output_min != *"ERROR"* ]]; then
                        echo -e "\U0002705 ${GREEN}Build Complete${NC}"
                else echo -e "\U000274C ${RED}Build Failed${NC}"
                fi;;
        "Quit")
            break;;
        *)
            echo "Invalid option $REPLY. Kindly select choice between menu range."
    esac
    REPLY=
done
}

# Menu script
echo ""
echo -e "${PURPLE}*******************************************************************"
echo "*                                                                 *"
echo "*                     Welcome to StarFive Yocto                   *"
echo "*                                                                 *"
echo -e "*******************************************************************${NC}"
echo "";
echo -e "${YELLOW}List below shows machine supported : ";
echo "1) StarFive Dubhe";
echo "2) StarFive JH8100";
echo -e "3) Quit${NC}";
echo "";

PS3="Select machine : "
options=("StarFive Dubhe" "StarFive JH8100" "Quit")

select opt in "${options[@]}"
do
    case $opt in
        "StarFive Dubhe")
		dubhe;;
	"StarFive JH8100")
		jh8100;;
	"Quit")
            break;;
        *)
       	    echo "Invalid option $REPLY. Kindly select choice between menu range."
    esac
    REPLY=
done
