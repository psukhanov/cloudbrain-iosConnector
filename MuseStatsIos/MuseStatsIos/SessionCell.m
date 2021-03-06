//
//  SessionCell.m
//  MuseStatsIos
//
//  Created by Felipe Valdez on 1/8/16.
//  Copyright © 2016 InteraXon. All rights reserved.
//

#import "SessionCell.h"
#import "Constants.h"
#import "Muse.h"
#import "ViewController.h"

@implementation SessionCell

-(void)setUpView
{
    // called from tableView:CellForIndexPath:
    
    NSString *name = [self.sessionData objectForKey:@"fileName"];
    NSDate *startDate = [self.sessionData objectForKey:@"startDate"];
    NSDate *endDate = [self.sessionData objectForKey:@"endDate"];
    NSUInteger size = [[self.sessionData objectForKey:@"size"] unsignedLongValue];
    NSString *duration = [self.sessionData objectForKey:@"duration"];
    
    NSDateFormatter *nsdf = [[NSDateFormatter alloc] init];
    [nsdf setDateStyle:NSDateFormatterMediumStyle];
    [nsdf setTimeStyle:NSDateFormatterShortStyle];
    NSString *strStart = [nsdf stringFromDate:startDate];
    //NSString *strEnd = [nsdf stringFromDate:endDate];
    
    NSString *sizeStr = [NSString stringWithFormat:@"%lu kB",size/1000];
    
    [self.lblTitle setText:name];
    [self.lblStartDate setText:strStart];
    [self.lblDuration setText:duration];
    [self.lblSize setText:sizeStr];
}

-(IBAction)deleteSessionForCell:(id)sender
{
    NSString *message = [NSString stringWithFormat:@"%@ will be permanently deleted. Proceed?",[self.sessionData objectForKey:@"fileName"]];
    [[[UIAlertView alloc] initWithTitle:@"Are you sure?" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Proceed", nil]show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(deleteSessionForCell:)])
        {
            [self.delegate deleteSessionForCell:self];
        }
    }
}

-(void)exportSessionData
{
    NSString *str = [self museFileToData:@"json"];
    
    NSString *filename = [self.sessionData objectForKey:@"fileName"];
    NSError *err;

    NSArray *arr = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&err];
    
    NSDictionary *data = @{@"data":arr,@"filename":filename};
    
    NSString *json = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:data options:0 error:&err] encoding:NSUTF8StringEncoding];
    if (err)
    {
        NSLog(@"json serialization error:%@",err);
    }
    
    NSString *URLString = [NSString stringWithFormat:@"%@/importBrainData",kMyndzpaceHost];
    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URLString]];
    [req setHTTPMethod:@"POST"];
    //[req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setHTTPBody:[NSJSONSerialization dataWithJSONObject:data options:0 error:nil]];

    [self.btnExport setUserInteractionEnabled:NO];
    self.uploadProgress = 0;
    NSURLConnection *connec = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
    
    
    /*NSURLSession *sesh = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
     NSURLSessionUploadTask *task =  [sesh uploadTaskWithRequest:req fromData:[json dataUsingEncoding:NSUTF8StringEncoding] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
     NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
     }];
     [task resume];*/
}

/*-(void)exportSessionDataAsFile
{
    NSData *fileData = [[self.sessionData objectForKey:@"file"] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *URLString = [NSString stringWithFormat:@"%@/importBrainDataFile",kMyndzpaceHost];
    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:URLString]];
    [req setHTTPMethod:@"POST"];
    //[req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSession *sesh = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionUploadTask *task =  [sesh uploadTaskWithRequest:req fromData:fileData completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }];
    [task resume];
}*/

#pragma mark NSURLConnection delegate methods

-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    self.uploadProgress = self.uploadProgress + (float)bytesWritten;
    CGFloat fraction = self.uploadProgress / (float)totalBytesExpectedToWrite;
    self.progView.progress = fraction;
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"export finished with response:%@",response);
    [[[UIAlertView alloc] initWithTitle:@"Export Finished" message:[NSString stringWithFormat:@"%@ exported to:%@",[self.sessionData objectForKey:@"fileName"],kMyndzpaceHost] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil]show];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [[[UIAlertView alloc] initWithTitle:@"Export Failed" message:[NSString stringWithFormat:@"Export failed due to error: %@",error.description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil]show];
    [self.btnExport setUserInteractionEnabled:YES];
    self.progView.progress = 0;
    
    NSLog(@"export failed with error:%@",error);
}

