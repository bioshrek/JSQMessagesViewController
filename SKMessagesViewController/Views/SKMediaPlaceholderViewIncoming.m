//
//  SKMediaPlaceholderViewIncoming.m
//  JSQMessages
//
//  Created by shrek wang on 12/28/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import "SKMediaPlaceholderViewIncoming.h"

@implementation SKMediaPlaceholderViewIncoming

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self commonInit];
}

- (void)commonInit
{
    [self setAppliesMediaViewMaskAsOutgoing:NO];
}

@end
