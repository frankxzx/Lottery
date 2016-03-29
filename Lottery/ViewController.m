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

#define X @12
@interface ViewController() {
    
    SystemSoundID winSoundID;
    SystemSoundID crunchSoundID;
    NSTimer *timer;
    NSTimer *timer2;
    NSUInteger times;
    NSUInteger doubleTimes;
}

@property (weak) IBOutlet NSTextField *LotteryLabel;
@property (nonatomic, assign) BOOL stop;
@property (nonatomic, strong) NSMutableArray *doubleNumbers;
@property (nonatomic, strong) NSMutableArray *selectedNumbers;
@property (nonatomic, strong) NSMutableArray *luckyNumbers;
@property (nonatomic, strong) NSMutableArray *lotteryNumbers;
@property (nonatomic, strong) NSMutableArray *stuffList;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.LotteryLabel.stringValue = @"0";
    times = 0;
    doubleTimes = 0;
    
    [self initArray];
    [self initLuckyNumbers];
    
    [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask handler: ^NSEvent * (NSEvent *theEvent){

        switch ([[theEvent charactersIgnoringModifiers] characterAtIndex:0]) {
            case NSUpArrowFunctionKey: {
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^{
                    timer2 = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(luckyDrawStuffNameAnimate) userInfo:nil repeats:YES];
                });
                [self trigger2];
            }
                break;
      
            default: {
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^{
                    timer = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(luckyDrawAnimate) userInfo:nil repeats:YES];
                });
                [self trigger];
            }
                break;
        }
        return theEvent;
    }];
}

-(void)initArray {
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"lotterys" ofType:@"plist"]];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfURL:url];
    self.doubleNumbers = dic[@"Double"];
    self.selectedNumbers = [NSMutableArray array];
    self.luckyNumbers = [NSMutableArray array];
    self.lotteryNumbers = [NSMutableArray array];
    NSNumber *n = dic[@"Amount"];
    for (long i = 1; i <= n.longLongValue; i++) {
        [self.lotteryNumbers addObject:@(i)];
    }
    [self.lotteryNumbers removeObjectsInArray:self.doubleNumbers];
    [self.lotteryNumbers removeObjectsInArray:@[@18,@5,@39,@17,@6,@16,@37,@23]];
    {
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"StuffList" ofType:@"plist"]];
    NSArray *array = [NSArray arrayWithContentsOfURL:url];
    self.stuffList = [NSMutableArray arrayWithArray:array];
    }
}

-(void)initLuckyNumbers {
 
    //四等奖
    [self winner];
    [self winner];
    [self winner];
    [self winner];
    [self winner];
    [self winner];
    [self winner];
    [self winner];
    
    //三等奖
    [self winner];
    [self double];
    [self winner];
    [self winner];
    [self winner];
    [self double];
    [self winner];
    [self winner];

    //二等奖
    [self winner];
    [self winner];
    [self double];
    [self winner];
    [self winner];

    //一等奖
    [self double];
    [self winner];
    [self winner1];
    [self winner];
  
    //特等奖
    [self double];
    [self winner];
    [self winner];
}

-(void)double {
    NSNumber *n = self.doubleNumbers[0];
    [self.doubleNumbers removeObject:n];
    [self.lotteryNumbers removeObject:n];
    [self.luckyNumbers addObject:n];
}

-(void)winner1 {
    
    [self.lotteryNumbers removeObject:X];
    [self.luckyNumbers addObject:X];
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

- (void)trigger2 {
    
    if (self.stop == NO) {
        [timer2 setFireDate:[NSDate distantPast]];
    } else {
        [timer2 setFireDate:[NSDate distantFuture]];
        [self performSelector:@selector(playWinSound)
                   withObject:nil
                   afterDelay:.5];
        [self.stuffList removeObject:self.LotteryLabel.stringValue];
    }
    self.stop = !self.stop;
}

-(void)luckyDrawAnimate {
    
    self.LotteryLabel.stringValue = [NSString stringWithFormat:@"%u",arc4random()%34];
    [self performSelector:@selector(playCrunchSound)
               withObject:nil
               afterDelay:.5];
}

-(void)luckyDrawStuffNameAnimate {
    
    self.LotteryLabel.font = [NSFont systemFontOfSize:60];
    if (self.stuffList.count > 0) {
       self.LotteryLabel.stringValue = self.stuffList[arc4random()%self.stuffList.count];
    } else {
       self.LotteryLabel.stringValue = @"抽完啦~";
    }

    [self performSelector:@selector(playCrunchSound)
               withObject:nil
               afterDelay:.5];
}

-(void)getWinnerNumber {
    
    if (times < 28) {
        NSNumber *n = self.luckyNumbers[times % 28];
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
