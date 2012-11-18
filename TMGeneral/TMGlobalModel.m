//
//  TMGlobalModel.m
//  TMGeneral
//
//  Created by mac on 12/10/19.
//  Copyright (c) 2012年 ThinkerMobile. All rights reserved.
//

#import "TMGlobalModel.h"

@implementation TMGlobalModel

- (void) updateDatas:(NSDictionary *) aJSONDic
{
    for (NSString *key in [aJSONDic allKeys]) {
        NSString *mapKey = [_mapKey objectForKey:key];
        if (mapKey == nil) {
            mapKey = key;
        }
        
        @try {
            id value = [aJSONDic objectForKey:key];
            if ([self validateValue:&value forKey:mapKey error:nil] )
                [self setValue:value forKey:mapKey];
        }
        @catch (NSException *exception) {
            NSLog(@"exception = %@", exception);
        }
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        _mapKey = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_appversion release];
    [_apiVersion release];
    [_mapKey release];
    [super dealloc];
}

@end
