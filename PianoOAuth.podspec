Pod::Spec.new do |s|
  s.name         = 'PianoOAuth'
  s.version      = '2.4.0'
  s.swift_version = '5.0'
  s.summary      = 'Enables iOS apps to sign in with Piano.io'
  s.homepage     = 'https://github.com/tinypass/piano-sdk-for-ios'
  s.license      = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.author       = 'Piano Inc.'
  s.platform     = :ios, '9.0'
  s.source       = { :git => 'https://github.com/tinypass/piano-sdk-for-ios.git', :tag => "#{s.version}" }
  s.resources = "Sources/OAuth/OAuth/Resources/*.png"
  s.source_files = 'Sources/Common/*.swift', 'Sources/OAuth/OAuth/**/*.swift', 'Sources/OAuth/OAuth/**/*.h'
  s.static_framework = true
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.dependency 'GoogleSignIn', '~> 5.0'
  s.dependency 'FBSDKLoginKit', '>= 9.0', '< 13.0'
end
