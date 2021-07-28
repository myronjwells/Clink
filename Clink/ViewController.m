//
//  ViewController.m
//  Clink
//
//  Created by Myron Wells on 9/11/14.
//  Copyright (c) 2014 Tazzy Production. All rights reserved.
//


//REMEBER:Size of the tiles are 44x44

#import "ViewController.h"
#import "AppDelegate.h"
#import "MainMenuViewController.h"
@import AVFoundation;

@interface ViewController ()
{
   BOOL playersTurn;
    BOOL newGame;
    BOOL userTappedToPlay;
    //BOOL backgroundFlashing;
    NSInteger intTagNumber;
    NSInteger intLeftMargin; // horizontal offset from the edge of the screen
    NSInteger intTopMargin; // vertical offset from the edge of the screen
    NSInteger intXSpacing; // number of pixels between the button origins (horizontally)
    NSInteger intYSpacing; // number of pixels between the button origins (vertically)
    NSInteger direction;
    float intXTile;
    float intYTile;
    NSInteger currentLevel;
    NSInteger highestLevel;
    NSInteger gameOverLevel;
    NSTimer* timers;
    float duration;
    
    
}
@property(nonatomic)UIView *world;
@property(nonatomic)UIScrollView*  scrollView;
@property(nonatomic)UIButton* starterButton;
@property(nonatomic)UIButton* buttonTile;
@property(nonatomic)NSMutableArray* gameTilePattern;
@property(nonatomic)NSUInteger currentActiveTileCount;
@property(nonatomic)NSUInteger currentGameCount;
@property(nonatomic)NSInteger  buttonIndex;
@property(nonatomic)NSUserDefaults *defaults;
@property (assign) SystemSoundID buttonTapSound;
@property (assign) SystemSoundID patternSuccessSound;
@property (assign) SystemSoundID gameFailSound;
@property (weak, nonatomic) IBOutlet UILabel *currentLevelLabel;
@property (weak, nonatomic) IBOutlet UILabel *highestLevelLabel;
@property (weak, nonatomic) IBOutlet UIView *HUDview;
@property (weak, nonatomic) IBOutlet UILabel *tapToBeginLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *timerProgress;
@property (weak,nonatomic)UITapGestureRecognizer* tap;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *navigationView;


@end

@implementation ViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}
- (void)viewDidLoad
{
    
    self.tapToBeginLabel.layer.cornerRadius = 8.0f;
    _currentGameCount = 6; //initial tile pattern length at start
     currentLevel = 0;
    intTagNumber  = 0;
    intLeftMargin = 0; // horizontal offset from the edge of the screen
    intTopMargin  = 0; // vertical offset from the edge of the screen
    intXSpacing   = 46; // number of pixels between the button origins (horizontally)
    intYSpacing   = 46; // number of pixels between the button origins (vertically)
    newGame = YES;
    userTappedToPlay = NO;
    
    [self configureSound];
    
    //self.timerProgress.layer.hidden = YES;
    self.currentLevelLabel.hidden = YES;
    self.highestLevelLabel.hidden = YES;
    
    CGFloat currentDeviceWidth = [[UIScreen mainScreen]bounds].size.width;
    CGFloat currentDeviceHeight = [[UIScreen mainScreen]bounds].size.height;
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    self.world =  [[UIView alloc]initWithFrame:CGRectMake(0, 0, currentDeviceWidth*5.5, currentDeviceHeight*5.5)];
    self.world.backgroundColor = [UIColor whiteColor];
    //[self.view addSubview:self.world];
    
    [self placeTiles];
    
  _scrollView = [[UIScrollView alloc] initWithFrame:[[self view] bounds]];
    [_scrollView setContentSize:self.world.frame.size];
    
    //The code below creates inset on the edges of the device screen that basicallyy acts as a padding for scrolling so the lit sqaures don't go off the edge of the screen.
    self.scrollView.contentInset = UIEdgeInsetsMake(70.0, 70.0, 70.0, 70.0);
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(70.0, 70.0, 70.0, 70.0);
    self.scrollView.scrollEnabled = NO;
   
    [_scrollView addSubview:self.world];
    
    
    [[self view] addSubview:_scrollView];
    self.HUDview.userInteractionEnabled = YES;
    [[self view] addSubview:self.HUDview];
    [[self view] addSubview:self.navigationView];
    
    self.currentLevelLabel.text = [NSString stringWithFormat:@"%li",currentLevel];

    UITapGestureRecognizer *tap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleTap:)];
    [tap setNumberOfTapsRequired:1];
    
    [self.HUDview addGestureRecognizer:tap];
    
        [self setInitialScreenPosition];
    
    
}

