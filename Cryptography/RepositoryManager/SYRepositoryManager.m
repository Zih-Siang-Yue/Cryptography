//
//  RepositoryManager.m
//  BCSDK
//
//  Created by Sean.Yue on 2019/6/21.
//  Copyright © 2019 skyline. All rights reserved.
//

#import "SYRepositoryManager.h"
#import "SYKeychainManager.h"
#import "NSData+AESAdditions.h"
#import "NSData+MBBase64.h"


@implementation SYRepositoryManager

NSString *primaryKey() {
    //TODO: 用組合的方式不要hard code
    return @"4053995405399500";
}

NSString *packageKey() {
//    NSString *key = @"1qaz2wsx3edc4rfv";
//
//    NSData *dataOriginal = [key dataUsingEncoding:NSUTF8StringEncoding];
//    NSData *encryptedData = [dataOriginal AES128EncryptWithKey:primaryKey()];
//    NSString *base64Str = encryptedData.base64Encoding;

    NSString *base64Key = @"23icg4+AkvuI0Lzi4sI9/MQh9K/0Cen1mh9bO0oLJjo=";
    NSData *encryptedData1 = [NSData dataWithBase64EncodedString:base64Key];
    NSData *decryptedData = [encryptedData1 AES128DecryptWithKey:primaryKey()];
    return [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
}

#pragma mark < public >

#pragma mark - save

+ (void)saveStr:(NSString *)str forKey:(NSString *)key {
    [SYKeychainManager save:key data:[self encryptBase64:str]];
}

+ (void)saveObject:(id<NSCoding>)object forKey:(NSString *)key {
    NSData *data = [SYKeychainManager convertObjToData:object];
    [self saveData:data forKey:key];
}

+ (void)saveData:(NSData *)data forKey:(NSString *)key {
    NSData *encryptedData = [data AES128EncryptWithKey:packageKey()];
    [SYKeychainManager save:key data:encryptedData];
}

#pragma mark - load

+ (NSString *)loadStrForKey:(NSString *)key {
    NSData *encryptedData = [SYKeychainManager load:key];
    return [self decryptBase64:encryptedData];
}

+ (id)loadObjectForKey:(NSString *)key {
    return [SYKeychainManager convertDataToObj:[self loadDataForKey:key]];
}

+ (NSData *)loadDataForKey:(NSString *)key {
    NSData *encyptedData = [SYKeychainManager load:key];
    return [encyptedData AES128DecryptWithKey:packageKey()];
}

#pragma mark - delete

+ (void)deleteForKey:(NSString *)key {
    [SYKeychainManager delete:key];
}

#pragma mark < private >

+ (NSData *)encryptBase64:(NSString *)str {
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptedData = [data AES128EncryptWithKey:packageKey()];
    NSData *encodeData = [encryptedData base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return encodeData;
}

+ (NSString *)decryptBase64:(NSData *)data {
    NSData *decodeData = [[NSData alloc] initWithBase64EncodedData:data options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSData *decryptedData = [decodeData AES128DecryptWithKey:packageKey()];
    return [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
}

@end
