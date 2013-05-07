#!/bin/bash
# 
exec 4> build.log 2>&4 # Redirect STDERR to logfile

export DEBUG_="true"

unset_env(){

local exlist=""

for arg in $@
do
#echo $arg
exlist+=${arg}"|"
done
#echo ${exlist}
exlist=${exlist%|}
[ -z $exlist ] && exlist="__NOT___"

for a in $(compgen -A function ; compgen -A variable)
do
[[ ${DEBUG_} = "true" ]] || echo $a
done

for a in $(compgen -A function ; compgen -A variable)
do
	
	eval "case $a in
	PATH|*BASH*|EUID|PPID|SHELLOPTS|UID|FUNCNAME|COLORTERM)
	#echo $a
	;;
	${exlist})
	#echo list:$a
	;;
	*)
	unset $a;;
	esac"
done 
 }

unset_env EUID 2>/dev/null
#
#unset_env: to clean up all parent env vars,MUST BE RUN BEFORE ANY env variables
#

#exec 4> build.log 2>&4



set -e
#set -o nounset
export LFS=/mnt/lfs
export script=$(readlink -f "$0")
export CWD=$(dirname "$script")
export MAKEFLAGS='-j 4'
export DEBUG_="true"
export TERM=xterm
export HOME="/home/"$(whoami) #/home/lfs/.xinitrc: No such file or directory, Setting_Up_the_Environment_C4 fail, decide ~ stand for 
export SHELL=/bin/bash
export PS1='\u:\w\$ '
#############WILL CHANGE IN NEW SYSTEM#################
export username="mao"
export newuser="mao"
export hostdev="/dev/loop0"
export hostfirstdev="/dev/mapper/loop0p1"
export firstdev="vda1"
export seconddev="vda2" 
export diskdev="vda"
export IP="192.168.122.12"
export GATEWAY="192.168.122.2"
export BROADCAST="192.168.122.255"
export nameserver="192.168.122.2 192.168.122.1"
#############WILL CHANGE IN NEW SYSTEM#################
[ $(uname -m) = 'x86_64' ] && ABI=64 || ABI=32
export udevversion=$(/sbin/udevadm --version)
export paper_size="A4"
export HOSTNAME="ALFS"
export domain="ibm.com"
export timezone="Asia/Shanghai"
export LANG="en_US.utf8"
export LANGUAGE=${LANG}
export LC_ALL=C
export PASSWORD="ping"
export KEYMAP="us"
export FS="ext3"
export wget_list="http://www.linuxfromscratch.org/lfs/view/stable/wget-list"
export md5sums="http://www.linuxfromscratch.org/lfs/view/stable/md5sums"
export sources=$LFS/sources
export CMDS=${CWD}/cmds.sh
export FUNCTIONS=${CWD}/functions.sh
export wgetlist=${sources}/"wget-list"
#sources="$LFS/sources"
#CMDS=${CWD}/cmds;  FUNCTIONS=${CWD}/functions.sh;} || {  CMDS=${LFSBUILD}/cmds;  FUNCTIONS=${LFSBUILD}/functions.sh;} 
export SUCCESS=${sources}/"LFSSUCCESS"
source ${FUNCTIONS} 2>/dev/null
#trap onexit 1 2 3 15 ERR
export tmp=${sources}/killpid
[ -f "$LFS/etc/profile" ] && export PKG_CONFIG_PATH=/opt/lib/pkgconfig:/opt/share/pkgconfig:/usr/lib/pkgconfig
[ -f "$LFS/etc/profile" ] && export LIBRARY_PATH=${LIBRARY_PATH:-}:/lib64:/lib:/usr/lib:/opt/lib 
[ -f "$LFS/etc/profile" ] && source "$LFS/etc/profile"
[ -f "$LFS/etc/profile.d/xorg.sh" ] && source "$LFS/etc/profile.d/xorg.sh"
[ -f "$LFS/etc/profile.d/kde.sh" ] && source "$LFS/etc/profile.d/kde.sh"
[ -f "$LFS/etc/profile.d/qt.sh" ] && source "$LFS/etc/profile.d/qt.sh" 
[ -f "$LFS/etc/profile" ] && export KDE_PREFIX=/opt/kde
trap "cleanup $? $LINENO" 0 1 2 3 13 15 ERR

cleanup(){

exec 3<&1

local exit_status=${1:-$?}
local lineno=$2
local inIFS=$IFS
IFS=$(echo -en "\n\b")
for pid in $(cat $tmp 2>/dev/null )
do
	kill -9  $pid || true
done
IFS=$inIFS
rm -f $tmp
echo Exiting $0 with $exit_status at line $lineno
exit $exit_status
exec 3>&1
}  

# To export all function to child process, MUST BE RUN after all other functions!!!
export_func(){

for func in $(declare -F | cut -d' ' -f3)
do
	if [ ! -z "$func" ] ;then
	export -f $func >/dev/null
	fi
done

}


is_success(){

local func=$1
[ ! -f "$SUCCESS" ] && { touch "$SUCCESS";chown -v lfs.lfs "$SUCCESS"; return 1 ; }

if grep "$func" "$SUCCESS" >/dev/null ; then
return 0
else 
return 1
fi

}



