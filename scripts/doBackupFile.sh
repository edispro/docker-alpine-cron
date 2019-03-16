#!/bin/bash
# Author: edispro active
#================================================================
#% SYNOPSIS
#+    ${SCRIPT_NAME} 
#%
#% OPTIONS
#%   --LOCAL_PATH=[path]		Local Dir path
#%   --EXCLODE1=[path]	exclode dir or file path
#%   --EXCLODE2=[path]		exclode dir or file path
#%   --EXCLODE3=[path]		exclode dir or file path
#%   --EXCLODE4=[path]		exclode dir or file path
#%   --FTP_USER=[name]			FTP server username
#%   --FTP_PASS=[password]		FTP server user password
#%   --FTP_HOST=[hostname]		FTP server hostname
#%   --FTP_PORT=[port]		FTP server port
#%   --FTP_PROTO=[ftp]		Protocol to use (default: ftp) ,sftp
#%   --REMOTE_PATH=[path]		Your FTP backup destination folder
#%   -h, --help				print this help
#-

#================================================================

  #== general functions ==#
usage() { printf "Usage: "; head -50 ${0} | grep "^#+" | sed -e "s/^#+[ ]*//g" -e "s/\${SCRIPT_NAME}/${SCRIPT_NAME}/g" ; }
usagefull() { head -50 ${0} | grep -e "^#[%+-]" | sed -e "s/^#[%+-]//g" -e "s/\${SCRIPT_NAME}/${SCRIPT_NAME}/g" ; }

#============================
#  SET VARIABLES
#============================
unset SCRIPT_NAME SCRIPT_OPTS ARRAY_OPTS
BIN_NETWORK="/usr/bin/nmcli"
  #== general variables ==#
SCRIPT_NAME="$(basename ${0})"
OptFull=$@
OptNum=$#

  #== program variables ==#
LOCAL_PATH=""
EXCLODE1=""
EXCLODE2=""
EXCLODE3=""
EXCLODE4=""
FTP_USER=""
FTP_PASS=""
FTP_HOST=""
FTP_PORT="21"
FTP_PROTO="ftp"
REMOTE_PATH="/"

#============================
#  OPTIONS WITH GETOPTS
#============================

  #== set short options ==#
SCRIPT_OPTS=':trebmingd:-:h'
  #== set long options associated with short one ==#
typeset -A ARRAY_OPTS
ARRAY_OPTS=(
	[LOCAL_PATH]=t
	[EXCLODE1]=r
	[EXCLODE2]=e
	[EXCLODE3]=b
	[EXCLODE4]=m
	[FTP_USER]=i
	[FTP_PASS]=N
	[FTP_HOST]=g
	[FTP_PORT]=d
	[FTP_PROTO]=c
	[REMOTE_PATH]=a

)

  #== parse options ==#
while getopts ${SCRIPT_OPTS} OPTION ; do
	#== translate long options to short ==#
	if [[ "x$OPTION" == "x-" ]]; then
		LONG_OPTION=$OPTARG
		LONG_OPTARG=$(echo $LONG_OPTION | grep "=" | cut -d'=' -f2)
		LONG_OPTIND=-1
		[[ "x$LONG_OPTARG" = "x" ]] && LONG_OPTIND=$OPTIND || LONG_OPTION=$(echo $OPTARG | cut -d'=' -f1)
		[[ $LONG_OPTIND -ne -1 ]] && eval LONG_OPTARG="\$$LONG_OPTIND"
		OPTION=${ARRAY_OPTS[$LONG_OPTION]}
		[[ "x$OPTION" = "x" ]] &&  OPTION="?" OPTARG="-$LONG_OPTION"
		
		if [[ $( echo "${SCRIPT_OPTS}" | grep -c "${OPTION}:" ) -eq 1 ]]; then
			if [[ "x${LONG_OPTARG}" = "x" ]] || [[ "${LONG_OPTARG}" = -* ]]; then 
				OPTION=":" OPTARG="-$LONG_OPTION"
			else
				OPTARG="$LONG_OPTARG";
				if [[ $LONG_OPTIND -ne -1 ]]; then
					[[ $OPTIND -le $Optnum ]] && OPTIND=$(( $OPTIND+1 ))
					shift $OPTIND
					OPTIND=1
				fi
			fi
		fi
	fi

	#== options follow by another option instead of argument ==#
	if [[ "x${OPTION}" != "x:" ]] && [[ "x${OPTION}" != "x?" ]] && [[ "${OPTARG}" = -* ]]; then 
		OPTARG="$OPTION" OPTION=":"
	fi
  
	#== manage options ==#
	case "$OPTION" in
		t  ) LOCAL_PATH=${LONG_OPTARG}                   ;;
		r  ) EXCLODE1=${LONG_OPTARG}                    ;;
		e  ) EXCLODE2=${LONG_OPTARG}           	   ;;
		b  ) EXCLODE3=${LONG_OPTARG}           	   ;;
		m  ) EXCLODE4=${LONG_OPTARG}           	   ;;
		i  ) FTP_USER=${LONG_OPTARG}           	   ;;
		N  ) FTP_PASS=${LONG_OPTARG}           	   ;;
		g  ) FTP_HOST=${LONG_OPTARG}           	   ;;
		d  ) FTP_PORT=${LONG_OPTARG}           	   ;;
		c  ) FTP_PROTO=${LONG_OPTARG}           	   ;;
		a  ) REMOTE_PATH=${LONG_OPTARG}           	   ;;
		h ) usagefull && exit 0 ;;
		: ) echo "${SCRIPT_NAME}: -$OPTARG: option requires an argument" >&2 && usage >&2 && exit 99 ;;
		? ) echo "${SCRIPT_NAME}: -$OPTARG: unknown option" >&2 && usage >&2 && exit 99 ;;
	esac
