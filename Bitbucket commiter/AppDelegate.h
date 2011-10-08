//
//  AppDelegate.h
//  Bitbucket commiter
//
//  Created by Pablo Merino on 06/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MFTaskDelegateProtocol.h"

@class MFTask,MFTaskDelegate;

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate, MFTaskDelegateProtocol> {
    IBOutlet NSWindow *errorSheet;
    IBOutlet NSTextFieldCell *errorText;
    IBOutlet NSTextFieldCell *gitPath;
    BOOL selectedRepo;
    BOOL gitAdd;
    BOOL gitCommit;
    BOOL gitPush;
    NSTask *pingdata;
    NSArray *pingargs;
    IBOutlet NSButton *gitAddBtn;
    IBOutlet NSButton *gitCommitBtn;
    IBOutlet NSButton *gitPushBtn;
    IBOutlet NSButton *gitPullBtn;
    IBOutlet NSButton *gitCancelBtn;
    IBOutlet NSButton *gitRepoSelect;

    IBOutlet NSTextFieldCell *commitMsg;
    NSString *filePath;
    IBOutlet NSTextView *logField;
    NSString *result;
    NSString *pushresult;
    MFTask *currentTask;
    NSFileHandle *writeHandle;

}

@property (assign) IBOutlet NSWindow *window;
@property(assign) IBOutlet NSWindow *errorSheet;
@property(retain) NSArray *pingargs;

- (IBAction)closeMyCustomSheet: (id)sender;
- (IBAction)selectRepo:(id)sender;
- (IBAction)gitAdd:(id)sender;
- (IBAction)gitCommit:(id)sender;
- (IBAction)gitPush:(id)sender;
- (IBAction)gitPull:(id)sender;
- (IBAction)gitCancel:(id)sender;

- (void)gitPushTask;

-(void)gitAddDidEnd:(NSNotification*)notification;
-(void)gitCommitDidEnd:(NSNotification*)notification;
-(void)gitPushDidEnd:(NSNotification*)notification;
-(void)writeToLog:(NSString*)data;
-(void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
@end
