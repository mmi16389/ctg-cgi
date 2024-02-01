# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

target 'GCI' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for GCI
  pod 'Alamofire', '~> 5.8.1'
  pod 'AlamofireImage', '~> 4.3.0'
  pod 'SwiftyJSON', '~> 5.0.0'
  pod 'lottie-ios', '~> 4.3.3'
  pod 'CoreStore', '~> 9.2.0'
  pod 'SwiftLint', '~> 0.54'
  pod 'ReachabilitySwift', '~> 5.0.0'
  pod 'KeychainSwift', '~> 20.0.0'
  pod 'IQKeyboardManagerSwift', '~> 6.5.16'
  pod 'SkyFloatingLabelTextField', '~> 4.0.0'
  pod 'ArcGIS-Runtime-SDK-iOS', '100.4'
  pod 'VersionTrackerSwift', '~> 3.0.0'
  pod 'AppCenter', '~> 5.0.4'
  pod 'AzureNotificationHubs-iOS', '3.1.5'
  
  target 'GCITests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'GCIUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14'
    end
  end
end
