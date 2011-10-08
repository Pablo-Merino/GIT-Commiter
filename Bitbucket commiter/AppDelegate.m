//
//  AppDelegate.m
//  Bitbucket commiter
//
//  Created by Pablo Merino on 06/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "MFTask.h"


@implementation AppDelegate

@synthesize window=_window, errorSheet=_errorSheet, pingargs=_pingargs;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application    
    // Create the File Open Dialog class.
    if (!selectedRepo) {
        [gitAddBtn setEnabled:NO];
        [gitCommitBtn setEnabled:NO];
        [gitPushBtn setEnabled:NO];
        [commitMsg setEnabled:NO];
        [gitPullBtn setEnabled:NO];
        [gitCancelBtn setEnabled:NO];

    }
    [self writeToLog:@"GIT commiter v1.0 starting..."];
    [self writeToLog:@"Please select a GIT repo"];


}
- (IBAction)selectRepo:(id)sender {
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    // Enable the selection of files in the dialog.
    [openDlg setCanChooseFiles:YES];
    
    // Enable the selection of directories in the dialog.
    [openDlg setCanChooseDirectories:YES];
    
    // Display the dialog.  If the OK button was pressed,
    // process the files.
    if ( [openDlg runModal] == NSOKButton )
    {
        // Get an array containing the full filenames of all
        // files and directories selected.
        NSURL *files = [openDlg URL];
        // Loop through all the files and process them.
        filePath = [files path];
        NSFileManager *mng = [[NSFileManager alloc] init];
        NSString *gitpath = [NSString stringWithFormat:@"%@/.git", filePath];
        if ([mng fileExistsAtPath:gitpath]) {
            gitPath.title = [NSString stringWithFormat:@"%@", filePath];
            selectedRepo = YES;
            [gitAddBtn setEnabled:YES];
            [filePath retain];
            [self writeToLog:[NSString stringWithFormat:@"Repo selected: %@", filePath]];
            [gitPullBtn setEnabled:YES];
            [gitCancelBtn setEnabled:NO];

        } else {
            [NSApp beginSheet: _errorSheet modalForWindow: _window modalDelegate: self didEndSelector: @selector(didEndSheet:returnCode:contextInfo:) contextInfo: nil];
            errorText.title = [NSString stringWithFormat:@"The selected folder is not a valid GIT repo :("];
            gitPath.title = [NSString stringWithFormat:@"Not a valid repo"];

            //NSAlert *error = [NSAlert alertWithMessageText:@"test" defaultButton:@"ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"lol"];
            //[error beginSheetModalForWindow:_window modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];
            
        }
        
    }

    
    
}
- (IBAction)gitAdd:(id)sender {
    NSTask *task = [NSTask new];
    [task setLaunchPath:@"/usr/bin/git"];
    [task setCurrentDirectoryPath:filePath];

    [task setArguments:[NSArray arrayWithObjects:@"add", @".", nil]];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    
    [task launch];
    
    
    [task release];
    
    gitAdd = YES;
    [gitCommitBtn setEnabled:YES];
    [commitMsg setEnabled:YES];
    [gitAddBtn setEnabled:NO];

}
- (IBAction)gitCommit:(id)sender {
    NSTask *task = [NSTask new];
    [task setLaunchPath:@"/usr/bin/git"];
    [task setCurrentDirectoryPath:filePath];

    [task setArguments:[NSArray arrayWithObjects:@"commit", @"-m", [NSString stringWithFormat:@"%@", [commitMsg stringValue]], nil]];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    
    [task launch];
    
    NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
    
    [task release];
    
    result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self writeToLog:result];

    gitCommit = YES;
    [gitPushBtn setEnabled:YES];
    [gitCommitBtn setEnabled:NO];
    [commitMsg setEnabled:NO];
    [gitCancelBtn setEnabled:YES];


}
- (IBAction)gitPush:(id)sender {
    NSPipe *readPipe = [[NSPipe alloc] init];

    currentTask = [[MFTask alloc] init];
    [currentTask setLaunchPath:@"/usr/bin/git"];
    [currentTask setCurrentDirectoryPath:filePath];
    [currentTask setTag:@"push"];
    [currentTask setStandardInput:readPipe];
    writeHandle = [readPipe fileHandleForWriting];

    [currentTask setArguments:[NSArray arrayWithObjects:@"push", nil]];
	[currentTask setDelegate:self];
	[currentTask launch];
    [gitPushBtn setEnabled:NO];
}

   


