#
# Be sure to run `pod lib lint Elastomeric.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Elastomeric'
  s.version          = '0.1.0'
  s.summary          = 'A simple Reactive mechanism intended to facilitate UI statefulness'

  s.homepage         = 'https://github.com/Ikonium/Elastomeric'
  s.license          = { :type => 'Public', :file => 'LICENSE' }
  s.author           = { 'Christopher Cohen' => 'chris@filmicpro.com' }
  s.source           = { :git => 'https://github.com/Ikonium/Elastomeric.git', :tag => s.version.to_s }
  s.swift_version    = '4.1'

  s.ios.deployment_target = '11.0'

  s.source_files = 'Elastomeric/Elastomeric.swift'

end