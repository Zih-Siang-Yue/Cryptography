//
//  CryptographyManager.h
//  CryptographyManager
//
//  Created by Sean.Yue on 2019/6/18.
//  Copyright © 2019 Sean.Yue. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CMError) {
    CMErrorSuccess,
    CMErrorUnknown,
    CMErrorWrongInputDataFormat,
    CMErrorOutOfMemory,
    CMErrorKeyNotFound,
    CMErrorUnableToEncrypt,
    CMErrorUnableToDecrypt,
    CMErrorUnableToSignature,
    CMErrorUnableToVerify
};

typedef NS_ENUM (NSInteger, CMKeyType) {
    CMKeyTypeRSA,
    CMKeyTypeEC,
    CMKeyTypeECSECPrimeRandom
};

typedef void (^CMCompletion)(BOOL success, NSData * _Nullable data, CMError err);
typedef void (^CMResult)(BOOL success);

NS_ASSUME_NONNULL_BEGIN

@interface SYAsymmetricCryptographer : NSObject

@property (copy, nonatomic) NSString *keyTag;
@property (assign, nonatomic) CFStringRef keyType;
@property (assign, nonatomic, readonly) BOOL isKeyPairExists;

/**
 @abstract Generate public & private key
 @param size -> Key size
 @param result -> Delete successfully or not.
 */
- (void)generateKeyPairWithKeySize:(NSNumber *)size result:(CMResult)result;

/**
 @abstract Delete public * private key
 @param result -> Delete successfully or not.
 */
- (void)deleteKeyPair:(CMResult)result;

/**
 @abstract Get public / private key
 @param keyClass -> kSecAttrKeyClassPublic / kSecAttrKeyClassPrivate ...
 */
- (__nullable SecKeyRef)getKeyRef:(CFStringRef)keyClass;

//Encrypt
- (void)encryptWithString:(NSString *)str completion:(CMCompletion)completion;
- (void)encryptWithData:(NSData *)data completion:(CMCompletion)completion;

//Decrypt
- (void)decryptWithString:(NSString *)str completion:(CMCompletion)completion;
- (void)decryptWithData:(NSData *)data completion:(CMCompletion)completion;

//Signature
- (void)signWithString:(NSString *)str completion:(CMCompletion)completion;
- (void)signWithData:(NSData *)data completion:(CMCompletion)completion;

//Verify
- (void)verifySign:(NSString *)sign originStr:(NSString *)originStr completion:(CMCompletion)completion;
- (void)verifySignData:(NSData *)signData originData:(NSData *)originData completion:(CMCompletion)completion;

@end

NS_ASSUME_NONNULL_END
