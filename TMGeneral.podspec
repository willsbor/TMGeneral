Pod::Spec.new do |s|
  s.name         = "TMGeneral"
  s.version      = "1.11.6"
  s.summary      = "Thinker Mobile for Project General Tools."
  s.homepage     = "http://www.thinkermobile.com/"
  s.license      = 'MIT'
  s.author       = { "willsbor Kang" => "kang@thinkermobile.com" }
  s.source       = { :git => "git@bitbucket.org:thinkermobile/tmgeneral.git", :tag => "#{s.version}" }
  s.platform     = :ios, '5.0'
  s.ios.deployment_target = '5.0'
  s.source_files = 'TMGeneral', 'TMGeneralResource', 'TMGeneral/model', 'TMGeneral/ModelManager', 'TMGeneral/Vender'
  s.resources    = 'TMGeneral/Model/*.xcdatamodeld'
  s.framework  = 'CoreData'
  s.requires_arc = true
  s.dependency 'AFNetworking',  '>=1.1.0'
  s.dependency 'AFDownloadRequestOperation',   '0.0.1'
  s.dependency 'UIKitCategoryAdditions_kang'
end
