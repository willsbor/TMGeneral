//
//  TMTools.h
//  TMGeneral
//
//  Created by mac on 12/10/16.
//  Copyright (c) 2012年 ThinkerMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef __TMTOOL_H__
#define __TMTOOL_H__

extern NSString *tmStringFromMD5(NSString *aString);
extern NSString *tmGetIPAddress();

extern NSString *tmStringNSDate(NSDate *aDate, NSString *aFormat);
extern NSString *tmStringNSDateByC(NSDate *aDate, const char *aFormat);

extern NSString *tmStringRemindTimeWithNSDate(NSDate *aDate);

extern NSString *tmGoogleSign(NSString *aURL, NSString* aKey, NSString *aClientID);

#endif