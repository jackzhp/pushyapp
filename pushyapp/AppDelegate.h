//
//  AppDelegate.h
//  pushyapp
//
//  Created by yogi on 3/22/20.
//  Copyright © 2020 yogi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (readonly, strong) NSPersistentCloudKitContainer *persistentContainer;

- (void)saveContext;


@end

