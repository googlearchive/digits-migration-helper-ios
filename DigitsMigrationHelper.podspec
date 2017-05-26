Pod::Spec.new do |s|
  s.name             = 'DigitsMigrationHelper'
  s.version          = '0.2.0'
  s.summary          = 'A Library for Migrating Digits Sessions to Firebase.'

  s.description      = <<-DESC
An Objective-C library for migrating Digits sessions to Firebase.
                       DESC

  s.homepage         = 'https://firebase.google.com'
  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.authors          = 'Google, Inc.'
  s.source           = { :git => 'https://github.com/firebase/digits-migration-helper-ios.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/Firebase'

  s.ios.deployment_target = '8.0'

  s.source_files = 'DigitsMigrationHelper/Classes/**/*'

  s.dependency 'JWT'
end
