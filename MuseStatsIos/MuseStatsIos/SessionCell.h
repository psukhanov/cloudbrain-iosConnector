//
//  SessionCell.h
//  MuseStatsIos
//
//  Created by Felipe Valdez on 1/8/16.
//  Copyright © 2016 InteraXon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SessionCell : UITableViewCell <NSURLConnectionDelegate, NSURLConnectionDataDelegate, UIAlertViewDelegate>

@property (nonatomic) IBOutlet UILabel *lblTitle, *lblStartDate, *lblDuration;
@property (nonatomic) IBOutlet UILabel *lblSize;
@property (nonatomic) IBOutlet UIProgressView *progView;
@property (nonatomic) IBOutlet UIButton *btnExport;

@property (nonatomic) NSDictionary *sessionData;
@property (nonatomic, weak) id delegate;
@property (nonatomic) NSIndexPath *indexPath;
@property CGFloat uploadProgress;

-(void)setUpView;
-(IBAction)exportSessionData;
-(IBAction)exportSessionDataAsFile;
- (IBAction)exportToCloudStorageTapped:(id)sender;
-(void)deleteSession:(NSDictionary*)session;

@end