done
shift $((${OPTIND} - 1))


if [ "$LOCAL_PATH" == "" ]  || [ "$FTP_USER" == "" ]  || [ "$FTP_PASS" == "" ]  || [ "$FTP_HOST" == "" ]  || [ "$FTP_PORT" == "" ] || [ "$ REMOTE_PATH" == "" ]
then
usagefull && exit 0;
fi

MYSQLDUMP="$(which mysqldump)"
TAR="$(which tar)"
LFTP="$(which lftp)"
GZIP="$(which gzip)"
TAR_OPTIONS="-zcf"
FILE_DATE=`date +%Y%m%d-%H%M`
EXCLODE1_OPTIONS=""
EXCLODE2_OPTIONS=""
EXCLODE3_OPTIONS=""
EXCLODE4_OPTIONS=""
if [ -n "$EXCLODE1" ]
then
EXCLODE1_OPTIONS="--exclude $EXCLODE1"
fi
if [ -n "$EXCLODE2" ]
then
EXCLODE2_OPTIONS="--exclude $EXCLODE2"
fi

if [ -n "$EXCLODE3" ]
then
EXCLODE3_OPTIONS="--exclude $EXCLODE3"
fi

if [ -n "$EXCLODE4" ]
then
EXCLODE4_OPTIONS="--exclude $EXCLODE4"
fi

echo "[`date '+%Y-%m-%d %H:%M:%S'`] ============================================================="
echo "[`date '+%Y-%m-%d %H:%M:%S'`] Begining new backup on ${FTP_PROTO}://${FTP_HOST}:${FTP_PORT}"

LFTP_CMD="-u ${FTP_USER},${FTP_PASS} ${FTP_PROTO}://${FTP_HOST}:${FTP_PORT}"

if [ -n "$FTP_HOST" ]
then
# Create remote dir if does not exists
echo "[`date '+%Y-%m-%d %H:%M:%S'`] Create remote dir if does not exists…"
${LFTP} ${LFTP_CMD} <<EOF
cd ${REMOTE_PATH} || mkdir -p ${REMOTE_PATH};
bye;
EOF

if [ -d ${LOCAL_PATH} ]; then
  # Control will enter here if /data exists.
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] Compressing ${LOCAL_PATH} folder…"
  cd ${LOCAL_PATH}
  $TAR $TAR_OPTIONS  $EXCLODE4_OPTIONS /backups/data-$FILE_DATE.tar.gz ./ $EXCLODE1_OPTIONS  $EXCLODE2_OPTIONS  $EXCLODE3_OPTIONS

  # Sending over FTP
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] Sending ${LOCAL_PATH} folder over FTP…"
  ${LFTP} ${LFTP_CMD} <<EOF
cd ${REMOTE_PATH};
put /backups/data-${FILE_DATE}.tar.gz;
bye;
EOF
else
  echo "[`date '+%Y-%m-%d %H:%M:%S'`] ${LOCAL_PATH} folder does not exists."
  exit 1
fi



echo "[`date '+%Y-%m-%d %H:%M:%S'`] Backup finished"

fi
rm -f /backups/data-$FILE_DATE.tar.gz 