# both these targets need to be run with privileges (e.g. sudo)
install:
	install systemd/pocket-dns /etc/systemd/system
	systemctl daemon-reload
	systemctl start pocket-dns.service

uninstall:
	systemctl stop pocket-dns.service
	rm /etc/systemd/system/pocket-dns.service
	systemctl daemon-reload



