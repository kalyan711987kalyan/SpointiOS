//
//  UIViewController+Alerts.h
//  Spoint
//
//  Created by kalyan on 06/11/17.
//  Copyright © 2017 Personal. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^AlertPromptCompletionBlock)(BOOL userPressedOK, NSString *_Nullable userInput);

@interface UIViewController (Alerts)
- (void)showSpinner:(nullable void (^)(void))completion;

/*! @fn hideSpinner
 @brief Hides the please wait spinner.
 @param completion Called after the spinner has been hidden.
 */
- (void)hideSpinner:(nullable void (^)(void))completion;

@end
