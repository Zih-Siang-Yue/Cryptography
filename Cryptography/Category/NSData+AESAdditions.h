#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface NSData (AESAdditions)

- (NSData*)AES256EncryptWithKey:(NSString*)key;
- (NSData*)AES256DecryptWithKey:(NSString*)key;

- (NSData*)AES128EncryptWithKey:(NSString*)key;
- (NSData*)AES128DecryptWithKey:(NSString*)key;

@end
