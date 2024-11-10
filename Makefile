clean:
	@echo "[+] Cleaning dependencies"
	flutter clean
	flutter pub get

split-apk:
	@echo "[+] Cleaning dependencies"
	flutter clean
	flutter pub get
	@echo "[+] Building split apk"
	flutter build apk --split-per-abi

universal:
	@echo "[+] Cleaning dependencies"
	flutter clean
	flutter pub get
	@echo "[+] Building universal apk"
	flutter build apk --release 