success_build(){
local func=$1
if [ $? == "0" ]  ; then
echo "$func" >> "$SUCCESS"
fi

}
PreparingVirtualKernelFileSystems(){
if ! grep "$FUNCNAME" "$SUCCESS" ; then

Preparing_Virtual_Kernel_File_Systems_C6 || true

success_build $FUNCNAME
else
	log "$FUNCNAME built/run,skip"
fi
}

download_packages(){


local sources="${1}"

if ! is_success $FUNCNAME ; then
	
	mkdir -pv ${sources}
	chmod -v a+wt ${sources}

	#### Begin to download package list, md5sums and packages of course.
	log "Download the sources package list... to ${sources}"
	progress wget -nc ${wget_list} -P ${sources} 
	log "Download the checksum file... to ${sources}"
	progress wget -nc $md5sums -P ${sources}
	log "Download all sources packages... to ${sources}"
	progress wget -nc -i ${sources}/wget-list -P ${sources} 

	cd ${sources}

	SAVEIFS=$IFS
	IFS=$(echo -en "\n\b")
	for i in {1..5}
	do
		missing=$(md5sum -c ${sources}/md5sums   >&4 | grep "FAILED" | cut -d":" -f1)
		if [ ! -z $missing ] ; then

			for d in $missing
			do
			miss=$(grep $d ${sources}/wget-list)
			progress wget -nc $miss -P ${sources} 
			done
		
		else
			break
		fi

	done
	IFS=$SAVEIFS
	success_build $FUNCNAME
else 
	log "${FUNCNAME} built, skip"
fi

}
mk_working_dir(){

if ! grep $FUNCNAME ${SUCCESS} >/dev/null; then
	
	log "Create ${LFSBUILD} "

	[ ! -d ${LFSBUILD} ] && mkdir -pv ${LFSBUILD}
	#mkdir -pv ${LFSBUILD}
	

	log "copy nessary files to ${LFSBUILD}" 

	cp -fv ${CWD}/cmds ${CWD}/functions.sh "${CWD}/$0" ${LFSBUILD}
	chmod -v +x ${LFSBUILD}/$0
	#ln -sfv "${SUCCESS}" ${LFSBUILD}
	[ ! -f ${SUCCESS} ] &&  touch ${SUCCESS}
	chown -Rv lfs.lfs ${LFSBUILD}
	[[ ${DEBUG_} = "true" ]] || success_build $FUNCNAME
else
	log "$FUNCNAME built,skip"
fi

}


chapterinstall(){

	local CHAPTER=$1
	local sources=$2

	local SUCCESS=${sources}/"LFSSUCCESS"
	debug CHAPTER
	debug sources
	debug SUCCESS
[ ! -d $sources ] && error 1  DIRNOTEXISIT "$sources not exists! "
[ ! -f $SUCCESS ] && error 1  PROGRESSMISS "$SUCCESS missing !"



if ! is_success "$CHAPTER" ; then
	local SAVEIFS=$IFS
	IFS=$(echo -en " \t\n\b")
	for func in $(eval echo \$$CHAPTER)
	do	
		into_folder "$sources"
		case "$func" in
		Preparing_Virtual_Kernel_File_Systems_C6|Package_Management_C6|*Chroot*|Cleaning_Up_C6|Changing_Ownership_C5|Rebooting_the_System_C9|About_Devices_C3)
		log "Will not run $func,skipped"
		continue ;;
		*)

		;;
		esac 
	
		successpack="${func}"
		debug func
		debug successpack
		
		
		time pack_install "$successpack" "${sources}" # || error 1  PACKBUILDFAILURE "$successpack failed to build in $FUNCNAME"
		

		#log " Leaving ${PWD} and back to ${sources}"
		#cd ${sources}


	
	done
	IFS=$SAVEIFS
	success_build $CHAPTER
else
log "Chapter :$CHAPTER been built,skip"
fi
}
remove_previous(){
local folder="$1"

[ -d "$folder" ] && { log "Previous "$folder" exists,removing"; progress rm -rf "$folder" || error 1  DIRREMOVEFAILURE "Failed to remove '$folder'" ; }
return 0

}
trim_pack(){
local packstr="$1"

echo $packstr | sed 's/\.tar.*$\|\.tgz$\|\.zip$//'

}
untar(){

local package="$1"
local sources="$2"

[ ! -z "$package" ] || error 1  NULLPACKSTR "Package name is null"
[ -d "$sources" ] || error 1  DIRNOTEXIST "Directory not exists"

packfolder=$(trim_pack ${package})

mkdir -pv $packfolder || error 1  CANNTCREATDIR "Cannot create dir: $packfolder "
case $package in 
	*.zip)
	type unzip || error 2 COMMANDNOTFOUND "Command unzip not found"
	unzip -x "$package" -d "$packfolder"
	;;
	*tar)
	[ ! -z "$package" ] && [ -f "$package" ] && { log "Untaring $package"; tar xf "$package" -C "$packfolder" --checkpoint=100 --checkpoint-action=dot ; echo -e "\n"; }
	;;
	*)
	 [ ! -z "$package" ] && [ -f "$package" ] && { log "Untaring $package"; tar xf "$package" -C "$packfolder"  --strip-components 1 --checkpoint=100 --checkpoint-action=dot ; echo -e "\n"; } 
	;;
