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

@class FIRDigitsSession;
@protocol FIRDigitsKeychain;
@class FIRDigitsKeychainItem;

extern NSString * _Nonnull const FIRDigitsMigratorErrorDomain NS_SWIFT_NAME(DigitsMigratorErrorDomain);
extern int const FIRDigitsMigratorClearAuthErrorCode NS_SWIFT_NAME(DigitsMigratorClearAuthErrorCode);
extern NSString * _Nonnull const FIRDigitsMigratorClearAuthErrorUserIDKey NS_SWIFT_NAME(DigitsMigratorClearAuthErrorUserIDKey);

/*
 Session management abstraction
 */
NS_SWIFT_NAME(DigitsSessionStore)
@interface FIRDigitsSessionStore : NSObject
@property id<FIRDigitsKeychain> _Nonnull keychain;
/** @fn init
 @brief Please use @fn initWithKeychain: .
 */
- (instancetype _Nonnull )init NS_UNAVAILABLE;
- (instancetype _Nonnull ) initWithKeychain:(id <FIRDigitsKeychain>_Nonnull)keychain NS_DESIGNATED_INITIALIZER;
@property (NS_NONATOMIC_IOSONLY, getter=getSession, readonly, strong) FIRDigitsSession * _Nonnull session;
- (BOOL)clearSession:(NSError*_Nonnull*_Nullable)error;
@property (NS_NONATOMIC_IOSONLY, getter=getItems, readonly, copy) NSArray * _Nullable items;
- (BOOL) deleteItem:(FIRDigitsKeychainItem *_Nonnull)item error:(NSError *_Nonnull*_Nullable)error;
@end
