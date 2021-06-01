XCODEGEN_CACHE_PATH := ./.xcodegen/cache

.PHONY: xcodegen
xcodegen:
	mint run xcodegen --spec ./project.yml --use-cache --cache-path $(XCODEGEN_CACHE_PATH)

xcodegen_clear:
	rm $(XCODEGEN_CACHE_PATH)

xcodegen_force: xcodegen_clear xcodegen

