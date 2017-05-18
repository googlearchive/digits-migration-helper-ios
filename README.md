# DigitsMigrationHelper

An Objective-C library for migrating Digits sessions to Firebase.

[![Build Status](https://travis-ci.org/firebase/digits-migration-helper-ios.svg?branch=master)](https://travis-ci.org/firebase/digits-migration-helper-ios)
[![Version](https://img.shields.io/cocoapods/v/DigitsMigrationHelper.svg?style=flat)](http://cocoapods.org/pods/DigitsMigrationHelper)
[![License](https://img.shields.io/cocoapods/l/DigitsMigrationHelper.svg?style=flat)](http://cocoapods.org/pods/DigitsMigrationHelper)
[![Platform](https://img.shields.io/cocoapods/p/DigitsMigrationHelper.svg?style=flat)](http://cocoapods.org/pods/DigitsMigrationHelper)


## Requirements

Before using this code, you must add the Firebase/Auth modules to your project:
https://firebase.google.com/docs/auth/ios/start

## Installation

### Install DigitsMigrationHelper

DigitsMigrationHelper is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
use_frameworks!
pod "DigitsMigrationHelper"
```

### Create DigitsMigrationHelper instance

Initialize a FIRDigitsMigrator object with the legacy Digits app consumer key and app consumer secret.
```objective-c
@import DigitsMigrationHelper;
...
FIRDigitsMigrator *migrator = [[FIRDigitsMigrator alloc] initWithDigitsAppConsumerKey:@"consumer_key"
                                                          withDigitsAppConsumerSecret:@"consumer_secret";
```
```swift
import DigitsMigrationHelper
...
let migrator = DigitsMigrator.init(digitsAppConsumerKey: "consumer_key",
    withDigitsAppConsumerSecret: @"consumer_secret")
```
### Exchange Digits session for a Firebase Auth session

This step is to use getLegacyAuth from FIRDigitsMigrator object to detect existing Digits session. If it's successful, a Firebase custom signin token is returned and the app can use it to signin (https://firebase.google.com/docs/auth/ios/custom-auth) with Firebase Auth to get a Firebase Auth session in return. If no Digits session is detected for the current app, then the token would be nil.

```objective-c
@import DigitsMigrationHelper;
@import Firebase;
...
[migrator getLegacyAuth:^(NSString *customSignInToken, FIRDigitsSession *session){
    if (customSignInToken) {
        [[FIRAuth auth] signInWithCustomToken:customSignInToken
                                   completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
                                       if (!error) {
                                           [migrator clearLegacyAuth:^(BOOL success, NSError * _Nullable error){
                                               NSLog(@"clearLegacyAuth, success=%d, error=%@", success, error);
                                           }];
                                       }
                                   }];
    }
}];
```
```swift
import DigitsMigrationHelper
import Firebase
...
migrator?.getLegacyAuth { (customSignInToken, session) in
  if let customSignInToken = customSignInToken {
    Auth.auth().signIn(withCustomToken: customSignInToken) { (user, error) in
      if let error = error {
        return
      }
      migrator?.clearLegacyAuth { (success, error) in
        print("clearLegacyAuth, success=\(success), error=\(error?.localizedDescription ?? "")")
      }
    }
  }
}
```
Notice that in the above sample code, if the sign-in with Firebase Auth is successful, it triggers clearLegacyAuth method from FIRDigitsMigrator. This is to clean up the Digits session from the app since it has already been converted into a Firebase auth session

### Remove legacy Digits SDK

We recommend  that during your development, first doing the above code change with your existing digits app with Digits SDK still included so that you can repeatedly test the conversion flow by relogging with Digits. Once you are fully done with the development and testing, you can now remove Digits SDK dependency from your newer version of the app to be shipped to end users.

### Other Considerations

* When to trigger the conversion logic.
  
  A common choice is to trigger that in AppDelete's application:didFinishLaunchingWithOptions: method. It's also possible to do that in other places that you feel suitable for your app.

* Persist the conversion result to avoid triggering it again.
  
  Once the conversion has been successfully done, your app could choose to remember this fact and avoid triggering the same token retrieval logic again (since it has performance panelty of reading from keychain). You can also make such a decision based on whether an existing Firebase auth session exists for the current app.
 
* What if the token is not found or the token conversion failure.
  
  In case the users already logged out of the session or the token has been revoked for various reasons, the getLegacyAuth or signInWithCustomToken call would fail with no positive result. In this case, you can launch your app's normal phone auth UI to have the user to go through the flow to get signed in.

## Example Project

To run the example project, clone the repo, and run `pod install` from the Example directory first. Then prepare these two plist files int Example/DigitsMigrationHelper directory.
  1. Download your Firebase project GoogleService-Info.plist file to add it the Example directory.
  1. Replace your Fabric API key with the placeholder at Example/Example-Info.plist. You can find your key and secret by visiting your organization’s settings page in Fabric and clicking on the respective links under the organization’s name.
  1. Create another plist file called creds.plist that contains your digits app's consumer key and consumer secret under that directory. This is the example file creds.plist file content:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>consumerKey</key>
    <string>....</string>
    <key>consumerSecret</key>
    <string>....</string>
  </dict>
</plist>
```
Then you should be able to run the project. On the main view of the app, you can try out the flow of signing into digits and the conversion by clicking "Convert Digits User" button. 

## Support

If you've found an error in this sample, please file an issue.

Patches are encouraged, and may be submitted by forking this project and submitting a pull request through GitHub.

## License

Copyright 2016 Google, Inc.

Licensed to the Apache Software Foundation (ASF) under one or more contributor license agreements. See the NOTICE file distributed with this work for additional information regarding copyright ownership. The ASF licenses this file to you under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

