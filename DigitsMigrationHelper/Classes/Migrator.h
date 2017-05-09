//
//  Copyright (c) 2017 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <Foundation/Foundation.h>
#import "Session.h"

/**
 @class FIRDigitsMigrator
 @brief A helper class for fetching digits session info and produce a
        Firebase custom token that can be used for sign-in with firebase
        auth.
  */
NS_SWIFT_NAME(DigitsMigrator)
@interface FIRDigitsMigrator : NSObject

/** @fn init
    @brief Please use @fn initWithDigitsAppConsumerKey: .
 */
- (instancetype _Nonnull )init NS_UNAVAILABLE;

/** @fn initWithDigitsAppConsumerKey
    @brief initialize FIRDigitsMigrator with digits' app consumer key and consumer secret
 */
- (instancetype _Nonnull ) initWithDigitsAppConsumerKey:(NSString * _Nonnull) digitsAppConsumerKey
                  withDigitsAppConsumerSecret:(NSString * _Nonnull) digitsAppConsumerSecret NS_DESIGNATED_INITIALIZER;

/** @fn getLegacyAuth:
    @brief Called to fetch digits session for the current app and report the result via
     a callback
    @param completion The callback that's triggered when the retrival is done. If the retrieval
        is successful, customSignInToken in the callback will be a token that can be used to
        trigger custom sign-in with Firebase Auth and session parameter contains detailed info
        of the found session. If retrieval fails, both customSignInToken and session will be null.
 */
- (void) getLegacyAuth:(void  (^ _Nonnull)(NSString * _Nullable customSignInToken, FIRDigitsSession * _Nullable session))completion;

/** @fn clearLegacyAuth:
    @brief Called to remove the digits session data from the current app. Your app would normally do this
     after successfully finishing the token conversion with Firebase and no longer needs the digits
     session any more.
    @param completion The callback that's triggered when the operation is done.
 */
- (void) clearLegacyAuth:(void (^ _Nonnull)(BOOL success, NSError * _Nullable error))completion;
@end
