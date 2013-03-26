Pod::Spec.new do |s|
  s.name         = "TMGeneral"
  s.version      = "1.3.0"
  s.summary      = "Thinker Mobile for Project General Tools."
  s.homepage     = "http://www.thinkermobile.com/"
  s.license      = {
    :type => 'NONE',
    :text => <<-LICENSE
              Copyright (C) <year> <copyright holders>

              All rights reserved.

    LICENSE
  }
  s.author       = { "KangKang" => "kang@thinkermobile.com" }
  s.source       = { :git => "git@bitbucket.org:thinkermobile/tmgeneral.git", :tag => '1.3.0' }
  s.platform     = :ios, '5.0'
  s.ios.deployment_target = '5.0'
  s.source_files = 'TMGeneral', 'TMGeneralResource', 'TMGeneral/model', 'TMGeneral/ModelManager', 'TMGeneral/Vender'
  s.resources    = 'TMGeneral/Model/*.xcdatamodeld'
  s.framework  = 'CoreData'
  s.requires_arc = true
  s.dependency 'AFNetworking',  '1.1.0'
  s.dependency 'AFDownloadRequestOperation',   '0.0.1'
end
