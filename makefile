UNAME=$(shell uname)
ifeq ($(UNAME), Darwin)
	PLATFORM = x86_64-apple-macosx10.10
	LIBRARY_DIRECTORY = ./.build/${PLATFORM}/debug
	TEST_RESOURCE_DIRECTORY = ./.build/${PLATFORM}/debug/SwiftyStatsPackageTests.xctest/Contents/Resources
else ifeq ($(UNAME), Linux)
	PLATFORM = x86_64-unknown-linux
	LIBRARY_DIRECTORY = ./.build/${PLATFORM}/debug
	TEST_RESOURCE_DIRECTORY = ${LIBRARY_DIRECTORY}
endif


# TEST_RESOURCES_DIRECTORY = ${LIBRARY_DIRECTORY}

debug:
		swift build -c debug

release:
		swift build -c release

copyTestResources:
		@echo "copying testfiles to $(TEST_RESOURCE_DIRECTORY)"
		mkdir -p ${TEST_RESOURCE_DIRECTORY}
		cp SwiftyStats/Resources/* ${TEST_RESOURCE_DIRECTORY}

test: copyTestResources
		swift test

clean:
		rm -rf .build

.PHONY: build test copyTestResources clean


