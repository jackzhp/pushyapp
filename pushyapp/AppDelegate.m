//
//  AppDelegate.m
//  pushyapp
//
//  Created by yogi on 3/22/20.
//  Copyright © 2020 yogi. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "NBannouncement.h"

@interface AppDelegate ()

@end
NBannouncement *a;

@implementation AppDelegate

//- (void)applicationWillEnterForeground:(UIApplication *)application API_AVAILABLE(ios(4.0)){
//        [NBannouncement scheduleToPull];
//    }
//- (void)applicationWillEnterBackground:(UIApplication *)application API_AVAILABLE(ios(4.0)){
//    [NBannouncement scheduleToPull];
//
//}

//scene based, the following one will not be called.
- (void)applicationDidEnterBackground:(UIApplication *)application API_AVAILABLE(ios(4.0)){
    NSLog(@"did enter background");
    [NBannouncement scheduleToPull];

}

/* Applications with the "fetch" background mode may be given opportunities to fetch updated content in the background or when it is convenient for the system. This method will be called in these situations. You should call the fetchCompletionHandler as soon as you're finished performing that operation, so the system can accurately estimate its power and data cost.
 */
-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler API_DEPRECATED("Use a BGAppRefreshTask in the BackgroundTasks framework instead", ios(7.0, 13.0), tvos(11.0, 13.0)){
    [NBannouncement doPull0:completionHandler];
}

//beginBackgroundTaskWithExpirationHandler I never call it though
- (void)endBackgroundTask:(UIBackgroundTaskIdentifier)identifier{
    NSLog(@"end bktask:%lu",(unsigned long)identifier);
}


- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(nullable NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions API_AVAILABLE(ios(6.0)){
    UNUserNotificationCenter.currentNotificationCenter.delegate=self; //application.keyWindow.rootViewController;
    NSLog(@"delegate:%@",UNUserNotificationCenter.currentNotificationCenter.delegate);
//    a=[[NBannouncement alloc]init];
    [NBannouncement registerTask];
//    [NBannouncement scheduleToPull];
    return YES;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    application.applicationIconBadgeNumber=0;
    UILocalNotification *localNotif=launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
    if(localNotif){
        [self onReceived:localNotif ViewController:application.keyWindow.rootViewController state:@"received on launch"];
    }else{ //this branch is execute in ios 13.3
//        UIAlertController * ac=[UIAlertController alertControllerWithTitle:@"can not find in the option" message:@"not in options" preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *aa=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
//        [ac addAction:aa];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [application.keyWindow.rootViewController presentViewController:ac animated:YES completion:nil ];
//        });
        NSLog(@"launched without the option");   }
    return YES;
}

-(void)onReceived:(UILocalNotification *)localNotif ViewController:(UIViewController *)root state:(NSString *)state{
    NSLog(@"old way, delegate:%@",UNUserNotificationCenter.currentNotificationCenter.delegate);

    UIAlertController * ac=[UIAlertController alertControllerWithTitle:state message:localNotif.alertBody preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *aa=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [ac addAction:aa];
    dispatch_async(dispatch_get_main_queue(), ^{
        [root presentViewController:ac animated:YES completion:nil ];
    });

}


//-(void) application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
//    application.applicationIconBadgeNumber=0;
//    [self onReceived:notification ViewController:application.keyWindow.rootViewController state:@"received while running"];
//}

//@protocol UNUserNotificationCenterDelegate <NSObject>
// The method will be called on the delegate only if the application is in the foreground. If the method is not implemented or the handler is not called in a timely manner then the notification will not be presented. The application can choose to have the notification presented as a sound, badge, alert and/or in the notification list. This decision should be based on whether the information in the notification is otherwise visible to the user.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler __API_AVAILABLE(macos(10.14), ios(10.0), watchos(3.0), tvos(10.0)){
    NSLog(@"will present is called, app foreground");
    completionHandler(UNNotificationPresentationOptionAlert);
}

// The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from application:didFinishLaunchingWithOptions:.
//this is called when received while running? it is called once, but I can not figure out when it is called.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler __API_AVAILABLE(macos(10.14), ios(10.0), watchos(3.0)) __API_UNAVAILABLE(tvos){
    NSLog(@"received response:%@",response);
    // Get the meeting ID from the original notification.
    NSDictionary<NSString*,NSString*> * userInfo = response.notification.request.content.userInfo;
    NSString *meetingID = userInfo[@"name1"];
    NSString *userID = userInfo[@"name2"];
    
    // Perform the task associated with the action.
    NSString *ar=response.actionIdentifier;
    NSLog(@"action:%@",ar);
    if([ar isEqualToString:@"Accept"]){
    }else if([ar isEqualToString:@"Reject"]){
    }else if([ar isEqualToString:@"com.apple.UNNotificationDefaultActionIdentifier"]){
    }
    // Always call the completion handler when done.
    completionHandler();
}

// The method will be called on the delegate when the application is launched in response to the user's request to view in-app notification settings. Add UNAuthorizationOptionProvidesAppNotificationSettings as an option in requestAuthorizationWithOptions:completionHandler: to add a button to inline notification settings view and the notification settings view in Settings. The notification will be nil when opened from Settings.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(nullable UNNotification *)notification __API_AVAILABLE(macos(10.14), ios(12.0)) __API_UNAVAILABLE(watchos, tvos){
    NSLog(@"openSettings is called");
    
}


-(void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void (^)(void))completionHandler{
    
    [self onReceived:notification ViewController:application.keyWindow.rootViewController state:@"on action"];
    
    
}
#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentCloudKitContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentCloudKitContainer alloc] initWithName:@"pushyapp"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end
