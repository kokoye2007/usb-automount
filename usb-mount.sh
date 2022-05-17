#!/bin/bash

ACTION=$1
DEVBASE=$2
DEVICE="/dev/${DEVBASE}"
DCKRR=/var/lib/docker

# See if this drive is already mounted
MOUNT_POINT=$(/bin/mount | /bin/grep "${DEVICE}" | /usr/bin/awk '{ print $3 }')

do_mount()
{
    if [[ -n ${MOUNT_POINT} ]]; then
        # Already mounted, exit
        exit 1
    fi
	
    # Get info for this drive: $ID_FS_LABEL, $ID_FS_UUID, and $ID_FS_TYPE
    eval "$(/sbin/blkid -o udev "${DEVICE}")"

    # Figure out a mount point to use
    LABEL=${ID_FS_LABEL}
    if [[ -z "${LABEL}" ]]; then
        LABEL=${DEVBASE}
    elif /bin/grep -q " /media/${LABEL} " /etc/mtab; then
        # Already in use, make a unique one
        LABEL+="-${DEVBASE}"
    fi
    MOUNT_POINT="/media/${LABEL}"

    /bin/mkdir -p "${MOUNT_POINT}"

    # Global mount options
    OPTS="rw,relatime"

    # File system type specific mount options
    if [[ ${ID_FS_TYPE} == "vfat" ]]; then
        OPTS+=",users,gid=100,umask=000,shortname=mixed,utf8=1,flush"
    fi

    if ! /bin/mount -o "${OPTS} ${DEVICE} ${MOUNT_POINT}"; then
        # Error during mount process: cleanup mountpoint
        /bin/rmdir "${MOUNT_POINT}"
        exit 1
    fi
	
}

# Copy Docker File
 
do_copy(){
#Docker Directory
DCKR=${MOUNT_POINT}/docker
#Log and Tracker for reboot
SUCCESS=${MOUNT_POINT}/copy.success
#Log for Error Tracker
LOG=${MOUNT_POINT}/docker.log
if [[ ! -f ${SUCCESS} ]]; then
	if [[ -d ${DCKR} ]]; then
		cp -rv "${DCKR}"/* "${DCKRR}" >> "${LOG}"
		echo -e "Copy data\n\tDate: $(date)\n" >> "${LOG}"
		touch "${SUCCESS}"
		reboot
	else 
		# Log for not docker dir
		touch "${MOUNT_POINT}/docker-dir-not-found"
		echo -e "Please make docker dir and put data\n\tNOTE $(date)\t" \
		>> "${LOG}"
	fi
fi 
}

do_unmount()
{
    if [[ -n ${MOUNT_POINT} ]]; then
        /bin/umount -l "${DEVICE}"
    fi

    # Delete all empty dirs in /media that aren't being used as mount points. 
    for f in /media/* ; do
        if [[ -n $(/usr/bin/find "$f" -maxdepth 0 -type d -empty) ]]; then
            if ! /bin/grep -q " $f " /etc/mtab; then
                /bin/rmdir "$f"
            fi
        fi
    done
}
case "${ACTION}" in
    add)
        do_mount
	do_copy
        ;;
    remove)
        do_unmount
        ;;
esac
