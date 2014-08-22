//
//  AsynSocketServerAppDelegate.h
//  AsynSocketServer
//
//  Created by Neworigin_Mac on 13-2-26.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AsyncSocket.h"
#define HOST_CLIENT_PORT 8080

@interface AsynSocketServerAppDelegate : NSObject <NSApplicationDelegate,AsyncSocketDelegate>{
    AsyncSocket *socket;
    AsyncSocket *acceptSocket;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextField *textField;
@property (assign) NSText *clientMessage;
@property (assign) NSText *readText;

- (IBAction)send:(id)sender;

@end
