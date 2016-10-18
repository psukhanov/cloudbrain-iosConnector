//
//  dataCell.h
//  MuseCloud
//
//  Created by Felipe Valdez on 3/21/16.
//  Copyright © 2016 InteraXon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  rawDataView;

@interface dataCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *lblTitle;
@property (nonatomic, strong) IBOutlet rawDataView *dataView;
@property (nonatomic, strong) NSDictionary *plotData;
@property (nonatomic, strong) IBOutlet UIView *legendView1, *legendView2, *legendView3, *legendView4;
@property (nonatomic, strong) IBOutlet UILabel *legendLabel1, *legendLabel2, *legendLabel3, *legendLabel4;

-(void)configureCell;

@end
