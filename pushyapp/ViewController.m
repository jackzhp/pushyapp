//
//  ViewController.m
//  pushyapp
//
//  Created by yogi on 3/22/20.
//  Copyright © 2020 yogi. All rights reserved.
//

#import "ViewController.h"
#import <UserNotifications/UserNotifications.h>


@interface ViewController ()

-(void)requestPermissionToNotify;
-(void)createNotification:(int)secondsInFuture;
@end

@implementation ViewController


- (IBAction)scheduleNotification:(id)sender {
    [self requestPermissionToNotify];
    [self createNotification:5];
}


BOOL useOld=NO;

-(void)requestPermissionToNotify{
    if(useOld){
        UIMutableUserNotificationAction *floatAction=[[UIMutableUserNotificationAction alloc] init];
        floatAction.identifier=@"float";
        floatAction.title=@"float";
        floatAction.activationMode=UIUserNotificationActivationModeBackground;
        floatAction.destructive=YES;
        floatAction.authenticationRequired=NO;
        
        UIMutableUserNotificationAction *stingAction=[[UIMutableUserNotificationAction alloc] init];
        stingAction.identifier=@"sting";
        stingAction.title=@"sting";
        stingAction.activationMode=UIUserNotificationActivationModeForeground;
        stingAction.destructive=NO;
        stingAction.authenticationRequired=NO;
        
        UIMutableUserNotificationCategory *category=[[UIMutableUserNotificationCategory alloc]init];
        category.identifier=@"main category";
        [category setActions:@[floatAction, stingAction] forContext:UIUserNotificationActionContextDefault];
        
        NSSet *categories=[NSSet setWithArray:@[category]];
        
        UIUserNotificationType types=UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings=[UIUserNotificationSettings settingsForTypes:types categories:categories];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }else{
        UNAuthorizationOptions options=UNAuthorizationOptionBadge|UNAuthorizationOptionSound|UNAuthorizationOptionAlert;
        [UNUserNotificationCenter.currentNotificationCenter requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if(error){
                //TODO: ...
            }else if(granted){
                [self onNotificationGranted];
            }else{
                
                //TODO:
            }
            
        }];
    }
    
}
-(void)onNotificationGranted{
    NSLog(@"permit to notify is granted");
    UNNotificationAction *aAccept=[UNNotificationAction actionWithIdentifier:@"Accept" title:@"Accept" options:UNNotificationActionOptionForeground];
    UNNotificationAction *aReject=[UNNotificationAction actionWithIdentifier:@"Reject" title:@"Reject" options:UNNotificationActionOptionNone];
    // Define the notification type
    UNNotificationCategory *category=[UNNotificationCategory categoryWithIdentifier:@"ar" actions:@[aAccept,aReject] intentIdentifiers:@[] hiddenPreviewsBodyPlaceholder:@"" options:UNNotificationCategoryOptionCustomDismissAction];// options:UNNotificationCategoryOptionNone];
    //    let meetingInviteCategory =
    //          UNNotificationCategory(identifier: "MEETING_INVITATION",
    //          actions: [acceptAction, declineAction],
    //          intentIdentifiers: [],
    //          hiddenPreviewsBodyPlaceholder: "",
    //          options: .customDismissAction)
    // Register the notification type.
    [UNUserNotificationCenter.currentNotificationCenter setNotificationCategories:[NSSet setWithArray:@[category]]];
    
}

-(void)createNotification:(int)secondsInFuture{
    if(useOld){
        UILocalNotification *localNotif=[[UILocalNotification alloc]init];
        localNotif.fireDate=[[NSDate date] dateByAddingTimeInterval:secondsInFuture];
        localNotif.timeZone=nil;
        localNotif.alertTitle=@"Alert title";
        localNotif.alertBody=@"Alert body";
        localNotif.alertAction=@"OK";
        localNotif.soundName=UILocalNotificationDefaultSoundName;
        localNotif.applicationIconBadgeNumber=100;
        localNotif.category=@"main";
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    }else{
        NSLog(@"will create notification with new:%@",UNUserNotificationCenter.currentNotificationCenter.delegate);
        UNMutableNotificationContent *nc=[[UNMutableNotificationContent alloc]init];
        nc.title=@"Weekly Staff Meeting";
        nc.body=@"body";
        nc.sound=UNNotificationSound.defaultSound;
        nc.userInfo=[NSDictionary dictionaryWithObjectsAndKeys:@"someid", @"name1",@"value2",@"name2", nil];
        nc.categoryIdentifier = @"ar";
        UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:secondsInFuture repeats: NO];
        UNNotificationRequest *nr=[UNNotificationRequest requestWithIdentifier:@"1234" content:nc trigger:trigger];
        
        [UNUserNotificationCenter.currentNotificationCenter addNotificationRequest:nr withCompletionHandler:^(NSError * _Nullable error) {
            NSLog(@"scheduled with error:%@",error);
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


@end
