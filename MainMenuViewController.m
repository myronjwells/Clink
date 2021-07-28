//
//  MainMenuViewController.m
//  Clink
//
//  Created by Myron Wells on 10/11/14.
//  Copyright (c) 2014 Tazzy Production. All rights reserved.
//

#import "MainMenuViewController.h"
#import "AppDelegate.h"
@implementation MainMenuViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}
- (void)viewDidLoad
{

    
    [super viewDidLoad];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Assets/backgroundGif" ofType:@"gif"];
    
    NSData *gif = [NSData dataWithContentsOfFile:filePath];
    
    
    [self.webview loadData:gif MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    self.webview.userInteractionEnabled = NO;
    
}
@end
