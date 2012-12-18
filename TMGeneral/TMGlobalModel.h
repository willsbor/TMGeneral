//
//  TMGlobalModel.h
//  TMGeneral
//
//  Created by mac on 12/10/19.
//  Copyright (c) 2012年 ThinkerMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TMGLOBAL_MODEL_KVO_APP_VERSION      @"_appversion"
#define TMGLOBAL_MODEL_KVO_API_VERSION    @"_apiVersion"

@interface TMGlobalModel : NSObject
{

}

@property (nonatomic, readonly) NSMutableDictionary* mapKey;

@property (nonatomic, strong) NSString *appversion;
@property (nonatomic, strong) NSString *apiVersion;

- (void) updateDatas:(NSDictionary *) aJSONDic;

@end
