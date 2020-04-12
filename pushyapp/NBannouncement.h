//
//  NBannouncement.h
//  pushyapp
//
//  Created by yogi on 3/23/20.
//  Copyright © 2020 yogi. All rights reserved.
//

#ifndef NBannouncement_h
#define NBannouncement_h
#import <UIKit/UIApplication.h>

@interface NBannouncement:NSObject<NSURLSessionDownloadDelegate>

+(void)registerTask;
+(void)scheduleToPull;
+(void)doPull0:(void (^)(UIBackgroundFetchResult result))completionHandler;

+(void)createNotification:(int)secondsInFuture;

@end

#endif /* NBannouncement_h */
