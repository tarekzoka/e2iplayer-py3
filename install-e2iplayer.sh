#!/bin/bash
# ###########################################
# SCRIPT : DOWNLOAD AND INSTALL E2IPLAYER_TSiplayer
# ###########################################
#
# Command: wget https://gitlab.com/MOHAMED_OS/e2iplayer/-/raw/main/install-e2iplayer.sh?inline=false -qO - | /bin/sh
#
# ###########################################

# Colors
Color_Off='\e[0m'
Red='\e[0;31m'
Green='\e[0;32m'
Yellow='\e[0;33m'

###########################################
# Configure where we can find things here #
TMPDIR='/tmp'
PLUGINPATH='/usr/lib/enigma2/python/Plugins/Extensions/IPTVPlayer'
SETTINGS='/etc/enigma2/settings'
URL='https://gitlab.com/MOHAMED_OS/e2iplayer/-'
MY_PATH='/media/mmc/iptvplayer.sh'
pyVersion=$(python -c"from sys import version_info; print(version_info[0])")

#########################
VERSION=$(wget $URL/raw/main/update2/lastversion.php -qO- | awk 'NR==1')
arrVar=("enigma2-plugin-extensions-e2iplayer-deps" "duktape" "exteplayer3" "gstplayer")

if [ "$pyVersion" = 3 ]; then
  arrVar+=("python3-sqlite3" "python3-pycurl" "python3-e2icjson")
else
  arrVar+=("python-sqlite3" "python-pycurl" "python-e2icjson" "cmdwrap")
fi
########################
if [ -f /etc/opkg/opkg.conf ]; then
  STATUS='/var/lib/opkg/status'
  OSTYPE='Opensource'
  OPKG='opkg update'
  OPKGINSTAL='opkg install'
elif [ -f /etc/apt/apt.conf ]; then
  STATUS='/var/lib/dpkg/status'
  OSTYPE='DreamOS'
  OPKG='apt-get update'
  OPKGINSTAL='apt-get install -y'
fi

#########################
case $(uname -m) in
armv7l*) plarform="armv7" ;;
mips*) plarform="mipsel" ;;
aarch64*) plarform="ARCH64" ;;
sh4*) plarform="sh4" ;;
esac

#########################
install() {
  if ! grep -qs "Package: $1" "$STATUS"; then
    $OPKG >/dev/null 2>&1
    echo -e "   >>>>   Please Wait to install ${Yellow} $1 ${Color_Off}  <<<<"
    sleep 0.8
    echo
    if [ "$OSTYPE" = "Opensource" ]; then
      $OPKGINSTAL "$1"
      sleep 1
      clear
    elif [ "$OSTYPE" = "DreamOS" ]; then
      $OPKGINSTAL "$1" -y
      sleep 1
      clear
    fi
  fi
}

#########################
for i in "${arrVar[@]}"; do
  install "$i"
done

#########################
clear

if [ -e ${TMPDIR}/e2iplayer-main.tar.gz ]; then
  echo -e "${Red}" "remove archive file" "${Color_Off}"
  rm -f ${TMPDIR}/e2iplayer-main.tar.gz
fi

if [ -e ${TMPDIR}/e2iplayer-main ]; then
  rm -fr ${TMPDIR}/e2iplayer-main
fi

echo -e "${Yellow}" "Downloading E2iPlayer plugin Please Wait ......" "${Color_Off}"
wget $URL/archive/main/e2iplayer-main.tar.gz -qP $TMPDIR
if [ $? -gt 0 ]; then
  echo -e "${Red}" "error downloading archive, end" "${Color_Off}"
  exit 1
else
  echo -e "${Green}" "Archive downloaded" "${Color_Off}"
fi

tar -xzf $TMPDIR/e2iplayer-main.tar.gz -C $TMPDIR
if [ $? -gt 0 ]; then
  echo -e "${Red}" "error extracting archive, end" "${Color_Off}"
else
  echo -e "${Green}" "Archive extracted" "${Color_Off}"
  rm -f ${TMPDIR}/e2iplayer-main.tar.gz
fi

if [ -d ${PLUGINPATH} ]; then
  echo -e "${Red}" "Removed old version of E2Iplayer" "${Color_Off}"
  rm -rf ${PLUGINPATH}

  if [ -e /etc/tsiplayer_xtream.conf ]; then
    rm -rf /etc/tsiplayer_xtream.conf
  fi

  if [ -d /iptvplayer_rootfs ]; then
    rm -rf /iptvplayer_rootfs
  fi
fi

cp -rf $TMPDIR/e2iplayer-main/tsiplayer_xtream.conf /etc
cp -rf $TMPDIR/e2iplayer-main/IPTVPlayer /usr/lib/enigma2/python/Plugins/Extensions/

if [ $? -gt 0 ]; then
  echo -e "${Red}" "error installing E2Iplayer, end" "${Color_Off}"
  exit 1
else
  echo -e "${Green}" "E2Iplayer installed" "${Color_Off}"
  rm -fr ${TMPDIR}/e2iplayer-main
fi

sleep 3

