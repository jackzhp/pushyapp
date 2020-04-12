//
//  ViewController.m
//  pushyapp
//
//  Created by yogi on 3/22/20.
//  Copyright © 2020 yogi. All rights reserved.
//

#import "ViewController.h"
#import <UserNotifications/UserNotifications.h>
#import "NBannouncement.h"


@interface ViewController ()

-(void)requestPermissionToNotify;
@end

@implementation ViewController


- (IBAction)scheduleNotification:(id)sender {
    [self requestPermissionToNotify];
    [NBannouncement createNotification:5];
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


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


@end
