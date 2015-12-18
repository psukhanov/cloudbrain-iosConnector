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
    
    _rmqclient = [RabbitMQClient sharedClient];
    [_rmqclient setupWithExchangeName:[self exchangeName]];
    
    @try {
        RabbitMQClient *client = [RabbitMQClient sharedClient];
        
        /*NSArray *test = @[@{@"timestamp":@57890,@"channel_0":@0,@"channel_1":@0,@"channel_2":@0,@"channel_3":@0}];
        NSString *testString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:test options:0 error:nil] encoding:NSUTF8StringEncoding];
        
        [client sendData:testString OnExchangeName:[self exchangeName]];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *appFile = [documentsDirectory stringByAppendingPathComponent:_saveFileName];

        NSFileManager *outputFileManager = [NSFileManager defaultManager];
        
        if (![outputFileManager fileExistsAtPath: appFile])
        {
            NSLog (@"Output file does not exist, creating a new one");
            [outputFileManager createFileAtPath: appFile
                                       contents: nil
                                     attributes: nil];
        }
        else {
            NSError *fileReadError;
            NSString *stringSoFar = [[NSString alloc] initWithContentsOfFile:appFile encoding:NSUTF8StringEncoding error:&fileReadError];
            NSLog(@"saved data so far:%@",stringSoFar);
        }
        
        _saveFile = [NSFileHandle fileHandleForWritingAtPath:appFile];
        [_saveFile seekToEndOfFile];*/
        
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
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
        NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath =
        [documentsDirectory stringByAppendingPathComponent:@"new_muse_file.muse"];
    self.fileWriter = [IXNMuseFileFactory museFileWriterWithPathString:filePath];
    //[self.fileWriter addAnnotationString:1 annotation:@"fileWriter created"];
    [self.fileWriter flush];
    return self;
}

- (void)receiveMuseDataPacket:(IXNMuseDataPacket *)packet {
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

            /*NSArray *eegData = packet.values;
            //NSLog(@"data:%@",data);
            
            NSNumber *timestamp = [NSNumber numberWithLongLong:packet.timestamp / 1000.0f];
            //NSLog(@"timestamp:%lu",timestamp);
            
            NSArray *send = @[@{@"timestamp":timestamp,@"channel_0":eegData[0],@"channel_1":eegData[1],@"channel_2":eegData[2],@"channel_3":eegData[3]}];
            
            NSString *payload = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:send options:0 error:nil] encoding:NSUTF8StringEncoding];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [_rmqclient sendData:payload OnExchangeName:[self exchangeName]];
                //NSLog(@"sent data");
            });
            
            NSData *data = [payload dataUsingEncoding:NSUTF8StringEncoding];
            [_saveFile writeData:data];
            */
            
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
            [self.fileWriter flush];
            break;
        case IXNConnectionStateConnected:
            state = @"connected";
            [self.fileWriter addAnnotationString:1 annotation:@"connected"];
            break;
        case IXNConnectionStateConnecting:
            state = @"connecting";
            [self.fileWriter addAnnotationString:1 annotation:@"connecting"];
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
    [self.fileWriter flush];
    [self.fileWriter addAnnotationString:2 annotation:@"session started"];
}

-(void)endSession
{
    [self.fileWriter addAnnotationString:3 annotation:@"session ended"];
    [self.fileWriter flush];
}

@end
