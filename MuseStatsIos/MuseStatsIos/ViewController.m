//
//  Interaxon, Inc. 2015
//  MuseStatsIos
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "LoggingListener.h"

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    if (!self.delegate)
        self.delegate = [(AppDelegate*)[UIApplication sharedApplication].delegate loggingListener];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)startSession:(id)sender
{
    if (!self.sessionStarted){
        NSLog(@"starting session");
        [self.btnSession setTitle:@"End Session" forState:UIControlStateNormal];
        self.sessionStarted = YES;
        
        if ([self.delegate respondsToSelector:@selector(startSession)])
        {
            [self.delegate startSession];
        }
    }
    else {
        NSLog(@"ending session");
        [self.btnSession setTitle:@"Start Session" forState:UIControlStateNormal];
        self.sessionStarted = NO;

        if ([self.delegate respondsToSelector:@selector(endSession)])
        {
            [self.delegate endSession];
        }
    }
}

@end
