//
//  Interaxon, Inc. 2015
//  MuseStatsIos
//

#import <UIKit/UIKit.h>
#import "Muse.h"
#import <CoreLocation/CoreLocation.h>

@class LoggingListener;
@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) id<IXNMuse> muse;
@property (nonatomic) LoggingListener *loggingListener;
@property (nonatomic) ViewController *viewController;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) NSArray *recordingOptions;

- (void)sayHi;
- (void)reconnectToMuse;

@end

