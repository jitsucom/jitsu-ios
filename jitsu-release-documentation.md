## How to release a new version?

### In Cocoapods
1) Go to Jitsu repo and add a new release with the new app version. 
2) Go to  `Jitsu.podspec`, and change `spec.version` to the new release version.
3) Push new version to Cocoapods trunk https://guides.cocoapods.org/making/getting-setup-with-trunk

To add contributor use `$ pod trunk add-owner EMAIL`. 
At the time being leosilver@yandex.ru is the person who can add contributors.

### In Carthage
