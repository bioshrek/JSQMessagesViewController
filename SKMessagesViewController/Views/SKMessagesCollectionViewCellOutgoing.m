//
//  SKMessagesCollectionViewCellOutgoing.m
//  JSQMessages
//
//  Created by shrek wang on 12/13/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import "SKMessagesCollectionViewCellOutgoing.h"

@interface SKMessagesCollectionViewCellOutgoing ()

@property (weak, nonatomic) IBOutlet MRActivityIndicatorView *activityIndicatorView;

@property (weak, nonatomic) IBOutlet MRCircularProgressView *circularProgressView;

@end

@implementation SKMessagesCollectionViewCellOutgoing

#pragma mark - override

// view will disappear
- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self.activityIndicatorView stopAnimating];
}

#pragma mark - rendering

- (void)configSendingStatusWithMessage:(id<SKMessageData>)message
{
    NSParameterAssert(nil != message);
    
    if ([message isMediaMessage]) {  // media message
        [self.activityIndicatorView removeFromSuperview];
        
        self.circularProgressView.lineWidth = 15.0f;
        self.circularProgressView.borderWidth = 1.0f;
        [self.circularProgressView.valueLabel removeFromSuperview];
        
        float fractionCompleted = [message progress].fractionCompleted;
        if (SKMessageStateSending == [message state]) {
            self.circularProgressView.hidden = NO;
            [self.circularProgressView setProgress:fractionCompleted
                                          animated:YES];
        } else {
            self.circularProgressView.hidden = YES;
        }
    } else {  // text message
        [self.circularProgressView removeFromSuperview];
        
        if (SKMessageStateSending == [message state]) {
            self.activityIndicatorView.hidden = NO;
            [self.activityIndicatorView startAnimating];
        } else {
            self.activityIndicatorView.hidden = YES;
            [self.activityIndicatorView stopAnimating];
        }
    }
}

@end
