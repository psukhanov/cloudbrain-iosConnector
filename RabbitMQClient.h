//
//  RabbitMQClient.h
//  MuseStatsIos
//
//  Created by Felipe Valdez on 11/19/15.
//  Copyright © 2015 InteraXon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMQPConnection.h"

@interface RabbitMQClient : NSObject

@property (nonatomic) AMQPConnection *connection;

+ (id)sharedClient;
-(void)sendData:(NSString *)payload OnExchangeName:(NSString*)exchangeName;

@end
