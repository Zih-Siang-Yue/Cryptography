//
//  KeychainManager.h
//  BCSDK
//
//  Created by Sean.Yue on 2019/5/24.
//  Copyright © 2019 skyline. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SYKeychainManager : NSObject

+ (void)save:(NSString*)service data:(id<NSCoding, NSSecureCoding>)data;
+ (id)load:(NSString*)service;
+ (void)delete:(NSString*)service;

+ (nullable NSData *)convertObjToData:(id<NSCoding>)obj;
+ (nullable id)convertDataToObj:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
