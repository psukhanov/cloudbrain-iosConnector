//
//  AudioPlayer.m
//  MuseStatsIos
//
//  Created by Felipe Valdez on 12/12/15.
//  Copyright © 2015 InteraXon. All rights reserved.
//

#import "AudioPlayer.h"
#import <AudioToolbox/AudioToolbox.h>

@interface AudioPlayer ()

@property SystemSoundID sound;

@end

@implementation AudioPlayer


-(void)playFile:(NSString*)fileName
{
    NSString *path = [[NSBundle mainBundle]
                            pathForResource:fileName ofType:@"wav"];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &_sound);
    AudioServicesPlaySystemSound(self.sound);
}

@end
