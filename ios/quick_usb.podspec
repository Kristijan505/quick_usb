#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint quick_usb.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'quick_usb'
  s.version          = '0.0.1'
  s.summary          = 'A cross-platform USB plugin for Flutter with iOS support'
  s.description      = <<-DESC
A Flutter plugin that provides USB device communication across multiple platforms including iOS.
                       DESC
  s.homepage         = 'https://github.com/woodemi/quick_usb'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Quick USB Team' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  
  # iOS External Accessory framework
  s.frameworks = 'ExternalAccessory', 'Foundation'
  
  s.platform = :ios, '12.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
  
  # Required for External Accessory framework
  s.info_plist = {
    'UISupportedExternalAccessoryProtocols' => ['com.apple.mfi']
  }
end
