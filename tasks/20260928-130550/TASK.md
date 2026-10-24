# use udevadm to monitor backlight changes

- STATUS: CLOSED
- PRIORITY: 100
- TAGS: 

`udevadm monitor --subsystem-match=backlight > /tmp/backlight_monitoring` would overwrite the file everytime the backlight is changed
using a filewatcher on the /tmp/backlight_monitoring file would probably work

use that to buffer the file:
```
udevadm monitor --subsystem-match=backlight --udev | stdbuf -oL stdbuf -eL grep --line-buffered "CHANGE" > /run/user/$UID/backlight_event
```

--udev to filter only udev events
stdbuf is to "actually" send an inotify notification for FileWatcher to notice