esac

}

locate_folder(){

local sources="$1"
local packstr="$2"

[ ! -z "$packstr" ] || error 1  NULLPACKSTR "Package name is null"
[ -d "$sources" ] || error 1  DIRNOTEXIST "Directory not exists"

echo $(find "$sources" -maxdepth 1  -iname $packstr"*" -type d | head -1)

}

into_folder(){

local folder="$1"

	[ -d "$folder" ] && { log "Entering ${folder}"; cd $folder; } || error 1  DIRNOTEXIST "Directory not exists"

}

find_pack_pre(){

local sources="$1"
local packstr="$2"

[ -d "$sources" ] || error 1  DIRNOTEXIST "Directory not exists"
[ ! -z "$packstr" ] || error 1  NULLPACKSTR "Package name is null"

package=$(find "$sources" -maxdepth 1 -iname ${packstr}"*".xz -o -iname ${packstr}"*".bz2 -o -iname ${packstr}"*".gz -type f | head -1)

echo "$package"

#[ -z "$package" ] && return 1 || return 0 

}

find_pack(){

local sources="$1"
local packstr="$2"

 [ -d "$sources" ] || error 1  DIRNOTEXIST "Directory not exists"
 [ -s "$wgetlist" ] || error 1  WGETLISTMISSING " wget-list is empty!"
 [ ! -z "$packstr" ] || error 1  NULLPACKSTR   "Package name is null"


package=$(grep -iEo  "/$packstr[^/]*\.tar\.((bz2)|(xz)|(gz))$" "$wgetlist")

package="${sources}"${package}

[ -f "$package" ] && echo "$package" || echo ""

}


run_cmdstr(){

		local cmdstr="$1"
		
		log "Building ${cmdstr} "
		local inIFS=$IFS
		IFS=$(echo -en " \t\n\b") # $XORG_CONFIG display incorrectly
		type ${cmdstr} | sed "/${cmdstr}/d" | head -50
	
		case  "$cmdstr" in
		*Stripping*|Creating_the_LFS_tools_Directory_C4|Creating_Directories_C6|Creating_Essential_Files_and_Symlinks_C6|Preparing_Virtual_Kernel_File_Systems_C6|Stripping_Again_C6|Creating_Custom_Symlinks_to_Devices_C7|Introduction_to_Xorg_7_7_C24|Adding_the_LFS_User_C4)
		time progress ${cmdstr} || true ;;
		Xorg_Drivers_C24)
		;;
		Linux_3_8_1_C8)
		time ${cmdstr} ;;
		*)
		time progress ${cmdstr} ;; #|| return 1 ;;
		esac 
		IFS=$inIFS

		return 0
}

build_dependency(){

	local func="$1"
	local sources="$2" 
 

	[ ! -z "$func" ] || error 1  NULLPACKSTR "Package name is null"
	[ -d "$sources" ] || error 1  DIRNOTEXIST "Sources Directory not exists"
	#[ ! -z "$CHAPTER" ] || error 1  NULLSTR "CHAPTER name is null"

	
	local depend_func=${func}"_required_or_recommended"
	local func_list="$(eval echo \$$depend_func)"
	local SAVEIFS=$IFS
	IFS=$(echo -en " \t")
	for dependfunc in  $func_list
	do
	block "Building dependency : $dependfunc for $func" 
	time pack_install $dependfunc "$sources" #  || error 1  PACKBUILDFAILURE "$dependfunc failed to build in $FUNCNAME"

	done
	IFS=$SAVEIFS
	 [[ -z "$func_list" ]] && log "No dependening  packages for $func" || block "$func"
	
}
get_pack_header(){

local func="$1"
[ ! -z "$func" ] || error 1  NULLPACKSTR "Package name is null"

		
		case "${func}" in
			*systemd* ) packstr="systemd" ;;
			*)
			packstr=$(echo "${func,,}" |  grep -E -o '^[a-zA-Z0-9]+(_[a-zA-Z]+)?'  | sed 's/_/-/' )
			;;
		esac
		echo $packstr
}
do_cleanup_untar_stuff(){

	local package="$1"
	local sources="$2"
	local packstr="$3"

	[ ! -z "$packstr" ] || error 1  NULLPACKSTR "Package header is null"
	[ -d "$sources" ] || error 1  DIRNOTEXIST "Sources Directory not exists"
	[ ! -z "$package" ] || error 1  NULLPACKNAME "Package name is null"

	buildfolder=${sources%/}"/"${packstr}"-build"
	prefolder=$(trim_pack ${package})
	newfolder=$prefolder

	remove_previous "$buildfolder" 
	case "$packstr" in 
		linux)
		[ ! -d "$prefolder"  ] && untar "$package" "$sources"
		;;
		*)
		remove_previous "$prefolder" 

		untar "$package" "$sources"
		;;
	esac

	into_folder "$newfolder"

}


