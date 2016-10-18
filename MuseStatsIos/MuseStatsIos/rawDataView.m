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
    
    NSArray *keys = [self.data allKeys];
    for (NSString *key in keys)
    {
        NSDictionary *channel = [self.data objectForKey:key];
        UIColor *strokeColor = [channel objectForKey:@"color"];
        NSArray *values = [channel objectForKey:@"values"];
        if (!values)
            return;
        
        CGFloat x = rect.origin.x;
        CGFloat xppt = rect.size.width / [values count];
        CGFloat y = rect.size.height/2;
        [path moveToPoint:CGPointMake(x, y)];
        
        int max = 2000 < [values count] ? 2000 : [values count];
        
        for (int i=0;i<max;i++)
        {
            NSNumber *num = values[i];
            y = ([num floatValue] * rect.size.height) + rect.size.height/2;
            x = x + xppt;
            
            CGPoint next = CGPointMake(x,y);
            [path addLineToPoint:next];
        }
        [strokeColor setStroke];
        [path stroke];
    }

}


@end
