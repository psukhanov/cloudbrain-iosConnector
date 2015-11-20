// AUTOGENERATED FILE - DO NOT MODIFY!
// This file generated by Djinni from packets.djinni

#import <Foundation/Foundation.h>

/**
 * Provides information about which Muse headband is sending the data.
 * This information is part of every packet.
 */

@interface IXNSenderInformation : NSObject
- (id)initWithSenderInformation:(IXNSenderInformation *)senderInformation;
- (id)initWithMacAddress:(NSString *)macAddress;

/** Bluetooth device address */
@property (nonatomic, readonly) NSString *macAddress;

@end