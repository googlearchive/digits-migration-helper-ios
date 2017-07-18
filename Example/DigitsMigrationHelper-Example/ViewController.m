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

#import "ViewController.h"
#import <DigitsKit/DigitsKit.h>

#import <DigitsMigrationHelper/Migrator.h>
#import <Firebase/Firebase.h>

@interface ViewController ()
@property(strong, nonatomic) FIRAuthStateDidChangeListenerHandle handleAuthStateDidChange;
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  DGTAuthenticateButton *authButton;
  authButton = [DGTAuthenticateButton buttonWithAuthenticationCompletion:^(DGTSession *session, NSError *error) {
    if (session.userID) {
      // TODO: associate the session userID with your user model
      NSString *msg = [NSString stringWithFormat:@"Phone number: %@", session.phoneNumber];
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You are logged in!"
                                                      message:msg
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
      [alert show];
    } else if (error) {
      NSLog(@"Authentication error: %@", error.localizedDescription);
    }
  }];
  authButton.center = self.view.center;
  [self.view addSubview:authButton];

  self.handleAuthStateDidChange = [[FIRAuth auth] addAuthStateDidChangeListener:^(FIRAuth *_Nonnull auth, FIRUser *_Nullable user) {
    NSLog(@"user=%@", user);
  }];
}

- (IBAction)convertDigitsUserClicked:(id)sender {
  NSLog(@"Going to convert digits user");

  NSDictionary *creds = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"creds" ofType:@"plist"]];
  NSString *key = creds[@"consumerKey"];
  NSString *secret = creds[@"consumerSecret"];

  // [START convert_digits_user]
  FIRDigitsMigrator *migrator = [[FIRDigitsMigrator alloc] initWithDigitsAppConsumerKey:key
                                                            withDigitsAppConsumerSecret:secret];

  [migrator getLegacyAuth:^(NSString *customSignInToken, FIRDigitsSession *session){
    if (customSignInToken) {
      NSLog(@"Legacy digits session detected: token=%@, session=%@", customSignInToken, [FIRDigitsSession describe:session]);

      [[FIRAuth auth] signInWithCustomToken:customSignInToken
                                 completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
        NSLog(@"signInWithCustomToken, user=%@, error=%@", user, error);
        if (!error) {
          NSString *msg = [NSString stringWithFormat:@"Converted to firebase user with id as %@", user.uid];
          // [START_EXCLUDE silent]
          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Conversion was successful!"
                                                          message:msg
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
          [alert show];
          // [END_EXCLUDE]

          [migrator clearLegacyAuth:^(BOOL success, NSError * _Nullable error){
            NSLog(@"clearLegacyAuth, success=%d, error=%@", success, error);
          }];
        }
      }];
    } else {
      NSLog(@"No legacy digits session detected");
      // [START_EXCLUDE]
      NSString *msg = @"Digits session not exist yet. Log into digits first to proceed.";
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No digits session!"
                                                      message:msg
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
      [alert show];
      // [END_EXCLUDE]
    }
  }];
  // [END convert_digits_user]
}

- (void)viewWillDisappear:(BOOL)animated {
  [[FIRAuth auth] removeAuthStateDidChangeListener:_handleAuthStateDidChange];
}

@end
