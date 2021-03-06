//
//  Interaxon, Inc. 2015
//  MuseStatsIos
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "LoggingListener.h"
#import "SessionCell.h"
#import "TuneViewController.h"
#import "SessionDetailViewController.h"

@interface ViewController ()

{
    NSTimer *sessionTimer;
}

@property(nonatomic, strong) SessionCell *sessionCell;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self loadData];
    [self.scroll setContentSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height)];
    
    UITapGestureRecognizer *bgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clearKeyboard)];
    //[self.view addGestureRecognizer:bgTap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    self.connectedToMuse = NO;
    self.horseshoe = @[@4,@4,@4,@4];
    
    [[UINavigationBar appearance] setTranslucent:NO];
}

-(void)configureBottomToolbar
{
    /*self.navigationController.toolbarHidden = NO;
     
     UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
     [btn setImage:[UIImage imageNamed:@"250px-Grey-dot.png"] forState:UIControlStateNormal];
     UIImageView *dot = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"40px-Grey-dot.png"]];
     [dot setFrame:CGRectMake(0, 0, 20, 20)];
     
     UIBarButtonItem *connectedIcon = [[UIBarButtonItem alloc] initWithCustomView:dot];
     
     NSArray *barButtonItems = @[connectedIcon];
     
     [self.navigationController setToolbarItems:barButtonItems animated:YES];*/
}

-(void)clearKeyboard
{
    [self.txtSessionName resignFirstResponder];
}

-(void)loadData
{
    // load saved sessions from documents directory / session_x.muse
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSArray *filelist= [filemgr directoryContentsAtPath:documentsDirectory];
        
    NSArray *sessions = [[NSUserDefaults standardUserDefaults] objectForKey:@"sessions"];
    NSArray *savedFileNames;
    if (!sessions){
        self.sessions = [NSMutableArray array];
        savedFileNames = [NSArray array];
    }
    else {
        savedFileNames = [sessions valueForKeyPath:@"fileName"];
        self.sessions = [sessions mutableCopy];
    }
    
    // check for newly added files
    for (NSString *filePath in filelist)
    {
        if ([filePath rangeOfString:@".csv"].location == NSNotFound && [filePath rangeOfString:@".wav"].location == NSNotFound)
        {
            if (![savedFileNames containsObject:filePath]){
                NSDictionary *data = [self museFileToData:filePath];
                [self.sessions addObject:data];
            }
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:self.sessions forKey:@"sessions"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"endDate" ascending:NO];
    [self.sessions sortUsingDescriptors:@[sort]];
    [self.tblSessions reloadData];

}

-(void)viewDidAppear:(BOOL)animated
{
    if (!self.delegate){
        LoggingListener *listener = [(AppDelegate*)[UIApplication sharedApplication].delegate loggingListener];
        self.delegate = listener;
        listener.viewController = self;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)startSession:(id)sender
{
    if (!self.sessionStarted){
        
        if (!self.connectedToMuse){
            [[[UIAlertView alloc] initWithTitle:@"Not connected" message:@"Please ensure that the Muse device is connected via bluetooth before starting a session" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil]show];
            return;
        }
        
        NSLog(@"starting session");
        UIColor *offColor = [UIColor colorWithRed:0.8 green:0.4 blue:0.4 alpha:1];
        
        NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"End Session" attributes:@{NSForegroundColorAttributeName:offColor}];
        [self.btnSession setAttributedTitle:title forState:UIControlStateNormal];
        
        self.sessionStarted = YES;
        self.dateSessionStart = [NSDate date];
        
        // start Timer
        [self.lblMinutes setText:@"00 Min"];
        [self.lblSeconds setText:@"00 Sec"];
        
        [self startTimer];
        
        if ([self.delegate respondsToSelector:@selector(startSessionWithName:)])
        {
            [self.delegate startSessionWithName:self.txtSessionName.text];
        }
    }
    else {
        NSLog(@"ending session");
        [self.btnSession setTitle:@"Start Session" forState:UIControlStateNormal];
        UIColor *onColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.8 alpha:1];

        NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"Start Session" attributes:@{NSForegroundColorAttributeName:onColor}];
        [self.btnSession setAttributedTitle:title forState:UIControlStateNormal];
        
        self.sessionStarted = NO;
        [sessionTimer invalidate];
        
        if ([self.delegate respondsToSelector:@selector(endSession)])
        {
            [self.delegate endSession];
        }
    }
}

