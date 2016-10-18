//
//  SessionDetailViewController.m
//  MuseCloud
//
//  Created by Felipe Valdez on 3/21/16.
//  Copyright © 2016 InteraXon. All rights reserved.
//

#import "SessionDetailViewController.h"
#import "dataCell.h"
#import "rawDataView.h"

@interface SessionDetailViewController ()

@end

@implementation SessionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.displayOptions = @[@"channel_0",@"channel_1",@"accel_x",@"blink"];
    self.displayOptions = [@{@"EEG":@[@"channel_0",@"channel_1"],@"accel":@[@"x",@"y",@"z"],@"other":@[@"blink"]} mutableCopy];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Session Details";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //return [[self.displayOptions allKeys] count];
    //return [[self.sessionData allKeys] count];
    return 1;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *keys = [self.sessionData allKeys];
    return [keys count];
    
    //NSString *key = [keys objectAtIndex:section];
    //NSArray *options = self.sessionData[key];
    
    //return [options count];
    
    //return [self.displayOptions count];
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    dataCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dataCell"];
   // NSArray *keys = [self.displayOptions allKeys];
    NSArray *keys = [self.sessionData allKeys];

    NSString *key = [keys objectAtIndex:indexPath.row];
    
   // NSArray *options = self.displayOptions[key];
    NSDictionary *channels = self.sessionData[key];
    
    cell.plotData = channels;
    
    [cell configureCell];
    [cell.lblTitle setText:key];

    return cell;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