- (void) gitAddDidEnd:(NSNotification *)notification {
    NSLog(@"gitAddDidEnd:");
    gitAdd = YES;
    [gitCommitBtn setEnabled:YES];
    [commitMsg setEnabled:YES];
    [gitAddBtn setEnabled:NO];
}

-(void)gitCommitDidEnd:(NSNotification*)notification {
    NSLog(@"gitCommitDidEnd:");
    gitCommit = YES;
    [gitPushBtn setEnabled:YES];
    [gitCommitBtn setEnabled:NO];
    [commitMsg setEnabled:NO];

}
-(void)gitPushDidEnd:(NSNotification*)notification {
    NSLog(@"gitPushDidEnd:");
    [self writeToLog:[NSString stringWithFormat:@"%@", pushresult]];
    
    gitPush = YES;
    [gitAddBtn setEnabled:YES];
    [gitPushBtn setEnabled:NO];

    
}
- (IBAction)gitCancel:(id)sender {
    if (gitCommit) {
        NSTask *task = [NSTask new];
        [task setLaunchPath:@"/usr/bin/git"];
        [task setCurrentDirectoryPath:filePath];

        [task setArguments:[NSArray arrayWithObjects: @"reset", @"--hard", @"HEAD~1", nil]];
        
        NSPipe *pipe = [NSPipe pipe];
        [task setStandardOutput:pipe];
        
        [task launch];
        
        NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
        
        [task release];
        
        result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [self writeToLog:[NSString stringWithFormat:@"%@", result]];
        gitCommit = NO;
        [gitCancelBtn setEnabled:NO];
        [gitAddBtn setEnabled:YES];
        [gitCommitBtn setEnabled:NO];
        [gitPushBtn setEnabled:NO];
        
    } else {
        [self writeToLog:@"No commit has been done"];
    }
    
    
    
    
}
- (IBAction)gitPull:(id)sender {
    currentTask = [[MFTask alloc] init];
    [currentTask setLaunchPath:@"/usr/bin/git"];
    [currentTask setCurrentDirectoryPath:filePath];
    [currentTask setTag:@"pull"];
    [currentTask setArguments:[NSArray arrayWithObjects:@"pull", nil]];
	[currentTask setDelegate:self];
	[currentTask launch];
    [gitPushBtn setEnabled:NO];
    
    
}
-(void)writeToLog:(NSString*)data {
    
    NSAttributedString *stringToAppend = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", data]];
    [[logField textStorage] appendAttributedString:stringToAppend];
    
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];
}
- (IBAction)closeMyCustomSheet: (id)sender
{
    [NSApp endSheet:_errorSheet];
}
//MFTASK!!!
- (void) taskDidRecieveData:(NSData*) theData fromTask:(MFTask*) task {
	NSString *stringRep = [[NSString alloc] initWithData:theData encoding:NSASCIIStringEncoding];
	NSLog(@"%@\n",stringRep);
	if ([stringRep isEqualToString:@"Username:"]) {

        [writeHandle writeData:[@"pablo-merino" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [self writeToLog:stringRep];
	
}

- (void) taskDidTerminate:(MFTask*) theTask {
    if([theTask tag] == @"pull") {
        [self writeToLog:@"Pulled :D"];

        [gitAddBtn setEnabled:YES];
        [gitPushBtn setEnabled:NO];
        [gitPullBtn setEnabled:YES];
        
    } else if([theTask tag] == @"push") {
        [self writeToLog:@"Pushed :D"];
        gitPush = YES;
        [gitAddBtn setEnabled:YES];
        [gitPushBtn setEnabled:NO];
        [gitPullBtn setEnabled:YES];
        [gitRepoSelect setEnabled:YES];

    }

    
}


- (void) taskDidRecieveErrorData:(NSData*) theData fromTask:(MFTask*)task {
    
	[self taskDidRecieveData:theData fromTask:task];
}

- (void) taskDidRecieveInvalidate:(MFTask*) theTask {
	
}

- (void) taskDidLaunch:(MFTask*) theTask {
    if([theTask tag] == @"pull") {
        [self writeToLog:@"Pulling..."];
        [gitCommitBtn setEnabled:NO];
        [gitAddBtn setEnabled:NO];
        [gitPushBtn setEnabled:NO];
        [gitCancelBtn setEnabled:NO];
        [gitPullBtn setEnabled:NO];
        [gitRepoSelect setEnabled:NO];

    } else if([theTask tag] == @"push") {
        [self writeToLog:@"Pushing..."];
        
        [gitPushBtn setEnabled:NO];
        [gitCancelBtn setEnabled:NO];
        [gitPullBtn setEnabled:NO];
        [gitRepoSelect setEnabled:NO];

    }

    
}

@end
