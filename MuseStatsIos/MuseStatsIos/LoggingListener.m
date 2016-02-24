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
    NSString *currentFilename;
}

@property (nonatomic) BOOL lastBlink;
@property (nonatomic) BOOL sawOneBlink;
@property(nonatomic)BOOL currentlyHeadBandOn;
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
    
    
    if (packet.packetType == IXNMuseDataPacketTypeHorseshoe){
        for (NSInteger i=0;i<packet.values.count;i++)
        {
            NSInteger value = [packet.values[i] integerValue];
            NSInteger prevValue = [self.viewController.horseshoe[i] integerValue];
            
            UIImageView *indicator = self.viewController.horseshoeIndicators[i];
            
            if (prevValue != value){
                
                if (value >= 3)
                {
                    //bad
                    [indicator setImage:[UIImage imageNamed:@"200px-Red-dot.png"]];
                }
                else if (value == 2)
                {
                    //OK
                    [indicator setImage:[UIImage imageNamed:@"200px-Yellow-dot.png"]];
                    
                }
                else if (value == 1)
                {
                    // good
                    [indicator setImage:[UIImage imageNamed:@"200px-Green-dot.png"]];
                    
                }
            }
        }
    }
    if (_shouldRecordData)
    {
        switch (packet.packetType) {
            case IXNMuseDataPacketTypeBattery:
                NSLog(@"battery packet received");
                NSLog([NSString stringWithFormat:@"%f",[packet.values[IXNBatteryChargePercentageRemaining] doubleValue]]);
                
                [self.fileWriter addDataPacket:IXNMuseDataPacketTypeBattery packet:packet];
                break;
            case IXNMuseDataPacketTypeAccelerometer:
            {
                [self.fileWriter addDataPacket:IXNMuseDataPacketTypeAccelerometer packet:packet];
                break;
            }
            case IXNMuseDataPacketTypeEeg:
            {
                [self.fileWriter addDataPacket:IXNMuseDataPacketTypeEeg packet:packet];

                NSArray *eegData = packet.values;
                NSNumber *timestamp = [NSNumber numberWithUnsignedLongLong:packet.timestamp];
                
                NSNumber *playing = [NSNumber numberWithBool:NO];
                if (self.viewController.tuneDelegate && self.viewController.tuneDelegate.isPlaying)
                {
                    playing = [NSNumber numberWithBool:YES];

                }
                
                [self.arrBuffer addObject:@{@"timestamp":timestamp,@"channel_0":eegData[0],@"channel_1":eegData[1],@"channel_2":eegData[2],@"channel_3":eegData[3],@"stimOn":playing}];
                
                if ([kRecordingMode isEqualToString:@"remote-online"]){
                    
                    // send RabbitMQ message in 10-sample buffers
                    if ([self.arrBuffer count] == 10){
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
            case IXNMuseDataPacketTypeHorseshoe:
            {
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

-(void)logStim:(BOOL)on
{
    if (on)
    {
        //NSString *annotation = [NSString stringWithFormat:@"stimOn:%f",freq];
        [self.fileWriter addAnnotationString:1 annotation:@"stimOn"];
    }
    else
        [self.fileWriter addAnnotationString:1 annotation:@"stimOff"];

}

- (void)receiveMuseArtifactPacket:(IXNMuseArtifactPacket *)packet {
 
    if (!self.currentlyHeadBandOn) {
        if (packet.headbandOn) {
            self.currentlyHeadBandOn = YES;
        }
    }
    if (self.currentlyHeadBandOn) {
        if (!packet.headbandOn) {
            self.currentlyHeadBandOn = NO;
        }
    }
    [self.viewController setHeadbandOnStatus:self.currentlyHeadBandOn];
    //if (!packet.headbandOn)
    //    return;
    if (!self.sawOneBlink) {
        self.sawOneBlink = YES;
        self.lastBlink = !packet.blink;
    }
    if (self.lastBlink != packet.blink) {
        if (packet.blink){
            NSLog(@"blink");
            [self.fileWriter addAnnotationString:1 annotation:@"blink"];
        }
        self.lastBlink = packet.blink;
    }
}

- (void)receiveMuseConnectionPacket:(IXNMuseConnectionPacket *)packet {
    NSString *state;
    switch (packet.currentConnectionState) {
        case IXNConnectionStateDisconnected:
            state = @"disconnected";
            if (_shouldRecordData){
                [self.fileWriter addAnnotationString:1 annotation:@"disconnected"];
                [self endSession];
            }
            [self.viewController setStatusConnected:NO];

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

-(void)startSessionWithName:(NSString *)name
{
    NSString *filename = name;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // if name not set, set it to session_x, x = 1 greater than largest session number to date
    if (!name || [name isEqualToString:@""])
    {
        NSFileManager *filemgr = [NSFileManager defaultManager];
        NSArray *filelist= [filemgr directoryContentsAtPath:documentsDirectory];
        
        NSInteger maxSessionNum = 0;
        for (NSString *filename in filelist)
        {
            NSArray *comps = [filename componentsSeparatedByString:@".muse"];
            if ([comps count] > 1){
                NSString *restOfName = [comps objectAtIndex:0];
                NSString *sessionNum = [[restOfName componentsSeparatedByString:@"_"] objectAtIndex:1];
                if ([sessionNum integerValue] > maxSessionNum)
                    maxSessionNum = [sessionNum integerValue];
            }
        }
        
        NSInteger newSessionNum = maxSessionNum + 1;
        filename = [NSString stringWithFormat:@"%@%ld%@",kSessionBaseFileName,(long)newSessionNum,@".muse"];
    }
    
    NSString *filePath =
    [documentsDirectory stringByAppendingPathComponent:filename];
    
    
    self.fileWriter = [IXNMuseFileFactory museFileWriterWithPathString:filePath];
    
    currentFilename = filename;
    
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
    
    if (![self.viewController.txtSessionName.text isEqualToString:@""])
    {
        NSError * err = NULL;
        NSFileManager * fm = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        BOOL result = [fm moveItemAtPath:[documentsDirectory stringByAppendingPathComponent:currentFilename] toPath:[documentsDirectory stringByAppendingPathComponent:self.viewController.txtSessionName.text] error:&err];
        if(!result)
            NSLog(@"Error: %@", err);
        [self.viewController.txtSessionName setText:@""];
    }
    currentFilename = @"";
    
    // dump data into RabbitMQ if needed
    if ([kRecordingMode isEqualToString:@"remote-offline"])
    {
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
