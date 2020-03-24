//
//  NBannoucement.m
//  pushyapp
//
//  Created by yogi on 3/23/20.
//  Copyright © 2020 yogi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NBannouncement.h"
#import <BackgroundTasks/BackgroundTasks.h>
#import <CoreData/NSPersistentContainer.h>


static NSString *idPullAnnouncement=@"com.zed.pushyapp.pullAnnoucement";
static int scheduleInterval=20;
static NBannouncement *a;


@implementation NBannouncement{
    BGAppRefreshTask *task0;
    void (^completionHandler)(UIBackgroundFetchResult result);
    NSURLSessionDownloadTask *task;

}

+(void)scheduleToPull{
    BGAppRefreshTaskRequest *request=[[BGAppRefreshTaskRequest alloc] initWithIdentifier:idPullAnnouncement];
    request.earliestBeginDate=[NSDate dateWithTimeIntervalSinceNow:scheduleInterval]; //in seconds, so 60*60 is 1 hour
    NSError *error;
    BOOL bok=[BGTaskScheduler.sharedScheduler submitTaskRequest:request error:&error];
    if(bok){
        NSLog(@"scheduled for:%d",scheduleInterval);
    }else{
        NSLog(@"scheduled with error:%@",error);
    }
}

+(void)registerTask{
    BOOL bok=[BGTaskScheduler.sharedScheduler registerForTaskWithIdentifier:idPullAnnouncement
                                                        usingQueue:nil //to use a default background queue
                                                     launchHandler:^(__kindof BGTask * _Nonnull task) {
        // Downcast the parameter to an app refresh task as this identifier is used for a refresh request.
        NSLog(@"laucning bk task");
        [NBannouncement scheduleToPull];
        [NBannouncement doPull1:task];
    }];
    NSLog(@"registered:%d", bok);
}
+(void)doPull0:(void (^)(UIBackgroundFetchResult result))completionHandler { //TODO: how to schedule to repeat this?
  a=[[NBannouncement alloc]init];
  a->completionHandler=completionHandler; [a doPull];
}
+(void)doPull1:(BGAppRefreshTask *)task0{
    a=[[NBannouncement alloc]init];
    a->task0=task0;
    //    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    //    queue.maxConcurrentOperationCount = 1;
    //    NSManagedObjectContext *context=nil;// [[NSPersistentContainer sh]newBackgroundContext];
    //    OperationPull *o=[[OperationPull alloc]initWithTarget:a selector:@selector(doPull) object:nil];
    //    task.expirationHandler = ^{
    //        // After all operations are cancelled, the completion block below is called to set the task to complete.
    //        [queue cancelAllOperations];
    //    };
    //    o.completionBlock = ^{
    //        [task setTaskCompletedWithSuccess:o.success];
    //    };
    //    [queue addOperation:o];
    [a doPull];
    task0.expirationHandler = ^{
        [a->task cancel];
        //TODO: this is too bad.
    };
}
-(void)doPull{
    NSURLSession *urlsession;//=[ManagerCache getSession];
    NSURLSessionConfiguration *cfg=   [NSURLSessionConfiguration defaultSessionConfiguration];
    cfg.URLCache=nil;
    cfg.requestCachePolicy =NSURLRequestReloadIgnoringLocalCacheData;
    //q should be serial to avoid many concurrent issues.
    NSString *url_s=@"http://www.google.com";
    urlsession=[NSURLSession sessionWithConfiguration:cfg delegate:self delegateQueue:[NSOperationQueue mainQueue]]; //
    
    NSString *url_st=[NSString stringWithFormat:@"%@?t=%f",url_s,[NSDate date].timeIntervalSince1970];
    NSURL *ourl=[NSURL URLWithString:url_st];
    //http://192.168.1.152:8080/wz_pj_h5_20191119/res/raw-assets/resources/paigow/ui_menu/texture/玩法.c2b6a.png
    //_path    __NSCFString *    @"/res/raw-assets/resources/public/textures/login/btn_ traveler.6bd7b.png"    0x0000600001a67d20
    if(ourl){
        task=[urlsession downloadTaskWithURL:ourl];
    }else{
        //TODO: on failed
        
        return;
    }
    [task resume];
}
//NSURLSessionDownloadDelegate
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    NSLog(@"resume is called %lld/%lld",fileOffset,expectedTotalBytes); //this is called, but I did not see progress updating
}

//#pragma mark NSURLSessionDownloadDelegate implementation

-(void)URLSession:(NSURLSession *)session      downloadTask:(NSURLSessionDownloadTask *)downloadTask
     didWriteData:(int64_t)bytesWritten  totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    if(downloadTask){
        NSLog(@"total not same: %lld/ %lld",totalBytesWritten,  totalBytesExpectedToWrite);
    }
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location{
    NSLog(@"end of finished:%@",location);
    //Now create local notification.
    if(task0){
        [task0 setTaskCompletedWithSuccess:YES];
    }else if(completionHandler){
        completionHandler(UIBackgroundFetchResultNewData);
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error{ //for client side error
    if(error){}else return; //this is called with error ==nil after finished is called
    NSLog(@"download error:%@",error);
}

@end
