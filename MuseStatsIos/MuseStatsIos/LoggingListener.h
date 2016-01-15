//
//  Interaxon, Inc. 2015
//  MuseStatsIos
//

#import <Foundation/Foundation.h>
#import "Muse.h"
#import "AppDelegate.h"
#import "RabbitMQClient.h"

@class ViewController;

@interface LoggingListener : NSObject<
    IXNMuseDataListener, IXNMuseConnectionListener
>

@property BOOL shouldRecordData;
@property NSMutableArray *arrBuffer;
@property (nonatomic, weak) ViewController *viewController;

// Designated initializer.
- (instancetype)initWithDelegate:(AppDelegate *)delegate;
- (void)receiveMuseDataPacket:(IXNMuseDataPacket *)packet;
- (void)receiveMuseArtifactPacket:(IXNMuseArtifactPacket *)packet;
- (void)receiveMuseConnectionPacket:(IXNMuseConnectionPacket *)packet;
-(void)startSession;
-(void)endSession;

@end
