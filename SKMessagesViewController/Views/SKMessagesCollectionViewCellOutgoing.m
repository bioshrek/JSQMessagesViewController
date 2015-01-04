//
//  SKMessagesCollectionViewCellOutgoing.m
//  JSQMessages
//
//  Created by shrek wang on 12/13/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import "SKMessagesCollectionViewCellOutgoing.h"

#import "SKMediaView.h"

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

@end
