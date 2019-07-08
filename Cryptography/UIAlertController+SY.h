//
//  UIAlertController+SY.h
//  hostApp
//
//  Created by Sean.Yue on 2019/5/13.
//  Copyright © 2019 skyline. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TapAction)(UIAlertAction *action);

NS_ASSUME_NONNULL_BEGIN

@interface UIAlertController (SY)

+ (UIAlertController*)showTitle:(NSString*)title msg:(nullable NSString*)msg;
+ (UIAlertController*)showTitle:(NSString*)title msg:(nullable NSString*)msg style:(UIAlertControllerStyle)style;
+ (UIAlertController*)showTitle:(NSString*)title msg:(nullable NSString*)msg style:(UIAlertControllerStyle)style
                       btnTitle:(NSString*)btnTitle btnStyle:(UIAlertActionStyle)btnStyle;
+ (UIAlertController*)showTitle:(NSString*)title msg:(nullable NSString*)msg style:(UIAlertControllerStyle)style
                       btnTitle:(NSString*)btnTitle btnStyle:(UIAlertActionStyle)btnStyle btnAction:(nullable TapAction)btnAction;
+ (UIAlertController*)showTitle:(NSString*)title msg:(nullable NSString*)msg
                     okBtnTitle:(NSString*)okTitle okAction:(nullable TapAction)okAction
                 cancelBtnTitle:(nullable NSString*)cancelTitle cancelAction:(nullable TapAction)cancelAction;
@end

NS_ASSUME_NONNULL_END
