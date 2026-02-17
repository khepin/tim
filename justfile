project := "tim/tim.xcodeproj"
scheme := "tim"
config := "Release"
build_dir := "build"

build:
    xcodebuild -project {{project}} -scheme {{scheme}} -configuration {{config}} -derivedDataPath {{build_dir}}

install: build
    -pkill -x tim
    sleep 1
    rm -rf /Applications/tim.app
    ditto "{{build_dir}}/Build/Products/{{config}}/tim.app" /Applications/tim.app
