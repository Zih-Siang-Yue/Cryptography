//
//  RepositoryManager.h
//  BCSDK
//
//  Created by Sean.Yue on 2019/6/21.
//  Copyright © 2019 skyline. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SYRepositoryManager : NSObject

#pragma mark - save
+ (void)saveStr:(NSString *)str forKey:(NSString *)key;
+ (void)saveObject:(id<NSCoding>)object forKey:(NSString *)key;
+ (void)saveData:(NSData *)data forKey:(NSString *)key;

#pragma mark - load
+ (NSString *)loadStrForKey:(NSString *)key;
+ (id)loadObjectForKey:(NSString *)key;
+ (NSData *)loadDataForKey:(NSString *)key;

#pragma mark - delete
+ (void)deleteForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
