Pod::Spec.new do |spec|
  spec.name               = "FplanKit"
  spec.version            = "0.0.1"
  spec.platform           = :ios, '13.0'
  spec.summary            = "Fplan Library for iOS apps"
  spec.description        = "Library for displaying expo plans"
  spec.homepage           = "https://www.expofp.com"
  spec.documentation_url  = "https://github.com/expofp/expofp-ios-sdk"
  spec.license            = { :type => "MIT" }
  spec.author                = { 'ExpoFP' => 'support@expofp.com' }
  spec.source             = { :git => 'https://github.com/expofp/expofp-ios-sdk.git', :tag => "#{spec.version}" }
  spec.swift_version      = "5"

  # Supported deployment targets
  spec.ios.deployment_target  = "13.0"

  # Published binaries
  spec.vendored_frameworks = "xcframework/FplanKit.xcframework"

  spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  spec.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end