/*
 TMAPIWebModel.h
 
 Copyright (c) 2012 willsbor Kang at ThinkerMobile
 
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


- (void)setCompletionBlockWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
