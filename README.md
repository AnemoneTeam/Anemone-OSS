# Anemone-OSS
Open Source components from Anemone, a theming engine for iOS 7 - 10

# Compatibility

The Open Source components here are fully compatible with their respective release builds.

The current version in the repo is fully compatible with: 2.1.1-9
(For use with 2.1.1-8, disable AnemoneFonts.dylib)

# FAQ

## How to build

To build Anemone, you need [theos](https://github.com/theos/theos) and a reasonably up-to-date iOS SDK.
Anemone is currently built with the iOS 9.3 SDK, although the 10.2 SDK also works.

## Adding header files

Header files that are not part of the iOS SDK should be added to the common/ folder.

## Code contribution policies

Code contributed to Anemone should be formatted reasonably well according to Objective-C conventions.

If your code change is not relevant to any of the existing files' names, please create a new file. Do not throw everything into one file.

To contribute, fork the repository, push your changes and submit a pull request for review.

## Can I use this code in my project?

Sure, as long as your project is open source and the license is compatible with the GNU GPLv3.

## Why isn't all the code here?

Anemone is composed of multiple components. Some are open source (and are available here), while others are closed source.

More components will be posted as they are open sourced.

## Do I need to use Cydia Substrate to run Anemone?

No. Although the public release build of Anemone requires Cydia Substrate, Anemone can be built to use [fishhook](https://github.com/facebook/fishhook) instead.

To build Anemone without substrate dependencies, set "NO_SUBSTRATE=1"

## Do I need RocketBootstrap to run Anemone?

No. Although the public release build of Anemone with Optitheme enabled requires RocketBootStrap, Anemone can run in slower, fallback mode instead.

To build Anemone without rocketbootstrap dependencies, set "NO_OPTITHEME=1"

## Can I build for the iOS Simulator?

Yes, Anemone builds and runs for the iOS simulator. Simply compile Anemone with the flags "NO_SUBSTRATE=1 NO_OPTITHEME=1" to disable substrate and rocketbootstrap for the simulator (since they're not available there).

Anemone can then be loaded using [simject](https://github.com/angelXwind/simject)
