#  Created by Tanaka Hiroshi on 2024/10/11.
P=$(PWD)
cd $P
# cd ~/Documents/SwiftUI_app/MAIN
time xcodebuild -target AltCP -configuration Release -scheme AltCP archive -archivePath ./build/build

afplay /System/Library/Sounds/Ping.aiff