-(void)startTimer
{
    sessionTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:sessionTimer forMode:NSDefaultRunLoopMode];
}

- (void)timerTick:(NSTimer *)timer {
    NSDate *now = [NSDate date];
    
    NSTimeInterval secondsElapsed = [now timeIntervalSinceDate:self.dateSessionStart];
    
    int nMin = floor(secondsElapsed/60.0f);
    int nSec = fmod(secondsElapsed, 60);
    
    [self.lblSeconds setText:[NSString stringWithFormat:@"%02d Sec",nSec]];
    [self.lblMinutes setText:[NSString stringWithFormat:@"%02d Min",nMin]];

}

- (NSDictionary*)museFileToData:(NSString*)fileName{
    //NSLog(@"start play muse");
    
    NSString *filePath =
    [self documentFilePathForFilename:fileName];
    
    id<IXNMuseFileReader> fileReader =
    [IXNMuseFileFactory museFileReaderWithPathString:filePath];

    
    int64_t firstTimestamp = 0;
    int64_t lastTimestamp = 0;
    
    while ([fileReader gotoNextMessage]) {
        IXNMessageType type = [fileReader getMessageType];
        int id_number = [fileReader getMessageId];
        int64_t timestamp = [fileReader getMessageTimestamp];
        
        if (firstTimestamp == 0)
            firstTimestamp = timestamp;
        
        lastTimestamp = timestamp;
        
        /*NSLog(@"type: %d, id: %d, timestamp: %lld",
         (int)type, id_number, timestamp);*/
        
        switch(type) {
            case IXNMessageTypeEeg:
            {
                break;
            }
            case IXNMessageTypeQuantization:
            case IXNMessageTypeAccelerometer:
            case IXNMessageTypeBattery:
            {
                IXNMuseDataPacket* packet = [fileReader getDataPacket];
                //NSLog(@"data packet = %d", (int)packet.packetType);
                break;
            }
            case IXNMessageTypeVersion:
            {
                IXNMuseVersion* version = [fileReader getVersion];
                //NSLog(@"version = %@", version.firmwareVersion);
                break;
            }
            case IXNMessageTypeConfiguration:
            {
                IXNMuseConfiguration* config = [fileReader getConfiguration];
                //NSLog(@"configuration = %@", config.bluetoothMac);
                break;
            }
            case IXNMessageTypeAnnotation:
            {
                IXNAnnotationData *annotation = [fileReader getAnnotation];
                //NSLog(@"annotation = %@", annotation.data);
                
                break;
            }
            default:
                break;
        }
    }
    
    CGFloat startTime = (double)firstTimestamp / (1000.0f * 1000.0f);
    CGFloat endTime = (double)lastTimestamp / (1000.0f * 1000.0f);
    CGFloat duration = endTime - startTime;
    
    int nMin = floor(duration/60.0f);
    int nSec = fmod(duration, 60);
    
    NSString *strDuration = [NSString stringWithFormat:@"%d m %d s",nMin,nSec];

    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:startTime];
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:endTime];
    
    NSNumber *size = [NSNumber numberWithUnsignedLong:[[NSData dataWithContentsOfFile:filePath] length]];
    
    NSDictionary *sessionData = @{@"startDate":startDate, @"endDate":endDate, @"size":size,@"fileName":fileName, @"duration":strDuration};
    
    return  sessionData;
}

