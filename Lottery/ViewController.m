//
//  ViewController.m
//  Lottery
//
//  Created by Xuzixiang on 16/1/15.
//  Copyright © 2016年 frankxzx. All rights reserved.
//

#import "ViewController.h"
#import "NSMutableArray+lottery.h"
#import <AudioToolbox/AudioToolbox.h>

static NSUInteger AMOUNTS = 40;

@interface ViewController() {
    
    SystemSoundID winSoundID;
    SystemSoundID crunchSoundID;
    NSTimer *timer;
    NSUInteger times;
}

@property (weak) IBOutlet NSTextField *LotteryLabel;
@property (nonatomic, assign) BOOL stop;
@property (nonatomic, strong) NSMutableArray *doubleNumbers;
@property (nonatomic, strong) NSMutableArray *selectedNumbers;
@property (nonatomic, strong) NSMutableArray *luckyNumbers;
@property (nonatomic, strong) NSMutableArray *lotteryNumbers;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.LotteryLabel.stringValue = @"0";

    [self initArray];
    [self initLuckyNumbers];
    
    [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask handler: ^NSEvent * (NSEvent *theEvent){
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            timer = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(luckyDrawAnimate) userInfo:nil repeats:YES];
        });
        [self trigger];
        return theEvent;
    }];
}

-(void)initArray {
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"lotterys" ofType:@"plist"]];
    self.doubleNumbers = [NSMutableArray arrayWithContentsOfURL:url];
    self.selectedNumbers = [NSMutableArray array];
    self.luckyNumbers = [NSMutableArray array];
    self.lotteryNumbers = [NSMutableArray array];
    times = 0;
    for (int i = 0; i < AMOUNTS; i++) {
        [self.lotteryNumbers addObject:@(i)];
    }
}

-(void)initLuckyNumbers {
 
    [self double];
    [self winner];
    [self winner];
    [self double];
    [self double];
    [self double];
    [self winner];
    [self winner];
    [self winner];
    [self winner];
    [self double];
    [self double];
    [self double];
    [self winner];
    [self winner];
    [self winner];
    [self winner];
}

-(void)double {
    NSNumber *n = self.doubleNumbers.random;
    [self.doubleNumbers removeObject:n];
    [self.lotteryNumbers removeObject:n];
    [self.luckyNumbers addObject:n];
}

-(void)winner {
    NSNumber *n = self.lotteryNumbers.random;
    [self.lotteryNumbers removeObject:n];
    [self.luckyNumbers addObject:n];
}

- (void)trigger {
    
    if (self.stop == NO) {
        [timer setFireDate:[NSDate distantPast]];
    } else {
        [timer setFireDate:[NSDate distantFuture]];
        [self performSelector:@selector(playWinSound)
                   withObject:nil
                   afterDelay:.5];
        [self getWinnerNumber];
    }
    self.stop = !self.stop;
}

-(void)luckyDrawAnimate {
    
    self.LotteryLabel.stringValue = [NSString stringWithFormat:@"%lu",arc4random()%AMOUNTS];
    [self performSelector:@selector(playCrunchSound)
               withObject:nil
               afterDelay:.5];
}

-(void)getWinnerNumber {
    
    if (times < 17) {
        NSNumber *n = self.luckyNumbers[times % 17];
        self.LotteryLabel.stringValue = n.stringValue;
    } else {
        NSNumber *n = self.lotteryNumbers.random;
        [self.lotteryNumbers removeObject:n];
        if(n) self.LotteryLabel.stringValue = n.stringValue;
        else {
            self.LotteryLabel.font = [NSFont systemFontOfSize:80];
            self.LotteryLabel.stringValue = @"所有奖券已抽完~";
        }
    }
        times++;
}

-(void)playWinSound {
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"win"
                                         withExtension:@"wav"];
    if(winSoundID == 0) {
        
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)url,
                                         &winSoundID);
    }
    AudioServicesPlaySystemSound(winSoundID);
}

-(void)playCrunchSound {

    NSURL *url = [[NSBundle mainBundle] URLForResource:@"crunch"
                                               withExtension:@"wav"];
    if(crunchSoundID == 0) {
        
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)url,
                                         &crunchSoundID);
    }
    AudioServicesPlaySystemSound(crunchSoundID);
}

@end
