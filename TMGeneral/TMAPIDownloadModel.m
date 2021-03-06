/*
 TMAPIResumeDownloadModel.m
 
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

#import "TMAPIDownloadModel.h"
#import <AFNetworking/AFNetworking.h>
#import "TMApiData.h"
#import "TMTools.h"
#import <AFDownloadRequestOperation_kang/AFDownloadRequestOperation.h>
#import "TMGeneralDataManager.h"

#define EFFECT_TEMP_FILE     [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,   NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"download"]

typedef void (^TMAPIDownloadModelProgressiveOperationProgressBlock)(NSInteger bytes, long long totalBytes, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile);

typedef enum
{
    TMAPI_ResumeDownload_State_Downloading,
    TMAPI_ResumeDownload_State_Downloaded,
    TMAPI_ResumeDownload_State_Pause,
} TMAPI_ResumeDownload_State;

@interface TMAPIDownloadModel ()
@property (nonatomic, copy) TMAPIDownloadModelProgressiveOperationProgressBlock progressiveDownloadProgress;
@end

@implementation TMAPIDownloadModel

- (void) main
{
    __block float _downloadRatio = 0.0;
    
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //Perform your tasks that your application requires
    
    __block TMAPI_ResumeDownload_State downloadState = TMAPI_ResumeDownload_State_Downloading;
    
    NSMutableURLRequest *request;
    /*
     NSString *strBaseURL = [self.inputParam objectForKey:TMAPI_WEB_BASEURL];
     if (strBaseURL != nil) {
     if (_httpClient == nil)
     _httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:strBaseURL]];
     
     NSString *method = @"GET";
     if (nil != [self.inputParam objectForKey:TMAPI_WEB_METHOD]) {
     method = [self.inputParam objectForKey:TMAPI_WEB_METHOD];
     }
     NSString *path = [self.inputParam objectForKey:TMAPI_WEB_PATH];
     NSAssert(path != nil, @"path shouldn't be nil");
     NSDictionary *param = [self.inputParam objectForKey:TMAPI_WEB_PARAM];
     request = [_httpClient requestWithMethod:method path:path parameters:param];
     NSNumber *timout = [self.inputParam objectForKey:TMAPI_WEB_TIMEOUT];
     if (timout!= nil) {
     request.timeoutInterval = [timout intValue];
     }
     } else {*/
    NSString *path = [self.inputParam objectForKey:TMAPI_DOWNLOAD_SOURCE_URL];
    NSAssert(path != nil, @"TMAPIDownloadModel path shouldn't be nil");
    request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
    //}
    
    NSLog(@"TMAPIDownloadModel url = %@", request.URL.absoluteString);
    
    NSString *tempfile = [self.inputParam objectForKey:TMAPI_DOWNLOAD_TARGET_PATH];
    
    _operation = nil;
    _operation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:tempfile shouldResume:YES];
    
    
    //_operation.outputStream = [NSOutputStream outputStreamToFileAtPath:tempfile append:NO];
    
    _downloadRatio = 0.0;
    downloadState = TMAPI_ResumeDownload_State_Downloading;
    
    __unsafe_unretained TMAPIDownloadModel *selfItem = self;
    [_operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"TMAPIDownloadModel Successfully downloaded file to ");
        downloadState = TMAPI_ResumeDownload_State_Downloaded;
        
        //NSLog(@"[responseObject class] = %@", [responseObject class]);
        
        [selfItem webSuccess:operation response:responseObject];
        
        [selfItem final];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"TMAPIDownloadModel Error: %@", error);
        downloadState = TMAPI_ResumeDownload_State_Pause;
        
        if (error.code == 516) {
            /*
             Error Domain=NSCocoaErrorDomain Code=516 "The operation couldn’t be completed. (Cocoa error 516.)" UserInfo=0x14b270 {NSUserStringVariant=(
             Move
             ), NSFilePath=/private/var/mobile/Applications/67D27145-C593-4A8A-BDF9-DA0E9DB2163C/tmp/Incomplete/e322c4f4f439b9c077e41c35703710d5, NSDestinationFilePath=/var/mobile/Applications/67D27145-C593-4A8A-BDF9-DA0E9DB2163C/Library/Caches/downloadlibUAirshipPush-1.3.3.a, NSUnderlyingError=0x14b390 "The operation couldn’t be completed. File exists"}
             */
            NSError *FileError = nil;
            [[NSFileManager defaultManager] removeItemAtPath:tempfile error:&FileError];
            if (FileError != nil) {
                NSLog(@"TMAPIDownloadModel Remove File error : %@", FileError);
            }
        }
        
        [selfItem webFailed:operation error:error];
        
        
        [selfItem checkRetryAndDoRetryOrFinal];
    }];
    
    
    //[_operation setProgressiveDownloadProgressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
    
    [_operation setProgressiveDownloadProgressBlock:^(AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile)  {
        //NSLog(@"Operation%i: bytesRead: %d", 1, bytesRead);
        //NSLog(@"Operation%i: totalBytesRead: %lld", 1, totalBytesRead);
        //NSLog(@"Operation%i: totalBytesExpected: %lld", 1, totalBytesExpected);
        //NSLog(@"Operation%i: totalBytesReadForFile: %lld", 1, totalBytesReadForFile);
        //NSLog(@"Operation%i: totalBytesExpectedToReadForFile: %lld", 1, totalBytesExpectedToReadForFile);
        
        //double dtmp = totalBytesReadForFile * 100;
        //dtmp /= totalBytesExpectedToReadForFile;
        
        //NSLog(@"%2.2f = %lld / %lld", dtmp, totalBytesReadForFile, totalBytesExpectedToReadForFile);
        if (selfItem.progressiveDownloadProgress) {
            selfItem.progressiveDownloadProgress(bytesRead, totalBytesRead, totalBytesExpected,totalBytesReadForFile, totalBytesExpectedToReadForFile);
        }
    }];
    
    NSLog(@"Start to Download....");
    [_operation start];
    
    //[_operation waitUntilFinished];
    
    
    //[application endBackgroundTask: background_task]; //End the task so the system knows that you are done with what you need to perform
    //background_task = UIBackgroundTaskInvalid; //Invalidate the background_task
    //});
    
    
}

- (void) webSuccess:(AFHTTPRequestOperation *)operation response:(id)responseObject
{
    
}

- (void) webFailed:(AFHTTPRequestOperation *)operation error:(NSError *)error
{
    
}

- (void) final
{
    _operation = nil;
    [super final];
}

- (void) pause
{
    [_operation pause];
}

- (void) resume
{
    [_operation resume];
}

- (void)setProgressiveDownloadProgressBlock:(void (^)(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile))block
{
    self.progressiveDownloadProgress = block;
}

- (void) cancel
{
    
    [_operation cancel];
    _operation = nil;
    [super cancel];
}

- (id) initWithInput:(NSDictionary *)aInput
{
    self = [super initWithInput:aInput];
    if (self) {
        [[TMGeneralDataManager sharedInstance] changeApiData:_actionItem With:^(TMApiData *apidata) {
            apidata.type = [NSNumber numberWithInt:TMAPI_Type_Web_Api];
        }];
        self.thread = TMAPI_Thread_Type_SubThread;
    }
    
    return self;
}



@end
