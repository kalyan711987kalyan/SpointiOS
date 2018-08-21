//
//  UIViewController+Alerts.m
//  Spoint
//
//  Created by kalyan on 06/11/17.
//  Copyright © 2017 Personal. All rights reserved.
//

#import "UIViewController+Alerts.h"
#import <objc/runtime.h>

/*! @var kPleaseWaitAssociatedObjectKey
 @brief Key used to identify the "please wait" spinner associated object.
 */
static NSString *const kPleaseWaitAssociatedObjectKey =
@"_UIViewControllerAlertCategory_PleaseWaitScreenAssociatedObject";

/*! @var kOK
 @brief Text for an 'OK' button.
 */
static NSString *const kOK = @"OK";

/*! @var kCancel
 @brief Text for an 'Cancel' button.
 */
static NSString *const kCancel = @"Cancel";

/*! @class SimpleTextPromptDelegate
 @brief A @c UIAlertViewDelegate which allows @c UIAlertView to be used with blocks more easily.
 */


@implementation UIViewController (Alerts)

- (void)showSpinner:(nullable void (^)(void))completion {

    [self showModernSpinner:completion];

}


- (void)showModernSpinner:(nullable void (^)(void))completion {
    UIAlertController *pleaseWaitAlert =
    objc_getAssociatedObject(self, (__bridge const void *)(kPleaseWaitAssociatedObjectKey));
    if (pleaseWaitAlert) {
        if (completion) {
            completion();
        }
        return;
    }
    pleaseWaitAlert = [UIAlertController alertControllerWithTitle:nil
                                                          message:@"Please Wait...\n\n\n\n"
                                                   preferredStyle:UIAlertControllerStyleAlert];

    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
                                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.color = [UIColor blackColor];
    spinner.center = CGPointMake(pleaseWaitAlert.view.bounds.size.width / 2,
                                 pleaseWaitAlert.view.bounds.size.height / 2);
    spinner.autoresizingMask =
    UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [spinner startAnimating];
    [pleaseWaitAlert.view addSubview:spinner];

    objc_setAssociatedObject(self, (__bridge const void *)(kPleaseWaitAssociatedObjectKey),
                             pleaseWaitAlert, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self presentViewController:pleaseWaitAlert animated:YES completion:completion];
}
- (void)hideSpinner:(nullable void (^)(void))completion {

    [self hideModernSpinner:completion];
}

- (void)hideModernSpinner:(nullable void (^)(void))completion {
    UIAlertController *pleaseWaitAlert =
    objc_getAssociatedObject(self, (__bridge const void *)(kPleaseWaitAssociatedObjectKey));

    [pleaseWaitAlert dismissViewControllerAnimated:YES completion:completion];

    objc_setAssociatedObject(self, (__bridge const void *)(kPleaseWaitAssociatedObjectKey), nil,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
