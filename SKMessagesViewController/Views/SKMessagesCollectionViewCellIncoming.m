//
//  SKMessagesCollectionViewCellIncoming.m
//  JSQMessages
//
//  Created by shrek wang on 12/13/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import "SKMessagesCollectionViewCellIncoming.h"

@interface SKMessagesCollectionViewCellIncoming ()

@property (weak, nonatomic) IBOutlet MRCircularProgressView *circularProgressView;

@end


@implementation SKMessagesCollectionViewCellIncoming

#pragma mark - rendering

- (void)configReceivingStatusWithMessage:(id<SKMessageData>)message
{
    NSParameterAssert(nil != message);
    
    if ([message isMediaMessage]) {  // media message
        
        self.circularProgressView.lineWidth = 15.0f;
        self.circularProgressView.borderWidth = 1.0f;
        [self.circularProgressView.valueLabel removeFromSuperview];
        
        float fractionCompleted = [message progress].fractionCompleted;
        if (SKMessageStateReceiving == [message state]) {
            self.circularProgressView.hidden = NO;
            [self.circularProgressView setProgress:fractionCompleted
                                          animated:YES];
        } else {
            self.circularProgressView.hidden = YES;
        }
    } else {  // text message
        [self.circularProgressView removeFromSuperview];
    }
}


@end
