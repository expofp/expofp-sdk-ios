Pod::Spec.new do |spec|
  spec.name               = "ExpoFP"
  spec.version            = "5.0.0-RC1"
  spec.platform           = :ios, '14.0'
  spec.summary            = "Expo Floor Plan"
  spec.description        = "Plan Map for ExpoFP SDK"
  spec.homepage           = "https://www.expofp.com"
  spec.documentation_url  = "https://expofp.github.io/expofp-mobile-sdk/ios-sdk"
  spec.license            = { :type => "MIT" }
  spec.author             = { 'ExpoFP' => 'support@expofp.com' }
  spec.source             = { :git => 'https://github.com/expofp/expofp-fplan-ios.git', :tag => "#{spec.version}" }
  spec.swift_version      = "5"

  # Supported deployment targets
  spec.ios.deployment_target  = "14.0"

  # Published binaries
  spec.ios.vendored_frameworks = "ExpoFP.xcframework"

end
