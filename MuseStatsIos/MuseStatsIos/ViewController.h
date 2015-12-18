//
//  Interaxon, Inc. 2015
//  MuseStatsIos
//

#import <UIKit/UIKit.h>

@class LoggingListener;

@interface ViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIButton *btnSession;

@property (nonatomic, weak) LoggingListener *delegate;
@property BOOL sessionStarted;

-(IBAction)startSession:(id)sender;

@end

