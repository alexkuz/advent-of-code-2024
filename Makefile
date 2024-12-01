.PHONY: test
test:
	cd zig && zig test src/day$(day).zig

.PHONY: run
run:
	cd zig && zig build run

.PHONY: release
release:
	cd zig && zig build run -Doptimize=ReleaseFast

.PHONY: screenshot
screenshot:
	cd zig && zig build -Doptimize=ReleaseFast && ../bin/termshot -f ../zig-screenshot.png -- ./zig-out/bin/advent2024
