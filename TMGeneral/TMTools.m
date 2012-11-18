//
//  TMTools.m
//  TMGeneral
//
//  Created by mac on 12/10/16.
//  Copyright (c) 2012年 ThinkerMobile. All rights reserved.
//

#import "TMTools.h"
#import <CommonCrypto/CommonDigest.h>
#import <ifaddrs.h>
#import <arpa/inet.h>


NSString *tmStringFromMD5(NSString *aString)
{
    
    if(aString == nil || [aString length] == 0)
        return nil;
    
    const char *value = [aString UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return [outputString autorelease];
}

NSString *tmStringNSDate(NSDate *aDate, NSString *aFormat)
{
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    if (aFormat == nil) {
        [formatter setDateFormat:@"yyyy.MM.dd HH:mm"];
    } else
        [formatter setDateFormat:aFormat];
    return  [[[formatter stringFromDate:aDate] retain] autorelease];
}

NSString *tmStringRemindTimeWithNSDate(NSDate *aDate)
{
    // The time interval
    //    NSTimeInterval theTimeInterval = ...;
    
    // Get the system calendar
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];
    
    // Create the NSDates
    NSDate *date1 = [[NSDate alloc] init];
    
    // Get conversion to months, days, hours, minutes
    unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSSecondCalendarUnit | NSYearCalendarUnit;
    
    NSDateComponents *breakdownInfo = [sysCalendar components:unitFlags fromDate:aDate  toDate:date1  options:0];
    
    //HiiirLog(@"Break down: %dmin %dhours %ddays %dmoths",[breakdownInfo minute], [breakdownInfo hour], [breakdownInfo day], [breakdownInfo month]);
    [date1 release];
    
    if ([breakdownInfo year] != 0) {
        return tmStringNSDate(aDate, @"yyyy.MM.dd HH:mm");
    }
    else if ([breakdownInfo month] != 0) {
        return tmStringNSDate(aDate, @"yyyy.MM.dd HH:mm");
    }
    else if ([breakdownInfo day] != 0) {
        return [[[NSString stringWithFormat:@"%d 天前", [breakdownInfo day]] retain] autorelease];
    }
    else if ([breakdownInfo hour] != 0) {
        return [[[NSString stringWithFormat:@"%d 小時前", [breakdownInfo hour]] retain] autorelease];
    }
    else if ([breakdownInfo minute] != 0) {
        return [[[NSString stringWithFormat:@"%d 分鐘前", [breakdownInfo minute]] retain] autorelease];
    }
    else if ([breakdownInfo second] != 0) {
        return [[[NSString stringWithFormat:@"%d 秒前", [breakdownInfo second]] retain] autorelease];
    }
    else
        return tmStringNSDate(aDate, @"yyyy.MM.dd HH:mm");
}

NSString *tmGetIPAddress()
{
    
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    return address;
}
