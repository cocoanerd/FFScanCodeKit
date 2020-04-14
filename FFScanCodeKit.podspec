#
# Be sure to run `pod lib lint FFScanCodeKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FFScanCodeKit'
  s.version          = '0.1.0'
  s.summary          = 'FFScanCodeKit.扫码组件'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'FFScanCodeKit是手动集成ZBar后自定义的扫码组件，包含二维码、条形码'

  s.homepage         = 'https://github.com/Cocoanerd/FFScanCodeKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Cocoanerd' => 'huifang@mamahao.com' }
  s.source           = { :git => 'https://github.com/Cocoanerd/FFScanCodeKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
    
  s.subspec 'ZBar' do |ss|
    ss.public_header_files = 'FFScanCodeKit/Classes/ZBarSDK/ZBarSDK.h'
    ss.source_files = 'FFScanCodeKit/Classes/**/*'
    ss.requires_arc = false
  end
  
  s.subspec 'View' do |ss|
    ss.public_header_files = 'FFScanCodeKit/View/FFScanningView.h', 'FFScanCodeKit/View/FFScanWrapper.h', 'FFScanCodeKit/View/FFScanningPermissions.h'
    ss.source_files = 'FFScanCodeKit/View/FFScanningView.{h,m}','FFScanCodeKit/View/FFScanWrapper.{h,m}','FFScanCodeKit/View/FFScanningPermissions.{h,m}'
    ss.dependency 'FFScanCodeKit/Relative'
    ss.dependency 'FFScanCodeKit/ZBar'
    ss.requires_arc = true
  end
  
  s.subspec 'Controller' do |ss|
    ss.public_header_files = 'FFScanCodeKit/Controller/FFScanningViewController.h'
    ss.source_files = 'FFScanCodeKit/Controller/FFScanningViewController.{h,m}'
    ss.dependency 'FFScanCodeKit/View'
    ss.requires_arc = true
  end
  
  s.subspec 'Relative' do |ss|
      ss.public_header_files = 'FFScanCodeKit/Relative/FFScanRelative.h'
      ss.source_files = 'FFScanCodeKit/Relative/FFScanRelative.{h,m}'
      ss.requires_arc = true
  end
  
  s.resource_bundles = {
    'FFScanCodeKit' => ['FFScanCodeKit/Assets/*']
  }

  s.frameworks = 'UIKit', 'Foundation', 'CoreGraphics', 'AVFoundation', 'CoreMedia', 'CoreVideo', 'QuartzCore'
  
  s.libraries = 'iconv'
  
  s.dependency 'Masonry'
  
end
