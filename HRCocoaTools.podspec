#
# Be sure to run `pod lib lint HRCocoaTools.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HRCocoaTools'
  s.version          = '0.2.8'
  s.summary          = 'Henry iOS tool Lib'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  私人使用工具库，封装了一些常用的基本库
                       DESC

  s.homepage         = 'https://github.com/iPermanent/HRCocoaTools'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'iPermanent' => 'henryzhangios@gmail.com' }
  s.source           = { :git => 'https://github.com/iPermanent/HRCocoaTools.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.comReachability/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  #s.source_files = 'HRCocoaTools/Classes/**/*'
  
  # s.resource_bundles = {
  #   'HRCocoaTools' => ['HRCocoaTools/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'

    s.subspec 'Animation' do |n|
    n.source_files = 'HRCocoaTools/Classes/Animation/*'
    n.dependency 'pop'
    end

    s.subspec 'Media' do |n|
    n.source_files = 'HRCocoaTools/Classes/Media/*'
    end

    s.subspec 'Util' do |n|
    n.source_files = 'HRCocoaTools/Classes/Util/*'
    n.dependency 'Reachability'
    end

    s.subspec 'Category' do |n|
    n.source_files = 'HRCocoaTools/Classes/Category/*'
    end

end
