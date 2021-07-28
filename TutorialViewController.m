//
//  TutorialViewController.m
//  Clink
//
//  Created by Myron Wells on 10/18/14.
//  Copyright (c) 2014 Tazzy Production. All rights reserved.
//

#import "TutorialViewController.h"

@implementation TutorialViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}
- (void)viewDidLoad
{
    
    
    [super viewDidLoad];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"tutorialGif" ofType:@"gif"];
    
    NSData *gif = [NSData dataWithContentsOfFile:filePath];
    
    
    [self.webview loadData:gif MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    self.webview.scalesPageToFit = YES;
    self.webview.userInteractionEnabled = NO;

}


@end
