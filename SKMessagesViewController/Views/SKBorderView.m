//
//  SKBorderView.m
//  JSQMessages
//
//  Created by shrek wang on 12/23/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import "SKBorderView.h"

@implementation SKBorderView

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGRect bounds = self.bounds;
    CGFloat width = CGRectGetWidth(bounds);
    CGFloat height = CGRectGetHeight(bounds);
    UIColor *lineColor = nil;
    CGFloat lineWidth = 0;
    
    // top
    lineColor = self.topBorderColor;
    lineWidth = self.borderLineWidths.top;
    if (lineColor && lineWidth) {
        [self drawHorizentalLineAtY:0 length:width width:lineWidth color:lineColor];
    }
    
    // bottom
    lineColor = self.bottomBorderColor;
    lineWidth = self.borderLineWidths.bottom;
    if (lineColor && lineWidth) {
        [self drawHorizentalLineAtY:height length:width width:lineWidth color:lineColor];
    }
    
    // left
    lineColor = self.leftBorderColor;
    lineWidth = self.borderLineWidths.left;
    if (lineColor && lineWidth) {
        [self drawVerticalLineAtX:0 length:width width:lineWidth color:lineColor];
    }
    
    // right
    lineColor = self.rightBorderColor;
    lineWidth = self.borderLineWidths.right;
    if (lineColor && lineWidth) {
        [self drawVerticalLineAtX:width length:width width:lineWidth color:lineColor];
    }
}

- (void)drawHorizentalLineAtY:(CGFloat)y length:(CGFloat)length width:(CGFloat)width color:(UIColor *)color
{
    NSParameterAssert(y >= 0 && nil != color);
    
    if (length <= 0 || width <= 0) return;
    
    CGContextRef ctxt = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctxt);
    
    [color set];
    
    CGPoint startPoint = CGPointMake(0, y);
    CGPoint endPoint = CGPointMake(length, y);
    
    UIBezierPath *straightLinePath = [[UIBezierPath alloc] init];
    [straightLinePath moveToPoint:startPoint];
    [straightLinePath addLineToPoint:endPoint];
    [straightLinePath stroke];
    
    CGContextRestoreGState(ctxt);
}

- (void)drawVerticalLineAtX:(CGFloat)x length:(CGFloat)length width:(CGFloat)width color:(UIColor *)color
{
    NSParameterAssert(x >= 0 && nil != color);
    
    if (length <= 0 || width <= 0) return;
    
    CGContextRef ctxt = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctxt);
    
    [color set];
    
    CGPoint startPoint = CGPointMake(x, 0);
    CGPoint endPoint = CGPointMake(x, length);
    
    UIBezierPath *straightLinePath = [[UIBezierPath alloc] init];
    [straightLinePath moveToPoint:startPoint];
    [straightLinePath addLineToPoint:endPoint];
    [straightLinePath stroke];
    
    CGContextRestoreGState(ctxt);
}

@end
