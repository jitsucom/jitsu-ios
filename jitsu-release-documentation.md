## How to release a new version?

### In Cocoapods
1) Go to Jitsu repo and add a new release with the new app version. 
2) Go to  `Jitsu.podspec`, and change `spec.version` to the new release version.
3) Push new version to Cocoapods trunk https://guides.cocoapods.org/making/getting-setup-with-trunk

To add contributor use `$ pod trunk add-owner EMAIL`. 
At the time being leosilver@yandex.ru is the person who can add contributors.

To use updated SDK in your project, update its version in the podfile, then use `pod install --repo-update`.

### In Carthage
If you have already made a release of new version in Jitsu repo, then you are all set.

Update version in cartfile, then run `carthage update --use-xcframeworks`.
If you have any issues with Carthage, check https://github.com/Carthage/Carthage#supporting-carthage-for-your-framework for help.


### In Swift Package Manager
