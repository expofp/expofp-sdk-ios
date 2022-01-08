Pod::Spec.new do |spec|
  spec.name               = "FplanKit"
  spec.version            = "0.0.1"
  spec.summary            = "Fplan Library for iOS apps"
  spec.description        = "Library for displaying expo plans"
  spec.homepage           = "https://www.expofp.com"
  spec.documentation_url  = "https://github.com/expofp/expofp-ios-sdk"
  spec.license            = { :type => "MIT" }
  s.author                = { 'ExpoFP' => 'support@expofp.com' }
  spec.source             = { :git => 'https://github.com/expofp/expofp-ios-sdk.git', :tag => "#{spec.version}" }
  spec.swift_version      = "5.3"

  # Supported deployment targets
  spec.ios.deployment_target  = "10.0"

  # Published binaries
  vendored_frameworks = "xcframework/FplanKit.xcframework"
end