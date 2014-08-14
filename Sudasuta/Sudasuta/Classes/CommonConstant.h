//
//  CommonConstant.h
//  Sudasuta
//
//  Created by user on 14-3-19.
//  Copyright (c) 2014年 user. All rights reserved.
//

#ifndef Sudasuta_CommonConstant_h
#define Sudasuta_CommonConstant_h

#ifndef _countof
#define _countof(_Array) (sizeof(_Array) / sizeof(_Array[0]))
#endif

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define DATABASE_FILE_FULL_NAME              @"sudasuta.db"
#define DATABASE_FILE_NAME                   @"sudasuta"
#define DATABASE_FILE_SUFFIX                 @"db"

#define kFavouriteDBName                     @"favourite"
#define kFavouriteDBVersion                  1

#define kTableFavourite                      @"Favourite"
#define kFavouriteColumnAutoId               @"id"
#define kFavouriteColumnUrl                  @"url"
#define kFavouriteColumnKeyword              @"keyword"
#define kFavouriteColumnTime                 @"date"

#define kMenuHeaderHeight                    44
#define kMenuCellHeight                      58

#define kSudasutaHomeUrl                     @"http://sudasuta.com/"
#define kSudasutaWeiboUrl                    @"http://weibo.com/sudasuta"

#define kNSUserDefaultKeySlideTypeIndex      @"SlideShowSettingSelectedTypeIndex"
#define kNSUserDefaultKeySlideDirectionIndex @"SlideShowSettingSelectedDirectionIndex"
#define kNSUserDefaultKeySlideIntervalIndex  @"SlideShowSettingSelectedIntervalIndex"
#define kNSUserDefaultKeySlideOrderIndex     @"SlideShowSettingSelectedOrderIndex"

#define kColumnMargin                        3
#define kColumnCount_Portrait                3
#define kColumnCount_Landscape               4

#define kStatusBarHeight                     20
#define kMenuSlideOffset                     260
#define kMenuSlideDuration                   0.3

#define kNetworkSearchURLHeader             @"http://image.baidu.com/i?tn=baiduimagejson&ct=201326592&cl=2&lm=-1&st=-1&fm=index&fr=&sf=1&fmq=&pv=&ic=0&nc=1&z=&se=1&showtab=0&fb=0&width=1440&height=900&face=0&istype=2&ie=utf-8&rn=120"
#define kNetworkThemeSearchURLHeader        @"http://image.baidu.com/i?ct=201326592&cl=2&nc=1&lm=-1&st=-1&tn=baiduimagejson&istype=2&pv=&z=0&ie=utf-8&cg=wallpaper&width=1440&height=900&z=&rn=120"

#endif
