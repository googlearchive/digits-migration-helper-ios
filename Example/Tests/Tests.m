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

@import XCTest;

#import <JWT/JWT.h>
#import <DigitsMigrationHelper/Migrator.h>
#import <DigitsMigrationHelper/SessionStore.h>
#import <DigitsMigrationHelper/Keychain.h>

#include "../../DigitsMigrationHelper/Classes/Session_Private.h"

@interface Tests : XCTestCase
@end

@implementation Tests


extern NSString* const FIRDigitsJWTAuthTokenKey;
extern NSString* const FIRDigitsJWTAuthTokenSecretKey;
extern NSString* const FIRDigitsJWTUserIDKey;
extern NSString* const FIRDigitsJWTPhoneNumberKey;
extern NSString* const FIRDigitsJWTEmailAddressKey;
extern NSString* const FIRDigitsJWTEmailAddressIsVerifiedKey;
extern NSString* const FIRDigitsJWTAppConsumerKey;
extern NSString* const FIRDigitsJWTAppConsumerSecret;
extern NSString* const FIRDigitsJWTFabricApiKey;

- (void)testSessionSerialization
{
    FIRDigitsSession *expected = [[FIRDigitsSession alloc] initWithAuthToken:@"token" authTokenSecret:@"secret" userID:@"1" phoneNumber:@"+1234567890" emailAddress:@"a@b.c" emailAddressIsVerified:YES];
    NSData *serialized = [NSKeyedArchiver archivedDataWithRootObject:expected];
    FIRDigitsSession *actual = [NSKeyedUnarchiver unarchiveObjectWithData:serialized];
    XCTAssertEqualObjects(actual, expected);
}

- (void)testGetItems
{
    NSString *expectedAccount = @"1";
    NSData *expectedData = [[NSData alloc] init];
    NSDate *expectedModificationDate = [NSDate date];
    NSDictionary *rawObjectWithRequiredFields = @{
                               (__bridge id)kSecAttrAccount:expectedAccount,
                               (__bridge id)kSecAttrModificationDate:expectedModificationDate,
                               (__bridge id)kSecValueData:expectedData
                               };
    id<FIRDigitsKeychain> keychain = [[FIRDigitsMockKeychain alloc] initWithItems:@[rawObjectWithRequiredFields] deleteItemResult:errSecSuccess];
    FIRDigitsSessionStore *sessionStore = [[FIRDigitsSessionStore alloc] initWithKeychain:keychain];
    FIRDigitsKeychainItem *actual = [sessionStore getItems].firstObject;

    XCTAssertEqualObjects(actual.account, expectedAccount);
    XCTAssertEqualObjects(actual.modificationDate, expectedModificationDate);
    XCTAssertEqualObjects(actual.data, expectedData);
}

- (void)testGetItemsFieldValidation
{
    NSDictionary *rawObjectWithMissingFields = @{
                                (__bridge id)kSecAttrAccount:@"1",
                                };
    id<FIRDigitsKeychain> keychain = [[FIRDigitsMockKeychain alloc] initWithItems:@[rawObjectWithMissingFields] deleteItemResult:errSecSuccess];
    FIRDigitsSessionStore *sessionStore = [[FIRDigitsSessionStore alloc] initWithKeychain:keychain];
    
    NSArray *actual = [sessionStore getItems];
    
    XCTAssertEqual(0, [actual count]);
}

- (void)testLatestSession
{
    NSDate *now = [NSDate date];
    NSTimeInterval secondsInDay = 24 * 60 * 60;
    NSDate *yesterday = [NSDate dateWithTimeInterval:-secondsInDay
                                           sinceDate:now];

    FIRDigitsSession *session1 = [[FIRDigitsSession alloc] initWithAuthToken:@"token" authTokenSecret:@"secret" userID:@"1" phoneNumber:@"+1234567890" emailAddress:@"a@b.c" emailAddressIsVerified:YES];
    FIRDigitsSession *expected = [[FIRDigitsSession alloc] initWithAuthToken:@"token" authTokenSecret:@"secret" userID:@"2" phoneNumber:@"+2345678901" emailAddress:@"b@c.d" emailAddressIsVerified:YES];
    NSData *data1 = [NSKeyedArchiver archivedDataWithRootObject:session1];
    NSData *data2 = [NSKeyedArchiver archivedDataWithRootObject:expected];

    NSArray *items = @[
  @{
      (__bridge id)kSecAttrAccount:session1.userID,
      (__bridge id)kSecAttrModificationDate:yesterday,
      (__bridge id)kSecValueData:data1
      },
  @{
      (__bridge id)kSecAttrAccount:expected.userID,
      (__bridge id)kSecAttrModificationDate:now,
      (__bridge id)kSecValueData:data2
      }
  ];

    id<FIRDigitsKeychain> keychain = [[FIRDigitsMockKeychain alloc] initWithItems:items deleteItemResult:errSecSuccess];
    FIRDigitsSessionStore *sessionStore = [[FIRDigitsSessionStore alloc] initWithKeychain:keychain];
    FIRDigitsSession *actual = [sessionStore getSession];

    XCTAssertEqualObjects(actual, expected);
}

