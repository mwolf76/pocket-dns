# both these targets need to be run with privileges (e.g. sudo)
install:
	rm -rf /usr/local/src/pocket-dns
	cp -r . /usr/local/src/pocket-dns
	install systemd/pocket-dns.service /etc/systemd/system
	systemctl daemon-reload
	systemctl start pocket-dns.service

uninstall:
	systemctl stop pocket-dns.service
	rm -f /etc/systemd/system/pocket-dns.service
	rm -rf /usr/local/src/pocket-dns
	systemctl daemon-reload
