//
//  Interaxon, Inc. 2015
//  MuseStatsIos
//

#import <UIKit/UIKit.h>

@class LoggingListener;
@class SessionCell;

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic) NSMutableArray *sessions;
@property (nonatomic, weak) IBOutlet UITableView *tblSessions;
@property (nonatomic, weak) IBOutlet UIButton *btnSession;
@property (nonatomic) IBOutlet UIPickerView *pickerSessionTimer;
@property (nonatomic) IBOutlet UILabel *lblMinutes, *lblSeconds;

@property (nonatomic, weak) LoggingListener *delegate;
@property BOOL sessionStarted;
@property NSDate *dateSessionStart;

-(void)loadData;
-(IBAction)startSession:(id)sender;
-(void)deleteSessionForCell:(SessionCell*)cell;

@end