-(void)updateProgress
{

    duration += 0.1;
    
    self.timerProgress.tintColor = [UIColor cyanColor];
    self.timerProgress.progress = (duration/timerDuration); // here 5.0 indicates your required time duration
    
    if (self.timerProgress.progress == 1)
    {
        [self hideTimerProgress];
        [timers invalidate];
        
        timers = nil;
        duration = 0.0;
        //[self startFlickerBackgroundColorAccordingToPatternCorrectness];
        
        [self playerLose];
        
    }
}
-(void)setInitialScreenPosition //this will most likely be the init method when i make this view controller its own class
{
    CGFloat initialScreenPoisitionX = (intXSpacing+1)*(((kButtonColumns/2)-0.5)- 3);
    CGFloat initialScreenPoisitionY = (intYSpacing+1)*(((kButtonRows/2)-0.5)- 6);
    [_scrollView setContentOffset:CGPointMake(initialScreenPoisitionX, initialScreenPoisitionY) animated:YES];
}

//runs once the user has tapped to begin the game at initial start
- (void)handleTap:(UIGestureRecognizer *)recognizer {
    NSLog(@"Wooo!");
    userTappedToPlay = YES;
    
    [self viewDidAppear:YES];
    self.tapToBeginLabel.hidden = YES;
    self.currentLevelLabel.hidden = NO;
    self.highestLevelLabel.hidden = NO;
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:NO];
    
    //need to add timer stopping mechanism here when player starts next round
    
    if(userTappedToPlay) {
    duration = 0.0;
    [timers invalidate];
    timers = nil;
   
    timers = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    [timers invalidate];
    
    _buttonIndex = 0.0;
    
    [self resetGameTilePatternImage];
    if(newGame)
    {
        [self resetBackgroundColorTimer];
        [self resetGameContents];
        [self generateGameArray];
        
        
    }
    
    [self resetBackgroundColorTimer];
    [self startComputersTurn];
    }
   
    }

-(void)viewWillAppear:(BOOL)animated
{
    self.defaults = [NSUserDefaults standardUserDefaults];
    NSInteger currentHighestLevel = [self.defaults integerForKey:@"HighestLevel"];
    self.highestLevelLabel.text = [NSString stringWithFormat:@"%ld",currentHighestLevel];
    
    

}

-(void)viewWillDisappear:(BOOL)animated
{
    NSInteger currentHighestLevel = highestLevel;
    [[NSUserDefaults standardUserDefaults]setInteger:currentHighestLevel forKey:@"HighestLevel"];
}

- (void)placeTiles
{
   
    for (int y = 0; y<kButtonRows; y++)
    {
        for (int x = 0; x<kButtonColumns; x++)
        {
            
            intXTile = (x * intXSpacing) + intLeftMargin;
            intYTile = (y * intYSpacing) + intTopMargin;
            
            // create a value button, text, or image
            buttons[x][y] = [[UIButton alloc] initWithFrame:CGRectMake(intXTile, intYTile, intXSpacing-2, intYSpacing-2)];
            [buttons[x][y] setBackgroundColor:[UIColor blackColor]];
            if(y==kButtonRows/2 && x==kButtonColumns/2)
            {
                buttons[x][y].backgroundColor = [UIColor cyanColor];
                self.starterButton = buttons[x][y];
                
                self.starterButton.selected = YES;
                self.starterButton.layer.shadowColor = [UIColor cyanColor].CGColor;
                self.starterButton.layer.cornerRadius = 5.0;
                
                
            }
           [buttons[x][y] addTarget:self action:@selector(actionPick:) forControlEvents:UIControlEventTouchDown];
            buttons[x][y].adjustsImageWhenHighlighted = NO;
            buttons[x][y].adjustsImageWhenDisabled = NO;
            buttons[x][y].tag = intTagNumber;
            buttons[x][y].selected = NO;
            [self.world addSubview:buttons[x][y]];
            
            
            intTagNumber++;
            
        }
    }
}

