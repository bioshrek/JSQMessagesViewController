//
//  SKMessagesCollectionViewCellOutgoing.m
//  JSQMessages
//
//  Created by shrek wang on 12/13/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import "SKMessagesCollectionViewCellOutgoing.h"

#import "SKMediaPlaceholderView.h"

@interface SKMessagesCollectionViewCellOutgoing ()

@property (weak, nonatomic) IBOutlet MRActivityIndicatorView *activityIndicatorView;

@property (weak, nonatomic) IBOutlet SKButton *errorIndicatorButton;

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
        
        UIView *mediaPlaceHolderView = [[message media] mediaPlaceholderView];
        if (![mediaPlaceHolderView isKindOfClass:[SKMediaPlaceholderView class]]) {
            return;
        }
        SKMediaPlaceholderView *skMediaPlaceholderView = (SKMediaPlaceholderView *)mediaPlaceHolderView;
        MRCircularProgressView *circularProgressView = skMediaPlaceholderView.circularProgressView;
        
        circularProgressView.lineWidth = CGRectGetWidth(circularProgressView.bounds) / 2.0f;
        circularProgressView.borderWidth = 1.0f;
        [circularProgressView.valueLabel removeFromSuperview];
        
        float fractionCompleted = [message progress].fractionCompleted;
        if (SKMessageStateSending == [message state]) {
            circularProgressView.hidden = NO;
            [circularProgressView setProgress:fractionCompleted
                                          animated:YES];
        } else {
            circularProgressView.hidden = YES;
        }
    } else {  // text message
        
        if (SKMessageStateSending == [message state]) {
            self.activityIndicatorView.hidden = NO;
            [self.activityIndicatorView startAnimating];
            
            self.errorIndicatorButton.hidden = YES;
        } else if (SKMessageStateSendingFailure == [message state]) {
            self.errorIndicatorButton.hidden = NO;
            
            self.activityIndicatorView.hidden = YES;
            [self.activityIndicatorView stopAnimating];
        } else {
            self.activityIndicatorView.hidden = YES;
            [self.activityIndicatorView stopAnimating];
            
            self.errorIndicatorButton.hidden = YES;
        }
    }
}

@end
