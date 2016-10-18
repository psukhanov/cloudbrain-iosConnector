//
//  Interaxon, Inc. 2015
//  MuseStatsIos
//

#import <UIKit/UIKit.h>
#import "Muse.h"
#import <CoreLocation/CoreLocation.h>

@class LoggingListener;
@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) id<IXNMuse> muse;
@property (nonatomic) LoggingListener *loggingListener;
@property (nonatomic) ViewController *viewController;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableDictionary *lastLocation;
@property (nonatomic, strong) NSMutableArray *unreportedLocations;
@property (nonatomic) NSArray *recordingOptions;

- (void)sayHi;
- (void)reconnectToMuse;
- (void)registerDataListeners;
- (void)setRecordingOptions;

@end

