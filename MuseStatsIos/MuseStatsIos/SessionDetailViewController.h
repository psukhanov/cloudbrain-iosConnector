//
//  SessionDetailViewController.h
//  MuseCloud
//
//  Created by Felipe Valdez on 3/21/16.
//  Copyright © 2016 InteraXon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SessionDetailViewController : UITableViewController

@property (nonatomic, strong) NSDictionary *sessionData;
@property (nonatomic, strong) NSArray *displayOptions;

@end
