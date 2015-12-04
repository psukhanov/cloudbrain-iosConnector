//
//  Interaxon, Inc. 2015
//  MuseStatsIos
//

#import "LoggingListener.h"
#import "RabbitMQClient.h"

@interface LoggingListener () {
    dispatch_once_t _connectedOnceToken;
    NSString * const kHostName;
    int const kPortNumber;
}
@property (nonatomic) BOOL lastBlink;
@property (nonatomic) BOOL sawOneBlink;
@property (nonatomic, weak) AppDelegate* delegate;
@property (nonatomic) id<IXNMuseFileWriter> fileWriter;

@property (nonatomic) NSString *deviceName, *deviceType, *metric;
@property (nonatomic, weak) RabbitMQClient *rmqclient;

@end

@implementation LoggingListener

- (instancetype)initWithDelegate:(AppDelegate *)delegate {
    _delegate = delegate;
    _deviceName = @"Paul-Muse";
    _deviceType = @"muse";
    _metric = @"eeg";
    _rmqclient = [RabbitMQClient sharedClient];
    [_rmqclient setupWithExchangeName:[self exchangeName]];
    
    @try {
        RabbitMQClient *client = [RabbitMQClient sharedClient];
        [client sendData:@"test" OnExchangeName:[self exchangeName]];
        
   }
    @catch (NSException *exception) {
        NSLog(@"e:%@",exception);
    }
    @finally {
        NSLog(@"sent RabbitMQ message");
    }

    /**
     * Set <key>UIFileSharingEnabled</key> to true in Info.plist if you want
     * to see the file in iTunes
     */
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(
//        NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *filePath =
//        [documentsDirectory stringByAppendingPathComponent:@"new_muse_file.muse"];
//    self.fileWriter = [IXNMuseFileFactory museFileWriterWithPathString:filePath];
//    [self.fileWriter addAnnotationString:1 annotation:@"fileWriter created"];
//    [self.fileWriter flush];
    return self;
}

- (void)receiveMuseDataPacket:(IXNMuseDataPacket *)packet {
    switch (packet.packetType) {
        case IXNMuseDataPacketTypeBattery:
            NSLog(@"battery packet received");
//            [self.fileWriter addDataPacket:1 packet:packet];
            break;
        case IXNMuseDataPacketTypeAccelerometer:
            break;
        case IXNMuseDataPacketTypeEeg:
        {
            NSArray *data = packet.values;
            NSLog(@"data:%@",data);
            
            NSInteger timestamp = packet.timestamp;
            NSLog(@"timestamp:%lu",timestamp);
            
            NSString *payload = [data componentsJoinedByString:@" "];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [_rmqclient sendData:payload OnExchangeName:[self exchangeName]];
                NSLog(@"sent data");
            });
        }
        case IXNMuseDataPacketTypeAlphaAbsolute:
        {
            /*NSArray *data = packet.values;
            NSLog(@"data:%@",data);
            
            NSInteger timestamp = packet.timestamp;
            NSLog(@"timestamp:%lu",timestamp);
            
            NSString *payload = [data componentsJoinedByString:@" "];*/
            
            //[client sendData:payload OnExchangeName:[self exchangeName]];
        }
        case IXNMuseDataPacketTypeBetaAbsolute:
            break;
        default:
            break;
    }
}

- (void)receiveMuseArtifactPacket:(IXNMuseArtifactPacket *)packet {
    if (!packet.headbandOn)
        return;
    if (!self.sawOneBlink) {
        self.sawOneBlink = YES;
        self.lastBlink = !packet.blink;
    }
    if (self.lastBlink != packet.blink) {
        if (packet.blink)
            NSLog(@"blink");
        self.lastBlink = packet.blink;
    }
}

- (void)receiveMuseConnectionPacket:(IXNMuseConnectionPacket *)packet {
    NSString *state;
    switch (packet.currentConnectionState) {
        case IXNConnectionStateDisconnected:
            state = @"disconnected";
//            [self.fileWriter addAnnotationString:1 annotation:@"disconnected"];
//            [self.fileWriter flush];
            break;
        case IXNConnectionStateConnected:
            state = @"connected";
//            [self.fileWriter addAnnotationString:1 annotation:@"connected"];
            break;
        case IXNConnectionStateConnecting:
            state = @"connecting";
//            [self.fileWriter addAnnotationString:1 annotation:@"connecting"];
            break;
        case IXNConnectionStateNeedsUpdate: state = @"needs update"; break;
        case IXNConnectionStateUnknown: state = @"unknown"; break;
        default: NSAssert(NO, @"impossible connection state received");
    }
    NSLog(@"connect: %@", state);
    if (packet.currentConnectionState == IXNConnectionStateConnected) {
        [self.delegate sayHi];
    } else if (packet.currentConnectionState == IXNConnectionStateDisconnected) {
        [self.delegate performSelector:@selector(reconnectToMuse)
                            withObject:nil
                            afterDelay:0];
    }
}

-(NSString*)exchangeName
{
    NSString *exchangeName = [NSString stringWithFormat:@"%@:%@:%@",self.deviceName,self.deviceType,self.metric];
    return exchangeName;
}

@end
