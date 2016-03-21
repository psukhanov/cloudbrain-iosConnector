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
@property (nonatomic, strong) NSArray *plotData;

-(void)configureCell;

@end