# pragma mark UITableViewDelegate Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sessions count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SessionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sessionCell"];
    NSDictionary *data = [self.sessions objectAtIndex:indexPath.row];
    [cell setSessionData:data];
    [cell setUpView];
    [cell setIndexPath:indexPath];
    
    cell.delegate = self;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    [header setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 310, 20)];
    [lbl setTextAlignment:NSTextAlignmentCenter];
    [lbl setFont:[UIFont fontWithName:@"HelveticaNeue" size:18.0]];
    [lbl setText:@"Recorded Sessions"];
    
    [header addSubview:lbl];
    return header;
}

//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//}

- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        if (self.sessionCell) {
            self.sessionCell = nil;
        }
        
        self.sessionCell = (SessionCell*)[tableView cellForRowAtIndexPath:indexPath];
       
        NSString *message = [NSString stringWithFormat:@"%@ will be permanently deleted. Proceed?",[self.sessionCell.sessionData objectForKey:@"fileName"]];
        [[[UIAlertView alloc] initWithTitle:@"Are you sure?" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Proceed", nil]show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        if ([self respondsToSelector:@selector(deleteSessionForCell:)])
        {
            [self deleteSessionForCell:self.sessionCell];
            [self.tblSessions reloadData];
        }
    }
}

-(void)deleteSessionForCell:(SessionCell*)cell
{
    NSDictionary *session = cell.sessionData;
    NSString *filename = [session objectForKey:@"fileName"];
    
    int count = 0;
    int sessionIndex = -1;
    for (NSDictionary *dic in self.sessions)
    {
        if ([[session objectForKey:@"fileName"] isEqualToString:[dic objectForKey:@"fileName"]])
        {
            sessionIndex = count;
        }
        count++;
    }
    
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:[self documentFilePathForFilename:filename] error:&error];
    if (error)
    {
        NSLog(@"file delete error:%@",error);
    }
    
    [self.sessions removeObjectAtIndex:sessionIndex];
    [self deleteCellAtIndexPath:cell.indexPath];
}

-(void)deleteCellAtIndexPath:(NSIndexPath*)indexPath
{
    [self.tblSessions beginUpdates];
    [self.tblSessions deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tblSessions endUpdates];
}

-(void)insertCellAtIndexPath:(NSIndexPath*)indexPath{
    [self.tblSessions beginUpdates];
    [self.tblSessions insertRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationFade)];
    [self.tblSessions endUpdates];
}

#pragma mark convenience methods
-(NSString*)documentFilePathForFilename:(NSString*)filename
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath =
    [documentsDirectory stringByAppendingPathComponent:filename];
    return filePath;
}

-(void)setStatusConnected:(BOOL)connected
{
    if (connected){
        [self.lblConnected setText:@"Connected"];
        [self.imgConnected setImage:[UIImage imageNamed:@"200px-Green-dot.png"]];
        for (UIImageView *indicator in self.horseshoeIndicators)
        {
            [indicator setImage:[UIImage imageNamed:@"200px-Red-dot.png"]];
        }
        self.connectedToMuse = YES;
    }
    else {
        [self.lblConnected setText:@"Not Connected"];
        [self.imgConnected setImage:[UIImage imageNamed:@"250px-Grey-dot.png"]];
        for (UIImageView *indicator in self.horseshoeIndicators)
        {
            [indicator setImage:[UIImage imageNamed:@"250px-Grey-dot.png"]];
        }
        self.connectedToMuse = NO;
    }
}

