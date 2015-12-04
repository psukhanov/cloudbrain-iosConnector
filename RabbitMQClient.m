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

+ (RabbitMQClient*)sharedClient {
    static RabbitMQClient *client = nil;
    static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            client = [[self alloc] init];
        });

    return client;
}

-(id)init
{
    self = [super init];
    if (self) {
        self.connection = [[AMQPConnection alloc] init];
    }
    return self; 
}

-(void)sendData:(NSString *)payload OnExchangeName:(NSString*)exchangeName
{
    
    [self.connection connectToHost:kHostName onPort:kPortNumber];
    
    [self.connection loginAsUser:kExchangeUsername withPasswort:kExchangePassword onVHost:@"/"];

    AMQPChannel *channel = [self.connection openChannel];
    
    AMQPExchange *exch = [[AMQPExchange alloc] initDirectExchangeWithName:exchangeName onChannel:channel isPassive:NO isDurable:YES getsAutoDeleted:NO];
    
    [exch publishMessage:payload usingRoutingKey:exchangeName];
    
}

@end