#########################
if [ -d $PLUGINPATH ]; then
  if [ -e ${MY_PATH} ]; then
    echo -e ":Your Device IS ${Yellow} $(uname -m) ${Color_Off} processor ..."
    echo "Add Setting To ${SETTINGS} ..."
    init 4
    sleep 5
    sed -e s/config.plugins.iptvplayer.*//g -i ${SETTINGS}
    sleep 2
    {
      echo "config.plugins.iptvplayer.AktualizacjaWmenu=true"
      echo "config.plugins.iptvplayer.alternative${plarform^^}MoviePlayer=extgstplayer"
      echo "config.plugins.iptvplayer.alternative${plarform^^}MoviePlayer0=extgstplayer"
      echo "config.plugins.iptvplayer.buforowanie_m3u8=false"
      echo "config.plugins.iptvplayer.cmdwrappath=/usr/bin/cmdwrap"
      echo "config.plugins.iptvplayer.debugprint=/tmp/iptv.dbg"
      echo "config.plugins.iptvplayer.default${plarform^^}MoviePlayer=exteplayer"
      echo "config.plugins.iptvplayer.default${plarform^^}MoviePlayer0=exteplayer"
      echo "config.plugins.iptvplayer.dukpath=/usr/bin/duk"
      echo "config.plugins.iptvplayer.extplayer_infobanner_clockformat=24"
      echo "config.plugins.iptvplayer.extplayer_skin=green"
      echo "config.plugins.iptvplayer.f4mdumppath=/usr/bin/f4mdump"
      echo "config.plugins.iptvplayer.gstplayerpath=/usr/bin/gstplayer"
      echo "config.plugins.iptvplayer.hlsdlpath=/usr/bin/hlsdl"
      echo "config.plugins.iptvplayer.NaszaSciezka=/media/mmc/Player/"
      echo "config.plugins.iptvplayer.osk_type=system"
      echo "config.plugins.iptvplayer.plarform=${plarform}"
      echo "config.plugins.iptvplayer.remember_last_position=true"
      echo "config.plugins.iptvplayer.rtmpdumppath=/usr/bin/rtmpdump"
      echo "config.plugins.iptvplayer.SciezkaCache=/media/mmc/Player/"
      echo "config.plugins.iptvplayer.uchardetpath=/usr/bin/uchardet"
      echo "config.plugins.iptvplayer.updateLastCheckedVersion=${VERSION}"
      echo "config.plugins.iptvplayer.wgetpath=wget"
    } >>${SETTINGS}
  else
    echo -e ":Your Device IS ${Yellow} $(uname -m) ${Color_Off} processor ..."
    echo "Add Setting To ${SETTINGS} ..."
    init 4
    sleep 5
    sed -e s/config.plugins.iptvplayer.*//g -i ${SETTINGS}
    sleep 2
    {
      echo "config.plugins.iptvplayer.AktualizacjaWmenu=true"
      echo "config.plugins.iptvplayer.SciezkaCache=/etc/IPTVCache/"
      echo "config.plugins.iptvplayer.alternative${plarform^^}MoviePlayer=extgstplayer"
      echo "config.plugins.iptvplayer.alternative${plarform^^}MoviePlayer0=extgstplayer"
      echo "config.plugins.iptvplayer.buforowanie_m3u8=false"
      echo "config.plugins.iptvplayer.cmdwrappath=/usr/bin/cmdwrap"
      echo "config.plugins.iptvplayer.debugprint=/tmp/iptv.dbg"
      echo "config.plugins.iptvplayer.default${plarform^^}MoviePlayer=exteplayer"
      echo "config.plugins.iptvplayer.default${plarform^^}MoviePlayer0=exteplayer"
      echo "config.plugins.iptvplayer.dukpath=/usr/bin/duk"
      echo "config.plugins.iptvplayer.extplayer_infobanner_clockformat=24"
      echo "config.plugins.iptvplayer.extplayer_skin=green"
      echo "config.plugins.iptvplayer.f4mdumppath=/usr/bin/f4mdump"
      echo "config.plugins.iptvplayer.gstplayerpath=/usr/bin/gstplayer"
      echo "config.plugins.iptvplayer.hlsdlpath=/usr/bin/hlsdl"
      echo "config.plugins.iptvplayer.plarform=${plarform}"
      echo "config.plugins.iptvplayer.remember_last_position=true"
      echo "config.plugins.iptvplayer.rtmpdumppath=/usr/bin/rtmpdump"
      echo "config.plugins.iptvplayer.uchardetpath=/usr/bin/uchardet"
      echo "config.plugins.iptvplayer.updateLastCheckedVersion=${VERSION}"
      echo "config.plugins.iptvplayer.wgetpath=wget"
    } >>${SETTINGS}
  fi
fi

#########################

sync
echo ""
echo "***********************************************************************"
echo "**                                                                    *"
echo "**                       E2iPlayer  : $VERSION                   *"
echo "**                       Script by  : MOHAMED_OS                      *"
echo "**  Support    : https://www.tunisia-sat.com/forums/threads/3951696/  *"
echo "**                                                                    *"
echo "***********************************************************************"
echo ""

sleep 0.8
echo -e "${Yellow}" "Device will restart now" "${Color_Off}"
if [ "$OSTYPE" = "DreamOS" ]; then
  sleep 2
  systemctl restart enigma2
else
  init 4
  sleep 2
  init 3
fi
exit 0
