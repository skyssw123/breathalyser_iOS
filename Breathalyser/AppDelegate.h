//
//  AppDelegate.h
//  Breathalyser
//
//  Created by Thomas Sin on 2017-02-25.
//  Copyright © 2017 sin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

