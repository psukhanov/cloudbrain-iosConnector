//
//  ViewController.h
//  Tunesky
//
//  Created by Felipe Valdez on 1/24/16.
//  Copyright © 2016 Paul Sukhanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "LoggingListener.h"

@interface TuneViewController : UIViewController <AVAudioPlayerDelegate>

@property (nonatomic, strong) IBOutlet UIStepper *stepperPitch, *stepperNReplays;
@property (nonatomic, strong) IBOutlet UILabel *lblTitle, *lblNReplays;
@property (nonatomic) NSMutableArray *arrData;

@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic) NSArray *soundFiles;
@property (nonatomic) NSInteger selectedSound, nReplays;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic) LoggingListener *logger;
@property (nonatomic) NSDate *soundLoopEnd;
@property (nonatomic) NSTimer *loopTimer;
@property NSInteger playLength;

-(IBAction)playSound;

@end

