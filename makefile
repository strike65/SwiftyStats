UNAME=$(shell uname)
ifeq ($(UNAME), Darwin)
	PLATFORM = x86_64-apple-macosx10.10
	LIBRARY_DIRECTORY = ./.build/${PLATFORM}/debug
	TEST_RESOURCE_DIRECTORY = ./.build/${PLATFORM}/>SwiftyStatsPackageTests.xctest/Contents/Resources
else ifeq ($(UNAME), Linux)
	PLATFORM = x86_64-unknown-linux
	LIBRARY_DIRECTORY = ./.build/${PLATFORM}/debug
	TEST_RESOURCE_DIRECTORY = ${LIBRARY_DIRECTORY}
endif

TEST_RESOURCES_DIRECTORY = ${LIBRARY_DIRECTORY}

build:
		swift build

copyTestResources:
		mkdir -p ${TEST_RESOURCES_DIRECTORY}
		cp SwiftyStats/Resources/* ${TEST_RESOURCES_DIRECTORY}

test: copyTestResources
		swift test

clean:
		rm -rf .build

.PHONY: build test copyTestResources clean


