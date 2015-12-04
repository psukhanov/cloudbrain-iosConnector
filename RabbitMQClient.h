//
//  RabbitMQClient.h
//  MuseStatsIos
//
//  Created by Felipe Valdez on 11/19/15.
//  Copyright © 2015 InteraXon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMQPConnection.h"
#import "AMQPExchange.h"

@interface RabbitMQClient : NSObject

@property (nonatomic) AMQPConnection *connection;
@property (nonatomic) AMQPExchange *exchange;

+ (id)sharedClient;
-(void)setupWithExchangeName:(NSString*)exchangeName;

-(void)sendData:(NSString *)payload OnExchangeName:(NSString*)exchangeName;

@end
