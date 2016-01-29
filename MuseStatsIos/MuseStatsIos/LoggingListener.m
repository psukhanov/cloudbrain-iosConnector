//
//  Interaxon, Inc. 2015
//  MuseStatsIos
//

#import "LoggingListener.h"
#import "RabbitMQClient.h"
#import "Constants.h"
#import "ViewController.h"

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
@property (nonatomic) NSString *saveFileName;
@property (nonatomic) NSFileHandle *saveFile;

@end

@implementation LoggingListener

- (instancetype)initWithDelegate:(AppDelegate *)delegate {
    _delegate = delegate;
    _deviceName = @"Paul-Muse";
    _deviceType = @"muse";
    _metric = @"eeg";
    _saveFileName = @"MyFile";
    _arrBuffer = [NSMutableArray array];
    
    _shouldRecordData = NO;
    
    _rmqclient = [RabbitMQClient sharedClient];
    [_rmqclient setupWithExchangeName:[self exchangeName]];
    
    @try {
        RabbitMQClient *client = [RabbitMQClient sharedClient];
        
   }
    @catch (NSException *exception) {
        NSLog(@"e:%@",exception);
    }
    @finally {
        //NSLog(@"sent RabbitMQ message");
    }

    /**
     * Set <key>UIFileSharingEnabled</key> to true in Info.plist if you want
     * to see the file in iTunes
     */
    
    return self;
}

- (void)receiveMuseDataPacket:(IXNMuseDataPacket *)packet {
    
    if (_shouldRecordData)
    {
        switch (packet.packetType) {
            case IXNMuseDataPacketTypeBattery:
                NSLog(@"battery packet received");
                NSLog([NSString stringWithFormat:@"%f",[packet.values[IXNBatteryChargePercentageRemaining] doubleValue]]);
                
                [self.fileWriter addDataPacket:1 packet:packet];
                break;
            case IXNMuseDataPacketTypeAccelerometer:
                break;
            case IXNMuseDataPacketTypeEeg:
            {
                [self.fileWriter addDataPacket:IXNMuseDataPacketTypeEeg packet:packet];

                NSArray *eegData = packet.values;
                //NSLog(@"data:%@",data);
                
                NSNumber *timestamp = [NSNumber numberWithUnsignedLongLong:packet.timestamp];

                //NSLog(@"timestamp:%lu",timestamp);
                
                [self.arrBuffer addObject:@{@"timestamp":timestamp,@"channel_0":eegData[0],@"channel_1":eegData[1],@"channel_2":eegData[2],@"channel_3":eegData[3]}];
                
                if ([kRecordingMode isEqualToString:@"remote-online"]){
                    
                    if ([self.arrBuffer count] == 200){
                        NSString *payload = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:self.arrBuffer options:0 error:nil] encoding:NSUTF8StringEncoding];
                        [self.arrBuffer removeAllObjects];

                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                            [_rmqclient sendData:payload OnExchangeName:[self exchangeName]];
                            //NSLog(@"sent data");
                        });
                    }
                }
                
                break;
            }
            case IXNMuseDataPacketTypeAlphaAbsolute:
            {
                break;
            }
            case IXNMuseDataPacketTypeBetaAbsolute:
                break;
            default:
                break;
        }
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
            [self.fileWriter addAnnotationString:1 annotation:@"disconnected"];
            [self.viewController setStatusConnected:NO];
            [self endSession];
            break;
        case IXNConnectionStateConnected:
            state = @"connected";
            [self.viewController setStatusConnected:YES];

            //[self.fileWriter addAnnotationString:1 annotation:@"connected"];
            break;
        case IXNConnectionStateConnecting:
            state = @"connecting";
            //[self.fileWriter addAnnotationString:1 annotation:@"connecting"];
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

-(void)startSession
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSArray *filelist= [filemgr directoryContentsAtPath:documentsDirectory];
    
    NSInteger maxSessionNum = 0;
    for (NSString *filename in filelist)
    {
        NSArray *comps = [filename componentsSeparatedByString:@".muse"];
        NSString *restOfName = [comps objectAtIndex:0];
        NSString *sessionNum = [[restOfName componentsSeparatedByString:@"_"] objectAtIndex:1];
        if ([sessionNum integerValue] > maxSessionNum)
            maxSessionNum = [sessionNum integerValue];
    }
    
    NSInteger newSessionNum = maxSessionNum + 1;
    
    NSString *filePath =
    [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%ld%@",kSessionBaseFileName,(long)newSessionNum,@".muse"]];
    
    self.fileWriter = [IXNMuseFileFactory museFileWriterWithPathString:filePath];
	[self.fileWriter addAnnotationString:1 annotation:@"fileWriter created"];
    [self.fileWriter flush];

    [self.fileWriter addAnnotationString:1 annotation:@"session started"];
    _shouldRecordData = YES;
}

-(void)endSession
{
    [self.fileWriter addAnnotationString:1 annotation:@"session ended"];
    [self.fileWriter flush];
    _shouldRecordData = NO;
    
    if ([kRecordingMode isEqualToString:@"remote-offline"])
    {
        if ([self.arrBuffer count] == 0)
        {
            //[self.arrBuffer addObject:@{@"timestamp":@1452473072000,@"channel_0":@1,@"channel_1":@1,@"channel_2":@1,@"channel_3":@1}];
        }
        NSString *payload = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:self.arrBuffer options:0 error:nil] encoding:NSUTF8StringEncoding];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [_rmqclient sendData:payload OnExchangeName:[self exchangeName]];
            //NSLog(@"sent data");
            [self.arrBuffer removeAllObjects];

        });
    }
    if (self.viewController)
    {
        [self.viewController loadData];
    }
}

@end
