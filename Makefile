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
	@if rpm -qi seaworthy &> /dev/null; \
		echo "Uninstalling previous Seaworthy version"; \
		then sudo rpm --erase seaworthy --allmatches; \
	fi

install: rpm
	@echo
	@echo "Installing Seaworthy package"
	@sudo rpm --install release/seaworthy-*.rpm

cycle: clean rpm uninstall install