post_download(){

	local pack="$1"
	local sources="$2" 


	[ ! -z "$pack" ] || error 1  NULLPACKSTR "Package name is null"
	[ -d "$sources" ] || error 1  DIRNOTEXIST "Sources Directory not exists"
	
	local pack_link=${pack}"_download"

	local SAVEIFS=$IFS
	IFS=$(echo -en " \t")
	for link in  $(eval echo \$$pack_link) 
	do
	 
	log "Download ${link} to ${sources}"

	progress wget --no-check-certificate -nc --timeout=60 --tries=5 "$link"  -P "${sources}" || true

	done
	IFS=$SAVEIFS
	
}

pack_install(){
		#GCC_4_7_2_C6
		local successpack="$1"
		local sources="$2" 
		#local CHAPTER=$3

		[ ! -z "$successpack" ] || error 1  NULLPACKSTR "Package name is null"
		[ -d "$sources" ] || error 1  DIRNOTEXIST "Sources Directory not exists"
		#[ ! -z "$CHAPTER" ] || error 1  NULLSTR "CHAPTER name is null"
		case "$successpack" in
			OpenSSL_1_0_1e_C4 )
			export MAKEFLAGS='-j 1'
			;;
			*)
			export MAKEFLAGS='-j 4'
			;;
		esac

		if ! is_callable "$successpack" ;then 
			log "$successpack is not defined,skipped"
		else

			if ! is_success "$successpack"  ; then # 
				block $successpack

				build_dependency "$successpack" "$sources"  

				packvar=${successpack}"_packname"
				packname=$(eval echo \$$packvar)
				if [ ! -z $packname ] ; then 
					package="${sources}""/"$packname
					packname=$(trim_pack ${packname})
					packstr=$(get_pack_header ${packname})
					local pack_link=${successpack}"_download"
			
					if [ ! -z "$(eval echo \$$pack_link)" ] ; then
						post_download $successpack "$sources" 
					
						[ ! -z $packname ] && [ -f  "$package" ] || error 1  PACKMISSING "Can't find package locally and download fails too!!"
					
					fi
				else	

					packstr=$(get_pack_header "$successpack")
	
					package=$(find_pack "$sources"  "${packstr}" )
				
					#[ ! -z $packstr ] && [ ! -f  "$package" ] && error 1  PACKMISSING "Can't find package locally, you may not download previously"

				
				fi

				[ -f  "$package" ] && do_cleanup_untar_stuff  "$package" "$sources" "$packstr"

			
				run_cmdstr ${successpack} #|| error 1  PACKBUILDFAILURE "${successpack} failed to build in $FUNCNAME" 

				[ ! -z "$package" ] && log "${package} building Complete!" || log "${successpack} running Complete!"

		
				[[ "$successpack" = "BLFS_Boot_Scripts_C2" ]] || success_build $successpack
			else
				log "$successpack been built, skipped"
			 
			fi
		fi
}

