//
//  RabbitMQClient.m
//  MuseStatsIos
//
//  Created by Felipe Valdez on 11/19/15.
//  Copyright © 2015 InteraXon. All rights reserved.
//

#import "RabbitMQClient.h"
#import "AMQPExchange.h"
#import "AMQPConnection.h"
#import "Constants.h"

@implementation RabbitMQClient

+ (id)sharedClient {
    static RabbitMQClient *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[self alloc] init];
        client.connection = [[AMQPConnection alloc] init];
        [client.connection connectToHost:kHostName onPort:kPortNumber];
        [client.connection loginAsUser:kExchangeUsername withPasswort:kExchangePassword onVHost:@""];

    });
    return client;
}

-(void)sendData:(NSString *)payload OnExchangeName:(NSString*)exchangeName
{
    AMQPChannel *channel = [self.connection openChannel];
    
    AMQPExchange *exch = [[AMQPExchange alloc] initDirectExchangeWithName:exchangeName onChannel:channel isPassive:NO isDurable:YES getsAutoDeleted:NO];
    
    [exch publishMessage:payload usingRoutingKey:exchangeName];
    
}

@end
