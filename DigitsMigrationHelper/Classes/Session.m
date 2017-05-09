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

#import "Session.h"
#import "Session_Private.h"

@import JWT;


NSString* const FIRDigitsSessionAuthTokenKey = @"auth_token";
NSString* const FIRDigitsSessionAuthTokenSecretKey = @"auth_token_secret";
NSString* const FIRDigitsSessionUserIDKey = @"user_id";
NSString* const FIRDigitsSessionPhoneNumberKey = @"phone_number";
NSString* const FIRDigitsSessionEmailAddressKey = @"email_address";
NSString* const FIRDigitsSessionEmailAddressIsVerifiedKey = @"email_address_is_verified";


NSString* const FIRDigitsJWTAuthTokenKey = @"auth_token";
NSString* const FIRDigitsJWTAuthTokenSecretKey = @"auth_token_secret";
NSString* const FIRDigitsJWTUserIDKey = @"id";
NSString* const FIRDigitsJWTPhoneNumberKey = @"phone_number";
NSString* const FIRDigitsJWTEmailAddressKey = @"email_address";
NSString* const FIRDigitsJWTEmailAddressIsVerifiedKey = @"email_address_is_verified";
NSString* const FIRDigitsJWTAppConsumerKey = @"app_consumer_key";
NSString* const FIRDigitsJWTAppConsumerSecret = @"app_consumer_secret";
NSString* const FIRDigitsJWTFabricApiKey = @"fabric_api_key";


@implementation FIRDigitsSession

- (instancetype)initWithAuthToken:(NSString *)authToken
                  authTokenSecret:(NSString *)authTokenSecret
                           userID:(NSString *)userID
                      phoneNumber:(NSString *)phoneNumber
                     emailAddress:(NSString *)emailAddress
           emailAddressIsVerified:(BOOL)emailAddressIsVerified {
  if (self = [super init]) {
    _authToken = [authToken copy];
    _authTokenSecret = [authTokenSecret copy];
    _userID = [userID copy];
    _phoneNumber = [phoneNumber copy];
    _emailAddress = [emailAddress copy];
    _emailAddressIsVerified = emailAddressIsVerified;
  }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  if (self = [super init]) {
    _authToken = [aDecoder decodeObjectForKey:FIRDigitsSessionAuthTokenKey];
    _authTokenSecret = [aDecoder decodeObjectForKey:FIRDigitsSessionAuthTokenSecretKey];
    _userID = [aDecoder decodeObjectForKey:FIRDigitsSessionUserIDKey];
    _phoneNumber = [aDecoder decodeObjectForKey:FIRDigitsSessionPhoneNumberKey];
    _emailAddress = [aDecoder decodeObjectForKey:FIRDigitsSessionEmailAddressKey];
    _emailAddressIsVerified = [aDecoder decodeBoolForKey:FIRDigitsSessionEmailAddressIsVerifiedKey];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:self.authToken forKey:FIRDigitsSessionAuthTokenKey];
  [aCoder encodeObject:self.authTokenSecret forKey:FIRDigitsSessionAuthTokenSecretKey];
  [aCoder encodeObject:self.userID forKey:FIRDigitsSessionUserIDKey];
  [aCoder encodeObject:self.phoneNumber forKey:FIRDigitsSessionPhoneNumberKey];
  [aCoder encodeObject:self.emailAddress forKey:FIRDigitsSessionEmailAddressKey];
  [aCoder encodeBool:self.emailAddressIsVerified forKey:FIRDigitsSessionEmailAddressIsVerifiedKey];
}


- (BOOL)isEqual:(id)other {
  if (other == self) {
    return YES;
  } else if ([other isKindOfClass:[FIRDigitsSession class]]) {
    FIRDigitsSession *otherSession = (FIRDigitsSession *)other;
    return [self.userID isEqualToString:otherSession.userID];
  } else {
    return NO;
  }
}

- (NSUInteger)hash {
  return (self.userID).hash;
}

+ (NSString*)toCustomSignInJWT:(FIRDigitsSession*)session
            withAppConsumerKey:(NSString *)appConsumerKey
         withAppConsumerSecret:(NSString *)appConsumerSecret
              withFabricApiKey:(NSString *)fabricApiKey {
  NSMutableDictionary *payload = [@{
                                    FIRDigitsJWTAuthTokenKey: session.authToken,
                                    FIRDigitsJWTAuthTokenSecretKey: session.authTokenSecret,
                                    FIRDigitsJWTUserIDKey: session.userID,
                                    FIRDigitsJWTPhoneNumberKey: session.phoneNumber,
                                    FIRDigitsJWTAppConsumerKey: appConsumerKey,
                                    FIRDigitsJWTAppConsumerSecret: appConsumerSecret,
                                    FIRDigitsJWTFabricApiKey: fabricApiKey
                                    } mutableCopy];
  if (session.emailAddress) {
    payload[FIRDigitsJWTEmailAddressKey] = session.emailAddress;
    payload[FIRDigitsJWTEmailAddressIsVerifiedKey] = @(session.emailAddressIsVerified);
  }

  id<JWTAlgorithm> algorithm = [JWTAlgorithmFactory algorithmByName:@"none"];
  return [JWTBuilder encodePayload:payload].algorithm(algorithm).encode;
}

+ (NSString *)describe:(FIRDigitsSession*)session {
  return [NSString stringWithFormat: @"FIRDigitsSession: authToken=%@ authTokenSecret=%@ userID=%@ phoneNumber=%@ emailAddress=%@ emailAddressIsVerified=%@", session.authToken, session.authTokenSecret, session.userID, session.phoneNumber, session.emailAddress, session.emailAddressIsVerified?@"true":@"false"];
}

@end
