//
//  DNWaitView.h
//  NinjaChat
//
//  Created by Dan Leoanrd on 2/5/2015.
//  Copyright (c) 2015 DeviceNinja. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * A HUD-like modal wait spinner for blocking UI operations
 */
@interface DNWaitView : UIView

/**
 * Display the wait view in center of the parent view with the 
 * given status text
 */
- (void)showWithText:(NSString *)text;

/**
 * Hide the wait view
 */
- (void)hide;

@end