prechroot(){

 
local cmdline=""

if [ $# -eq 0 ] ; then
	while read -r line
	do 
	if [ ! -z "$line"   ]; then
	cmdline+=$line
	cmdline+=";"
	fi
	done
	
else
	cmdline="$1"
fi

CHROOT=$(type chroot | cut -d' ' -f3)

"$CHROOT" "$LFS" /tools/bin/env \
    HOME=/root                  \
    TERM="$TERM"                \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin \
    /tools/bin/bash --login +h -c "$cmdline"

}

bootstrapchroot(){

local cmdline=""

if [ $# -eq 0 ] ; then
	while read -r line
	do 
	if [ ! -z "$line"   ]; then
	cmdline+=$line
	cmdline+=";"
	fi
	done
	
else
	cmdline="$1"
fi

CHROOT=$(type chroot | cut -d' ' -f3)

"$CHROOT" "$LFS" /usr/bin/env  \
    HOME=/root TERM="$TERM"  \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin \
    /bin/bash --login -c "$cmdline"

}

part1(){

sed -i "s/PAGE=<paper_size>/PAGE=${paper_size}/" ${CMDS}
#sed -n "/${paper_size}/p" ${CMDS}

safe_pattern=$(printf '%s\n' "$timezone" | sed 's/[[\.*^$/]/\\&/g')
# now you can safely do
sed -i "s/remove-destination \/usr\/share\/zoneinfo\/<xxx>/remove-destination \/usr\/share\/zoneinfo\/${safe_pattern}/ " ${CMDS}
#sed -n "/${safe_pattern}/p" ${CMDS}


sed -i 's/<[xxx|yyy|zzz]*>//'  ${CMDS}

#sed -n '/<[xxx|yyy|zzz]*>/p'  ${CMDS}

sed -i "s/HOSTNAME=<lfs>/HOSTNAME=${HOSTNAME}/" ${CMDS}
#sed -n "/${HOSTNAME}/p" ${CMDS}

sed -i "s/^BROADCAST=[0-9]*.[0-9]*.[0-9]*.[0-9]*$/BROADCAST=${BROADCAST}/" ${CMDS}
#sed -n "/BROADCAST=/p" ${CMDS}

sed -i "s/^IP=[0-9]*.[0-9]*.[0-9]*.[0-9]*$/IP=${IP}/" ${CMDS}
#sed -n "/IP=/p" ${CMDS}

sed -i "s/^GATEWAY=[0-9]*.[0-9]*.[0-9]*.[0-9]*$/GATEWAY=${GATEWAY}/" ${CMDS}
#sed -n "/GATEWAY=/p" ${CMDS}

sed -i "s/domain <Your Domain Name>/domain ${domain}/ " ${CMDS}
#sed -n "/domain/p" ${CMDS}

#sed -i '/nameserver <IP address of your primary nameserver>/d' ${CMDS}
#sed -i '/nameserver <IP address of your secondary nameserver>/d' ${CMDS}

sed -i "/nameserver /d" ${CMDS}

for nserver in $(echo ${nameserver} | sort -rn)
do
echo $nserver
#sed -i "/nameserver /d" ${CMDS}
sed -i "/domain ${domain}/a nameserver $nserver" ${CMDS}
done


#sed -i "N;N;s/\n<IP address of your primary nameserver>/ ${nameserver}/ " ${CMDS}
#sed -n "/nameserver/p" ${CMDS}

#sed -i "N;s/\n<IP address of your secondary nameserver>/ ${nameserver}/ " ${CMDS}
##sed -n "/${nameserver}/p" ${CMDS}grep Error glibc-check-log

sed -i "s/LANG=<host_LANG_value>/LANG=en_US/ " ${CMDS}
#sed -n "/make LANG=/p" ${CMDS}

sed -i "/locale -a/d" ${CMDS}
sed -i "/LC_ALL=<locale name>/d" ${CMDS}
#sed -n "/LC_ALL=<locale name>/p" ${CMDS}

sed -i "s/export LANG=<ll>_<CC>.<charmap><@modifiers>/export LANG=${LANG}/" ${CMDS}
#sed -n "/export LANG=/p" ${CMDS}

sed -i '/make.*[^_]check\|make.*[^_]test/d' ${CMDS}
#sed -n '/make.*[^_]check\|make.*[^_]test/p' ${CMDS}

sed -i '/exec[ ]*[\/tools]*\/bin\/bash[ ]*--login[ ]*+h/d' ${CMDS}

sed -i '/su nobody -s \/bin\/bash \\/d' ${CMDS}
#sed -n '/su nobody -s \/bin\/bash \\/p' ${CMDS}
sed -i '/gmp-check-log/d' ${CMDS}
sed -i '/glibc-check-log/d' ${CMDS}
sed -i "/^ABI=32 \.\/configure \.\.\.$/d" ${CMDS} 
sed -i "s/^\.\/configure --prefix=\/usr --enable-cxx$/ABI=${ABI} &/" ${CMDS}
#sed -n '/ABI=/p' ${CMDS}

sed -i '/pushd testsuite/,/popd/d' ${CMDS}

sed -i "/passwd root$/ {s/$/ << EOF/;s/$/\n/;s/$/${PASSWORD}/;s/$/\n/;s/$/${PASSWORD}/;s/$/\n/;s/$/EOF/}" ${CMDS}
#sed -n '/passwd root/ {N;N;N;N;p} ' ${CMDS}

sed -i "/passwd lfs$/ {s/$/ << EOF/;s/$/\n/;s/$/${PASSWORD}/;s/$/\n/;s/$/${PASSWORD}/;s/$/\n/;s/$/EOF/}" ${CMDS}
#sed -n '/passwd lfs/ {N;N;N;N;p} ' ${CMDS}

sed -i "/vim -c ':options'/d" ${CMDS}
#sed -n "/vim -c/p" ${CMDS}
sed -i "/^logout$/d" ${CMDS}
#sed -n "/^logout$/p" ${CMDS}
sed -i '/chroot $LFS/,/--login/d' ${CMDS}
#sed -n '/chroot $LFS/,/--login/p' ${CMDS}

sed -i '/127.0.0.1 localhost/d' ${CMDS}
sed -i '/<192.168.1.1> <HOSTNAME.example.org>/d' $CMDS

sed -i "s/127.0.0.1 <HOSTNAME.example.org> <HOSTNAME> localhost/127.0.0.1 ${HOSTNAME} localhost/" $CMDS

sed -i "/${IP}[ \t]*${HOSTNAME}/d" $CMDS
sed -i "/127.0.0.1 ${HOSTNAME} localhost/a ${IP}	${HOSTNAME}" $CMDS
#sed -n "/127.0.0.1/p" $CMDS
#sed -n "/${IP}[ \t]*${HOSTNAME}/p" $CMDS

sed -i "s/KEYMAP=\"de-latin1\"/KEYMAP=\"${KEYMAP}\"/"  $CMDS

sed -i '/KEYMAP_CORRECTIONS="euro2"/d' $CMDS
sed -i '/LEGACY_CHARSET="iso-8859-15"/d' $CMDS
sed -i '/FONT="LatArCyrHeb-16 -m 8859-15"/d' $CMDS

#sed -n "/UNICODE=\"1\"/,/KEYMAP=\"${KEYMAP}\"/p" $CMDS

sed -i "s/\/dev\/[ \t]*\/[ \t]*<fff>/\/dev\/${firstdev}     \/            ${FS}/" $CMDS
sed -i "s/\/dev\/     swap         swap/\/dev\/${seconddev}     swap         swap/" $CMDS
#sed -n '/# Begin \/etc\/fstab/,/# End \/etc\/fstab/p' $CMDS

dev_pattern=$(printf '%s\n' "$hostdev" | sed 's/[[\.*^$/]/\\&/g')

sed -i "s/grub-install \/dev\/sda/grub-install ${dev_pattern}/" $CMDS
#sed -n "/grub-install \/dev\//p" $CMDS

sed -i "s/root=\/dev\/sda2/root=\/dev\/${firstdev}/" $CMDS
#sed -n "/root=\/dev\//p" $CMDS

sed -i "/exec env -i HOME=\$HOME TERM=\$TERM/d" $CMDS
#sed -n "/exec env -i HOME=\$HOME TERM=\$TERM/p" $CMDS

sed -i "/^\. ~\/.bashrc$/d" $CMDS
sed -i "/cat > ~\/.bash_profile << \"EOF\"/a . ~/.bashrc" $CMDS
#sed -n "/cat > ~\/.bash_profile << \"EOF\"/,/cat > ~\/.bashrc << \"EOF\"/p" $CMDS

}
part2(){

#safe=$(printf '%s\n' "${LFSBUILD}/cmds" | sed 's/[[\.*^$/]/\\&/g')
#sed -i "/${safe}/d" $CMDS

#sed -i "/export LFS LC_ALL LFS_TGT PATH/a source  $safe" $CMDS
##sed -n "/${safe}/p" $CMDS

#safe2=$(printf '%s\n' "${LFSBUILD}/functions.sh" | sed 's/[[\.*^$/]/\\&/g')
#sed -i "/${safe2}/d" $CMDS
#sed -i "/export LFS LC_ALL LFS_TGT PATH/a source  $safe2" $CMDS
##sed -n "/${safe2}/p" $CMDS


sed -i '/Typography_C0(){/,/}/d' $CMDS
#sed -n '/Typography_C0(){/,/}/p' $CMDS

sed -i '/About_SBUs_C4(){/,/}/d' $CMDS
#sed -n '/About_SBUs_C4(){/,/}/p' $CMDS

sed -i "/Package_Management_C6(){/,/}/d" $CMDS
#sed -n "/Package_Management_C6(){/,/}/p" $CMDS

sed -i '/su - lfs/d' $CMDS
#sed -n '/su - lfs/p' $CMDS


sed -i '/tzselect/d' $CMDS
#sed -n '/tzselect/p' $CMDS
sed -i '/hdparm -I \/dev\/sda | grep NCQ/d' $CMDS
#sed -n '/hdparm -I \/dev\/sda | grep NCQ/p' $CMDS

sed -i '/cd \/tmp &&/,/blank=as_needed grub-img.iso/d' $CMDS
#sed -n '/cd \/tmp &&/,/blank=as_needed grub-img.iso/p' $CMDS

sed -i 's/mkdir -v/mkdir -pv/' $CMDS
#sed -n '/mkdir -v/p' $CMDS

sed -i 's/ln -sv/ln -sfv/' $CMDS
#sed -n '/ln -sv/p' $CMDS

sed -i 's/mkdir[ \t]*\//mkdir -pv \//' $CMDS
#sed -n '/mkdir[ \t]*\//p' $CMDS

sed -i 's/chown -v/chown -R/' $CMDS
#sed -n '/chown -R/p' $CMDS
sed -i '/if ignore_if; then continue; fi/d' $CMDS
sed -i "/build\/udevadm hwdb --update/a sed -i 's/if ignore_if; then continue; fi/#&/' udev-lfs-197-2/init-net-rules.sh" $CMDS

sed -i '/\" \/etc\/udev\/rules.d\/70-persistent-net.rule/d' $CMDS
sed -i '/bash udev-lfs-197-2\/init-net-rules.sh/a  sed -i "s/\\"00:0c:29:[^\\".]*\\"/\\"00:0c:29:*:*:*\\"/" /etc/udev/rules.d/70-persistent-net.rules '  $CMDS 
#sed -n '/\" \/etc\/udev\/rules.d\/70-persistent-net.rule/p' $CMDS

sed -i '/Conventions_Used_in_this_Book_C1(){/,/}/d' $CMDS
#sed -n '/Conventions_Used_in_this_Book_C1(){/,/}/p' $CMDS


sed -i '/Notes_on_Building_Software_C2(){/,/}/d' $CMDS
#sed -n '/Notes_on_Building_Software_C2(){/,/}/p' $CMDS

sed -i '/cat > \/etc\/krb5\.conf << "EOF"/,/make install-krb5/d' $CMDS
#sed -n '/cat > \/etc\/krb5\.conf << "EOF"/,/make install-krb5/p' $CMDS


sed -i "s/useradd -m <newuser>/useradd -m ${newuser}/" $CMDS
#sed -n "/useradd -m ${newuser}/p" $CMDS

sed -i '/<report-name.twr>/d' $CMDS

sed -i "s/<udev-Installed LFS Version>/1\.8\.8/" $CMDS
#sed -n '/<udev-Installed LFS Version>/p' $CMDS

sed -i '/convmv/d' $CMDS
sed -i '/<\/path\/to\/unzipped\/files>/d' $CMDS

sed -i '/Running_a_CVS_Server_C13(){/,/}/d' $CMDS

sed -i 's/export PATH="$PATH/export PATH=$PATH/' $CMDS
#sed -n '/export PATH="$PATH/p' $CMDS

 sed -i "s/<username>/${username}/" $CMDS
 #sed -n "/${username}/p" $CMDS

 sed -i "s/<password>/${PASSWORD}/" $CMDS

sed -i "s/<PREFIX>/\/opt/" $CMDS
#sed -n "/<PREFIX>/p" $CMDS

sed -i '/Perl_Modules_C13(){/,/}/d' $CMDS

sed -i "s/dhclient <eth0>/dhclient eth0/" $CMDS

sed  -i "s/\/etc\/openldap\/schema[ \t]*\&\&/\/etc\/openldap\/schema/" $CMDS
#sed  -n "/\/etc\/openldap\/schema[ \t]*\&\&/p" $CMDS

sed -i "s/root password <new-password>/root password ${PASSWORD}/" $CMDS
#sed -n '/root password <new-password>/p' $CMDS

sed -i 's/$DOCNAME.dvi  &&/$DOCNAME.dvi/' $CMDS

sed -i '/lp -o number-up=2 <filename>/d' $CMDS
###########################################
sed -i '/^mkdir -pv \$LFS$/d' $CMDS
sed -i '/^mount -v -t ext3 \/dev\/ \$LFS$/d' $CMDS
sed -i '/^mkdir -pv \$LFS\/usr$/d'  $CMDS
sed -i '/^mount -v -t ext3 \/dev\/ \$LFS\/usr$/d' $CMDS

sed -i "/\/sbin\/swapon -v \/dev/a mount -v -t ext3 ${hostfirstdev} $LFS"  $CMDS

sed -i '/\/sbin\/swapon -v \/dev/a mkdir -pv $LFS'  $CMDS

sed -i '/\/sbin\/swapon -v \/dev/d' $CMDS

###################################################

 sed -i '/shutdown -r now/d' $CMDS
sed -i 's/"EOF" \&\&/"EOF"/'  $CMDS
sed -i '/^bash -e$/d' $CMDS
sed -i '/^exit$/d' $CMDS

sed -i 's/^set root=(hd0,2)$/set root=(hd0,1)/' $CMDS
sed -i '/^grep FATAL check.log$/d' $CMDS
}

parse_book(){

if ! is_success $FUNCNAME ; then


[ ! -s "${CMDS}" ] && { log "Parsing online LFS book and generating ${CMDS}"; python ${CWD}/parsebook.py >&4; } || log "Will not parse LFS book, as ${CMDS} exists."
[ ! -s "${CMDS}" ] && error 1  CMDSMISS "Online LFS Book parse fail!"

log "Modify generated ${CMDS} according to actual requirement"

exec 3>&1 
exec >&4

#time part1
#time part2


exec 1>&3

[[ ${DEBUG_} = "true" ]] ||  success_build $FUNCNAME
else
log "$FUNCNAME built/ran,skipped"
fi

time source ${CMDS} 2>/dev/null

}
	
print_progress(){
	  
	  echo "Running :${BOLD}${REVERSE} $* ${OFF},Please wait: "
	  while true
	  do
	    echo -n "#"
	    sleep 1
	  done

}

progress(){

local func=$1


print_progress $* & echo $! >>$tmp

if id "lfs" >/dev/null 2>&1 ; then
	chown -v lfs $tmp >&4 2>&1
else
	chown -v `whoami` $tmp >&4 2>&1
fi

disown
MYSELF=$!
trap "echo ' Catch CTRL+c ,exiting...' >&3 ;cleanup 1 $LINENO;" INT
echo ""

$* >&4 

kill $MYSELF >/dev/null 2>&1 && sed -i "/$MYSELF/d" $tmp
echo  ""
return 0
}

restart_or_not(){

if is_success "C9_TheEnd" ;then
log "Looking like previous build had been done; Restart a new build ?"

echo "Choose (yes/no): "
	if read -n 1 -t 10  answer ; then
		case $answer in
		Y|y|yes)
			debug "Empty $SUCCESS to restart"
			>"$SUCCESS"
			;;
		N|n|no) 
			exit 0;;
		*) 
			echo "Incorrect input"
			exit 1;;
		esac
	else 
	echo "Time out!exit"
	exit 0
	fi
