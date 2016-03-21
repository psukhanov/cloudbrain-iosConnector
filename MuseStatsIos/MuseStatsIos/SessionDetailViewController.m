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
    self.displayOptions = @[@"channel_0",@"channel_1",@"accel_x",@"blink"];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.displayOptions count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    dataCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dataCell"];
    NSString *option = [self.displayOptions objectAtIndex:indexPath.row];
    
    NSDictionary *data = [self.sessionData objectForKey:@"channels"];
    cell.plotData = [data objectForKey:option];
    [cell.lblTitle setText:option];
    
    [cell configureCell];
    
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
