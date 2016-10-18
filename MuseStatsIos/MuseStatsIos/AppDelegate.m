//
//  Interaxon, Inc. 2015
//  MuseStatsIos
//

#import "AppDelegate.h"

#import "LoggingListener.h"
#import "Constants.h"
#import "ViewController.h"

@interface AppDelegate ()

@property (weak, nonatomic) IXNMuseManager *manager;
//@property (nonatomic) LoggingListener *loggingListener;
@property (nonatomic) NSTimer *musePickerTimer;

@end

@implementation AppDelegate

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    @synchronized (self.manager) {
        // All variables and listeners are already wired up; return.
        if (self.manager)
            return;
        self.manager = [IXNMuseManager sharedManager];
    }
    if (!self.muse) {
        // Intent: show a bluetooth picker, but only if there isn't already a
        // Muse connected to the device. Do this by delaying the picker by 1
        // second. If startWithMuse happens before the timer expires, cancel
        // the timer.
        
        self.musePickerTimer =
            [NSTimer scheduledTimerWithTimeInterval:5
                                             target:self
                                           selector:@selector(showPicker)
                                           userInfo:nil
                                            repeats:NO];
    }
    // to resume connection if we disconnected in applicationDidEnterBakcground::
     else if (self.muse.getConnectionState == IXNConnectionStateDisconnected)
         [self.muse runAsynchronously];
    
    if (!self.loggingListener)
        self.loggingListener = [[LoggingListener alloc] initWithDelegate:self];
    
    [self.manager addObserver:self
                   forKeyPath:[self.manager connectedMusesKeyPath]
                      options:(NSKeyValueObservingOptionNew |
                               NSKeyValueObservingOptionInitial)
                      context:nil];
}

- (void)showPicker {
    [self.manager showMusePickerWithCompletion:^(NSError *e) {
        if (e)
            NSLog(@"Error showing Muse picker: %@", e.description);
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:[self.manager connectedMusesKeyPath]]) {
        NSSet *connectedMuses = [change objectForKey:NSKeyValueChangeNewKey];
        if (connectedMuses.count) {
            [self startWithMuse:[connectedMuses anyObject]];
            [self.viewController setStatusConnected:YES];
        }
        else {
            [self.viewController setStatusConnected:NO];
        }
    }
}

- (void)startWithMuse:(id<IXNMuse>)muse {
    // Uncomment to test Muse File Reader
    @synchronized (self.muse) {
        if (self.muse) {
            return;
        }
        self.muse = muse;
    }
    [self.musePickerTimer invalidate];
    self.musePickerTimer = nil;
    [self registerDataListeners];
    [self.muse runAsynchronously];
}

