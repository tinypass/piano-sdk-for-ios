Pod::Spec.new do |s|
  s.name         = 'PianoC1X'
  s.version      = '2.4.0'
  s.swift_version = '5.0'
  s.summary      = 'Enables iOS apps to use C1X integration by Piano.io'
  s.homepage     = 'https://github.com/tinypass/piano-sdk-for-ios'
  s.license      = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.author       = 'Piano Inc.'
  s.platform     = :ios, '9.0'
  s.source       = { :git => 'https://github.com/tinypass/piano-sdk-for-ios.git', :tag => "#{s.version}" }
  s.source_files = 'Sources/C1X/C1X/**/*.swift', 'Sources/C1X/C1X/**/*.h'
  s.static_framework = true
  s.dependency 'PianoComposer', "~> #{s.version}"
  s.dependency 'CxenseSDK', '~> 1.9.5'
end
