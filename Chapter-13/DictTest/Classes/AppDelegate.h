//
//  AppDelegate.h
//  DictTest
//
//  Created by Wagner Truppel on 4/14/09.
//  Copyright Wagner Truppel 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegate: NSObject <UIApplicationDelegate>
{
    @private

        IBOutlet UIWindow* window;
        IBOutlet ViewController* viewController;
}

@property (nonatomic, retain) UIWindow* window;
@property (nonatomic, retain) ViewController* viewController;

@end
