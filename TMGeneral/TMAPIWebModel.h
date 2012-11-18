//
//  TMAPIWebModel.h
//  TMGeneral
//
//  Created by mac on 12/10/10.
//  Copyright (c) 2012年 ThinkerMobile. All rights reserved.
//

#import "TMAPIModel.h"

#define TMAPI_WEB_METHOD    @"web_method"
#define TMAPI_WEB_BASEURL   @"web_baseURL"
#define TMAPI_WEB_PATH      @"web_path"
#define TMAPI_WEB_PARAM     @"web_param"
#define TMAPI_WEB_TIMEOUT   @"web_timeout"

/*
enum {
    TMAPI_GuaranteeAction_None = 0,
    TMAPI_GuaranteeAction_Wifi = (1 << 0),
    TMAPI_GuaranteeAction_3G   = (1 << 1),
    
    TMAPI_GuaranteeAction_Internet = TMAPI_GuaranteeAction_Wifi | TMAPI_GuaranteeAction_3G,
};*/

@class AFHTTPClient;
@class AFHTTPRequestOperation;
@interface TMAPIWebModel : TMAPIModel
{
    @protected
    AFHTTPClient *_httpClient;
    AFHTTPRequestOperation *_operation;
}

@property (nonatomic) int guaranteeAction;

- (void) webSuccess:(AFHTTPRequestOperation *)operation response:(id)responseObject;
- (void) webFailed:(AFHTTPRequestOperation *)operation error:(NSError *)error;

@end
