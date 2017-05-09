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

#import "Migrator.h"
#import "Keychain.h"
#import "KeychainItem.h"
#import "Session.h"
#import "Session_Private.h"
#import "SessionStore.h"


// actual value for fabric api key in the token does not matter. But
// we need its presence to make it work.
NSString* const FABRIC_API_KEY_IN_CUSTOM_TOKEN = @"Fabric Api Key";

@interface FIRDigitsMigrator()
@property (readonly) FIRDigitsSessionStore *sessionStore;
@property (readonly, copy) NSString *digitsAppConsumerKey;
@property (readonly, copy) NSString *digitsAppConsumerSecret;
@end

@interface Digits
+ (Digits *)sharedInstance;
- (void)logOut;
@end

@implementation FIRDigitsMigrator

- (instancetype) initWithDigitsAppConsumerKey:(NSString *) digitsAppConsumerKey
                  withDigitsAppConsumerSecret:(NSString *) digitsAppConsumerSecret {
  self = [super init];
  if (self) {
    _digitsAppConsumerKey = digitsAppConsumerKey;
    _digitsAppConsumerSecret = digitsAppConsumerSecret;
    id<FIRDigitsKeychain> keychain = [[FIRDigitsProdKeychain alloc] init];
    _sessionStore = [[FIRDigitsSessionStore alloc] initWithKeychain:keychain];
  }

  return self;
}

- (void) getLegacyAuth:(void (^)(NSString *customSignInToken, FIRDigitsSession * _Nullable session))completion {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    FIRDigitsSession *session = [_sessionStore getSession];
    NSString *token = nil;

    if (session) {
      token = [FIRDigitsSession toCustomSignInJWT:session
                               withAppConsumerKey:_digitsAppConsumerKey
                            withAppConsumerSecret:_digitsAppConsumerSecret
                                 withFabricApiKey:FABRIC_API_KEY_IN_CUSTOM_TOKEN];
      }
      dispatch_async(dispatch_get_main_queue(), ^{
        completion(token, session);
      });
  });
}

- (void) clearLegacyAuth:(void (^)(BOOL success, NSError * _Nullable error))completion {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    id digitsClass = NSClassFromString(@"Digits");
    // if we are able to detect the existance of Digits class at runtime, we will do a Digits signout
    // to better force the erasure of the digits session
    if (digitsClass && [digitsClass respondsToSelector:@selector(sharedInstance)]) {
      NSLog(@"Digits class found and it responds to shared Instance");
      id digitsInstance = [digitsClass sharedInstance];
      if ([digitsInstance respondsToSelector:@selector(logOut)]) {
        [digitsInstance logOut];
      }
    }

    NSError *error;
    BOOL success = [_sessionStore clearSession:&error];
    dispatch_async(dispatch_get_main_queue(), ^{
      completion(success, error);
    });
  });
}

@end
