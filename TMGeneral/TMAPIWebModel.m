//
//  TMAPIWebModel.m
//  TMGeneral
//
//  Created by mac on 12/10/10.
//  Copyright (c) 2012年 ThinkerMobile. All rights reserved.
//

#import "TMAPIWebModel.h"
#import "AFHTTPClient.h"
#import "TMApiData.h"

@interface TMAPIWebModel ()
{

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
    
    NSLog(@"url = %@", request.URL.absoluteString);
    
    _operation = [[_httpClient HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self webSuccess:operation response:responseObject];
        
        [self final];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self webFailed:operation error:error];
        
        if ([self checkRetry]) {
            [self retry];
        } else
            [self final];
        
    } ] retain];
    
    [_operation start];
    
    [super main];
}

- (void) webSuccess:(AFHTTPRequestOperation *)operation response:(id)responseObject
{
    
}

- (void) webFailed:(AFHTTPRequestOperation *)operation error:(NSError *)error
{
    
}

- (void) final
{    
    [_operation release]; _operation = nil;
    [super final];
}

- (void) cancel
{
    [_operation cancel];
    [_operation release]; _operation = nil;
    [super cancel];
}

- (id) initWithInput:(NSDictionary *)aInput
{
    self = [super initWithInput:aInput];
    if (self) {
        _actionItem.type = [NSNumber numberWithInt:TMAPI_Type_Web_Api];
    }
    
    return self;
}


- (void)dealloc
{
    [_httpClient release]; 
    [super dealloc];
}

@end
