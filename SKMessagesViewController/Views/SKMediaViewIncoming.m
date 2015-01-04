//
//  SKMediaPlaceholderViewIncoming.m
//  JSQMessages
//
//  Created by shrek wang on 12/28/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import "SKMediaViewIncoming.h"

@implementation SKMediaViewIncoming

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitSKMediaViewIncoming];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self commonInitSKMediaViewIncoming];
}

- (void)commonInitSKMediaViewIncoming
{
    [self setAppliesMediaViewMaskAsOutgoing:NO];
}

@end
