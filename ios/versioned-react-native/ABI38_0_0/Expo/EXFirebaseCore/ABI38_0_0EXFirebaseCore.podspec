require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

firebase_sdk_version = '7.7.0'
if defined? $FirebaseSDKVersion
  firebase_sdk_version = $FirebaseSDKVersion
end

Pod::Spec.new do |s|
  s.name           = 'ABI38_0_0EXFirebaseCore'
  s.version        = package['version']
  s.summary        = package['description']
  s.description    = package['description']
  s.license        = package['license']
  s.author         = package['author']
  s.homepage       = package['homepage']
  s.platform       = :ios, '10.0'
  s.source         = { git: 'https://github.com/expo/expo.git' }
  s.source_files   = 'ABI38_0_0EXFirebaseCore/**/*.{h,m}'
  s.preserve_paths = 'ABI38_0_0EXFirebaseCore/**/*.{h,m}'
  s.requires_arc   = true

  s.dependency 'ABI38_0_0UMCore'
  s.dependency 'Firebase/Core', firebase_sdk_version
end
