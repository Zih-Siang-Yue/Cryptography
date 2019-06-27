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

@property (assign, nonatomic) CFStringRef keyType;
@property (strong, nonatomic) NSNumber *keySize;
@property (copy, nonatomic) NSString *keyTag;

@end

@implementation SYAsymmetricCryptographer

/*
 ======== The samples to generate key pair as follows ========
 
 void rsaGenerate(void) {
 NSString *keyTag = @"com.AsymmetricCrypto.rsa.keypair";
 asymmertricGenerate(kSecAttrKeyTypeRSA, @(2048), keyTag);
 }
 
 void ecGenerate(void) {
 NSString *keyTag = @"com.AsymmetricCrypto.ec.keypair";
 asymmertricGenerate(kSecAttrKeyTypeEC, @(256), keyTag);
 }
 
 */

#pragma mark - public

- (void)generateKeyPair:(CMKeyType)type keySize:(NSNumber *)size keyTag:(NSString *)tag {
    switch (type) {
        case CMKeyTypeRSA:
            self.keyType = kSecAttrKeyTypeRSA;

        case CMKeyTypeEC:
            self.keyType = kSecAttrKeyTypeEC;
            
        case CMKeyTypeECSECPrimeRandom:
            self.keyType = kSecAttrKeyTypeECSECPrimeRandom;
            
        default:
            break;
    }
    
    self.keySize = size;
    self.keyTag = tag;
    
    [self asymmertricGenerate];
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        SecKeyRef pubKey = [self getKeyRef:kSecAttrKeyClassPublic];
        if (!pubKey) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(false, nil, CMErrorKeyNotFound);
            });
        }
        else {
            NSMutableData *cipherData = [[NSMutableData alloc] initWithLength:SecKeyGetBlockSize(pubKey)];
            size_t cipherDataLen = cipherData.length;
            if (!cipherData) {
                completion(false, nil, CMErrorOutOfMemory);
            }
            //kSecPaddingPKCS1, kSecPaddingPKCS1SHA256...
            OSStatus status = SecKeyEncrypt(pubKey, kSecPaddingPKCS1, data.bytes, data.length, cipherData.mutableBytes, &cipherDataLen);
            dispatch_async(dispatch_get_main_queue(), ^{
                CMError err = status == errSecSuccess ? CMErrorSuccess : CMErrorUnableToEncrypt;
                completion(status == errSecSuccess, cipherData, err);
            });
        }
    });
}

#pragma mark - decrypt

- (void)decryptWithString:(NSString *)str completion:(CMCompletion)completion {
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    if (data) {
        [self decryptWithData:data completion:completion];
    }
    else {
        completion(false, nil, CMErrorWrongInputDataFormat);
    }
}

- (void)decryptWithData:(NSData *)data completion:(CMCompletion)completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
    });
}

#pragma mark - private

- (void)asymmertricGenerate {
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
    if (status == errSecSuccess) {
        return (SecKeyRef)ref;
    }
    else {
        return nil;
    }
}

@end
