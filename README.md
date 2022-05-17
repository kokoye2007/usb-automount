# usb-automount

# Docker usb source dir

please put in 

`usb/docker` folder

# Success log

`usb/copy.success` is success log.

if usb had this log. script not copy again from this usb.

# Error and log

- detail log `usb/docker.log` 
- docker content dir is missing `usb/docker-dir-not-found`

# CONFIG

```
#System docker dir
DCKRR=/var/lib/docker
#Docker Directory
DCKR=${MOUNT_POINT}/docker
#Log and Tracker for reboot
SUCCESS=${MOUNT_POINT}/copy.success
#Log for Error Tracker
LOG=${MOUNT_POINT}/docker.log
```

# Make

- Install
```
sudo make install
```

- Remove
```
sudo make remove
```
