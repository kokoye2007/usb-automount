.PHONY: install remove
install:
	install -D usb-mount.sh $(DESTDIR)$(PREFIX)/bin/usb-mount.sh
	install -Dm644 99-local.rules $(DESTDIR)$(PREFIX)/lib/udev/rules.d/99-local.rules
	install -Dm644 usb-mount@.service $(DESTDIR)$(PREFIX)/lib/systemd/system/usb-mount@.service

remove:
	rm $(DESTDIR)$(PREFIX)/lib/udev/rules.d/99-local.rules
	rm $(DESTDIR)$(PREFIX)/lib/systemd/system/usb-mount@.service
	rm $(DESTDIR)$(PREFIX)/bin/usb-mount.sh