fi


}

mount_lfs_and_virtual(){

#&& [ $(cat "$SUCCESS" | wc -l) -gt 0 ]
if  ! grep "$LFS"  /proc/mounts ; then 

log "Looking like $LFS not mounted, mounting $LFS and Virtual Kernel File system"

exec 3<&2
Mounting_the_New_Partition_C2 && { Preparing_Virtual_Kernel_File_Systems_C6 || true; }  || error 1 CANNOTMOUNT "Cannot mount $LFS"
exec 3>&1
fi

}

SuInstall(){

local ch=$1
local sources=$2 

#########do NOT use su - lfs#################
su lfs /bin/bash -c  "ConstructingaTemporarySystem $ch ${sources}"
#########do NOT use su - lfs#################

}
gtrap(){

trap "echo $$; echo 'catch trap';cleanup $? $LINENO" 0 1 2 3 13 15

}
find_child_pid(){

    curPid=$1
    childPids=$(ps -o pid --no-headers --ppid ${curPid} || true)
  
    debug childPids 
    echo $curPid >>$tmp
    #cat $tmp
    if [ ! -z "$childPids" ] ; then
	    for childPid in $childPids
	    do
		find_child_pid  $childPid
	    done
    else
         return 0
    fi
}
blockid(){
block "$(id)"
}

