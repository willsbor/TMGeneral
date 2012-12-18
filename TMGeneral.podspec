Pod::Spec.new do |s|
  s.name         = "TMGeneral"
  s.version      = "1.0.0"
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
  s.source       = { :git => "git@bitbucket.org:thinkermobile/tmgeneral.git", :tag => '1.0.0' }
  s.resources    = 'TMGeneral/TMGeneralDataModel.xcdatamodeld'
  s.platform     = :ios, '5.0'
  s.ios.deployment_target = '5.0'
  s.source_files = 'TMGeneral', 'TMGeneralResource', 'TMGeneral/model'
  s.framework  = 'CoreData'
  s.dependency 'JSONKit',       '1.4'
  s.dependency 'AFNetworking',  '1.0.1'
  s.dependency 'AFDownloadRequestOperation',   '0.0.1'
end
