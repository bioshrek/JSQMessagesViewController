//
//  SKButton.m
//  SKButtons
//
//  Created by shrek wang on 12/22/14.
//  Copyright (c) 2014 shrek wang. All rights reserved.
//

#import "SKButton.h"

@implementation SKButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.masksToBounds = YES;
    }
    return self;
}

#pragma mark - setter

- (void)setBorderWidth:(CGFloat)borderWidth
{
    NSParameterAssert(borderWidth >= 0);
    
    self.layer.borderWidth = borderWidth;
}

- (void)setBorderColor:(UIColor *)borderColor
{
    NSParameterAssert(nil != borderColor);
    
    self.layer.borderColor = borderColor.CGColor;
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    NSParameterAssert(cornerRadius >= 0);
    
    self.layer.cornerRadius = cornerRadius;
}

- (void)becomeRoundIfPossible
{
    CGRect bounds = self.bounds;
    CGFloat width = CGRectGetWidth(bounds);
    if (width != CGRectGetHeight(bounds)) {
        return;
    }
    
    // width == height
    self.cornerRadius = width / 2.0f;
}

@end
