//
//  SKMessagesCollectionViewCellOutgoing.m
//  JSQMessages
//
//  Created by shrek wang on 12/13/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import "SKMessagesCollectionViewCellOutgoing.h"

@interface SKMessagesCollectionViewCellOutgoing ()

@property (weak, nonatomic) IBOutlet MRCircularProgressView *circularProgressView;

@property (weak, nonatomic) IBOutlet MRActivityIndicatorView *activityIndicatorView;

@end

@implementation SKMessagesCollectionViewCellOutgoing

#pragma mark - override


- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self.activityIndicatorView stopAnimating];
}



@end
