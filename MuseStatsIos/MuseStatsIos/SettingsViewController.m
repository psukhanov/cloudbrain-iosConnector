//
//  SettingsViewController.m
//  MuseCloud
//
//  Created by Felipe Valdez on 4/4/16.
//  Copyright © 2016 InteraXon. All rights reserved.
//

#import "SettingsViewController.h"
#import "settingCell.h"
#import "Constants.h"
#import "AppDelegate.h"

@implementation SettingsViewController
{
    NSDictionary *_recordingOptions;
}
-(void)viewDidLoad
{
    NSDictionary *options = [[NSUserDefaults standardUserDefaults] objectForKey:kSettingsOptionKey];
    if (!options)
        options = @{@"channels":@[@"channel 1",@"channel 2",@"channel 3", @"channel 4"],
                    @"EEG":@[@"raw",@"alpha",@"beta",@"gamma",@"delta"],
                    @"other":@[@"acceleration",@"blink",@"location"]};

    _recordingOptions = options;
    _recordingOptions = @{@"channels":@[@"channel 1",@"channel 2",@"channel 3", @"channel 4"],
                          @"EEG":@[@"raw",@"alpha",@"beta",@"gamma",@"delta"],
                          @"other":@[@"acceleration",@"blink",@"location"]};
    self.title = @"Recording Options";
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSArray *keys = [_recordingOptions allKeys];
    return [keys count];;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = [[_recordingOptions allKeys] objectAtIndex:section];
    NSArray *options = [_recordingOptions objectForKey:key];
    
    return [options count];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *container = [[UIView alloc]  initWithFrame:CGRectMake(0, 0, 320, 30)];
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 320, 30)];
    NSString *key = [[_recordingOptions allKeys] objectAtIndex:section];
    lbl.text = key;
    [lbl setFont:[UIFont fontWithName:@"Menlo-Regular" size:14.0]];
    [container addSubview:lbl];
    
    return container;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *optionsDict = [[NSUserDefaults standardUserDefaults] objectForKey:kSettingsOptionKey];

    settingCell *cell = (settingCell*)[tableView dequeueReusableCellWithIdentifier:@"settingCell"];
    cell.delegate = self;
    NSString *key = [[_recordingOptions allKeys] objectAtIndex:indexPath.section];
    NSArray *options = [_recordingOptions objectForKey:key];
    NSString *option = [options objectAtIndex:indexPath.row];
    [cell.lblSetting setText:option];
    [cell setData:@{@"option":option,@"category":key}];
    
    if ([optionsDict objectForKey:option]){
        
        BOOL enabled = [[optionsDict objectForKey:option] boolValue];
        if (enabled)
            [cell.swSetting setOn:YES];
        else
            [cell.swSetting setOn:NO];
    }
    else {
        [cell.swSetting setOn:NO];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(void)setOption:(NSString*)option On:(BOOL)yesOrNo
{
    NSMutableDictionary *options = [[[NSUserDefaults standardUserDefaults] objectForKey:kSettingsOptionKey] mutableCopy];
    if (!options)
        options = [NSMutableDictionary dictionary];
    
    if (yesOrNo)
        [options setObject:[NSNumber numberWithBool:YES] forKey:option];
    else
        [options setObject:[NSNumber numberWithBool:NO] forKey:option];

    [[NSUserDefaults standardUserDefaults] setObject:options forKey:kSettingsOptionKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)viewWillDisappear:(BOOL)animated
{
    AppDelegate *del = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [del setRecordingOptions];
    [del registerDataListeners];
}

@end
