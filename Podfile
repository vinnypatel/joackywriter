# Uncomment this line to define a global platform for your project
platform :ios, '11.0'
target 'JoackyWriter' do
# Comment this line if you're not using Swift and don't want to use dynamic frameworks
use_frameworks!

# Pods for Fax

pod 'UICollectionViewLeftAlignedLayout'
pod 'FXKeychain'
pod 'StepSlider'
#pod 'IQKeyboardManagerSwift'
#    pod 'FittableFontLabel'
#pod 'SwiftyDropbox'
#pod 'FBSDKCoreKit'
#pod 'FBSDKLoginKit'
#pod 'FBSDKShareKit'
#pod 'Firebase/Crashlytics'
#pod 'Firebase/Analytics'

end

post_install do |installer|
installer.pods_project.targets.each do |target|
target.build_configurations.each do |config|
config.build_settings['SWIFT_VERSION'] = '4.2'
end
end
end
