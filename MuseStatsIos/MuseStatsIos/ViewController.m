//
//  Interaxon, Inc. 2015
//  MuseStatsIos
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "LoggingListener.h"
#import "SessionCell.h"

@interface ViewController ()

{
    NSTimer *sessionTimer;
}

@end



@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData];
    [(UIScrollView*)self.view setContentSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height)];
    
    UITapGestureRecognizer *bgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clearKeyboard)];
    [self.view addGestureRecognizer:bgTap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    self.connectedToMuse = NO;
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
    
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    app.nSessions = [NSNumber numberWithLong:[filelist count]];
    
    self.sessions = [NSMutableArray array];
    
    for (NSString *filePath in filelist)
    {
        NSDictionary *data = [self museFileToData:filePath];
        [self.sessions addObject:data];
    }
    
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
        
        if ([self.delegate respondsToSelector:@selector(startSession)])
        {
            [self.delegate startSession];
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
    
    /*NSString *strDuration = [NSString stringWithFormat:@"%d m %d s",nMin,nSec];
    static NSDateFormatter *dateFormatter;
     if (!dateFormatter) {
     dateFormatter = [[NSDateFormatter alloc] init];
     dateFormatter.dateFormat = @"h:mm:ss a";  // very simple format  "8:47:22 AM"
     }*/
    
    [self.lblSeconds setText:[NSString stringWithFormat:@"%02d Sec",nSec]];
    [self.lblMinutes setText:[NSString stringWithFormat:@"%02d Min",nMin]];

}

- (NSDictionary*)museFileToData:(NSString*)fileName{
    NSLog(@"start play muse");
    
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
                NSLog(@"version = %@", version.firmwareVersion);
                break;
            }
            case IXNMessageTypeConfiguration:
            {
                IXNMuseConfiguration* config = [fileReader getConfiguration];
                NSLog(@"configuration = %@", config.bluetoothMac);
                break;
            }
            case IXNMessageTypeAnnotation:
            {
                IXNAnnotationData *annotation = [fileReader getAnnotation];
                NSLog(@"annotation = %@", annotation.data);
                
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
        self.connectedToMuse = YES;
    }
    else {
        [self.lblConnected setText:@"Not Connected"];
        [self.imgConnected setImage:[UIImage imageNamed:@"250px-Grey-dot.png"]];
        self.connectedToMuse = NO;
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
    [(UIScrollView*)self.view setContentInset:contentInsets];
    [(UIScrollView*)self.view setScrollIndicatorInsets:contentInsets];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    //UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 0, 0, 0);

    [(UIScrollView*)self.view setContentInset:contentInsets];
    [(UIScrollView*)self.view setScrollIndicatorInsets:contentInsets];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

/*
#pragma UIPickerViewDelegate

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 60;
}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    NSString *unit;
    if (component == 0)
    {
        unit = @"min";
    }
    else {
        unit = @"sec";
    }
    
    NSString *title = [NSString stringWithFormat:@"%02lu",row];
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 50, 15)];
    [lbl setText:title];
    return lbl;
}
*/

@end
