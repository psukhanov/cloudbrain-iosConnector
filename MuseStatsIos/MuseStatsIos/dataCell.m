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
    UIColor *color = [UIColor blackColor];

    NSArray *channelKeys = [self.plotData allKeys];
    NSMutableDictionary *dataViewData = [@{} mutableCopy];
    
    int max = 0;
    for (int i=0;i<[channelKeys count];i++)
    {
        NSString *channelKey = channelKeys[i];
        UIColor *color = [UIColor blackColor];
        NSArray *values = self.plotData[channelKeys[i]];
        [dataViewData setObject:@{@"color":color, @"values":values} forKey:channelKey];
        
        NSString *lblName = [NSString stringWithFormat:@"legendLabel%d",i+1];
        NSString *colorViewName = [NSString stringWithFormat:@"legendView%d",i+1];
        
        UILabel *lbl = [self valueForKey:lblName];
        if (lbl){
            [lbl setHidden:NO];
            [lbl setText:channelKey];
        }
        
        UIView *colorView = [self valueForKey:colorViewName];
        if (colorView){
            [colorView setHidden:NO];
            [colorView setBackgroundColor:color];
        }
        max = i+1;
    }
    
    for (int j=max+1;j<=4;j++)
    {
        NSString *lblName = [NSString stringWithFormat:@"legendLabel%d",j];
        NSString *colorViewName = [NSString stringWithFormat:@"legendView%d",j];
        UILabel *lbl = [self valueForKey:lblName];
        if (lbl)
            [lbl setHidden:YES];
        UIView *colorView = [self valueForKey:colorViewName];
        if (colorView)
            [colorView setHidden:YES];
    }
    
    [self.dataView setData:dataViewData];
    [self.dataView setNeedsDisplay];

//    if ([self.plotData count]<2)
//    {
//        
//    }
}

@end
