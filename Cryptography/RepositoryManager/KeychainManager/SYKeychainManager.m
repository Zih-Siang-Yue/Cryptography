//
//  KeychainManager.m
//  BCSDK
//
//  Created by Sean.Yue on 2019/5/24.
//  Copyright © 2019 skyline. All rights reserved.
//

#import "SYKeychainManager.h"

@interface SYKeychainManager()

@end

@implementation SYKeychainManager

#pragma mark - private

+ (NSMutableDictionary*)getKeychainQuery:(NSString*)service {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (id)kSecClassGenericPassword, (id)kSecClass,
            service, (id)kSecAttrService,
            service, (id)kSecAttrAccount,
            (id)kSecAttrAccessibleAfterFirstUnlock, (id)kSecAttrAccessible,
            nil];
}

#pragma mark - public

+ (void)save:(NSString*)service data:(id<NSCoding, NSSecureCoding>)data {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((CFDictionaryRef) keychainQuery);
    [keychainQuery setObject:[self convertObjToData:data] forKey:(id)kSecValueData];
    SecItemAdd((CFDictionaryRef)keychainQuery, NULL);
}

+ (id)load:(NSString*)service {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    
    id ret = nil;
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((CFDictionaryRef)keychainQuery, (CFTypeRef*)&keyData) == noErr) {
        @try {
            ret = [self convertDataToObj:(__bridge NSData*)keyData];
        } @catch (NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", service, e);
        } @finally {
            
        }
    }
    if (keyData)
        CFRelease(keyData);
    
    return ret;
}

+ (void)delete:(NSString*)service {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((CFDictionaryRef)keychainQuery);
}

#pragma mark - misc

+ (nullable NSData *)convertObjToData:(id<NSCoding>)obj {
    NSData *data;
    if (@available(iOS 12.0, *)) {
        data = [NSKeyedArchiver archivedDataWithRootObject:obj requiringSecureCoding:NO error:nil];
    }
    else {
        data = [NSKeyedArchiver archivedDataWithRootObject:obj];
    }
    return data;
}

+ (nullable id)convertDataToObj:(NSData *)data {
    NSObject *obj;
    if (@available(iOS 12.0, *)) {
        obj = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSObject class] fromData:data error:nil];
    }
    else {
        obj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return obj;
}


@end
