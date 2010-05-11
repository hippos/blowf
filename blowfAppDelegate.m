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
  
  [self setEncedData:[BlowFishUtils encryptTextWithPhrase:targetText phrase:[phraseField stringValue]]];

  [encryptField setString:[encedData description]];
  
}

- (IBAction)decrypt:(id)sender
{
  NSString *decedText = [BlowFishUtils decryptWithPhrase:[self encedData] phrase:[phraseField stringValue]];

  if (decedText == nil)
  {
    NSAlert *alert = [NSAlert alertWithMessageText:@"decrypto failed" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"decrypto failed"];
    [alert runModal];
  }
  else
  {
    [encryptField setString:decedText];
    [self setEncedData:nil];
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
    [self setEncedData:nil];
    [self setEncedData:[NSData dataWithContentsOfFile:[openpanel filename]]];
    content   = [[self encedData] description];
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

- (IBAction)saveAs:(id)sender
{
  NSSavePanel *sp = [NSSavePanel savePanel];

  if ([self encedData] != nil)
  {
    [sp setRequiredFileType:@"blf"];
  }
  else
  {
    [sp setRequiredFileType:@"txt"];
  }

  [sp setCanCreateDirectories:YES];

  [sp beginSheetForDirectory:NSHomeDirectory() file:nil
   modalForWindow:[NSApp mainWindow]  modalDelegate:self
   didEndSelector:@selector(saveFileAsSheetDidEnd:returnCode:contextInfo:) contextInfo:[sp requiredFileType]];
}

- (void)saveFileAsSheetDidEnd:(NSSavePanel *)savePanel returnCode:(int)returnCode contextInfo:(id)inf
{
  if (returnCode == NSCancelButton)
  {
    return;
  }

  NSError *err = nil;

  if ([(NSString *) inf isEqualToString:@"txt"])
  {
    NSString *targetText = [[encryptField textStorage] mutableString];
    [targetText writeToURL:[savePanel URL] atomically:YES encoding:NSUTF8StringEncoding error:&err];
  }
  else
  {
    [[self encedData] writeToURL:[savePanel URL] options:NSAtomicWrite error:&err];
  }

  if (err)
  {
    NSAlert *alert = [NSAlert alertWithError:err];
    [alert runModal];
  }
}

- (IBAction)clear:(id)sender
{
  [self setEncedData:nil];
  [phraseField setStringValue:@""];
  [encryptField setString:@""];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
  if ([menuItem action] == @selector(saveAs :))
  {
    if (([self encedData] != nil) || ([[[encryptField textStorage] mutableString] length] > 0))
    {
      return YES;
    }
    else
    {
      return NO;
    }
  }
  return YES;
}

- (NSData *)encedData
{
  return encedData;
}

- (void)setEncedData:(NSData *)value
{
  [self willChangeValueForKey:@"encedData"];
  
  encedData = nil;
  
  if ([value length] != 0)
  {
    encedData = [value copy];
  }

  [self didChangeValueForKey:@"encedData"];
}

@end
