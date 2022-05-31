Pod::Spec.new do |s|
  s.name             = 'SwiftUIFlowLayout'
  s.version          = '1.0.4'
  s.summary          = 'A Flow Layout is a container that orders its views sequentially, breaking into a new "line" according to the available width of the screen.'
  s.homepage         = 'https://github.com/globulus/swiftui-flow-layout'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Gordan Glavaš' => 'gordan.glavas@gmail.com' }
  s.source           = { :git => 'https://github.com/globulus/swiftui-flow-layout.git', :tag => s.version.to_s }
  s.ios.deployment_target = '13.0'
  s.swift_version = '4.0'
  s.source_files = 'Sources/SwiftUIFlowLayout/**/*'
end