- (NSString*)museFileToData:(NSString*)format {
    NSLog(@"start play muse");
    
    if (!format || [format isEqualToString:@""])
        format = @"csv";
    
    NSMutableArray *exportData = [[NSMutableArray alloc] init];
    NSMutableString *strFileData = [[NSMutableString alloc] init];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filename = [self.sessionData objectForKey:@"fileName"];
    NSString *filePath =
    [documentsDirectory stringByAppendingPathComponent:filename];
    
    BOOL stimOn = NO;
    BOOL blinkOn = NO;
    float accel_x = 0;
    float accel_y = 0;
    float accel_z = 0;
    
    
    //NSDictionary *settings = [[NSUserDefaults standardUserDefaults] objectForKey:kSettingsOptionKey];
    
    [strFileData appendFormat:@"%@ %@ %@ %@ %@ %@ %@ %@ %@ %@\n",@"timestamp",@"channel_1",@"channel_2",@"channel_3",@"channel_4",@"stimulus", @"blink",@"accel_x",@"accel_y",@"accel_z"];
    
    id<IXNMuseFileReader> fileReader =
    [IXNMuseFileFactory museFileReaderWithPathString:filePath];

    while ([fileReader gotoNextMessage]) {
        IXNMessageType type = [fileReader getMessageType];
        
        /*NSLog(@"type: %d, id: %d, timestamp: %lld",
         (int)type, id_number, timestamp);*/
        
        switch(type) {
            case IXNMessageTypeEeg:
            {
                IXNMuseDataPacket* packet = [fileReader getDataPacket];
                NSArray *eegData = packet.values;
                //NSLog(@"orig time:%lld",packet.timestamp);
                
                NSNumber *timestamp = [NSNumber numberWithUnsignedLongLong:packet.timestamp];
                //NSLog(@"timestamp:%@",timestamp);
                
                NSNumber *stim = [NSNumber numberWithBool:stimOn];
                NSNumber *blink = [NSNumber numberWithBool:blinkOn];
                
                NSDictionary *send = @{@"timestamp":timestamp,@"channel_0":eegData[0],@"channel_1":eegData[1],@"channel_2":eegData[2],@"channel_3":eegData[3],@"stimOn":stim,@"blink":blink};
                
                [exportData addObject:send];
                [strFileData appendFormat:@"%@ %@ %@ %@ %@ %@ %@ %.2f %.2f %.2f\n",timestamp,eegData[0],eegData[1],eegData[2],eegData[3],stim, blink, accel_x, accel_y, accel_z];
                
                blinkOn = NO;
                //NSLog(@"eeg data packet = %f", [packet.values[IXNEegTP9] doubleValue]);
                break;
            }
            case IXNMessageTypeQuantization:
            case IXNMessageTypeAccelerometer:
            {
                IXNMuseDataPacket* packet = [fileReader getDataPacket];
                accel_x = [packet.values[0] floatValue];
                accel_y = [packet.values[1] floatValue];
                accel_z = [packet.values[2] floatValue];

                break;
            }
            case IXNMessageTypeAnnotation:
            {
                IXNAnnotationData *annotation = [fileReader getAnnotation];
                if ([annotation.data isEqualToString:@"stimOn"])
                {
                    stimOn = YES;
                    //NSLog(@"stimOn");
                }
                else if ([annotation.data isEqualToString:@"stimOff"])
                {
                    stimOn = NO;
                    //NSLog(@"stimOff");
                }
                else if ([annotation.data isEqualToString:@"blink"])
                {
                    blinkOn = YES;
                }
                //NSLog(@"annotation = %@", annotation.data);
                
                break;
            }
            default:
                break;
        }
    }
    NSError *error;
    
    NSString *json = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:exportData options:0 error:&error] encoding:NSUTF8StringEncoding];
    
    if ([format isEqualToString:@"csv"])
        return  strFileData;
    else
        return json;
}

