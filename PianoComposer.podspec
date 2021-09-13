Pod::Spec.new do |s|
  s.name         = 'PianoComposer'
  s.version      = '2.4.0'
  s.swift_version = '5.0'
  s.summary      = 'Enables iOS apps to use mobile composer by Piano.io'
  s.homepage     = 'https://github.com/tinypass/piano-sdk-for-ios'
  s.license      = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.author       = 'Piano Inc.'
  s.platform     = :ios, '9.0'
  s.source       = { :git => 'https://github.com/tinypass/piano-sdk-for-ios.git', :tag => "#{s.version}" }
  s.resources =  'Composer/Composer/Resources/*.png'
  s.source_files = 'Common/*.swift', 'Composer/Composer/**/*.swift', 'Composer/Composer/**/*.h'
end
