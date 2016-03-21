//
//  rawDataView.m
//  MuseCloud
//
//  Created by Felipe Valdez on 3/13/16.
//  Copyright © 2016 InteraXon. All rights reserved.
//

#import "rawDataView.h"

@implementation rawDataView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code

    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGFloat x = rect.origin.x;
    CGFloat xppt = rect.size.width / self.data.count;
    CGFloat y = rect.size.height/2;
    [path moveToPoint:CGPointMake(x, y)];
    
    for (NSNumber *num in self.data)
    {
        y = ([num floatValue] * rect.size.height) + rect.size.height/2;
        x = x + xppt;
        
        CGPoint next = CGPointMake(x,y);
        [path addLineToPoint:next];
    }
    [[UIColor blackColor] setStroke];
    [path stroke];
}


@end