- (NSArray*)museFileToArray{
    
    NSMutableArray *exportData = [[NSMutableArray alloc] init];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filename = [self.sessionData objectForKey:@"fileName"];
    NSString *filePath =
    [documentsDirectory stringByAppendingPathComponent:filename];
    
    BOOL stimOn = NO;
    BOOL blinkOn = NO;
    float accel_x = 0;
    float accel_y = 0;
    float accel_z = 0;
    NSArray *alpha = [NSArray arrayWithObject:[NSNumber numberWithDouble:0]];
    NSArray *beta = [NSArray arrayWithObject:[NSNumber numberWithDouble:0]];
    NSArray *gamma = [NSArray arrayWithObject:[NSNumber numberWithDouble:0]];
    NSArray *delta = [NSArray arrayWithObject:[NSNumber numberWithDouble:0]];

    
    id<IXNMuseFileReader> fileReader =
    [IXNMuseFileFactory museFileReaderWithPathString:filePath];
    
    while ([fileReader gotoNextMessage]) {
        IXNMessageType type = [fileReader getMessageType];
        
        switch(type) {
            case IXNMessageTypeEeg:
            {
                IXNMuseDataPacket* packet = [fileReader getDataPacket];
                NSLog(@"data packet type:%d",(int)packet.packetType);
                if (packet.packetType == IXNMuseDataPacketTypeAlphaAbsolute)
                {
                    NSLog(@"alpha packet type:");
                    alpha = packet.values;
                    break;
                }
                else if (packet.packetType == IXNMuseDataPacketTypeBetaAbsolute)
                {
                    beta = packet.values;
                }
                
                NSArray *eegData = packet.values;
                //NSLog(@"orig time:%lld",packet.timestamp);
                
                NSNumber *timestamp = [NSNumber numberWithUnsignedLongLong:packet.timestamp];
                //NSLog(@"timestamp:%@",timestamp);
                
                NSNumber *stim = [NSNumber numberWithBool:stimOn];
                NSNumber *blink = [NSNumber numberWithBool:blinkOn];
                
                NSNumber *alpha_0 = [NSNumber numberWithDouble:0];
                if (alpha && [alpha count] > 0)
                    alpha_0 = alpha[0];
                
                NSDictionary *send = @{@"timestamp":timestamp,@"channel_0":eegData[0],@"channel_1":eegData[1],@"channel_2":eegData[2],@"channel_3":eegData[3],@"stimOn":stim,@"blink":blink,@"accel_x":[NSNumber numberWithDouble:accel_x],@"alpha_0":alpha_0};
                
                [exportData addObject:send];
                
                blinkOn = NO;
                //NSLog(@"eeg data packet = %f", [packet.values[IXNEegTP9] doubleValue]);
                break;
            }
            case IXNMessageTypeAlgValue:
            {
                NSLog(@"alg value:");
                break;
            }
//            case IXNMessageTypeMuseElements:
//            {
//                
//            }
            case IXNMessageTypeDsp:
            {
                NSLog(@"dsp:");
                break;
            }
            case IXNMessageTypeQuantization:
            case IXNMessageTypeAccelerometer:
            {
                IXNMuseDataPacket* packet = [fileReader getDataPacket];
                accel_x = [packet.values[0] floatValue];
                accel_y = [packet.values[1] floatValue];
                accel_z = [packet.values[2] floatValue];
                
                break;
            }
            case IXNMessageTypeAnnotation:
            {
                IXNAnnotationData *annotation = [fileReader getAnnotation];
                if ([annotation.data isEqualToString:@"stimOn"])
                {
                    stimOn = YES;
                    //NSLog(@"stimOn");
                }
                else if ([annotation.data isEqualToString:@"stimOff"])
                {
                    stimOn = NO;
                    //NSLog(@"stimOff");
                }
                else if ([annotation.data isEqualToString:@"blink"])
                {
                    blinkOn = YES;
                }
                //NSLog(@"annotation = %@", annotation.data);
                
                break;
            }
            default:
                break;
        }
    }
    
    return exportData;
}

- (IBAction)exportToCloudStorageTapped:(id)sender {
    
    NSString *data = [self museFileToData:@"csv"];
    
    NSString *filename = [self.sessionData objectForKey:@"fileName"];
    NSString *tmpFileName = [filename stringByAppendingString:@".csv"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSError *error;
    
    NSString *tmpFilePath = [documentsDirectory stringByAppendingPathComponent:tmpFileName];
    [data writeToFile:tmpFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    NSURL *url =  [NSURL fileURLWithPath:tmpFilePath];
    UIDocumentMenuViewController *docMenuVC = [[UIDocumentMenuViewController alloc]initWithURL:url inMode:UIDocumentPickerModeExportToService];

    
    docMenuVC.delegate = self.delegate;
    [self.delegate presentViewController:docMenuVC animated:YES completion:nil];
    
}

-(void)deleteTemporaryFile:(NSString*)filepath
{
    
}
@end
