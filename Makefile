
.PHONY : log install_buck build watch message targets audit debug test xcode_tests clean project audit

# Use local version of Buck
BUCK=tools/buck.pex
JAVA11="--config java.target_level=11 --config java.source_level=11 "
export buck_root=$(shell $(BUCK) root)
export buck_out=${buck_root}/buck-out
IPHONE_SIMULATOR_NAME="iPhone 11"

carth:
	carthage update --platform iOS --use-xcframeworks

log:
	echo "Make"

install_buck:
	curl https://jitpack.io/com/github/airbnb/buck/626d201d241a051e79cbeafc63b78574b1d1e463/buck-626d201d241a051e79cbeafc63b78574b1d1e463.pex --output tools/buck
	chmod u+x tools/buck

update_cocoapods:
	pod repo update
	pod install

build:
	$(BUCK) build //App:TicTacToeApp ${JAVA11}

build_release:
	$(BUCK) build //App:TicTacToeApp --config-file ./BuildConfigurations/Release.buckconfig ${JAVA11}

watch:
	$(BUCK) build //App:ExampleWatchAppExtension#watchsimulator-i386 ${JAVA11}

message:
	$(BUCK) build //App:ExampleMessageExtension ${JAVA11}

debug:
	$(BUCK) install //App:TicTacToeApp --run --simulator-name '${IPHONE_SIMULATOR_NAME}' ${JAVA11}

debug_release:
	$(BUCK) install //App:TicTacToeApp --run --simulator-name '${IPHONE_SIMULATOR_NAME}' --config-file ./BuildConfigurations/Release.buckconfig ${JAVA11}

targets:
	$(BUCK) targets //... ${JAVA11}

ci: targets build test ui_test project xcode_tests 
	echo "Done"

test:
	@rm -f $(buck_out)/tmp/*.profraw
	@rm -f $(buck_out)/gen/*.profdata
	$(BUCK) test //App:TicTacToeAppCITests --test-runner-env XCTOOL_TEST_ENV_LLVM_PROFILE_FILE="$(buck_out)/tmp/code-%p.profraw%15x" \
		--config custom.other_cflags="\$$(config custom.code_coverage_cflags)" \
		--config custom.other_cxxflags="\$$(config custom.code_coverage_cxxflags)" \
		--config custom.other_ldflags="\$$(config custom.code_coverage_ldflags)" \
		--config custom.other_swift_compiler_flags="\$$(config custom.code_coverage_swift_compiler_flags)"
	xcrun llvm-profdata merge -sparse "$(buck_out)/tmp/code-"*.profraw -o "$(buck_out)/gen/Coverage.profdata"
	xcrun llvm-cov report "$(buck_out)/gen/App/TicTacToeAppBinary#iphonesimulator-x86_64" -instr-profile "$(buck_out)/gen/Coverage.profdata" -ignore-filename-regex "Pods|Carthage|buck-out"

# Buck requires a different test-runner to run UI tests. `fbxctest` from FBSimulatorControl has a compatible CLI invocation and can be used as a drop-in replacement for `xctool` here.
fbxctest = tools/fbxctest/bin/fbxctest
ui_test:
	# Diable UI Test for now, because it's broken on Xcode 10.2
	# $(BUCK) test //App:XCUITests --config apple.xctool_path=$(fbxctest) ${JAVA11}

audit:
	$(BUCK) audit rules App/BUCK > Config/Gen/App-BUCK.py ${JAVA11}
	$(BUCK) audit rules Pods/BUCK > Config/Gen/Pods-BUCK.py ${JAVA11}

clean:
	rm -rf **/*.xcworkspace
	rm -rf **/*.xcodeproj
	rm -rf buck-out

kill_xcode:
	killall Xcode || true
	killall Simulator || true

xcode_tests: project
	xcodebuild build test -workspace App/TicTacToeApp.xcworkspace -scheme TicTacToeApp -destination 'platform=iOS Simulator,name=${IPHONE_SIMULATOR_NAME},OS=latest' | xcpretty && exit ${PIPESTATUS[0]}

project: clean
	$(BUCK) project //App:workspace ${JAVA11}
	open App/TicTacToeApp.xcworkspace
