//
//  HashManager.h
//  Cryptography
//
//  Created by Sean.Yue on 2019/7/8.
//  Copyright © 2019 Sean.Yue. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HashManager : NSObject

+ (NSString *)md5:(NSString *)str;
+ (NSString *)sha1:(NSString *)str;

@end

NS_ASSUME_NONNULL_END
