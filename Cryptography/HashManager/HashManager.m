//
//  HashManager.m
//  Cryptography
//
//  Created by Sean.Yue on 2019/7/8.
//  Copyright © 2019 Sean.Yue. All rights reserved.
//

#import "HashManager.h"
#import <CommonCrypto/CommonDigest.h>

@implementation HashManager

+ (NSString *)md5:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, strlen(cStr), digest);

    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    NSData *dataFromByte = [[NSData alloc] initWithBytes:digest length:CC_MD5_DIGEST_LENGTH];
    NSData *dataFromStr = [output dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"dataFromByte: %@, dataFromStr: %@", dataFromByte, dataFromStr);
    return output;
}

//+ (NSData *)md5Data:(NSString *)str {
//    const char *cStr = [str UTF8String];
//    unsigned char digest[CC_MD5_DIGEST_LENGTH];
//    CC_MD5(cStr, strlen(cStr), digest);
//
//    return [[NSData alloc] initWithBytes:digest length:CC_MD5_DIGEST_LENGTH];
//}

//+ (unsigned char)md5:(NSString *)str {
//    const char *cStr = [str UTF8String];
//    unsigned char digest[CC_MD5_DIGEST_LENGTH];
//    CC_MD5(cStr, strlen(cStr), digest);
//    return digest;
//}

+ (NSString *)sha1:(NSString *)str {
    const char *cStr = [str cStringUsingEncoding:NSUTF8StringEncoding];
    
    NSData *data = [NSData dataWithBytes:cStr length:str.length];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}

@end
