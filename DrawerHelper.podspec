#
#  Be sure to run `pod spec lint DrawerHelper.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "DrawerHelper"
  spec.version      = "0.1.0"
  spec.summary      = "The tool to help you control the behavior of the drawer view"

  spec.description  = <<-DESC
The tool to help you control the behavior of the drawer view.
                   DESC

  spec.homepage     = "https://github.com/romdevios/DrawerHelper"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Roman Filippov" => "roman.filippov.dev@gmail.com" }


#  spec.platform     = :ios, "9.0"
  
  spec.tvos.deployment_target = "9.0"
  spec.ios.deployment_target = "9.0"
  spec.swift_version = "5.2"

  #  When using multiple platforms
  # spec.osx.deployment_target = "10.7"
  # spec.watchos.deployment_target = "2.0"


  spec.source       = { :git => "https://github.com/romdevios/DrawerHelper.git", :tag => "#{spec.version}" }

  spec.source_files  = "Sources/**/*.swift"


end
