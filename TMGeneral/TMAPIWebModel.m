//
//  TMAPIWebModel.m
//  TMGeneral
//
//  Created by mac on 12/10/10.
//  Copyright (c) 2012年 ThinkerMobile. All rights reserved.
//

#import "TMAPIWebModel.h"
#import <AFNetworking/AFNetworking.h>
#import "TMApiData.h"
#import "AFHTTPRequestOperation.h"
#import "TMGeneralDataManager.h"

typedef void(^WebSuccess)(AFHTTPRequestOperation *operation, id responseObject);
typedef void(^WebFailed)(AFHTTPRequestOperation *operation, NSError *error);

@interface TMAPIWebModel ()
{
    WebSuccess _successResponse;
    WebFailed  _failedResponse;
}
@end

@implementation TMAPIWebModel

- (void) main
{
    
    NSString *strBaseURL = [self.inputParam objectForKey:TMAPI_WEB_BASEURL];
    NSAssert(strBaseURL != nil, @"BaseURL shouldn't be nil");
    
    if (_httpClient == nil)
        _httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:strBaseURL]];
    
    NSString *method = @"GET";
    if (nil != [self.inputParam objectForKey:TMAPI_WEB_METHOD]) {
        method = [self.inputParam objectForKey:TMAPI_WEB_METHOD];
    }
    NSString *path = [self.inputParam objectForKey:TMAPI_WEB_PATH];
    NSAssert(path != nil, @"path shouldn't be nil");
    NSDictionary *param = [self.inputParam objectForKey:TMAPI_WEB_PARAM];
    NSMutableURLRequest *request = [_httpClient requestWithMethod:method path:path parameters:param];
    NSNumber *timout = [self.inputParam objectForKey:TMAPI_WEB_TIMEOUT];
    if (timout!= nil) {
        request.timeoutInterval = [timout intValue];
    }
    
#ifdef DEBUG
    NSLog(@"url = %@", request.URL.absoluteString);
#endif
    
    __unsafe_unretained TMAPIWebModel *selfItem = self;
    _operation = [_httpClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [selfItem webSuccess:operation response:responseObject];
        
        if (_successResponse != nil) {
            _successResponse(operation, responseObject);
        }
        
        
        [selfItem final];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [selfItem webFailed:operation error:error];
        
        if (_failedResponse != nil) {
            _failedResponse(operation, error);
        }
        
        [selfItem checkRetryAndDoRetryOrFinal];
    } ];
    
    [_operation start];
    
    [super main];
}

- (void) webSuccess:(AFHTTPRequestOperation *)operation response:(id)responseObject
{
    
}

- (void) webFailed:(AFHTTPRequestOperation *)operation error:(NSError *)error
{
    
}

- (void)setCompletionBlockWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    _successResponse = success;
    _failedResponse = failure;
}

- (void) final
{
    _operation = nil;
    [super final];
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
    }
    
    return self;
}



@end
