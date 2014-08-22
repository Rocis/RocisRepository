//
//  AsynSocketClientViewController.m
//  AsynSocketClient
//
//  Created by Neworigin_Mac on 13-2-26.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "AsynSocketClientViewController.h"

@interface AsynSocketClientViewController ()

@end

@implementation AsynSocketClientViewController
@synthesize client;
@synthesize outputMsg;
@synthesize inputMsg;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.outputMsg.numberOfLines = 0;
    
    //在需要联接地方使用connectToHost联接服务器
    [self connectServer:HOST_IP port:HOST_PORT];
    
    //客户端：监听读取
}

- (void)viewDidUnload
{
    self.client = nil;
    [self setOutputMsg:nil];
    [self setInputMsg:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

//定义自定义方法connectToHost联接服务器
- (int) connectServer: (NSString *) hostIP port:(int) hostPort
{
    if (!client) {
        client = [[AsyncSocket alloc] initWithDelegate:self];//其中initWithDelegate的参数中self是必须。这个对象指针中的各个Socket响应的函数将被ASyncSocket所调用。initWithDelegate把将当前对象传递进去，这样只要在当前对象方法实现相应方法。
        NSError * error = nil;
        if ([client connectToHost:hostIP onPort:hostPort error:&error]) {   // 连接给定的主机和端口，主机hostname可以是域名或者是IP地址
            NSLog(@"connect ok");
            
            return SRV_CONNECT_SUC;
        } else {
            NSLog(@"%ld %@", (long)[error code], [error localizedDescription]);   
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[@"Connection failed to host " stringByAppendingString:hostIP]
                                                            message:[[[NSString alloc]initWithFormat:@"%ld",(long)[error code]]
                                                                     stringByAppendingString:[error localizedDescription]]
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil
                                  ];   
            [alert show];   
            [alert release]; 
            return SRV_CONNECT_FAIL;
        }
    } else {
        //读取socket上第一次成功可用的字节,如果timeout值是负数的，读操作将不使用timeout；tag是为了方便，可以使用它作为数组的索引、步数、state id 、指针等
        
        //继续监听读取
        [client readDataWithTimeout:-1 tag:0];
        return SRV_CONNECTED;   
    }   
}

- (void)dealloc {
    [outputMsg release];
    [inputMsg release];
    [super dealloc];
}

#pragma -mark Socket数据发送.
//发送按钮的行为:发送数据
- (IBAction) sendMsg:(id)sender {
    if (!client) {
        [self showMessage:@"Sorry this connect is failure"];
    } else {
        // NSString 转换成NSData 对象
        NSString *inputMsgStr = self.inputMsg.text;
        NSString * content = [inputMsgStr stringByAppendingString:@"\r\n"];
        NSLog(@"inputMsgStr：%@",content);
        NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
        
        //AsyncSocket  writeData    方法来发送数据
        [client writeData:data withTimeout:-1 tag:3];//将data写入socket，当完成的时候委托被调用
    }
}

//当一个socket已完成请求数据的写入时候调用
- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"thread(%@),onSocket:%p didWriteDataWithTag:%ld",[[NSThread currentThread] name],sock,tag);
}

//触摸背景键盘消失
- (IBAction) backgroundTouch:(id)sender{   
    [inputMsg resignFirstResponder];   
}


- (void) showMessage:(NSString *) msg{
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Alert!"  message:msg
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}   

#pragma mark AsynScketDelegate

//链接将要取消的时候调用
- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    NSLog(@"Error");
}

//当socket由于或没有错误而断开连接，如果你想要在断开连接后release socket，在此方法中释放当前嵌套字
- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    NSString *msg = @"Sorry this connect is failure";
    [self showMessage:msg];
    client = nil;   
}

//当socket连接正准备好ReadData和WriteData;host:主机参数是一个IP地址,而不是一个DNS名称 port:端口号
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    [self showMessage:[NSString stringWithFormat:@"服务器链接成功!\n HOST:%@ PORT:%d",host,port]];
    
    //继续监听读取 
    [client readDataWithTimeout:-1 tag:4];
}


#pragma -mark 接收Socket数据.

//data是服务器发回的数据
//当socket已完成所要求的数据读入内存时调用，如果有错误则不调用
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString* aStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Hava received datas is :%@",aStr);
    self.outputMsg.text = [@"Server:" stringByAppendingFormat:@"%@\n", aStr];
    
    [aStr release];
    
    //继续监听读取:注意递归调用
    [client readDataWithTimeout:-1 tag:5];
}


@end
