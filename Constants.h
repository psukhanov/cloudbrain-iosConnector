//
//  Constants.h
//  MuseStatsIos
//
//  Created by Felipe Valdez on 11/19/15.
//  Copyright © 2015 InteraXon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

extern NSString *const kHostName;
extern NSString *const kMyndzpaceHost;

extern int const kPortNumber;
extern NSString *const kExchangeUsername;
extern NSString *const kExchangePassword;

extern NSString *const kSessionBaseFileName;

extern NSString *const kRecordingMode;
/*
typedef enum recordingMode : NSUInteger {
    kRecordingModeRemoteOffline,
    kRecordingModeRemoteOnline,
    kRecordingModeLocal
} recordingMode;*/

@end
