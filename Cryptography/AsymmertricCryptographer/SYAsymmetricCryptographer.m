//
//  CryptographyManager.m
//  CryptographyManager
//
//  Created by Sean.Yue on 2019/6/18.
//  Copyright © 2019 Sean.Yue. All rights reserved.
//

#import "SYAsymmetricCryptographer.h"
#import <CommonCrypto/CommonCryptor.h>

@interface SYAsymmetricCryptographer()

@property (strong, nonatomic) NSNumber *keySize;

@end

@implementation SYAsymmetricCryptographer

#pragma mark - init

- (instancetype)init {
    self = [super init];
    if (self) {
        //Defalut
        self.keyTag = @"com.AsymmetricCrypto.rsa.keypair";
        self.keyType = kSecAttrKeyTypeRSA;
    }
    return self;
}

#pragma mark - getter

- (BOOL)isKeyPairExists {
    return [self getKeyRef:kSecAttrKeyClassPublic] != nil;
}

#pragma mark - public

- (void)generateKeyPairWithKeySize:(NSNumber *)size result:(CMResult)result {
    self.keySize = size;
    [self asymmertricGenerate:result];
}

- (void)deleteKeyPair:(CMResult)result {
    __weak typeof (self) wSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *params = @{(__bridge id)kSecClass: (__bridge id)kSecClassKey,
                                 (__bridge id)kSecAttrApplicationTag: self.keyTag
                                 };
        
        OSStatus status = SecItemDelete((CFDictionaryRef)params);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == errSecSuccess) {
                wSelf.keySize = nil;
            }
            result(status == errSecSuccess);
        });
    });
}

#pragma mark - encrypt

- (void)encryptWithString:(NSString *)str completion:(CMCompletion)completion {
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    if (data) {
        [self encryptWithData:data completion:completion];
    }
    else {
        completion(false, nil, CMErrorWrongInputDataFormat);
    }
}

- (void)encryptWithData:(NSData *)data completion:(CMCompletion)completion {
    //override
}

#pragma mark - decrypt

- (void)decryptWithString:(NSString *)str completion:(CMCompletion)completion {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:str options:0];
    if (data) {
        [self decryptWithData:data completion:completion];
    }
    else {
        completion(false, nil, CMErrorWrongInputDataFormat);
    }
}

- (void)decryptWithData:(NSData *)data completion:(CMCompletion)completion {
    //override
}

#pragma mark - signature

- (void)signWithString:(NSString *)str completion:(CMCompletion)completion {
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    if (data) {
        [self signWithData:data completion:completion];
    }
    else {
        completion(false, nil, CMErrorWrongInputDataFormat);
    }
}

- (void)signWithData:(NSData *)data completion:(CMCompletion)completion {
    //override
}

#pragma mark - verify

- (void)verifySign:(NSString *)sign originStr:(NSString *)originStr completion:(CMCompletion)completion {
    NSData *signData = [[NSData alloc] initWithBase64EncodedString:sign options:0];
    NSData *originData = [originStr dataUsingEncoding:NSUTF8StringEncoding];
    if (signData && originData) {
        [self verifySignData:signData originData:originData completion:completion];
    }
    else {
        completion(false, nil, CMErrorWrongInputDataFormat);
    }
}

- (void)verifySignData:(NSData *)signData originData:(NSData *)originData completion:(CMCompletion)completion {
    //override
}

#pragma mark - private

- (void)asymmertricGenerate:(CMResult)result {
    NSDictionary *pubKeyParams = @{(__bridge id)kSecAttrIsPermanent: @(YES),
                                      (__bridge id)kSecAttrApplicationTag: self.keyTag
                                      };
    NSDictionary *priKeyParams = @{(__bridge id)kSecAttrIsPermanent: @(YES),
                                       (__bridge id)kSecAttrApplicationTag: self.keyTag
                                       };
    NSDictionary *params = @{(__bridge id)kSecAttrKeyType: (__bridge id)self.keyType,
                             (__bridge id)kSecAttrKeySizeInBits: self.keySize,
                             (__bridge id)kSecPublicKeyAttrs: pubKeyParams,
                             (__bridge id)kSecPrivateKeyAttrs: priKeyParams
                             };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        SecKeyRef pubKey, priKey;
        OSStatus status = SecKeyGeneratePair((CFDictionaryRef)params, &pubKey, &priKey);
        if (status == errSecSuccess) {
            NSLog(@"generate successfully: pubKey -> %@, priKey -> %@", pubKey, priKey);
        }
        result(status == errSecSuccess);
    });
}

- (__nullable SecKeyRef)getKeyRef:(CFStringRef)keyClass {
    //keyClass -> e.g: kSecAttrKeyClassPublic / kSecAttrKeyClassPrivate
    //keyType -> e.g: kSecAttrKeyTypeRSA / kSecAttrKeyTypeEC
    NSDictionary *params = @{(__bridge id)kSecClass: (__bridge id)kSecClassKey,
                             (__bridge id)kSecAttrKeyType: (__bridge id)self.keyType,
                             (__bridge id)kSecAttrApplicationTag: self.keyTag,
                             (__bridge id)kSecAttrKeyClass: (__bridge id)keyClass,
                             (__bridge id)kSecReturnRef: @(YES)
                             };
    CFTypeRef ref;
    OSStatus status = SecItemCopyMatching((CFDictionaryRef)params, &ref);
    return status == errSecSuccess ? (SecKeyRef)ref: nil;
}

@end