// This gets called by LoggingListener
- (void)sayHi {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Muse says hi"
                                                    message:@"Muse is now connected"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

-(void)registerDataListeners{
    if (!self.muse)
        return;
    [self.muse unregisterAllListeners];
    
    [self.muse registerDataListener:self.loggingListener
                               type:IXNMuseDataPacketTypeBattery];
    [self.muse registerDataListener:self.loggingListener type:IXNMuseDataPacketTypeHorseshoe];
    
    if ([self.recordingOptions containsObject:@"blink"]){
        [self.muse registerDataListener:self.loggingListener
                                   type:IXNMuseDataPacketTypeArtifacts];
    }
    
    if ([self.recordingOptions containsObject:@"acceleration"]){
        [self.muse registerDataListener:self.loggingListener
                                   type:IXNMuseDataPacketTypeAccelerometer];
    }
    
    if ([self.recordingOptions containsObject:@"raw"]){
        [self.muse registerDataListener:self.loggingListener type:IXNMuseDataPacketTypeEeg];
    }
    
    if ([self.recordingOptions containsObject:@"alpha"]){
        [self.muse registerDataListener:self.loggingListener type:IXNMuseDataPacketTypeAlphaAbsolute];
        NSLog(@"registering for alpha");
    }
    
    if ([self.recordingOptions containsObject:@"beta"]){
        [self.muse registerDataListener:self.loggingListener type:IXNMuseDataPacketTypeBetaAbsolute];
    }
    if ([self.recordingOptions containsObject:@"gamma"]){
        [self.muse registerDataListener:self.loggingListener type:IXNMuseDataPacketTypeGammaAbsolute];
    }
    if ([self.recordingOptions containsObject:@"theta"]){
        [self.muse registerDataListener:self.loggingListener type:IXNMuseDataPacketTypeThetaAbsolute];
    }
    if ([self.recordingOptions containsObject:@"delta"]){
        [self.muse registerDataListener:self.loggingListener type:IXNMuseDataPacketTypeDeltaAbsolute];
    }
    
    [self.muse registerConnectionListener:self.loggingListener];

}

- (void)reconnectToMuse {
    [self.muse runAsynchronously];
}

-(void)setRecordingOptions
{
    NSDictionary *options = [[NSUserDefaults standardUserDefaults] objectForKey:kSettingsOptionKey];
    NSMutableArray *activated = [NSMutableArray array];
    
    for (NSString *key in options)
    {
        BOOL on = [[options objectForKey:key] boolValue];
        if (on)
            [activated addObject:key];
    }
    self.recordingOptions = activated;
}

-(void)setDataListeners
{
    if (!self.muse)
        return;
    
    [self.muse registerDataListener:self.loggingListener
                               type:IXNMuseDataPacketTypeBattery];
    [self.muse registerDataListener:self.loggingListener type:IXNMuseDataPacketTypeHorseshoe];
    
    if ([self.recordingOptions containsObject:@"blink"]){
        [self.muse registerDataListener:self.loggingListener
                                   type:IXNMuseDataPacketTypeArtifacts];
    }
    else {
        [self.muse unregisterDataListener:self.loggingListener
                                   type:IXNMuseDataPacketTypeArtifacts];
    }
    
    if ([self.recordingOptions containsObject:@"acceleration"]){
        [self.muse registerDataListener:self.loggingListener
                                   type:IXNMuseDataPacketTypeAccelerometer];
    }
    else {
        [self.muse unregisterDataListener:self.loggingListener
                                   type:IXNMuseDataPacketTypeAccelerometer];
    }
    
    if ([self.recordingOptions containsObject:@"raw"]){
        [self.muse registerDataListener:self.loggingListener type:IXNMuseDataPacketTypeEeg];
    }
    
    if ([self.recordingOptions containsObject:@"alpha"]){
        [self.muse registerDataListener:self.loggingListener type:IXNMuseDataPacketTypeAlphaAbsolute];
    }
    
    if ([self.recordingOptions containsObject:@"beta"]){
        [self.muse registerDataListener:self.loggingListener type:IXNMuseDataPacketTypeBetaAbsolute];
    }
    if ([self.recordingOptions containsObject:@"gamma"]){
        [self.muse registerDataListener:self.loggingListener type:IXNMuseDataPacketTypeGammaAbsolute];
    }
    if ([self.recordingOptions containsObject:@"theta"]){
        [self.muse registerDataListener:self.loggingListener type:IXNMuseDataPacketTypeThetaAbsolute];
    }
    if ([self.recordingOptions containsObject:@"delta"]){
        [self.muse registerDataListener:self.loggingListener type:IXNMuseDataPacketTypeDeltaAbsolute];
    }
    
    [self.muse registerConnectionListener:self.loggingListener];
    if ([self.recordingOptions containsObject:@"location"]){
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        
        // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.locationManager requestAlwaysAuthorization];
        }
        
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        self.locationManager.distanceFilter = kDistanceFilter;
        [self.locationManager startUpdatingLocation];
        //[self.locationManager startMonitoringSignificantLocationChanges];
    }
    else {
        if (self.locationManager)
            [self.locationManager stopUpdatingLocation];
        self.locationManager = nil;
    }
        
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //[[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionary] forKey:kSettingsOptionKey];
    
    [self setRecordingOptions];
    //self.recordingOptions = @[@"location",@"raw",@"blink",@"acceleration",@"alpha",@"beta",@"gamma",@"delta",@"theta"];
    
    self.unreportedLocations = [NSMutableArray array];

    if ([self.recordingOptions containsObject:@"location"]){
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    
        // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.locationManager requestAlwaysAuthorization];
        }
    
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        self.locationManager.distanceFilter = kDistanceFilter;
        //[self.locationManager startMonitoringSignificantLocationChanges];
        [self.locationManager startUpdatingLocation];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

    // To disconnect instead of executing in the background:
    // [self.muse disconnect:NO];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    self.muse = nil;
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedAlways)
    {
        
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *last = [locations lastObject];
    
    // can filter based on accuracy of location info
    NSDate *now = last.timestamp;
    if (!now)
        now = [NSDate date];
    
    CGFloat timestamp = [now timeIntervalSince1970];
    
    NSDateFormatter *nsdf = [[NSDateFormatter alloc] init];
    [nsdf setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *nowString = [nsdf stringFromDate:now];
    
    // save location data locally, for backup purposes
    NSString *saveString = [NSString stringWithFormat:@"{\"lat\":%f, \"lng\":%f, \"timestamp\":%f},",last.coordinate.latitude,last.coordinate.longitude, timestamp];
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *fileName = [NSString stringWithFormat:@"%@/locations.txt",
                          documentsDirectory];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    if(![fileManager fileExistsAtPath:fileName])
    {
        [saveString writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:&error];
    }
    else
    {
        NSFileHandle *myHandle = [NSFileHandle fileHandleForWritingAtPath:fileName];
        [myHandle seekToEndOfFile];
        [myHandle writeData:[saveString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:last.coordinate.latitude longitude:last.coordinate.longitude];
    
    // geocode location and export last location if present
    [[[CLGeocoder alloc] init] reverseGeocodeLocation:loc  completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        if (error)
            [self logError:error.description];
        
        NSString *name = @"";
        NSString *address = @"";
        NSString *city = @"";
        NSString *state = @"";
        NSString *country = @"";
        
        if (!error && [placemarks count]>0){
            
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            NSDictionary *dic = placemark.addressDictionary;
            if (dic){
                //name = [NSString stringWithFormat:@"%@|%@|%@|%@",dic[@"Name"],dic[@"City"],dic[@"State"],dic[@"Country"]];
                if (placemark.name)
                    name = placemark.name;
                
                address = [NSString stringWithFormat:@"%@",[dic objectForKey:@"Name"]];
                city = [dic objectForKey:@"City"];
                state = [dic objectForKey:@"State"];
                country = [dic objectForKey:@"Country"];
            }
        }

        // for testing export location
       /* NSString *one_hour = [nsdf stringFromDate:[NSDate dateWithTimeInterval:60*60 sinceDate:now]];
        
        NSMutableDictionary *currentLocation = [@{@"lat":[NSNumber numberWithDouble:last.coordinate.latitude],@"lng":[NSNumber numberWithDouble:last.coordinate.longitude],@"timestamp":[NSNumber numberWithInteger:timestamp],@"location":name,@"address":address,@"startDate":nowString,@"country":country,@"state":state,@"city":city,@"endDate":one_hour} mutableCopy];
        
        [self exportLocationData:@[currentLocation]]; */
    
        NSMutableDictionary *currentLocation = [@{@"lat":[NSNumber numberWithDouble:last.coordinate.latitude],@"lng":[NSNumber numberWithDouble:last.coordinate.longitude],@"timestamp":[NSNumber numberWithInteger:timestamp],@"location":name,@"address":address,@"startDate":nowString,@"country":country,@"state":state,@"city":city} mutableCopy];

        if (self.lastLocation){
            NSDate *lastDate = [nsdf dateFromString:self.lastLocation[@"startDate"]];
            // make sure at least half a minute has passed to avoid over-reporting
            if ([now timeIntervalSinceDate:lastDate] >= 30){
                [self.lastLocation setValue:nowString forKey:@"endDate"];
                [self.unreportedLocations addObject:[self.lastLocation copy]];
                [self exportLocationData:self.unreportedLocations];
            }
        }
        self.lastLocation = currentLocation;
    }];

}

-(void)exportLocationData:(NSArray*)dataPoints
{
    // when exporting, should try with the full list of un-pushed locations,
    // if push fails (due to lack of internet connection or server down) , continue storing location data in array,
    // if push succeeds, clear the locations array
    
    NSString *URLString = [NSString stringWithFormat:@"%@/importLocationData",kMyndzpaceHost];
    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URLString]];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[NSJSONSerialization dataWithJSONObject:dataPoints options:0 error:nil]];
    
    NSURLConnection *connec = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
    
    /*NSURLSession *sesh = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
     NSURLSessionUploadTask *task =  [sesh uploadTaskWithRequest:req fromData:[json dataUsingEncoding:NSUTF8StringEncoding] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
     NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
     }];
     [task resume];*/
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // log the error, see what locations dic looks like
    NSString *errorStr = [NSString stringWithFormat:@"%@\n%@",error.description,self.unreportedLocations];
    [self logError:errorStr];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self.unreportedLocations removeAllObjects];
}

-(void)logError:(NSString*)error
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@/error.txt",
                          documentsDirectory];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *fileErr;
    
    if(![fileManager fileExistsAtPath:fileName])
    {
        [error writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:&fileErr];
    }
    else
    {
        NSFileHandle *myHandle = [NSFileHandle fileHandleForWritingAtPath:fileName];
        [myHandle seekToEndOfFile];
        [myHandle writeData:[error dataUsingEncoding:NSUTF8StringEncoding]];
    }
}

@end
