//
//  AsynSocketServerAppDelegate.m
//  AsynSocketServer
//
//  Created by Neworigin_Mac on 13-2-26.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "AsynSocketServerAppDelegate.h"

@implementation AsynSocketServerAppDelegate

@synthesize window = _window;
@synthesize textField = _textField;
@synthesize clientMessage = _clientMessage;
@synthesize readText = _readText;


- (void)dealloc
{
    [_window release];
    [_textField release];
    [_clientMessage release];
    [_readText release];
    [acceptSocket release];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [_textField setTitleWithMnemonic:@"在此输入要发送内容"];
    socket = [[AsyncSocket alloc] initWithDelegate:self];
    
    NSError *error = nil;
    if ([socket acceptOnPort:HOST_CLIENT_PORT error:&error]) {
         NSLog(@"accept ok");
    } else {
        NSLog(@"accept failed");
        NSLog(@"%@", error);
        return;
    }
    
    acceptSocket = [[AsyncSocket alloc] initWithDelegate:self];
}

//发送按钮行为
- (IBAction)send:(id)sender {
    NSData * acceptData = [[self.textField stringValue] dataUsingEncoding:NSUTF8StringEncoding];
    [acceptSocket writeData:acceptData withTimeout:-1 tag:0];
}

#pragma mark- AsyncSocketDelegate
//当产生一个socket去处理连接时调用，此方法会返回
- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
    NSLog(@"did accept new socket");
    // newSocket被创建用来处理和客户端的连接，必须retain，并用acceptSocket进行readData writeData
    acceptSocket = [newSocket retain];
}

//开启监听 当socket连接成功之后，正准备读和写的时候调用。host属性是一个IP地址，而不是一个DNS 名称
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"客户端与服务器链接成功！");
    //服务器端进行监听
    [acceptSocket readDataWithTimeout:-1 tag:1];
}

////连接成功，打开监听数据读取，如果不监听那么无法读取数据 当socket已完成所要求的数据读入内存时调用，如果有错误则不调用
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"didReadDatawithTag:%lu",tag);
    
    NSString *msg = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    
    NSLog(@"%@", [@"Client:" stringByAppendingFormat:@"%@\n", msg]);
    
    //继续监听读取
    [acceptSocket readDataWithTimeout:-1 tag:2];
}

// 当一个socket已完成请求数据的写入时候调用
- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"didWriteDataTag:%lu",tag);
}

@end
