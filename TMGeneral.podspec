Pod::Spec.new do |s|
  s.name         = "TMGeneral"
  s.version      = "0.0.5"
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
  s.source       = { :git => "git@bitbucket.org:thinkermobile/tmgeneral.git", :tag => '0.0.5' }
  s.resources    = 'TMGeneral/TMGeneralDataModel.xcdatamodeld'
  s.platform     = :ios
  s.ios.deployment_target = '4.3'
  s.source_files = 'TMGeneral', 'TMGeneralResource', 'TMGeneral/model'
  s.framework  = 'CoreData'
  s.dependency 'JSONKit',       '1.4'
  s.dependency 'AFNetworking',  '0.10.1'
  s.dependency 'AFDownloadRequestOperation_kang',   '0.0.1'
end
