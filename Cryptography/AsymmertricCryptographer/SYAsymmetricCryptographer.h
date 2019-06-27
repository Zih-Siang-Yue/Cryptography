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
    CMErrorUnableToDecrypt
};

typedef NS_ENUM (NSInteger, CMKeyType) {
    CMKeyTypeRSA,
    CMKeyTypeEC,
    CMKeyTypeECSECPrimeRandom
};

typedef void (^CMCompletion)(BOOL success, NSData * _Nullable encryptedData, CMError err);


NS_ASSUME_NONNULL_BEGIN

@interface SYAsymmetricCryptographer : NSObject

/**
 @abstract Generate public & private key
 @param type Key type
 @param size Key size
 @param tag A identifier to find the key later
 */
- (void)generateKeyPair:(CMKeyType)type keySize:(NSNumber *)size keyTag:(NSString *)tag;

@end

NS_ASSUME_NONNULL_END
