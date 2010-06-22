//
//  BlowFishUtils.m
//  blowWind
//
//  Created by hippos on 10/05/05.
//  Copyright 2010 hippos-lab.com. All rights reserved.
//

#import <openssl/evp.h>
#import "BlowFishUtils.h"
#import "HashValue.h"

@implementation BlowFishUtils

+ (NSData *)encryptTextWithPhrase:(NSString *)plainText phrase:(NSString *)passPhrase
{
  EVP_CIPHER_CTX      ctx;

  int                 templen        = 0;
  int                 olen           = 0;
  NSInteger           ilen           = [plainText lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
  unsigned char       v[]            = { 1, 2, 3, 4, 5, 6, 7, 8 };
  const unsigned char *ibuff         = (const unsigned char *)[plainText cStringUsingEncoding:NSUTF8StringEncoding];
  unsigned char       *obuff         = 0x00;
  NSData              *encryptedData = nil;

  HashValue           *key =
    [[HashValue alloc] initHashValueMD5HashWithBytes:[passPhrase cStringUsingEncoding:NSUTF8StringEncoding] length:[
       passPhrase lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];

  EVP_CIPHER_CTX_init(&ctx);
/*  
  EVP_EncryptInit_ex(&ctx, EVP_bf_cbc(), NULL, (const unsigned char *)[key value], v);
*/  
  EVP_EncryptInit_ex(&ctx, EVP_bf_cbc(), NULL, NULL, v);
  EVP_CIPHER_CTX_set_key_length(&ctx, 32);
  EVP_EncryptInit_ex(&ctx, NULL, NULL, (const unsigned char *)[key value], NULL);

  /* for Debug */
  DLog(@"Key Length:%d(%d)",EVP_CIPHER_key_length(EVP_bf_cbc()),EVP_CIPHER_CTX_key_length(&ctx));

  obuff = calloc(ilen + EVP_CIPHER_CTX_block_size(&ctx), sizeof(unsigned char));

  EVP_EncryptUpdate(&ctx, obuff, &olen, ibuff, ilen);

  NSInteger finalSuccess = EVP_EncryptFinal_ex(&ctx, &obuff[olen], &templen);

  EVP_CIPHER_CTX_cleanup(&ctx);

  if (finalSuccess)
  {
    encryptedData = [NSData dataWithBytes:obuff length:olen + templen];
  }
  else
  {
    NSLog(@"encrypto failed :(in) %@ (key) %@", plainText, key);
  }

  free(obuff);
  [key release];
  return encryptedData;
}

+ (NSString *) decryptWithPhrase:(NSData *)encData phrase:(NSString *)passPhrase
{
  EVP_CIPHER_CTX      ctx;

  NSInteger           ilen         = [encData length];
  int                 olen         = 0;
  int                 templen      = 0;
  unsigned char       v[]          = { 1, 2, 3, 4, 5, 6, 7, 8 }; /*** DO NOT CHANGE ***/
  const unsigned char *ibuff       = (const unsigned char *)[encData bytes];
  unsigned char       *obuff       = 0x00;
  NSString            *decedString = nil;

  HashValue           *key =
    [[HashValue alloc] initHashValueMD5HashWithBytes:[passPhrase cStringUsingEncoding:NSUTF8StringEncoding] length:[
       passPhrase lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];

  EVP_CIPHER_CTX_init(&ctx);
/*
  EVP_DecryptInit_ex(&ctx, EVP_bf_cbc(), NULL, (const unsigned char *)[key value], v);
*/
  EVP_DecryptInit_ex(&ctx, EVP_bf_cbc(), NULL, NULL, v);
  EVP_CIPHER_CTX_set_key_length(&ctx, 32);
  EVP_DecryptInit_ex(&ctx, NULL, NULL, (const unsigned char *)[key value], NULL);
  
  /* for Debug */
  DLog(@"Key Length:%d(%d)",EVP_CIPHER_key_length(EVP_bf_cbc()),EVP_CIPHER_CTX_key_length(&ctx));

  obuff = calloc(ilen, sizeof(unsigned char));

  EVP_DecryptUpdate(&ctx, obuff, &olen, ibuff, ilen);

  NSInteger finalSuccess = EVP_DecryptFinal_ex(&ctx, &obuff[olen], &templen);

  if (finalSuccess)
  {
    decedString = [[NSString alloc] initWithBytes:obuff length:olen + templen encoding:NSUTF8StringEncoding];
  }
  else
  {
    NSLog(@"decrypto failed :(in) %@ (key) %@", encData, key);
  }

  EVP_CIPHER_CTX_cleanup(&ctx);
  free(obuff);
  [key release];

  return [decedString autorelease];
}

@end
