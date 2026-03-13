.PHONY: run build kill

run: kill build
	swift run Zenith

build:
	swift build

kill:
	-killall Zenith 2>/dev/null || true
