//
//  Interaxon, Inc. 2015
//  MuseStatsIos
//

#import <UIKit/UIKit.h>
#import "Muse.h"

@class LoggingListener;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) id<IXNMuse> muse;
@property (nonatomic) LoggingListener *loggingListener;

- (void)sayHi;
- (void)reconnectToMuse;

@end

