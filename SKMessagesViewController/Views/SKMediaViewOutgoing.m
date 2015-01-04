//
//  SKMediaPlaceholderViewOutgoing.m
//  JSQMessages
//
//  Created by shrek wang on 12/28/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import "SKMediaViewOutgoing.h"

@implementation SKMediaViewOutgoing

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitSKMediaViewOutgoing];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self commonInitSKMediaViewOutgoing];
}

- (void)commonInitSKMediaViewOutgoing
{
    [self setAppliesMediaViewMaskAsOutgoing:YES];
}

@end
