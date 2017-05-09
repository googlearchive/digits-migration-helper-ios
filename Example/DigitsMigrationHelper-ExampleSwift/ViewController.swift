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

import UIKit
import DigitsMigrationHelper
import Firebase
import DigitsKit

class ViewController: UIViewController {

  var handleAuthStateDidChange: AuthStateDidChangeListenerHandle?

  override func viewDidLoad() {
    super.viewDidLoad()
    let authButton = DGTAuthenticateButton.init { (session, error) in
      if let error = error {
        print("Authentication error: \(error.localizedDescription)")
      }
      if let session = session {
        // TODO: associate the session userID with your user model
        let msg = "Phone number: \(session.phoneNumber)"
        let alert = UIAlertView.init(title: "You are logged in!", message: msg, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
      }
    }
    view.addSubview(authButton!)

    handleAuthStateDidChange = Auth.auth().addStateDidChangeListener({ (auth, user) in
      print("user=\(String(describing: user))")
    })
  }

  @IBAction func convertDigitsUserClicked(sender: Any) {
    print("Going to convert digits user")

    let creds = NSDictionary.init(contentsOfFile: Bundle.main.path(forResource: "creds", ofType: "plist")!)
    let key = creds?["consumerKey"]
    let secret = creds?["consumerSecret"]

    // [START convert_digits_user]
    let migrator = DigitsMigrator.init(digitsAppConsumerKey: key as! String, withDigitsAppConsumerSecret: secret as! String)

    migrator.getLegacyAuth { (customSignInToken, session) in
      if let customSignInToken = customSignInToken {
        print("Legacy digits session detected: token=\(customSignInToken), session=\(DigitsSession.describe(session))")

        Auth.auth().signIn(withCustomToken: customSignInToken) { (user, error) in
          if let error = error {
            print("signInWithCustomToken, user=\(String(describing: user)), error=\(error)")
            return
          }

          // [START_EXCLUDE silent]
          let msg = "Converted to firebase user with id as \(user?.uid ?? "")"
          let alert = UIAlertView.init(title: "Conversion was successful!", message: msg, delegate: nil, cancelButtonTitle: "OK")
          alert.show()
          // [END_EXCLUDE]
          migrator.clearLegacyAuth { (success, error) in
            print("clearLegacyAuth, success=\(success), error=\(error?.localizedDescription ?? "")")
          }
        }
      }
    }
    // [END convert_digits_user]
  }

  override func viewDidDisappear(_ animated: Bool) {
    guard let handleAuthStateDidChange = handleAuthStateDidChange else { return }
    Auth.auth().removeStateDidChangeListener(handleAuthStateDidChange)
  }

}

