//
//  ViewController.h
//  Clink
//
//  Created by Myron Wells on 9/11/14.
//  Copyright (c) 2014 Tazzy Production. All rights reserved.
//

#import <UIKit/UIKit.h>
//needs to be odd number to work out with a tile in the center
#define kButtonColumns 61
#define kButtonRows 61
#define computerTurnSpeed 0.2
#define timerDuration 2.0
@interface ViewController : UIViewController {
    
    UIButton *buttons[kButtonColumns][kButtonRows];
}

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapToBegin;

@end
