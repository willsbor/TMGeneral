//
//  TMAPIResumeDownloadModel.h
//  TMGeneral
//
//  Created by mac on 12/10/18.
//  Copyright (c) 2012年 ThinkerMobile. All rights reserved.
//

#import "TMAPIModel.h"

#define TMAPI_DOWNLOAD_SOURCE_URL    @"download_source_url"
#define TMAPI_DOWNLOAD_TARGET_PATH    @"download_target_path"

@class AFDownloadRequestOperation;
@class AFHTTPRequestOperation;
@interface TMAPIDownloadModel : TMAPIModel
{
    AFDownloadRequestOperation *_operation;
}

@property (nonatomic) int guaranteeAction;

- (void) webSuccess:(AFHTTPRequestOperation *)operation response:(id)responseObject;
- (void) webFailed:(AFHTTPRequestOperation *)operation error:(NSError *)error;

- (void) pause;
- (void) resume;

- (void)setProgressiveDownloadProgressBlock:(void (^)(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile))block;

@end
