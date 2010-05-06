//
//  blowfAppDelegate.h
//  blowf
//
//  Created by kazuot on 10/05/07.
//  Copyright 2010 hippos-lab.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface blowfAppDelegate : NSObject<NSApplicationDelegate>
{
  NSWindow    *window;
  NSTextView *encryptField;
  NSTextField *phraseField;
  NSData      *encedData;
}

@property (assign) IBOutlet NSWindow    *window;
@property (assign) IBOutlet NSTextView  *encryptField;
@property (assign) IBOutlet NSTextField *phraseField;
@property (assign) NSData               *encedData;

- (IBAction)opentext:(id)sender;
- (IBAction)opencrypto:(id)sender;
- (IBAction)encrypt:(id)sender;
- (IBAction)decrypt:(id)sender;

- (void)selectFileSheetDidEnd:(NSOpenPanel *)openpanel returnCode:(int)returnCode contextInfo:(id)inf;

@end
