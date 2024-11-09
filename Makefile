clean:
	@echo "[+] Cleaning dependencies"
	flutter clean
	flutter pub get

apk:
	@echo "[+] Cleaning dependencies"
	flutter clean
	flutter pub get
	@echo "[+] Building apk"
	flutter build apk --split-per-abi
