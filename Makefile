.PHONY: setup build run clean kill log test format lint help release

APP_NAME = Hinto
SCHEME = Hinto
BUILD_DIR = build
APP_PATH = $(BUILD_DIR)/Build/Products/Release/$(APP_NAME).app
DMG_PATH = $(APP_NAME).dmg
APPLE_TEAM_ID = JQ43BAV5D8

setup:
	@echo "Setting up local development certificate..."
	@./Scripts/codesign/setup_local.sh
	@echo "Done. You can now run: make build"

build:
	@echo "Building $(APP_NAME)..."
	@xcodebuild -scheme $(SCHEME) -configuration Release -derivedDataPath $(BUILD_DIR) build 2>&1 | grep -E "(error:|warning:|BUILD SUCCEEDED|BUILD FAILED)" || true

run: kill build
	@echo "Opening $(APP_NAME)..."
	@sleep 0.3
	@open $(APP_PATH)

kill:
	@pkill -9 $(APP_NAME) 2>/dev/null || true

clean:
	@echo "Cleaning..."
	@rm -rf $(BUILD_DIR) .build
	@echo "Done."

log:
	@tail -f /tmp/hinto.log

test:
	@echo "Running tests..."
	@swift test 2>&1 | grep -E "(Test Case|passed|failed|error:)" || swift test

format:
	@swiftformat .

lint:
	@swiftformat --lint .

release: clean
	@echo "Building $(APP_NAME) for release..."
	@xcodebuild \
		-scheme $(SCHEME) \
		-configuration Release \
		-derivedDataPath $(BUILD_DIR) \
		CODE_SIGN_IDENTITY="Developer ID Application" \
		CODE_SIGN_STYLE=Manual \
		DEVELOPMENT_TEAM="$(APPLE_TEAM_ID)" \
		CODE_SIGN_INJECT_BASE_ENTITLEMENTS=NO \
		OTHER_CODE_SIGN_FLAGS="--timestamp --options runtime" \
		build
	@echo "Notarizing..."
	@cd $(BUILD_DIR)/Build/Products/Release && \
		ditto -c -k --keepParent $(APP_NAME).app $(APP_NAME).zip && \
		xcrun notarytool submit $(APP_NAME).zip \
			--apple-id "$(APPLE_ID)" \
			--password "$(APPLE_PASSWORD)" \
			--team-id "$(APPLE_TEAM_ID)" \
			--wait && \
		xcrun stapler staple $(APP_NAME).app && \
		rm $(APP_NAME).zip
	@echo "Creating DMG..."
	@rm -f $(DMG_PATH)
	@if [ ! -d create-dmg ]; then git clone https://github.com/create-dmg/create-dmg.git; fi
	@./create-dmg/create-dmg \
		--volname "$(APP_NAME)" \
		--background "Resources/dmg-background.tiff" \
		--window-pos 200 120 \
		--window-size 500 320 \
		--icon-size 80 \
		--icon "$(APP_NAME).app" 125 175 \
		--app-drop-link 375 175 \
		--hide-extension "$(APP_NAME).app" \
		--no-internet-enable \
		$(DMG_PATH) \
		$(APP_PATH)
	@echo "Done! Created $(DMG_PATH)"

help:
	@echo "Usage:"
	@echo "  make setup   - Create local self-signed certificate (run once)"
	@echo "  make build   - Build the app"
	@echo "  make run     - Kill, build, and run the app"
	@echo "  make kill    - Kill running instance"
	@echo "  make clean   - Remove build directory"
	@echo "  make log     - Tail the log file"
	@echo "  make test    - Run unit tests"
	@echo "  make format  - Format code with SwiftFormat"
	@echo "  make lint    - Check code formatting"
	@echo "  make release - Build, notarize, and create DMG (requires APPLE_ID and APPLE_PASSWORD)"
