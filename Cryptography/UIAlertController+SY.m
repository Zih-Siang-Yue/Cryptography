//
//  UIAlertController+SY.m
//  hostApp
//
//  Created by Sean.Yue on 2019/5/13.
//  Copyright © 2019 skyline. All rights reserved.
//

#import "UIAlertController+SY.h"
#import <objc/runtime.h>

@interface UIAlertController (SY)

@property (strong, nonatomic) UIWindow *alertWindow;

@end

@implementation UIAlertController (SY)

@dynamic alertWindow;

- (void)setAlertWindow:(UIWindow *)alertWindow {
    objc_setAssociatedObject(self, @selector(alertWindow), alertWindow, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIWindow *)alertWindow {
    return objc_getAssociatedObject(self, @selector(alertWindow));
}

@end

@implementation UIAlertController (StayFun)

#pragma mark - public

+ (UIAlertController*)showTitle:(NSString*)title msg:(nullable NSString*)msg {
    return [UIAlertController showTitle:title msg:msg style:UIAlertControllerStyleAlert];
}

+ (UIAlertController*)showTitle:(NSString*)title msg:(nullable NSString*)msg style:(UIAlertControllerStyle)style {
    return [UIAlertController showTitle:title msg:msg style:style btnTitle:@"OK" btnStyle:UIAlertActionStyleDefault];
}

+ (UIAlertController*)showTitle:(NSString*)title msg:(nullable NSString*)msg style:(UIAlertControllerStyle)style
                       btnTitle:(NSString*)btnTitle btnStyle:(UIAlertActionStyle)btnStyle {
    return [UIAlertController showTitle:title msg:msg style:style btnTitle:btnTitle btnStyle:btnStyle btnAction:nil];
}

+ (UIAlertController*)showTitle:(NSString*)title msg:(nullable NSString*)msg style:(UIAlertControllerStyle)style
                       btnTitle:(NSString*)btnTitle btnStyle:(UIAlertActionStyle)btnStyle btnAction:(nullable TapAction)btnAction {
    return [UIAlertController showTitle:title msg:msg okBtnTitle:btnTitle okAction:btnAction cancelBtnTitle:nil cancelAction:nil];
}

+ (UIAlertController*)showTitle:(NSString*)title msg:(nullable NSString*)msg
                     okBtnTitle:(NSString*)okTitle okAction:(nullable TapAction)okAction
                 cancelBtnTitle:(nullable NSString*)cancelTitle cancelAction:(nullable TapAction)cancelAction {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:okAction];
    [alert addAction:ok];
    
    if (cancelTitle) {
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleDefault handler:cancelAction];
        [alert addAction:cancel];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert showWithAnimated:YES];
    });
    return alert;
}

#pragma mark - present

- (void)showWithAnimated:(BOOL)animated {
    self.alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.alertWindow.rootViewController = [[UIViewController alloc] init];
    
    id<UIApplicationDelegate> delegate = [UIApplication sharedApplication].delegate;
    if ([delegate respondsToSelector:@selector(window)]) {
        // we inherit the main window's tintColor
        self.alertWindow.tintColor = delegate.window.tintColor;
    }
    
    // window level is above the top window (this makes the alert, if it's a sheet, show over the keyboard)
    UIWindow *topWindow = [UIApplication sharedApplication].windows.lastObject;
    self.alertWindow.windowLevel = topWindow.windowLevel + 1;
    
    [self.alertWindow makeKeyAndVisible];
    __weak typeof (self) wSelf = self;
    [self.alertWindow.rootViewController presentViewController:self animated:animated completion:^{
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:wSelf action:@selector(dismiss)];
        [wSelf.view.superview addGestureRecognizer:tap];
    }];
}

#pragma mark - dismiss

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - life cycle

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.alertWindow.hidden = YES;
    self.alertWindow = nil;
}

@end
