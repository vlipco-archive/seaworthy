clean:
	@if [[ -d "./release" ]]; then echo "Cleaning release dir"; rm -rf "./release"; fi
	@echo "Creating empty release dir"
	@mkdir -p release

rpm: clean
	@echo
	@cd package-src && ./make-rpm
	@mv package-src/*.rpm ./release/
	@for pkg in $$(ls release/*.rpm -1); do \
		info="$${pkg%%.x*}-info"; files="$${pkg%%.x*}-files"; \
		rpm -qlp $$pkg > $$files; \
		rpm -qip $$pkg > $$info; \
		echo -e "\nConfig files:" >> $$info; \
		rpm -qcp $$pkg >> $$info; \
	done

uninstall: 
	@echo
	@if rpm -qi seaworthy &> /dev/null; then \
		echo "Uninstalling previous Seaworthy version"; \
		sudo rpm --erase seaworthy --allmatches; \
	fi

install: rpm
	@echo
	@echo "Installing Seaworthy package"
	@sudo rpm --install release/seaworthy-*.rpm

# the first run of the stop cluster.target will fail
# handle that in an elegant way!
dev_clean:
	@sudo systemctl stop cluster.target || echo "... ignoring"
	@if [[ -d "/var/lib/seaworthy/components" ]] && which swrth &> /dev/null; then \
		echo "Disabling local components for clean cycle"; \
		for comp in $$(ls /var/lib/seaworthy/components -1); do \
			echo "Disabling $$comp"; \
			sudo swrth components disable $$comp; \
		done; \
	fi
	@if [[ -d "/var/lib/seaworthy" ]]; then \
		echo "Cleaning cluster dir"; \
		sudo rm -rf "/var/lib/seaworthy"; \
	fi
	@if [[ -d "/var/local/consul" ]]; then \
		echo "Cleaning cluster data"; \
		sudo rm -rf "/var/local/consul"; \
	fi

start:
	@sudo swrth components enable waypoint
	@sudo swrth components enable admin
	@sudo systemctl restart docker.service
	@sudo systemctl restart cluster.target

cycle: clean rpm dev_clean uninstall install start