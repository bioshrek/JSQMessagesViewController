//
//  SKDemoToolbar.m
//  JSQMessages
//
//  Created by shrek wang on 3/31/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import "SKDemoToolbar.h"

#import "UIView+JSQMessages.h"

@implementation SKDemoToolbar

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];

    
    NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([JSQMessagesToolbarContentView class]) owner:nil options:nil];
    JSQMessagesToolbarContentView *toolbarContentView = [nibViews firstObject];
    toolbarContentView.frame = self.frame;
    [self addSubview:toolbarContentView];
    [self jsq_pinAllEdgesOfSubview:toolbarContentView];
    [self setNeedsUpdateConstraints];
    _contentView = toolbarContentView;
}

@end
