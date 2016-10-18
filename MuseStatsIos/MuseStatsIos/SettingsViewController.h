//
//  SettingsViewController.h
//  MuseCloud
//
//  Created by Felipe Valdez on 4/4/16.
//  Copyright © 2016 InteraXon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UITableViewController;

-(void)setOption:(NSString*)option On:(BOOL)yesOrNo;

@end

//@protocol settingCellDelegate <NSObject>
//
//-setOption:(NSString*)option ForCategory:(NSString*)category;
//
//@end