-(void)generateGameArray
{
    int i = 0;
    self.gameTilePattern = [[NSMutableArray alloc]init];
    NSInteger startPoint = self.starterButton.tag;
    //[self.tiles setTileType:GridTileTypeActive at:startPoint];
    self.starterButton.selected = YES;
    newGame = NO;
    _currentActiveTileCount = 1;
    NSInteger currentPosition = startPoint;
    while(_currentActiveTileCount < _currentGameCount)
    {
        
        
        direction = 1 + arc4random() % (4);
        NSInteger  newPosition = -1; //No Such Tag just needed to initialize it with something
        switch (direction) {
            case 1: //UP
                newPosition = currentPosition - kButtonColumns;
                
                
                break;
            case 2: //DOWN
                newPosition = currentPosition + kButtonColumns;
                
                break;
            case 3: //LEFT
                newPosition = currentPosition - 1;
                
                break;
                
            case 4: //RIGHT
                newPosition = currentPosition + 1;
                
                break;
                
                
        }
        
        
        if (![(UIButton*)[self.view viewWithTag:newPosition]isSelected])
        {
            
            
            
            currentPosition = newPosition;
            
            
            self.buttonTile = (UIButton*)[self.view viewWithTag:currentPosition];
            
            self.buttonTile.selected = YES;
          
            [self.gameTilePattern addObject:[NSNumber numberWithInteger:currentPosition]];
            
            _currentActiveTileCount++;
            NSLog(@"Array tags %@",[self.gameTilePattern objectAtIndex:i]);
            i++;
        
        
            NSLog(@"Array is working");
            
            
           
        }
        
        
        
    }
   
   }


-(void)buttonChangewithButton:(UIButton*)button {
    
    button.layer.backgroundColor = [[UIColor orangeColor]CGColor];
    [self playButtonSound];
    
    button.selected = YES;
}

-(void)PatternSuccessWithFinalButton:(UIButton*)button {
    
    button.layer.backgroundColor = [[UIColor orangeColor]CGColor];
    [self playPatternSuccessSound];
    
    button.selected = YES;
}

- (void)startComputersTurn {
    
    [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(updateComputerTurnWithTimer:) userInfo:@0 repeats:NO];
    [self hideTimerProgress];
    
}

- (void)updateComputerTurnWithTimer:(NSTimer *)timer {
    playersTurn = NO;
    self.HUDview.userInteractionEnabled = NO;
    NSInteger index = [timer.userInfo integerValue];
    if (index >= self.gameTilePattern.count)
    
    {
        for(NSNumber* tag in self.gameTilePattern)
        {
            UIButton* buttonTile = (UIButton*)[self.view viewWithTag:tag.intValue];
            [self buttonResetWithButton:buttonTile];
            //self.timerProgress.layer.hidden = NO;
            playersTurn = YES;
            duration = 0.0;
            [timers invalidate];
            timers = nil;
            timers = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
            [self startBackgroundColorTimer];
           
        }
        [self setInitialScreenPosition];
        self.view.userInteractionEnabled = YES;
        
        return;
    }
    
    
    
    [self buttonChangewithButton:[self getButtonTileFromArrayOfTagsByIndex:index]];
    
    
    UIButton* buttontile = [self getButtonTileFromArrayOfTagsByIndex:index];
    
    
   //scrolls the screen to the next button selected
    [self.scrollView scrollRectToVisible:buttontile.frame animated:YES];
    
    //starts the computers plotting of lit squares based on the gamepatternarray
    [NSTimer scheduledTimerWithTimeInterval:computerTurnSpeed target:self selector:@selector(updateComputerTurnWithTimer:) userInfo:@(index+1) repeats:NO];
    
}

