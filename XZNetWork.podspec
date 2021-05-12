
Pod::Spec.new do |spec|


  spec.name         = "XZNetWork"
  spec.version      = "0.0.1"
  spec.summary      = "网络请求封装"
  spec.description  = "网络请求依赖请求，捆绑请求"
  spec.homepage     = "https://github.com/xiezefeng/XZNetWork"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author  = { "xiexiaofeng" => "815040727@qq.com" }
  spec.platform     = :ios
  spec.ios.deployment_target = "10.0"

  spec.source       = { :git => "https://github.com/xiezefeng/XZNetWork.git", :tag => "#{spec.version}" }
  spec.source_files  =  "XZNetwork/*.{h,m}"
  spec.requires_arc = true
  spec.frameworks = 'Foundation', 'UIKit'
  spec.dependency "AFNetworking",'~> 4.0.0'

end
