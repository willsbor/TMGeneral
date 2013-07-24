//
//  TMApiData+Plus.h
//  TMGeneral
//
//  Created by willsborKang on 13/7/7.
//  Copyright (c) 2013年 thinkermobile. All rights reserved.
//

#import "TMApiData.h"

#define TMAPIMODEL_DEFAULT_RETRY_DELAY_TIME   5.0  /// sec
#define TMAPIMODEL_DEFAULT_CHECK_API_DURATION   30.0 ///< sec


typedef enum
{
    TMAPI_Mode_Leave_With_Cancel,
    TMAPI_Mode_Leave_Without_Cancel,
} TMAPI_Mode;

typedef enum
{
    TMAPI_State_Init,
    TMAPI_State_Doing,
    TMAPI_State_Finished,
    TMAPI_State_Pending,  ///< retry : 中途的狀態
    TMAPI_State_Failed,   ///< retry 到最後失敗
    TMAPI_State_Stop,   ///< 被系統強制換狀態
} TMAPI_State;

typedef enum
{
    TMAPI_Type_General,
    TMAPI_Type_Web_Api,
} TMAPI_Type;

typedef enum
{
    TMAPI_Cache_Type_None,
    TMAPI_Cache_Type_ThisActive,
    TMAPI_Cache_Type_EveryActive,
} TMAPI_Cache_Type;

@interface TMApiData (Plus)

@end
