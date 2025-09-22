
platform :ios, '11.0'

use_frameworks! :linkage => :static

target 'HR' do
  pod 'FSCalendar'
  pod 'SwiftGifOrigin'
end


install! 'cocoapods', :deterministic_uuids => false

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # Make sure it links correctly without generating Pods_HR.framework
      config.build_settings['OTHER_LDFLAGS'] = config.build_settings['OTHER_LDFLAGS'].to_s
        .gsub('$(inherited)', '')
    end
  end

  # Remove the Pods_HR.framework reference that gets injected
  installer.aggregate_targets.each do |aggregate_target|
    aggregate_target.user_project.native_targets.each do |native_target|
      native_target.frameworks_build_phase.files_references.each do |ref|
        if ref.path.include? "Pods_HR.framework"
          ref.remove_from_project
        end
      end
    end
  end
end