blockpwd(){
block "$(pwd)"
}

blockscript(){
block "$script"
}
ConstructingaTemporarySystem(){
local ch=$1
local sources=$2
export HOME=/home/lfs
set -xve
env HOME=$HOME TERM=$TERM bash -c "intoTemporarySystem $ch ${sources}" 
return 0

}

intoTemporarySystem(){
local ch=$1
local sources=$2

set -xve
#find_child_pid $$
source ~/.bashrc
blockid
blockpwd
blockscript
chapterinstall $ch ${sources}

}
InstallSystem(){

local ch=$1
local sources=$2
#trap "cleanup $? $LINENO" 0 1 2 3 13 15 ERR
set -xve
export SUCCESS=${sources}/"LFSSUCCESS"
export tmp=${sources}/killpid
export wgetlist=${sources}/"wget-list"
export HOME="/home/"$(whoami)
blockid
blockpwd
blockscript
chapterinstall $ch  "${sources}"

}

InstallSpecificPack()
{
local pack=$1
local sources=$2
local ch=$3

set -xve
export SUCCESS=${sources}/"LFSSUCCESS"
export tmp=${sources}/killpid
export wgetlist=${sources}/"wget-list"
[ ! -f $SUCCESS ] && error 1  PROGRESSMISS "$SUCCESS missing !"


blockid
blockpwd
blockscript
pack_install $pack  "$sources" 

}
bookinstall(){

local inIFS=$IFS
IFS=$(echo -en " \t\n\b")
for ch in $LFSCHAPTERS
do
	
	block $ch
	case $ch in
		C0_Preface)
		chapterinstall $ch "${sources}" 
		;;
		C1_Introduction|C2_PreparingaNewPartition)
		log "Chapter: $ch is skipped"
		;;
		C3_PackagesandPatches)
		download_packages ${sources}
		;;
		C4_FinalPreparations)
		
		chapterinstall $ch  ${sources}
		;;
		C5_ConstructingaTemporarySystem) 
		SuInstall $ch ${sources} 
		;;
		C6_InstallingBasicSystemSoftware)
		PreparingVirtualKernelFileSystems
		prechroot "InstallSystem $ch '/sources' "
		;; 
		C7_SettingUpSystemBootscripts) 
		bootstrapchroot  "InstallSystem $ch '/sources' "
		;;
		C8_MakingtheLFSSystemBootable)
		bootstrapchroot  "InstallSystem $ch '/sources' "
		;;
		C9_TheEnd)
		bootstrapchroot  "InstallSystem $ch '/sources' "
		;;
		*)
		break
		;;
	esac
