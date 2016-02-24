//
//  Interaxon, Inc. 2015
//  MuseStatsIos
//

#import <UIKit/UIKit.h>
#import "TuneViewController.h"

@class LoggingListener;
@class SessionCell;
@class TuneViewController;

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIDocumentPickerDelegate, UIDocumentMenuDelegate>

@property (nonatomic) NSMutableArray *sessions;
@property (nonatomic, weak) IBOutlet UITableView *tblSessions;
@property (nonatomic, weak) IBOutlet UIButton *btnSession;
@property (nonatomic) IBOutlet UIPickerView *pickerSessionTimer;
@property (nonatomic) IBOutlet UILabel *lblMinutes, *lblSeconds, *lblConnected;
@property (nonatomic) IBOutlet UITextField *txtSessionName;
@property (nonatomic) IBOutlet UIImageView *imgConnected;
@property (nonatomic) IBOutlet UIScrollView *scroll;

@property (nonatomic, weak) LoggingListener *delegate;
@property BOOL sessionStarted;
@property NSDate *dateSessionStart;
@property BOOL connectedToMuse;
@property IBOutletCollection(UIImageView) NSArray *horseshoeIndicators;
@property NSArray *horseshoe;

@property TuneViewController *tuneDelegate;

-(void)loadData;
-(IBAction)startSession:(id)sender;
-(void)deleteSessionForCell:(SessionCell*)cell;
-(void)setStatusConnected:(BOOL)connected;
-(IBAction)goToTuneView:(id)sender;

@end

