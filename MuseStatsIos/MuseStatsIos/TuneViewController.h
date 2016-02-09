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

@property (nonatomic, strong) IBOutlet UIStepper *stepper;
@property (nonatomic, strong) IBOutlet UILabel *lblTitle;
@property (nonatomic) NSMutableArray *arrData;

@property (nonatomic, strong) AVAudioPlayer *player;
@property NSArray *soundFiles; 
@property NSInteger selectedSound;
@property BOOL isPlaying;
@property LoggingListener *logger;


-(IBAction)playSound;

@end

