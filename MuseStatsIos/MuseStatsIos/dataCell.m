//
//  dataCell.m
//  MuseCloud
//
//  Created by Felipe Valdez on 3/21/16.
//  Copyright © 2016 InteraXon. All rights reserved.
//

#import "dataCell.h"
#import "rawDataView.h"

@implementation dataCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureCell
{
    self.dataView.data = self.plotData;
    [self.dataView setNeedsDisplay];
}

@end
