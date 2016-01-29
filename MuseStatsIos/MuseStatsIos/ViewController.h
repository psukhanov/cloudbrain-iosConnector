//
//  Interaxon, Inc. 2015
//  MuseStatsIos
//

#import <UIKit/UIKit.h>

@class LoggingListener;
@class SessionCell;

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>

@property (nonatomic) NSMutableArray *sessions;
@property (nonatomic, weak) IBOutlet UITableView *tblSessions;
@property (nonatomic, weak) IBOutlet UIButton *btnSession;
@property (nonatomic) IBOutlet UIPickerView *pickerSessionTimer;
@property (nonatomic) IBOutlet UILabel *lblMinutes, *lblSeconds, *lblConnected;
@property (nonatomic) IBOutlet UITextField *txtSessionName;
@property (nonatomic) IBOutlet UIImageView *imgConnected;

@property (nonatomic, weak) LoggingListener *delegate;
@property BOOL sessionStarted;
@property NSDate *dateSessionStart;
@property BOOL connectedToMuse;

-(void)loadData;
-(IBAction)startSession:(id)sender;
-(void)deleteSessionForCell:(SessionCell*)cell;
-(void)setStatusConnected:(BOOL)connected;

@end

