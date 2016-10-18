//
//  settingCell.m
//  MuseCloud
//
//  Created by Felipe Valdez on 4/9/16.
//  Copyright © 2016 InteraXon. All rights reserved.
//

#import "settingCell.h"

@implementation settingCell

-(IBAction)switchTripped:(id)sender
{
    NSString *option = [self.data objectForKey:@"option"];
    NSString *category = [self.data objectForKey:@"category"];
    UISwitch *sw = (UISwitch*)sender;
    
    if (sw.isOn){
        [self.swSetting setOn:YES];
        [self.delegate setOption:option On:YES];
    }
    else{
        [self.swSetting setOn:NO];
        [self.delegate setOption:option On:NO];
    }
}

@end
