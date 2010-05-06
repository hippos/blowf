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
  EVP_CIPHER_CTX       ctx;

  int                  templen       = 0;
  NSInteger            i             = 0;
  NSInteger            olen          = 0;
  NSInteger            ilen          = [plainText lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
  unsigned char        v[]           = { 1, 2, 3, 4, 5, 6, 7, 8 };
  const unsigned char *ibuff         = (const unsigned char *)[plainText cStringUsingEncoding:NSUTF8StringEncoding];
  unsigned char       *obuff         = 0x00;
  NSData              *encryptedData = nil;

  HashValue           *key           =
    [[HashValue alloc] initHashValueMD5HashWithBytes:[passPhrase cStringUsingEncoding:NSUTF8StringEncoding] length:[
       passPhrase lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];

  EVP_CIPHER_CTX_init(&ctx);
  EVP_EncryptInit_ex(&ctx, EVP_bf_cbc(), NULL, (const unsigned char *)[key value], v);

  obuff = calloc(ilen + EVP_CIPHER_CTX_block_size(&ctx), sizeof(unsigned char));

  for (i = 0; i < (ilen / BASE_ENCRYPT_LENGTH); i++)
  {
    EVP_EncryptUpdate(&ctx, &obuff[olen], &templen, &ibuff[olen], BASE_ENCRYPT_LENGTH);
    olen += templen;
  }

  if (ilen % BASE_ENCRYPT_LENGTH)
  {
    EVP_EncryptUpdate(&ctx, &obuff[olen], &templen, &ibuff[olen], (ilen % BASE_ENCRYPT_LENGTH));
    olen += templen;
  }

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
  return encryptedData;
}

+ (NSString *) decryptWithPhrase:(NSData *)encData phrase:(NSString *)passPhrase
{
  EVP_CIPHER_CTX       ctx;

  NSInteger            i           = 0;
  NSInteger            ilen        = [encData length];
  NSInteger            olen        = 0;
  int                  templen     = 0;
  unsigned char        v[]         = { 1, 2, 3, 4, 5, 6, 7, 8 }; /*** DO NOT CHANGE ***/
  const unsigned char *ibuff       = (const unsigned char *)[encData bytes];
  unsigned char       *obuff       = 0x00;
  NSString            *decedString = nil;

  HashValue           *key         =
    [[HashValue alloc] initHashValueMD5HashWithBytes:[passPhrase cStringUsingEncoding:NSUTF8StringEncoding] length:[
       passPhrase lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];

  EVP_CIPHER_CTX_init(&ctx);
  EVP_DecryptInit_ex(&ctx, EVP_bf_cbc(), NULL, (const unsigned char *)[key value], v);

  obuff = calloc(ilen + (EVP_CIPHER_CTX_block_size(&ctx) + 1), sizeof(unsigned char));

  for (i = 0; i < (ilen / 8); i++)
  {
    EVP_DecryptUpdate(&ctx, &obuff[olen], &templen, ibuff + (i * 8), 8);
    olen += templen;
  }

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

  return decedString;
}

@end