-(void)buttonResetWithButton:(UIButton*)button
{
    button.layer.backgroundColor = [[UIColor blackColor]CGColor];
    button.layer.shadowColor = nil;
    button.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    button.layer.shadowRadius = 0.0f;
    button.layer.shadowOpacity = 0.0f;
    button.selected = NO;
}

-(UIButton*)getButtonTileFromArrayOfTagsByIndex:(NSInteger)index {
    NSInteger ButtonTag = [[self.gameTilePattern objectAtIndex:index]intValue];
    
    UIButton* plottedButton = (UIButton*)[self.view viewWithTag:ButtonTag];
    plottedButton.tag = ButtonTag;
    return plottedButton;

}


-(void)startBackgroundColorTimer
{
    
    
    
    [UIView animateWithDuration:timerDuration delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.view.layer.backgroundColor = [UIColor redColor].CGColor;
        //self.world.layer.backgroundColor = [UIColor redColor].CGColor;
    } completion:^(BOOL finished){
    }];
}



-(void)resetBackgroundColorTimer
{
    self.view.layer.backgroundColor = [UIColor whiteColor].CGColor;
    self.world.layer.backgroundColor = [UIColor whiteColor].CGColor;
}

-(NSNumber*)addButtonTileWithCurrentPosition:(NSInteger)currentPosition
{
    NSInteger  newPosition = -1;
    do
    {
    direction = 1 + arc4random() % (4);
     //No Such Tag just needed to initialize it with something
    switch (direction) {
        case 1: //UP
            newPosition = currentPosition - kButtonColumns;
            
            break;
        case 2: //DOWN
            newPosition = currentPosition + kButtonColumns;
            
            break;
        case 3: //LEFT
            newPosition = currentPosition - 1;
            
            break;
            
        case 4: //RIGHT
            newPosition = currentPosition + 1;
           
            break;
            
            
    }
    
    
   
    } while ([(UIButton*)[self.view viewWithTag:newPosition]isSelected]);
    
        
        
        
        currentPosition = newPosition;
        
        
        self.buttonTile = (UIButton*)[self.view viewWithTag:currentPosition];
        
        self.buttonTile.selected = YES;
    
    
    return [NSNumber numberWithInteger:currentPosition];
}

-(void)resetGameTilePatternImage
{
    for (NSNumber* tagNumber in self.gameTilePattern)
    {
        self.buttonTile = (UIButton*)[self.view viewWithTag:[tagNumber integerValue]];
        [self buttonResetWithButton:self.buttonTile];
    }
}

-(IBAction)actionPick:(id)sender
{
    
       UIButton *buttonPressed = (UIButton*)sender;
    if(!playersTurn) {self.view.userInteractionEnabled = NO;}
    else
    {self.view.userInteractionEnabled = YES;}
    
    if(_buttonIndex < self.gameTilePattern.count && playersTurn)
    {
        self.view.userInteractionEnabled = YES;
        
        if (buttonPressed.tag == [[self.gameTilePattern objectAtIndex:_buttonIndex]integerValue]) {
                NSLog(@"Winner!");
                [self buttonChangewithButton:buttonPressed];
            
                  //[timers fire];
            [timers invalidate];
            duration = 0.0;
            timers = nil;
            [self resetBackgroundColorTimer];
            timers = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
               [self startBackgroundColorTimer];
         
                [self.scrollView scrollRectToVisible:buttonPressed.frame animated:YES];
            
                _buttonIndex++;
            
            if(_buttonIndex == self.gameTilePattern.count)
            {
                 playersTurn = NO;
                NSLog(@"Yay! Pattern Success!");
                [self PatternSuccessWithFinalButton:buttonPressed];
                [self.gameTilePattern addObject:[self addButtonTileWithCurrentPosition:buttonPressed.tag]];
                _currentGameCount++;
                currentLevel++;
                [self setHighestLevel];
                self.currentLevelLabel.text = [NSString stringWithFormat:@"%li",(long)currentLevel];
                self.view.userInteractionEnabled = NO;
                [self performSelector:@selector(viewDidAppear:) withObject:nil afterDelay:0.8f];
                
            }
            
            }
        else{
            
            [self playerLose];
            
            }
        
        
        
    }

}


