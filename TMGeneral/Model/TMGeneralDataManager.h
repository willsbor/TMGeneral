//
//  TMGeneralDataManager.h
//  TMGeneral
//
//  Created by willsborKang on 12/12/19.
//  Copyright (c) 2012年 thinkermobile. All rights reserved.
//

#import "TMDataManager.h"

@interface TMGeneralDataManager : TMDataManager

+ (TMGeneralDataManager *)sharedInstance;

- (void) save;

@end
