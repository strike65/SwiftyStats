UNAME=$(shell uname)
ifeq ($(UNAME), Darwin)
	PLATFORM = x86_64-apple-macosx
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
		SWIFT_MODULECACHE_PATH=.build/swift-modulecache CLANG_MODULE_CACHE_PATH=.build/clang-modulecache swift test

numerics-test: copyTestResources
		@mkdir -p TestArtifacts
		@echo "[$$(date -u +'%Y-%m-%dT%H:%M:%SZ')] make numerics-test --filter SwiftyStatsTests.SSFloatingPointTests/.* --attachments-path TestArtifacts" >> session.log
		SWIFT_MODULECACHE_PATH=.build/swift-modulecache CLANG_MODULE_CACHE_PATH=.build/clang-modulecache swift test --filter "SwiftyStatsTests.SSFloatingPointTests/.*" --attachments-path TestArtifacts

clean:
		rm -rf .build

.PHONY: build test numerics-test copyTestResources clean
