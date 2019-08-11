Pod::Spec.new do |s|
    s.name             = "ZappPlayerPluginBaby"
    s.version          = '1.4.0'
    s.summary          = "ZappPlayerPluginBaby"
    s.description      = <<-DESC
    ZappPlayerPluginBaby plugin.
    DESC
    s.homepage         = "https://github.com/applicaster/ZappPlayerPluginBaby-iOS"
    s.license          = 'CMPS'
    s.author           = { "cmps" => "r.kedarya@applicaster.com" }
    s.source           = { :git => "git@github.com:applicaster/ZappPlayerPluginBaby-iOS.git", :tag => s.version.to_s }
    
    s.platform     = :ios, '10.0'
    s.requires_arc = true

    s.public_header_files = 'ZappPlayerPluginBaby/Classes/*.h'
    s.source_files = 'ZappPlayerPluginBaby/Classes/*.{h,m,swift}'
    
    s.resources = [
    "ZappPlayerPluginBaby/Resources/*.xcassets",
    "ZappPlayerPluginBaby/Resources/*.storyboard",
    "ZappPlayerPluginBaby/Resources/*.xib",
    "ZappPlayerPluginBaby/Resources/*.png"]
    
    s.xcconfig =  {
        'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES',
        'ENABLE_BITCODE' => 'YES',
        'SWIFT_VERSION' => '5.0'
    }
    
    s.dependency 'ApplicasterSDK'
    s.dependency 'ZappLoginPluginsSDK'
end
