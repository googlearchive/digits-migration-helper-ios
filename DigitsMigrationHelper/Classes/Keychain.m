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

#import "Keychain.h"
#import "KeychainItem.h"

@implementation FIRDigitsMockKeychain
- (instancetype) initWithItems:(NSArray*)items deleteItemResult:(OSStatus)deleteItemResult {
  self = [super init];
  if (self) {
    _items = items;
    _deleteItemResult = deleteItemResult;
  }
  return self;
}

- (NSArray *)getItems:(NSDictionary *)query {
  return _items;
}

- (OSStatus)deleteItem:(NSDictionary *)query {
  return _deleteItemResult;
}
@end

@implementation FIRDigitsProdKeychain
- (NSArray *)getItems:(NSDictionary *)query {
  CFTypeRef cfResponse = NULL;
  SecItemCopyMatching((__bridge CFDictionaryRef)query, &cfResponse);
  return CFBridgingRelease(cfResponse);
}

- (OSStatus)deleteItem:(NSDictionary *)query {
  return SecItemDelete((__bridge CFDictionaryRef)query);
}
@end
