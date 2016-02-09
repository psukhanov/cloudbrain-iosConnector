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
    
    self.soundFiles = @[@"a2",@"a#2",@"c3"];
    self.selectedSound = 0;
    
    [self loadSoundFile:self.selectedSound];
    [self playSound];
    
    [self.stepper setMaximumValue:self.soundFiles.count-1];
    [self.stepper addTarget:self action:@selector(changeSoundFile:) forControlEvents:UIControlEventValueChanged];
    
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

-(void)changeSoundFile:(UIStepper*)stepper
{
    NSInteger value = stepper.value;
    NSString *name = [self.soundFiles objectAtIndex:value];
    [self.lblTitle setText:name];
    
    [self loadSoundFile:value];
    [self playSound];
}

-(void)viewWillDisappear:(BOOL)animated
{
    NSError *error;
    NSString *stringToWrite = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:self.arrData options:0 error:&error] encoding:NSUTF8StringEncoding];
    
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"sound_timing.txt"];
    [stringToWrite writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
}
@end
