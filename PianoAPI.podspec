Pod::Spec.new do |s|
    s.name         = 'PianoAPI'
    s.version      = '1.0.0'
    s.swift_version = '5.0'
    s.summary      = 'Piano API for iOS'
    s.homepage     = 'https://github.com/tinypass/piano-sdk-for-ios'
    s.license      = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
    s.author       = 'Piano Inc.'
    s.platform     = :ios, '9.0'
    s.source       = { :path => '.' }
    s.source_files = 'PianoAPI/**/*.swift', 'PianoAPI/**/*.h'
    s.static_framework = true
end
