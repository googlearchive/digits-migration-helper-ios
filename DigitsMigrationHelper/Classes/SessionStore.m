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

#import "SessionStore.h"
#import "Session.h"
#import "Keychain.h"
#import "KeychainItem.h"

NSString * const serviceName = @"api.digits.api-service.user-session-store-service-name";
NSString *const FIRDigitsMigratorErrorDomain = @"FIRDigitsMigrator";
int const FIRDigitsMigratorClearAuthErrorCode = 1;
NSString *const FIRDigitsMigratorClearAuthErrorUserIDKey = @"userID";

@implementation FIRDigitsSessionStore

- (instancetype)initWithKeychain:(id<FIRDigitsKeychain>)keychain {
  self = [super init];
  if (self) {
      _keychain = keychain;

      // Map old archived DGTSession data into new FIRDigitsSession data
      static dispatch_once_t onceToken = 0;
      dispatch_once(&onceToken, ^{
          [NSKeyedUnarchiver setClass:[FIRDigitsSession class] forClassName:@"DGTSession"];
      });
  }
  return self;
}

#pragma mark - Session methods

- (FIRDigitsSession*) getSession {
  NSArray *unsorted = [self getItems];
  NSArray *sorted = [self sortKeychainItemsByDate:unsorted];
  FIRDigitsKeychainItem *latest = sorted.lastObject;

  if (latest) {
    return [NSKeyedUnarchiver unarchiveObjectWithData:latest.data];
  } else {
    return nil;
  }
}

- (NSArray *) sortKeychainItemsByDate:(NSArray *)unsorted {
  NSArray *sorted = [unsorted sortedArrayUsingComparator:^NSComparisonResult(FIRDigitsKeychainItem *obj1, FIRDigitsKeychainItem *obj2) {
    return [obj1.modificationDate compare:obj2.modificationDate];
  }];
  return sorted;
}

- (BOOL)clearSession:(NSError * __autoreleasing *)error{
  NSArray *items = [self getItems];
  BOOL success = YES;
  for (FIRDigitsKeychainItem *item in items) {
    success = success && [self deleteItem:item error:error];
  }
  return success;
}

#pragma mark - Keychain methods

- (NSArray*) getItems {
  NSDictionary *query = @{
                          (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                          (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitAll,
                          (__bridge id)kSecReturnData: (__bridge id)kCFBooleanTrue,
                          (__bridge id)kSecReturnAttributes: (__bridge id)kCFBooleanTrue,
                          (__bridge id)kSecAttrService: serviceName,
                          };

  NSArray *rawObjects = [_keychain getItems:query];

  NSMutableArray *objects = [NSMutableArray array];
  for (NSDictionary *rawObject in rawObjects) {
    NSString *account = rawObject[(__bridge id)kSecAttrAccount];
    NSDate *modificationDate = rawObject[(__bridge id)kSecAttrModificationDate];
    NSData *data = rawObject[(__bridge id)kSecValueData];
    if (account && modificationDate && data) {
      FIRDigitsKeychainItem *item = [[FIRDigitsKeychainItem alloc] initWithAccount:account data:data modificationDate:modificationDate];
      [objects addObject:item];
    }
  }

  return objects;
}

- (BOOL) deleteItem:(FIRDigitsKeychainItem *)item error:(NSError **)error {
  NSDictionary *query = @{
                          (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                          (__bridge id)kSecAttrService: serviceName,
                          (__bridge id)kSecAttrAccount: item.account,
                          };
  OSStatus status = [_keychain deleteItem:query];

  if (status != errSecSuccess && status != errSecItemNotFound) {
    *error = [NSError errorWithDomain:FIRDigitsMigratorErrorDomain
                                 code:FIRDigitsMigratorClearAuthErrorCode
                             userInfo:@{FIRDigitsMigratorClearAuthErrorUserIDKey: item.account}];
    return NO;
  } else {
    return YES;
  }
}

@end
