//
//  SYRSACryptographer.m
//  Cryptography
//
//  Created by Sean.Yue on 2019/7/4.
//  Copyright © 2019 Sean.Yue. All rights reserved.
//

#import "SYRSACryptographer.h"
#import <CommonCrypto/CommonDigest.h>

@implementation SYRSACryptographer

#pragma mark - init

- (instancetype)init {
    self = [super init];
    if (self) {
        self.keyTag = @"com.AsymmetricCrypto.rsa.keypair";
        self.keyType = kSecAttrKeyTypeRSA;
    }
    return self;
}

#pragma mark - encrypt

- (void)encryptWithData:(NSData *)data completion:(CMCompletion)completion {
    [super encryptWithData:data completion:completion];
    __weak typeof (self) wSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        SecKeyRef pubKey = [wSelf getKeyRef:kSecAttrKeyClassPublic];
        if (!pubKey) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(false, nil, CMErrorKeyNotFound);
            });
        }
        else {
            NSMutableData *cipherData = [[NSMutableData alloc] initWithLength:SecKeyGetBlockSize(pubKey)];
            if (!cipherData) {
                completion(false, nil, CMErrorOutOfMemory);
                return;
            }
            unsigned char *cipherText = cipherData.mutableBytes;
            size_t cipherDataLen = cipherData.length;
            
            OSStatus status = SecKeyEncrypt(pubKey, kSecPaddingPKCS1, data.bytes, data.length, cipherText, &cipherDataLen);
            dispatch_async(dispatch_get_main_queue(), ^{
                CMError err = status == errSecSuccess ? CMErrorSuccess : CMErrorUnableToEncrypt;
                completion(status == errSecSuccess, cipherData, err);
            });
        }
    });
}

#pragma mark - decrypt

- (void)decryptWithData:(NSData *)data completion:(CMCompletion)completion {
    [super decryptWithData:data completion:completion];
    __weak typeof (self) wSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        SecKeyRef priKey = [wSelf getKeyRef:kSecAttrKeyClassPrivate];
        if (!priKey) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(false, nil, CMErrorKeyNotFound);
            });
        }
        else {
            NSMutableData *decipherData = [[NSMutableData alloc] initWithLength:SecKeyGetBlockSize(priKey)];
            if (!decipherData) {
                completion(false, nil, CMErrorOutOfMemory);
                return;
            }
            unsigned char *decipherText = decipherData.mutableBytes;
            size_t decipherDataLen = decipherData.length;
            
            OSStatus status = SecKeyDecrypt(priKey, kSecPaddingPKCS1, data.bytes, data.length, decipherText, &decipherDataLen);
            dispatch_async(dispatch_get_main_queue(), ^{
                decipherData.length = decipherDataLen;
                CMError err = status == errSecSuccess ? CMErrorSuccess : CMErrorUnableToDecrypt;
                completion(status == errSecSuccess, decipherData, err);
            });
        }
    });
}

#pragma mark - signature

- (void)signWithData:(NSData *)data completion:(CMCompletion)completion {
    [super signWithData:data completion:completion];
    __weak typeof (self) wSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        SecKeyRef priKey = [wSelf getKeyRef:kSecAttrKeyClassPrivate];
        if (!priKey) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(false, nil, CMErrorKeyNotFound);
            });
        }
        else {
            //此處長度需要注意!!! ,
            //CC_SHA1 -> 20(CC_SHA1_DIGEST_LENGTH)
            //CC_SHA224 -> 28(CC_SHA224_DIGEST_LENGTH)
            //CC_SHA256 -> 32(CC_SHA256_DIGEST_LENGTH)
            //CC_SHA384 -> 48(CC_SHA384_DIGEST_LENGTH)
            //CC_SHA512 -> 64(CC_SHA512_DIGEST_LENGTH)
            NSMutableData *hashData = [[NSMutableData alloc] initWithLength:CC_SHA1_DIGEST_LENGTH];
            if (!hashData) {
                completion(false, nil, CMErrorOutOfMemory);
                return;
            }
            
            NSMutableData *resultData = [[NSMutableData alloc] initWithLength:SecKeyGetBlockSize(priKey)];
            unsigned char *resultPointer = resultData.mutableBytes;
            size_t resultDataLen = resultData.length;

            OSStatus status = SecKeyRawSign(priKey, kSecPaddingPKCS1SHA1, hashData.mutableBytes, hashData.length, resultPointer, &resultDataLen);
            dispatch_async(dispatch_get_main_queue(), ^{
                resultData.length = resultDataLen;
                CMError err = status == errSecSuccess ? CMErrorSuccess : CMErrorUnableToSignature;
                completion(status == errSecSuccess, resultData, err);
            });
        }
    });
}

#pragma mark - verify

- (void)verifySignData:(NSData *)signData originData:(NSData *)originData completion:(CMCompletion)completion {
    [super verifySignData:signData originData:originData completion:completion];
    __weak typeof (self) wSelf = self;
    dispatch_async(dispatch_get_global_queue(NSURLSessionTaskPriorityDefault, 0), ^{
        SecKeyRef pubKey = [wSelf getKeyRef:kSecAttrKeyClassPublic];
        if (!pubKey) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(false, nil, CMErrorKeyNotFound);
            });
        }
        else {
            NSMutableData *hashData = [[NSMutableData alloc] initWithLength:CC_SHA1_DIGEST_LENGTH];
            if (!hashData) {
                completion(false, nil, CMErrorOutOfMemory);
                return;
            }
            
            OSStatus status = SecKeyRawVerify(pubKey, kSecPaddingPKCS1SHA1, hashData.bytes, hashData.length, signData.bytes, signData.length);
            dispatch_async(dispatch_get_main_queue(), ^{
                CMError err = status == errSecSuccess ? CMErrorSuccess : CMErrorUnableToVerify;
                completion(status == errSecSuccess, nil, err);
            });
        }
    });
}

@end