- (void)testSessionToJWT
{
    FIRDigitsSession *session = [[FIRDigitsSession alloc] initWithAuthToken:@"token" authTokenSecret:@"secret" userID:@"1" phoneNumber:@"+1234567890" emailAddress:@"a@b.c" emailAddressIsVerified:YES];
    
    NSString * consumerKey = @"consumer key";
    NSString * consumerSecrete = @"consumer secret";
    NSString * fabricApiKey = @"fabric Api key";
    
    
    NSString *encoded = [FIRDigitsSession toCustomSignInJWT:session
                                         withAppConsumerKey:consumerKey
                                      withAppConsumerSecret:consumerSecrete
                                           withFabricApiKey:fabricApiKey];
    NSDictionary *actual = [JWTBuilder decodeMessage:encoded].algorithmName(@"none").decode[@"payload"];
    NSDictionary *expected =  @{
                               FIRDigitsJWTAuthTokenKey:session.authToken,
                               FIRDigitsJWTAuthTokenSecretKey:session.authTokenSecret,
                               FIRDigitsJWTUserIDKey:session.userID,
                               FIRDigitsJWTPhoneNumberKey:session.phoneNumber,
                               FIRDigitsJWTEmailAddressKey:session.emailAddress,
                               FIRDigitsJWTEmailAddressIsVerifiedKey:@(session.emailAddressIsVerified),
                               FIRDigitsJWTAppConsumerKey:consumerKey,
                               FIRDigitsJWTAppConsumerSecret:consumerSecrete,
                               FIRDigitsJWTFabricApiKey: fabricApiKey};

    XCTAssertEqualObjects(actual, expected);
}

- (void)testClearSession
{
    FIRDigitsSession *expected = [[FIRDigitsSession alloc] initWithAuthToken:@"token" authTokenSecret:@"secret" userID:@"1" phoneNumber:@"+1234567890" emailAddress:@"a@b.c" emailAddressIsVerified:YES];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:expected];
    NSDate *now = [NSDate date];
    NSArray *items = @[@{
                           (__bridge id)kSecAttrAccount:expected.userID,
                           (__bridge id)kSecAttrModificationDate:now,
                           (__bridge id)kSecValueData:data
                           }];
    id<FIRDigitsKeychain> keychain = [[FIRDigitsMockKeychain alloc] initWithItems:items deleteItemResult:errSecSuccess];
    FIRDigitsSessionStore *sessionStore = [[FIRDigitsSessionStore alloc] initWithKeychain:keychain];
    NSError *error;
    BOOL actual = [sessionStore clearSession:&error];
    XCTAssertTrue(actual);
    XCTAssertNil(error);
}

- (void)testClearSessionFailure
{
    NSString *userID = @"1";
    FIRDigitsSession *session = [[FIRDigitsSession alloc] initWithAuthToken:@"token" authTokenSecret:@"secret" userID:userID phoneNumber:@"+1234567890" emailAddress:@"a@b.c" emailAddressIsVerified:YES];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:session];
    NSDate *now = [NSDate date];
    NSArray *items = @[@{
                           (__bridge id)kSecAttrAccount:session.userID,
                           (__bridge id)kSecAttrModificationDate:now,
                           (__bridge id)kSecValueData:data
                           }];
    id<FIRDigitsKeychain> keychain = [[FIRDigitsMockKeychain alloc] initWithItems:items deleteItemResult:errSecInternalComponent];
    FIRDigitsSessionStore *sessionStore = [[FIRDigitsSessionStore alloc] initWithKeychain:keychain];
    NSError *actualError = nil;
    NSError *expected = [NSError errorWithDomain:FIRDigitsMigratorErrorDomain
                                         code:FIRDigitsMigratorClearAuthErrorCode
                                     userInfo:@{FIRDigitsMigratorClearAuthErrorUserIDKey: userID}];
    BOOL actualSuccess = [sessionStore clearSession:&actualError];
    XCTAssertEqualObjects(actualError, expected);
    XCTAssertFalse(actualSuccess);
}
@end

