Pod::Spec.new do |s|
  s.name         = "TMGeneral"
  s.version      = "1.14.1"
  s.summary      = "A UI general tool. include UI tool, Data Model, control function."
  s.homepage     = "https://github.com/willsbor/TMGeneral"
  s.license      = 'MIT'
  s.author       = { "willsbor Kang" => "kang@thinkermobile.com" }
  s.source       = { :git => "https://github.com/willsbor/TMGeneral.git", :tag => "#{s.version}" }
  s.platform     = :ios, '5.0'
  s.ios.deployment_target = '5.0'
  s.source_files = 'TMGeneral', 'TMGeneralResource', 'TMGeneral/model', 'TMGeneral/ModelManager', 'TMGeneral/Vender'
  s.resources    = 'TMGeneral/Model/*.xcdatamodeld'
  s.framework  = 'CoreData'
  s.requires_arc = true
  s.dependency 'AFNetworking',  '1.3.1'
  s.dependency 'AFDownloadRequestOperation_kang',   '0.0.2'
end
