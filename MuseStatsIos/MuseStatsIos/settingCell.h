//
//  settingCell.h
//  MuseCloud
//
//  Created by Felipe Valdez on 4/9/16.
//  Copyright © 2016 InteraXon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "settingsViewController.h"

@interface settingCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UISwitch *swSetting;
@property (nonatomic, strong) IBOutlet UILabel *lblSetting;
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, weak) SettingsViewController *delegate;

-(IBAction)switchTripped:(id)sender;

@end
