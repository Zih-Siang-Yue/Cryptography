//
//  CryptographyManager.m
//  CryptographyManager
//
//  Created by Sean.Yue on 2019/6/18.
//  Copyright © 2019 Sean.Yue. All rights reserved.
//

#import "SYAsymmetricCryptographer.h"
#import <CommonCrypto/CommonCryptor.h>

#define Temp_Key_Type kSecAttrKeyTypeEC
#define Temp_Key_Tag @"com.eccKeyForCrypto"

@interface SYAsymmetricCryptographer()

@property (assign, nonatomic) CFStringRef keyType;
@property (strong, nonatomic) NSNumber *keySize;
@property (copy, nonatomic) NSString *keyTag;

@end

@implementation SYAsymmetricCryptographer

#pragma mark - getter

- (BOOL)isKeyPairExists {
    return [self getKeyRef:kSecAttrKeyClassPublic] != nil;
}

#pragma mark - public

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

- (void)deleteKeyPair:(void (^)(BOOL))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *params = @{(__bridge id)kSecClass: (__bridge id)kSecClassKey,
                                 (__bridge id)kSecAttrApplicationTag: Temp_Key_Tag//self.keyTag
                                 };
        
        OSStatus status = SecItemDelete((CFDictionaryRef)params);
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(status == errSecSuccess);
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        SecKeyRef pubKey = [self getKeyRef:kSecAttrKeyClassPublic];
        if (!pubKey) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(false, nil, CMErrorKeyNotFound);
            });
        }
        else {
//            NSMutableData *cipherData = [[NSMutableData alloc] initWithLength:SecKeyGetBlockSize(pubKey)];
//            if (!cipherData) {
//                completion(false, nil, CMErrorOutOfMemory);
//                return;
//            }
//            unsigned char *cipherText = cipherData.mutableBytes;
//            size_t cipherDataLen = cipherData.length;

            CFErrorRef err = nil;
            NSData *cipherData = (NSData*)CFBridgingRelease(SecKeyCreateEncryptedData(pubKey, kSecKeyAlgorithmECIESEncryptionStandardX963SHA256AESGCM, (CFDataRef)data, &err));
            dispatch_async(dispatch_get_main_queue(), ^{
                CMError errCode = err == nil ? CMErrorSuccess : CMErrorUnableToEncrypt;
                completion(err == nil, cipherData, errCode);
            });            
//            OSStatus status = SecKeyEncrypt(pubKey, kSecPaddingPKCS1, data.bytes, data.length, (uint8_t*)cipherData.mutableBytes, &cipherDataLen);
//            NSLog(@"--> encrypting.....");
//            dispatch_async(dispatch_get_main_queue(), ^{
//                NSLog(@"--> encrypted.....");
//                CMError err = status == errSecSuccess ? CMErrorSuccess : CMErrorUnableToEncrypt;
//                completion(status == errSecSuccess, cipherData, err);
//                free(cipherText);
//            });
//            return;
        }
    });
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        SecKeyRef priKey = [self getKeyRef:kSecAttrKeyClassPrivate];
        if (!priKey) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(false, nil, CMErrorKeyNotFound);
            });
        }
        else {
            CFErrorRef err = nil;
            NSData *decypherData = (NSData *)CFBridgingRelease(SecKeyCreateDecryptedData(priKey, kSecKeyAlgorithmECIESEncryptionStandardX963SHA256AESGCM, (CFDataRef)data, &err));
            dispatch_async(dispatch_get_main_queue(), ^{
                CMError errCode = err == nil ? CMErrorSuccess : CMErrorUnableToDecrypt;
                completion(err == nil, decypherData, errCode);
            });
//            NSMutableData *decipherData = [[NSMutableData alloc] initWithLength:1024];
//            if (!decipherData) {
//                completion(false, nil, CMErrorOutOfMemory);
//                return;
//            }
//            unsigned char *decipherText = decipherData.mutableBytes;
//            size_t decipherDataLen = decipherData.length;
//
//            OSStatus status = SecKeyDecrypt(priKey, kSecPaddingPKCS1, data.bytes, data.length, decipherText, &decipherDataLen);
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if (status == errSecSuccess) {
//                    decipherData.length = decipherDataLen;
//                    NSString *str = [[NSString alloc] initWithData:decipherData encoding:NSUTF8StringEncoding];
//                    //TODO: should be nsdata format
//                    str != nil ? completion(true, str, CMErrorSuccess) : completion(false, nil, CMErrorUnableToDecrypt);
//                }
//                else {
//                    completion(false, nil, CMErrorUnableToDecrypt);
//                }
//                free(decipherText);
//            });
//            return;
        }
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
                             (__bridge id)kSecAttrKeyType: (__bridge id)Temp_Key_Type, //self.keyType,
                             (__bridge id)kSecAttrApplicationTag: Temp_Key_Tag, //self.keyTag,
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
