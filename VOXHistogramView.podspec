Pod::Spec.new do |s|
  s.name             = "VOXHistogramView"
  s.version          = "0.1.0"
  s.summary          = "The best way to display histogram in your project."
  s.homepage         = "https://github.com/Coppertino/VOXHistogramView"
  s.license          = 'MIT'
  s.author           = { "Nickolay Sheika" => "hawk.ukr@gmail.com" }
  s.source           = { :git => "https://github.com/Coppertino/VOXHistogramView.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.1'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'

  s.dependency 'macros_blocks', '0.0.3'
  s.dependency 'FrameAccessor', '2.0'
end
