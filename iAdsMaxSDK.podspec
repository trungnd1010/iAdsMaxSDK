#
# Be sure to run `pod lib lint iAdsMaxSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'iAdsMaxSDK'
  s.version          = '1.18.0'
  s.summary          = 'A short description of iAdsMaxSDK.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/trungnd1010/iAdsMaxSDK'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Trung Nguyen' => 'trungnd@ikameglobal.com' }
  s.source           = { :git => 'https://github.com/trungnd1010/iAdsMaxSDK', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '14.0'
  s.swift_version = '5.0'

  s.source_files = 'iAdsMaxSDK/Classes/**/*'
  
  s.static_framework = true
  
  s.dependency 'AppLovinSDK'
  s.dependency 'iAdsCoreSDK'
  s.dependency 'iComponentsSDK'
  
  s.dependency 'AmazonPublisherServicesSDK'
  s.dependency 'AppLovinMediationAmazonAdMarketplaceAdapter'
  s.dependency 'AppLovinMediationBidMachineAdapter'
  s.dependency 'AppLovinMediationFyberAdapter'
  s.dependency 'AppLovinMediationGoogleAdManagerAdapter'
  s.dependency 'AppLovinMediationGoogleAdapter'
  s.dependency 'AppLovinMediationInMobiAdapter'
  s.dependency 'AppLovinMediationVungleAdapter'
  s.dependency 'AppLovinMediationFacebookAdapter', '6.15.2.1'
  s.dependency 'AppLovinMediationMintegralAdapter'
  s.dependency 'AppLovinMediationOguryPresageAdapter'
  s.dependency 'AppLovinMediationByteDanceAdapter'
  s.dependency 'AppLovinMediationUnityAdsAdapter'
end
