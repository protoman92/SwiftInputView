Pod::Spec.new do |s|

    s.platform = :ios
    s.ios.deployment_target = '9.0'
    s.name = "SwiftInputView"
    s.summary = "Adaptable input holder view that supports different types of inputs"
    s.requires_arc = true
    s.version = "1.1.2"
    s.license = { :type => "Apache-2.0", :file => "LICENSE" }
    s.author = { "Hai Pham" => "swiften.svc@gmail.com" }
    s.homepage = "https://github.com/protoman92/SwiftInputView.git"
    s.source = { :git => "https://github.com/protoman92/SwiftInputView.git", :tag => "#{s.version}"}
    s.framework = "UIKit"
    s.dependency 'SwiftPlaceholderTextView/Main'
    s.dependency 'SwiftReactiveTextField/Main'

    s.subspec 'Main' do |main|
        main.source_files = "SwiftInputView/**/*.{swift,xib}"
    end

end
