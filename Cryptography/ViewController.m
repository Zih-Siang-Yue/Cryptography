//
//  ViewController.m
//  Cryptography
//
//  Created by Sean.Yue on 2019/6/25.
//  Copyright © 2019 Sean.Yue. All rights reserved.
//

#import "ViewController.h"
#import "SYRepositoryManager.h"
#import "SYRSACryptographer.h"
#import "SYECCryptographer.h"
#import "UIAlertController+SY.h"

#define Server_IP_Key @"SERVER_IP_KEY"

@interface ViewController ()

@property (strong, nonatomic) SYAsymmetricCryptographer *crypto;


@property (weak, nonatomic) IBOutlet UITextField *clearTextField;
@property (weak, nonatomic) IBOutlet UITextField *cipheredTextField;

@property (weak, nonatomic) IBOutlet UIButton *keyBtn;
@property (weak, nonatomic) IBOutlet UIButton *cypherBtn;
@property (weak, nonatomic) IBOutlet UIButton *decypherBtn;
@property (weak, nonatomic) IBOutlet UIButton *signBtn;
@property (weak, nonatomic) IBOutlet UIButton *verifyBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configBase];
    [self configBtn];
    [self testKeychainSavingAndLoading];
}

- (void)testKeychainSavingAndLoading {
    NSString *serverIp = @"192.168.2.173";
    [SYRepositoryManager saveObject:serverIp forKey:Server_IP_Key];
    NSString *ip = [SYRepositoryManager loadObjectForKey:Server_IP_Key];
    NSLog(@"ori server ip: %@, saved server ip: %@", serverIp, ip);
}

- (void)configBase {
    self.crypto = [SYECCryptographer new];
//    self.crypto = [SYRSACryptographer new];
}

- (void)configBtn {
    NSString *title = self.crypto.isKeyPairExists ? @"Delete Key" : @"Generate Key";
    [self.keyBtn setTitle:title forState:UIControlStateNormal];
    [self.keyBtn addTarget:self action:@selector(keyAction) forControlEvents:UIControlEventTouchUpInside];
    [self.cypherBtn addTarget:self action:@selector(cypher) forControlEvents:UIControlEventTouchUpInside];
    [self.decypherBtn addTarget:self action:@selector(decypher) forControlEvents:UIControlEventTouchUpInside];
    [self.signBtn addTarget:self action:@selector(signature) forControlEvents:UIControlEventTouchUpInside];
    [self.verifyBtn addTarget:self action:@selector(verify) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - btn action

- (void)keyAction {
    self.crypto.isKeyPairExists ? [self deleteKeyPair] : [self generateKeyPair];
}

- (void)generateKeyPair {
    __weak typeof (self) wSelf = self;
    [self.crypto generateKeyPairWithKeySize:@(256) result:^(BOOL success) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [wSelf.keyBtn setTitle:@"Delete Key" forState:UIControlStateNormal];
            });
        }
    }];
    
//    [self.crypto generateKeyPairWithKeySize:@(2048) result:^(BOOL success) {
//        if (success) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [wSelf.keyBtn setTitle:@"Delete Key" forState:UIControlStateNormal];
//            });
//        }
//    }];
}

- (void)deleteKeyPair {
    __weak typeof (self) wSelf = self;
    [self.crypto deleteKeyPair:^(BOOL isSuccess) {
        if (isSuccess) {
            [wSelf.keyBtn setTitle:@"Generate Key" forState:UIControlStateNormal];
        }
    }];
}

- (void)cypher {
    if ([self.clearTextField.text isEqualToString:@""]) {
        [UIAlertController showTitle:@"Empty" msg:@"Please enter the content...."];
        return;
    }
    
    [self.crypto encryptWithString:self.clearTextField.text completion:^(BOOL success, NSData * _Nullable data, CMError err) {
        if (success) {
            NSString *str = [data base64EncodedStringWithOptions:0];
            self.cipheredTextField.text = str;
            self.clearTextField.text = @"";
        }
        else {
            NSString *msg = [NSString stringWithFormat:@"err code: %ld", (long)err];
            [UIAlertController showTitle:@"Encrypted failure" msg:msg];
        }
    }];
}

- (void)decypher {
    if ([self.cipheredTextField.text isEqualToString:@""]) {
        [UIAlertController showTitle:@"Empty" msg:@"Please enter the content...."];
        return;
    }
    
    [self.crypto decryptWithString:self.cipheredTextField.text completion:^(BOOL success, NSData * _Nullable data, CMError err) {
        if (success) {
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            self.clearTextField.text = str;
            self.cipheredTextField.text = @"";
        }
        else {
            NSString *msg = [NSString stringWithFormat:@"err code: %ld", (long)err];
            [UIAlertController showTitle:@"Decrypted failure" msg:msg];
        }
    }];
}

- (void)signature {
    if ([self.clearTextField.text isEqualToString:@""]) {
        [UIAlertController showTitle:@"Empty" msg:@"Please enter the content...."];
        return;
    }
    
    [self.crypto signWithString:self.clearTextField.text completion:^(BOOL success, NSData * _Nullable data, CMError err) {
        if (success) {
            NSString *str = [data base64EncodedStringWithOptions:0];
            self.cipheredTextField.text = str;
        }
        else {
            NSString *msg = [NSString stringWithFormat:@"err code: %ld", (long)err];
            [UIAlertController showTitle:@"Signature failure" msg:msg];
        }
    }];
}

- (void)verify {
    if ([self.cipheredTextField.text isEqualToString:@""] && [self.clearTextField.text isEqualToString:@""]) {
        [UIAlertController showTitle:@"Empty" msg:@"Please enter the content...."];
        return;
    }

    [self.crypto verifySign:self.cipheredTextField.text originStr:self.clearTextField.text completion:^(BOOL success, NSData * _Nullable data, CMError err) {
        NSString *msg = success ? @"Success" : @"Fail";
        [UIAlertController showTitle:@"Verify Signature" msg:msg];
    }];
}



@end