-(void)setHeadbandOnStatus:(BOOL)onStatus
{
    if (onStatus) {
        [self.headBandOnStatus setText:@"You're wearing the headband"];
        
    }
    else
    {
         [self.headBandOnStatus setText:@"You're not wearing the headband"];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    CGRect    screenRect;
    CGRect    windowRect;
    CGRect    viewRect;
    
    // determine's keyboard height
    screenRect    = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    windowRect    = [self.view.window convertRect:screenRect fromWindow:nil];
    viewRect      = [self.view        convertRect:windowRect fromView:nil];
    CGSize kbSize = viewRect.size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height+20, 0.0);
    [(UIScrollView*)self.scroll setContentInset:contentInsets];
    [(UIScrollView*)self.scroll setScrollIndicatorInsets:contentInsets];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    //UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 0, 0, 0);

    [(UIScrollView*)self.scroll setContentInset:contentInsets];
    [(UIScrollView*)self.scroll setScrollIndicatorInsets:contentInsets];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


- (void)documentMenu:(UIDocumentMenuViewController *)documentMenu didPickDocumentPicker:(UIDocumentPickerViewController *)documentPicker
{
    documentPicker.delegate = self;
    //[documentPicker.view setFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height)];
    
    [self presentViewController:documentPicker animated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url
{
    /*NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@",url] error:&error];
    if (error)
    {
        NSLog(@"file delete error:%@",error);
    }*/
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    if([[segue identifier] isEqualToString:@"tuneSegue"]){
        TuneViewController *tune = (TuneViewController *)[segue destinationViewController];
        self.tuneDelegate = tune;
        tune.logger = self.delegate;
    }
    else if ([[segue identifier] isEqualToString:@"sessionDetailSegue"])
    {
        NSIndexPath *selected = [self.tblSessions indexPathForSelectedRow];
        SessionCell *cell = [self.tblSessions cellForRowAtIndexPath:[self.tblSessions indexPathForSelectedRow]];
        
        NSMutableDictionary *data = [[self.sessions objectAtIndex:selected.row] mutableCopy];
        
        NSArray *arr = [cell museFileToArray];
        //NSLog(@"muse file array:%@",arr);
        
        // data re-formatting a computational bottleneck? -- NOPE
        NSDictionary *dic = [self arrayOfDictionariesToDictionary:arr];
        NSLog(@"dic:%@",dic);

        NSDictionary *sessionData = @{@"Raw":
                                        @{@"ch_0":dic[@"channel_0"],
                                          @"ch_1":dic[@"channel_1"]},
                                      @"Acceleration":
                                          @{@"x":dic[@"accel_x"]},
                                      @"Alpha":
                                          @{@"al_0":dic[@"alpha_0"]}
                                      };
        //[data setObject:dic forKey:@"EEG"];
        [(SessionDetailViewController*)[segue destinationViewController] setSessionData:sessionData];
    }
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

-(IBAction)unwindSegue:(UIStoryboardSegue*)segue
{
    
}

-(NSArray*)normalizeData:(NSArray*)data
{
    NSNumber *avg = [data valueForKeyPath:@"@avg.self"];
    NSNumber *max = [data valueForKeyPath:@"@max.self"];
    NSMutableArray *new = [NSMutableArray array];
    for (NSNumber *num in data)
    {
        if ([max doubleValue] != 0)
            [new addObject:[NSNumber numberWithDouble:([num doubleValue] - [avg doubleValue])/[max doubleValue]]];
        else
            [new addObject:[NSNumber numberWithDouble:0]];
    }
    return new;
}

-(NSDictionary*)arrayOfDictionariesToDictionary:(NSArray*)array
{
    NSLog(@"starting dic to dic%@",[NSDate date]);
    
    NSMutableDictionary *newDic = [@{} mutableCopy];
    for (NSDictionary *dic in array)
    {
        for (NSString *key in [dic allKeys])
        {
            NSNumber *value = [NSNumber numberWithDouble:[[dic objectForKey:key] doubleValue]];
            
            NSMutableArray *newArr = [newDic objectForKey:key];
            if (!newArr)
                newArr = [NSMutableArray array];
            [newArr addObject:value];
            [newDic setObject:newArr forKey:key];
        }
    }
    
    for (NSString *key in [newDic allKeys])
    {
        NSArray *arr = [newDic objectForKey:key];
        arr = [self normalizeData:arr];
        
        [newDic setObject:arr forKey:key];
    }
    
    NSLog(@"ending dic to dic%@",[NSDate date]);

    return newDic;
}
@end
