platform :ios, '13.0'

use_frameworks! :linkage => :static

target 'HR' do

end

install! 'cocoapods', :deterministic_uuids => false

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # Exclude arm64 ONLY for simulator
      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
      # Deployment target fix
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
    end
  end
end
