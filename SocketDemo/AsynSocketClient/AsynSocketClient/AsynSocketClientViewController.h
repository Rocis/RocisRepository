//
//  AsynSocketClientViewController.h
//  AsynSocketClient
//
//  Created by Neworigin_Mac on 13-2-26.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncSocket.h"
#define SRV_CONNECT_FAIL 0 
#define SRV_CONNECT_SUC 1 
#define SRV_CONNECTED 2 
#define HOST_IP @"127.0.0.1"
#define HOST_PORT 8080
//#define HOST_IP @"192.168.0.2"
//#define HOST_PORT 6969

@interface AsynSocketClientViewController : UIViewController<AsyncSocketDelegate>

@property (nonatomic, retain) AsyncSocket *client;   
@property (retain, nonatomic) IBOutlet UILabel *outputMsg;
@property (retain, nonatomic) IBOutlet UITextField *inputMsg;
- (IBAction) sendMsg:(id)sender;
- (void) showMessage:(NSString *) msg;
- (IBAction) backgroundTouch:(id)sender;
- (int) connectServer: (NSString *) hostIP port:(int) hostPort;   
@end