-(void)playerLose
{
    NSLog(@"Loser!");
    gameOverLevel = currentLevel;
    newGame = YES;
    [UIView animateWithDuration:0.2 delay:0.0 options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.HUDview.layer.backgroundColor = [UIColor redColor].CGColor;
                         
                         
                        
                     }
                     completion:^(BOOL finished){
                         [self playGameFailSound];
                         NSLog(@"Done!");
                         self.HUDview.layer.backgroundColor = [UIColor clearColor].CGColor;
                         [self hideTimerProgress];
                         [self viewDidAppear:YES];
                     }];

    
//[self performSelector:@selector(viewDidAppear:) withObject:nil afterDelay:1.8f];
    
}

-(void)setHighestLevel
{
    //pulls the currently saved highest level from the system 
     highestLevel = [self.defaults integerForKey:@"HighestLevel"];
    
    if(currentLevel>highestLevel)
    {
        highestLevel = currentLevel;
        
        NSInteger currentHighestLevel = highestLevel;
        
        [self.defaults setInteger:currentHighestLevel forKey:@"HighestLevel"];
        [self.defaults synchronize];
        self.highestLevelLabel.text = [NSString stringWithFormat:@"%ld",(long)currentHighestLevel];
    }
    
    
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self resetGameContents];
    [self viewDidLoad];
    //MainMenuViewController *mainVC = (MainMenuViewController*)segue.destinationViewController;
    
}

-(void)resetGameContents
{
   
    [self.gameTilePattern removeAllObjects];
    self.gameTilePattern = nil;
    self.buttonTile = nil;
    _currentGameCount = 6;
         currentLevel = 0;
    self.currentLevelLabel.text = [NSString stringWithFormat:@"%li",currentLevel];
    [timers invalidate];
    timers = nil;
    
}

-(void)configureSound {
    // buttonTap Sound configurations
    NSString *buttonTapPath = [[NSBundle mainBundle]
                            pathForResource:@"Assets/buttonTap" ofType:@"wav"];
    NSURL *buttonTapURL = [NSURL fileURLWithPath:buttonTapPath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)buttonTapURL, &_buttonTapSound);
    
    // patternSuccess Sound configurations
    NSString *patternSuccessPath = [[NSBundle mainBundle]
                               pathForResource:@"Assets/patternSuccess" ofType:@"wav"];
    NSURL *patternSuccessURL = [NSURL fileURLWithPath:patternSuccessPath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)patternSuccessURL, &_patternSuccessSound);

    
    // gameFail Sound configurations
    NSString *gameFailPath = [[NSBundle mainBundle]
                               pathForResource:@"Assets/gameFail" ofType:@"wav"];
    NSURL *gameFailURL = [NSURL fileURLWithPath:gameFailPath];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)gameFailURL, &_gameFailSound);

}
-(void)hideTimerProgress
{
    self.timerProgress.tintColor = [UIColor clearColor];
}
-(void)playButtonSound
{
    AudioServicesPlaySystemSound(self.buttonTapSound);
}
-(void)playPatternSuccessSound
{
    AudioServicesPlaySystemSound(self.patternSuccessSound);
}
-(void)playGameFailSound
{
    AudioServicesPlaySystemSound(self.gameFailSound);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
