//
//  BlowFishUtils.h
//  blowWind
//
//  Created by hippos on 10/05/05.
//  Copyright 2010 hippos-lab.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define BASE_ENCRYPT_LENGTH 256

@interface BlowFishUtils : NSObject
{
  ;
}

+ (NSData *)   encryptTextWithPhrase:(NSString *)plainText phrase:(NSString *)passPhrase;
+ (NSString *) decryptWithPhrase:(NSData *)encData phrase:(NSString *)passPhrase;

@end
