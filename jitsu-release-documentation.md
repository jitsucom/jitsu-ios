## How to release a new version?


### In Cocoapods

#### Release version
1) Go to Jitsu repo and add a new release with the new app version. 
2) Go to  `Jitsu.podspec`, and change `spec.version` to the new release version.
3) Run `pod trunk push [Jitsu.podspec]` to push Jitsu to Cocoapods trunk.
More on that: https://guides.cocoapods.org/making/getting-setup-with-trunk

To add contributor use `$ pod trunk add-owner EMAIL`. 
At the time being leosilver@yandex.ru is the person who can add contributors.

#### To use updated SDK in your project
Update its version in the podfile, then use `pod install --repo-update`.


### In Carthage

#### Release version
If you have already made a release of new version in Jitsu repo, then you are all set.

If you have any issues with Carthage, check https://github.com/Carthage/Carthage#supporting-carthage-for-your-framework for help.

#### To use updated SDK in your project
Update version in cartfile, then run `carthage update --use-xcframeworks`.


### In Swift Package Manager

#### Release version
If you have already made a release of new version in Jitsu repo, then you are all set.

#### To use updated SDK in your project
You can update to the latest version of any packages you depend on at any time by selecting File ▸ Swift Packages ▸ Update to Latest Package Versions.



## Core Data
Managed Object Model is created manually. This means no UI is used to generate and describe core data entities. 
Entities are described in classes ending with "MO" (BatchMO, EnrichedEventMO, etc).

To create a new entity add its description to CoreDataStack class


