//
//  SYECCryptographer.m
//  Cryptography
//
//  Created by Sean.Yue on 2019/7/4.
//  Copyright © 2019 Sean.Yue. All rights reserved.
//

#import "SYECCryptographer.h"

@implementation SYECCryptographer

#pragma mark - init

- (instancetype)init {
    self = [super init];
    if (self) {
        self.keyTag = @"com.AsymmetricCrypto.ec.keypair";
        self.keyType = kSecAttrKeyTypeEC;
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
            CFErrorRef err = nil;
            //TODO: algorithm needs to changed.
            NSData *cipherData = (NSData*)CFBridgingRelease(SecKeyCreateEncryptedData(pubKey, kSecKeyAlgorithmECIESEncryptionStandardX963SHA256AESGCM, (CFDataRef)data, &err));
            dispatch_async(dispatch_get_main_queue(), ^{
                CMError errCode = err == nil ? CMErrorSuccess : CMErrorUnableToEncrypt;
                completion(err == nil, cipherData, errCode);
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
            CFErrorRef err = nil;
            //TODO: algorithm needs to changed.
            NSData *decypherData = (NSData *)CFBridgingRelease(SecKeyCreateDecryptedData(priKey, kSecKeyAlgorithmECIESEncryptionStandardX963SHA256AESGCM, (CFDataRef)data, &err));
            dispatch_async(dispatch_get_main_queue(), ^{
                CMError errCode = err == nil ? CMErrorSuccess : CMErrorUnableToDecrypt;
                completion(err == nil, decypherData, errCode);
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
            CFErrorRef err = nil;
            NSData *signedData = CFBridgingRelease(SecKeyCreateSignature(priKey, kSecKeyAlgorithmECDSASignatureRFC4754, (CFDataRef)data, &err));
            dispatch_async(dispatch_get_main_queue(), ^{
                CMError errCode = err == nil ? CMErrorSuccess : CMErrorUnableToSignature;
                completion(err == nil, signedData, errCode);
            });
        }
    });
}

#pragma mark - verify

- (void)verifySignData:(NSData *)signData originData:(NSData *)originData completion:(CMCompletion)completion {
    [super verifySignData:signData originData:originData completion:completion];
    __weak typeof (self) wSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        SecKeyRef pubKey = [wSelf getKeyRef:kSecAttrKeyClassPublic];
        if (!pubKey) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(false, nil, CMErrorKeyNotFound);
            });
        }
        else {
            CFErrorRef err = nil;
            BOOL isVerified = SecKeyVerifySignature(pubKey, kSecKeyAlgorithmECDSASignatureRFC4754, (CFDataRef)originData, (CFDataRef)signData, &err);
            dispatch_async(dispatch_get_main_queue(), ^{
                CMError errCode = err == nil ? CMErrorSuccess : CMErrorUnableToVerify;
                completion(isVerified, nil, errCode);
            });
        }
    });
}

@end
