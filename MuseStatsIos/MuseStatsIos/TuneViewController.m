//
//  ViewController.m
//  Tunesky
//
//  Created by Felipe Valdez on 1/24/16.
//  Copyright © 2016 Paul Sukhanov. All rights reserved.
//

#import "TuneViewController.h"

@interface TuneViewController ()

@end

@implementation TuneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.arrData = [NSMutableArray array];
    
    self.soundFiles = @[@"c2_65.41",@"c#2_69.3",@"d2_73.42",@"d#2_77.78",@"e2_82.41",@"f2_87.31",@"f#2_92.5",@"g2_98.00",@"g#2_103.83",@"a2_110.00",@"a#2_116.54",@"b2_123.47"];
    
    self.selectedSound = 0;
    
    [self loadSoundFile:self.selectedSound];
    //[self playSound];
    
    [self.stepperPitch setMaximumValue:self.soundFiles.count-1];
    [self.stepperPitch addTarget:self action:@selector(changeSoundFile:) forControlEvents:UIControlEventValueChanged];
    
    [self.stepperNReplays setMinimumValue:1];
    [self.stepperNReplays addTarget:self action:@selector(setReplays:) forControlEvents:UIControlEventValueChanged];
    self.nReplays = 1;
    self.playLength = 5;

    //NSFileManager *fmg = [NSFileManager defaultManager];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)playSound
{
    NSInteger timestamp = [[NSDate date] timeIntervalSince1970];
    NSString *noteName = self.lblTitle.text;
    NSDictionary *sound = @{@"timestamp":[NSNumber numberWithLong:timestamp],@"note":noteName};
    [self.arrData addObject:sound];
    
    self.isPlaying = YES;
    
    if (self.logger)
        [self.logger logStim:YES];
    
    [self.player play];
}

-(void)loadSoundFile:(NSInteger)fileNumber
{
    if (self.player)
        [self.player stop];
    
    if (fileNumber  < self.soundFiles.count){
        NSString *filename = [self.soundFiles objectAtIndex:fileNumber];
                NSString *filePath = [[NSBundle mainBundle] pathForResource:filename ofType:@"wav"];
        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:filePath];
        NSError *error;

        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
        self.player.delegate = self;
        if (error)
            NSLog(@"error:%@",error);
    }
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    self.isPlaying = NO;
    if (self.logger)
        [self.logger logStim:NO];
}

-(void)setReplays:(UIStepper*)stepper
{
    NSInteger value = stepper.value;
    self.nReplays = value;
    [self.lblNReplays setText:[NSString stringWithFormat:@"%lu Replays",value]];
}

-(void)changeSoundFile:(UIStepper*)stepper
{
    NSInteger value = stepper.value;
    NSString *name = [self.soundFiles objectAtIndex:value];
    [self.lblTitle setText:name];
    
    [self loadSoundFile:value];
    //[self playSound];
}

-(void)viewWillDisappear:(BOOL)animated
{
    //NSError *error;
    //NSString *stringToWrite = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:self.arrData options:0 error:&error] encoding:NSUTF8StringEncoding];
    
    //NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"sound_timing.txt"];
    //[stringToWrite writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    [self.player stop];
    self.player = nil;
    
}

-(IBAction)playSelection
{
    NSInteger repeatInterval = self.playLength * 2;
    NSInteger totalPlayTime = repeatInterval * self.nReplays;


    self.loopTimer = [NSTimer timerWithTimeInterval:repeatInterval target:self selector:@selector(playLoopedSound) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.loopTimer forMode:NSDefaultRunLoopMode];
    NSString *toneName = self.lblTitle.text;

    [self.logger startSessionWithName:[NSString stringWithFormat:@"audio_experiment_%@",self.lblTitle.text]];
    
    NSDate *soundLoopStart = [NSDate date];
    self.soundLoopEnd = [soundLoopStart dateByAddingTimeInterval:totalPlayTime];
    [self playSound];

}

-(IBAction)playRandomSelection
{
    NSInteger repeatInterval = self.playLength * 2;
    NSInteger totalPlayTime = repeatInterval * self.nReplays;
    
    self.loopTimer = [NSTimer timerWithTimeInterval:repeatInterval target:self selector:@selector(playRandomSound) userInfo:nil repeats:YES];
    NSDate *soundLoopStart = [NSDate date];

    self.soundLoopEnd = [soundLoopStart dateByAddingTimeInterval:totalPlayTime];
    [[NSRunLoop mainRunLoop] addTimer:self.loopTimer forMode:NSDefaultRunLoopMode];
    [self.logger startSessionWithName:[NSString stringWithFormat:@"audio_experiment_random"]];

}


-(void)playLoopedSound
{
    if ([[NSDate date] compare:self.soundLoopEnd] == NSOrderedAscending)
    {
        self.stepperNReplays.value -= 1;
        [self.lblNReplays setText:[NSString stringWithFormat:@"%lu replays",(NSInteger)self.stepperNReplays.value]];
        [self playSound];
    }
    else {
        [self.logger endSession];
        [self.loopTimer invalidate];
        self.loopTimer = nil;
    }
}

-(void)playRandomSound
{
    if ([[NSDate date] compare:self.soundLoopEnd] == NSOrderedAscending)
    {
        // still valid
        NSUInteger r = arc4random_uniform(self.soundFiles.count-1);
        [self loadSoundFile:r];
        [self playSound];
    }
    else {
        [self.logger endSession];
        [self.loopTimer invalidate];
        self.loopTimer = nil;
    }
}
@end
