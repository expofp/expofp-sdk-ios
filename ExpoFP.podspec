Pod::Spec.new do |spec|
  spec.name               = "ExpoFP"
  spec.version            = "5.4.6"
  spec.platform           = :ios, '14.0'
  spec.summary            = "ExpoFP SDK"
  spec.description        = "ExpoFP SDK to show and manage expo floor plans. Use documentation for integration"
  spec.homepage           = "https://expofp.com"
  spec.documentation_url  = "https://expofp.github.io/expofp-sdk-ios/documentation/expofp/"
  spec.license            = { :type => "MIT" }
  spec.author             = { 'ExpoFP' => 'support@expofp.com' }
  spec.source             = { :git => 'https://github.com/expofp/expofp-sdk-ios.git', :tag => "#{spec.version}" }
  spec.swift_version      = "5"

  # Supported deployment targets
  spec.ios.deployment_target  = "14.0"

  # Published binaries
  spec.ios.vendored_frameworks = "ExpoFP.xcframework"

end
