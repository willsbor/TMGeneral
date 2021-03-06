/*
 TMTools.m
 
 Copyright (c) 2012 willsbor Kang
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "TMTools.h"
#import <CommonCrypto/CommonDigest.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <UIKit/UIDevice.h>

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import "GTMStringEncoding.h"

static NSMutableDictionary *gCacheDataFormatters;
static dispatch_once_t pred5;
static dispatch_once_t pred6;
static dispatch_once_t pred7;

void tmCleanToolsCaches()
{
    gCacheDataFormatters = nil;
    pred5 = pred6 = pred7 = 0;
}

void tmActionIfEqualOrGreaterThen5(void (^yesAction)(void) , void (^noAction)(void))
{
    static BOOL isVersion = NO;
    
    dispatch_once(&pred5, ^{
        NSString *reqSysVer = @"5.0";
        NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
        if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
            isVersion = YES;
        else
            isVersion = NO;
    });
    
    
    if (isVersion) {
        if (yesAction) yesAction();
    }
    else {
        if (noAction) noAction();
    }
}

void tmActionIfEqualOrGreaterThen6(void (^yesAction)(void) , void (^noAction)(void))
{
    static BOOL isVersion = NO;
    
    dispatch_once(&pred6, ^{
        NSString *reqSysVer = @"6.0";
        NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
        if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
            isVersion = YES;
        else
            isVersion = NO;
    });
    
    
    if (isVersion) {
        if (yesAction) yesAction();
    }
    else {
        if (noAction) noAction();
    }
}

void tmActionIfEqualOrGreaterThen7(void (^yesAction)(void) , void (^noAction)(void))
{
    static BOOL isVersion = NO;
    
    dispatch_once(&pred7, ^{
        NSString *reqSysVer = @"7.0";
        NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
        if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
            isVersion = YES;
        else
            isVersion = NO;
    });
    
    
    if (isVersion) {
        if (yesAction) yesAction();
    }
    else {
        if (noAction) noAction();
    }
}


NSString *tmStringFromMD5(NSString *aString)
{
    
    if(aString == nil || [aString length] == 0)
        return nil;
    
    const char *value = [aString UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, strlen(value), outputBuffer);
    
    NSMutableString *__autoreleasing outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}

NSString *tmStringNSDate(NSDate *aDate, NSString *aFormat)
{
    if (!gCacheDataFormatters) {
        gCacheDataFormatters = [[NSMutableDictionary alloc] init];
    }
    
    if (aFormat == nil) {
        aFormat = @"yyyy.MM.dd HH:mm";
    }
    
    NSDateFormatter *formatter = gCacheDataFormatters[aFormat];
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:aFormat];
        gCacheDataFormatters[aFormat] = formatter;
    }
    
    NSString *__autoreleasing resultString = [formatter stringFromDate:aDate];
    return resultString;
}

NSDate *tmNSDateString(NSString *aDateString, NSString *aFormat)
{
    if (!gCacheDataFormatters) {
        gCacheDataFormatters = [[NSMutableDictionary alloc] init];
    }
    
    if (aFormat == nil) {
        aFormat = @"yyyy.MM.dd HH:mm";
    }
    
    NSDateFormatter *formatter = gCacheDataFormatters[aFormat];
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:aFormat];
        gCacheDataFormatters[aFormat] = formatter;
    }
    
    NSDate *__autoreleasing resultDate = [formatter dateFromString:aDateString];
    return resultDate;
}

NSString *tmStringNSDateByC(NSDate *aDate, const char *aFormat) {
    struct tm *timeinfo;
    char buffer[80];
    
    time_t rawtime = [aDate timeIntervalSince1970] - [[NSTimeZone localTimeZone] secondsFromGMT];
    timeinfo = localtime(&rawtime);
    
    if (aFormat == NULL) {
        aFormat = "%Y.%m.%d %H:%M";
        /// "%Y-%m-%dT%H:%M:%S%z"
    }
    strftime(buffer, 80, aFormat, timeinfo);
    
    return [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
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
    
    NSString *__autoreleasing resultString = nil;
    if ([breakdownInfo year] != 0) {
        resultString = tmStringNSDate(aDate, @"yyyy.MM.dd HH:mm");
    }
    else if ([breakdownInfo month] != 0) {
        resultString = tmStringNSDate(aDate, @"yyyy.MM.dd HH:mm");
    }
    else if ([breakdownInfo day] != 0) {
        resultString = [NSString stringWithFormat:@"%d 天前", [breakdownInfo day]];
    }
    else if ([breakdownInfo hour] != 0) {
        resultString = [NSString stringWithFormat:@"%d 小時前", [breakdownInfo hour]];
    }
    else if ([breakdownInfo minute] != 0) {
        resultString = [NSString stringWithFormat:@"%d 分鐘前", [breakdownInfo minute]];
    }
    else if ([breakdownInfo second] != 0) {
        resultString = [NSString stringWithFormat:@"%d 秒前", [breakdownInfo second]];
    }
    else
        resultString = tmStringNSDate(aDate, @"yyyy.MM.dd HH:mm");
    
    return resultString;
}

NSString *tmGetIPAddress()
{
    
    NSString *__autoreleasing address = @"error";
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

NSString *tmGoogleSign(NSString *aURL, NSString* aKey, NSString *aClientID)
{
    NSString *url = [NSString stringWithFormat:@"%@&client=%@", aURL, aClientID];
    
    // Stores the url in a NSData.
    NSData *urlData = [url dataUsingEncoding: NSASCIIStringEncoding];
    
    // URL-safe Base64 coder/decoder.
    GTMStringEncoding *encoding =
    [GTMStringEncoding rfc4648Base64WebsafeStringEncoding];
    
    // Decodes the URL-safe Base64 key to binary.
    NSData *binaryKey = [encoding decode:aKey];
    
    // Signs the URL.
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1,
           [binaryKey bytes], [binaryKey length],
           [urlData bytes], [urlData length],
           &result);
    NSData *binarySignature =
    [NSData dataWithBytes:&result length:CC_SHA1_DIGEST_LENGTH];
    
    // Encodes the signature to URL-safe Base64.
    NSString *signature = [encoding encode:binarySignature];
    
    NSString *__autoreleasing signString = [NSString stringWithFormat:@"%@&signature=%@", url, signature];
    return signString;
}