done
IFS=$inIFS

}


parse_book 

mount_lfs_and_virtual

restart_or_not

time export_func 2>/dev/null

#post_download "LVM2_2_02_98_C5" "/mnt/lfs/sources"
post_download "Wget_1_14_C15" "/mnt/lfs/sources"
post_download "OpenSSL_1_0_1e_C4" "/mnt/lfs/sources"
time bootstrapchroot 'InstallSpecificPack "Wget_1_14_C15" "/sources"'
time bootstrapchroot 'InstallSpecificPack "About_initramfs_C5" "/sources"'
bookinstall

#time bootstrapchroot 'InstallSpecificPack "OpenSSL_1_0_1e_C4" "/sources"'
#post_download "OpenSSL_1_0_1e_C4" "/mnt/lfs/sources"
time bootstrapchroot 'InstallSpecificPack "OpenSSH_6_1p1_C4" "/sources" '


#bootstrapchroot  "InstallSystem 'C4_Security' '/sources' "
#bootstrapchroot  "InstallSystem 'C24_XWindowSystemEnvironment' '/sources' "
#bootstrapchroot  "InstallSystem 'C33_XfceDesktop' '/sources' "

#pack_install "Linux_3_8_1_C8" "${sources}"
#pack_install "shared_mime_info_1_1_C25" "${sources}"
#pack_install "GnuPG_1_4_13_C4" "${sources}"
#chapterinstall "C27_Introduction" "$sources"
#chapterinstall "C28_TheKDECore" "$sources"
#chapterinstall "C30_GNOMECorePackages" "$sources"
cleanup 0 $LINENO
exit 0


