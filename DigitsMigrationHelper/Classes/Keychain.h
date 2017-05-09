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
#import "KeychainItem.h"

/*
 Keychain global state abstraction
 */
NS_SWIFT_NAME(DigitsKeychain)
@protocol FIRDigitsKeychain <NSObject>
- (NSArray*_Nullable) getItems:(NSDictionary*_Nonnull)query;
- (OSStatus) deleteItem:(NSDictionary*_Nonnull)query;
@end

NS_SWIFT_NAME(DigitsMockKeychain)
@interface FIRDigitsMockKeychain : NSObject <FIRDigitsKeychain>
@property NSArray * _Nonnull items;
@property OSStatus deleteItemResult;
/** @fn init
 @brief Please use @fn initWithItems:deleteItemResult: .
 */
- (instancetype _Nonnull )init NS_UNAVAILABLE;
- (instancetype _Nonnull ) initWithItems:(NSArray*_Nonnull)items deleteItemResult:(OSStatus)deleteItemResult NS_DESIGNATED_INITIALIZER;
@end

NS_SWIFT_NAME(DigitsProdKeychain)
@interface FIRDigitsProdKeychain : NSObject <FIRDigitsKeychain>
@end

