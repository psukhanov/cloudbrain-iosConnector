//
//  SessionCell.m
//  MuseStatsIos
//
//  Created by Felipe Valdez on 1/8/16.
//  Copyright © 2016 InteraXon. All rights reserved.
//

#import "SessionCell.h"
#import <AFNetworking/AFNetworking.h>
#import "Constants.h"

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
    NSArray *arr = [self.sessionData objectForKey:@"data"];
    NSString *filename = [self.sessionData objectForKey:@"fileName"];
    
    NSDictionary *data = @{@"data":arr,@"filename":filename};
    
    NSError *err;
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
    
    NSURLSession *sesh = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionUploadTask *task =  [sesh uploadTaskWithRequest:req fromData:[json dataUsingEncoding:NSUTF8StringEncoding] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
       NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
   }];
    //[task resume];
    
    [self.btnExport setUserInteractionEnabled:NO];
    self.uploadProgress = 0;
    NSURLConnection *connec = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
    
    /*AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:URLString]];
    
    //manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:@"" parameters:arr progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"post succeeded");
        NSLog(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"post failed");
        NSLog(error);
    }];*/
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

@end
