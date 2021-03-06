//
//  AppInfo.m
//  Tjfa
//
//  Created by 邱峰 on 6/29/14.
//  Copyright (c) 2014 邱峰. All rights reserved.
//

#import "AppInfo.h"

@implementation AppInfo

+ (NSString*)appName
{
    return @"一键加86";
}

+ (NSString*)appDownloadAddress
{

    NSString* str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id=%@", [AppInfo appId]];
    return str;
}

+ (NSString*)appId
{
    NSString* appid = @"898552525";
    return appid;
}

+ (NSString*)appVersion
{
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString* app_Version = [infoDictionary objectForKey:@"CFBundleVersion"];
    return app_Version;
}

@end
