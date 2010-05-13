//
//  DDTextView.m
//  TextViewDD
//
//  Created by hippos on 10/05/13.
//  Copyright 2010 hippos-lab.com. All rights reserved.
//

#import "blowfAppDelegate.h";
#import "DDTextView.h"


@implementation DDTextView

- (NSDragOperation)draggingEntered:(id < NSDraggingInfo >)sender
{
  return NSDragOperationNone;
}

- (NSDragOperation)draggingUpdated:(id < NSDraggingInfo >)sender
{
  return NSDragOperationNone;
}

- (void)draggingExited:(id < NSDraggingInfo >)sender
{
  // nothing do
}

- (BOOL)prepareForDragOperation:(id < NSDraggingInfo >)sender
{
  return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo> )sender
{
  NSPasteboard *paste = [sender draggingPasteboard];
  NSArray      *types = [NSArray arrayWithObjects:NSFilenamesPboardType, nil];
  NSString     *type  = [paste availableTypeFromArray:types];
  NSData       *data  = [paste dataForType:type];

  if (data == nil)
  {
    NSRunAlertPanel(@"Pasteboard Data Error", @"past operation failed", nil, nil, nil);
    return NO;
  }
  
  if ([type isEqualToString:NSFilenamesPboardType])
  {
    [self performDragOperationWithFileNames:[paste propertyListForType:@"NSFilenamesPboardType"]];
  }
  else
  {
    return NO;
  }
  [self setNeedsDisplay:YES];
  return YES;
}

- (void)concludeDragOperation:(id < NSDraggingInfo >)sender
{
  // nothing do
}

- (void)performDragOperationWithFileNames:(NSArray *)files
{
  if (files == nil || [files count] == 0)
  {
    return;
  }

  NSError  *err  = nil;
  NSString *file = [files objectAtIndex:0];

  if ([[file pathExtension] isEqualToString:@"blf"] == YES)
  {
    NSData *cryptData = [NSData dataWithContentsOfFile:file];
    [[blowfAppDelegate sharedAppDelegate] setEncedData:cryptData];
    [self setString:[cryptData description]];
  }
  else
  {
    NSString *content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:&err];
    if (err)
    {
      NSRunAlertPanel(@"File Open Error", [err localizedDescription], nil, nil, nil);
      return;
    }
    [self setString:content];
  }
}

@end
