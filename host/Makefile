# both these targets need to be run with privileges (e.g. sudo)
install:
	install scripts/announce /usr/local/bin
	install systemd/announce.service /etc/systemd/system
	install systemd/announce.timer /etc/systemd/system
	systemctl daemon-reload
	systemctl start announce.service
	systemctl enable announce.timer

uninstall:
	systemctl disable announce.timer
	systemctl stop announce.service
	rm /etc/systemd/system/announce.timer
	rm /etc/systemd/system/announce.service
	systemctl daemon-reload


