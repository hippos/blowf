//
//  blowfAppDelegate.m
//  blowf
//
//  Created by kazuot on 10/05/07.
//  Copyright 2010 hippos-lab.com. All rights reserved.
//

#import <openssl/evp.h>
#import "blowfAppDelegate.h"
#import "BlowFishUtils.h"

@implementation blowfAppDelegate

@synthesize window;
@synthesize encedData;
@synthesize encryptField,phraseField;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  // Insert code here to initialize your application
}

- (IBAction)encrypt:(id)sender
{
  if ([[phraseField stringValue] lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > EVP_MAX_KEY_LENGTH)
  {
    NSAlert *alert = [NSAlert alertWithMessageText:@"key phrase lengh error" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"too long"];
    [alert runModal];
    return;
  }
  
  NSString* targetText = [[encryptField textStorage] mutableString];
  
  encedData = [BlowFishUtils encryptTextWithPhrase:targetText phrase:[phraseField stringValue]];

  [encryptField setString:[encedData description]];
  
}

- (IBAction)decrypt:(id)sender
{
  NSString *decedText = [BlowFishUtils decryptWithPhrase:encedData phrase:[phraseField stringValue]];

  if (decedText == nil)
  {
    NSAlert *alert = [NSAlert alertWithMessageText:@"decrypto failed" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"decrypto failed"];
    [alert runModal];
  }
  else
  {
    [encryptField setString:decedText];
  }
}

- (IBAction)opentext:(id)sender
{
  NSOpenPanel *opanel = [NSOpenPanel openPanel];

  [opanel setCanChooseFiles:YES];
  [opanel setCanChooseDirectories:NO];
  [opanel setCanCreateDirectories:NO];

  [opanel beginSheetForDirectory:NSHomeDirectory() file:nil
   modalForWindow:[NSApp mainWindow]  modalDelegate:self
   didEndSelector:@selector(selectFileSheetDidEnd:returnCode:contextInfo:) contextInfo:@"text"];
}

- (IBAction)opencrypto:(id)sender
{
  NSOpenPanel *opanel = [NSOpenPanel openPanel];

  [opanel setCanChooseFiles:YES];
  [opanel setCanChooseDirectories:NO];
  [opanel setCanCreateDirectories:NO];

  [opanel beginSheetForDirectory:NSHomeDirectory() file:nil
   modalForWindow:[NSApp mainWindow]  modalDelegate:self
   didEndSelector:@selector(selectFileSheetDidEnd:returnCode:contextInfo:) contextInfo:@"crypt"];
}

- (void)selectFileSheetDidEnd:(NSOpenPanel *)openpanel returnCode:(int)returnCode contextInfo:(id)inf
{
  if (returnCode == NSCancelButton)
  {
    return;
  }

  NSString *content;
  if ([(NSString *) inf isEqualToString:@"crypt"] == YES)
  {
    encedData = nil;
    encedData = [NSData dataWithContentsOfFile:[openpanel filename]];
    content   = [encedData description];
  }
  else
  {
    NSError *err = nil;
    content = [NSString stringWithContentsOfFile:[openpanel filename] encoding:NSUTF8StringEncoding error:&err];
    if (err)
    {
      NSAlert *alert = [NSAlert alertWithError:err];
      [alert runModal];
      return;
    }
  }

  [encryptField setString:content];
  return;
}

@end
