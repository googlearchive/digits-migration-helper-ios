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

/*
 Keychain data convenience class
 */
NS_SWIFT_NAME(DigitsKeychainItem)
@interface FIRDigitsKeychainItem : NSObject
@property (nonatomic, copy, readonly) NSString * _Nonnull account;
@property (nonatomic, copy, readonly) NSData * _Nonnull data;
@property (nonatomic, copy, readonly, nullable) NSDate *modificationDate;
/** @fn init
 @brief Please use @fn initWithAccount:data:modificationDate: .
 */
- (instancetype _Nonnull )init NS_UNAVAILABLE;
- (instancetype _Nonnull ) initWithAccount:(NSString*_Nonnull)account data:(NSData*_Nonnull)data modificationDate:(nullable NSDate *)modificationDate NS_DESIGNATED_INITIALIZER;
@end
