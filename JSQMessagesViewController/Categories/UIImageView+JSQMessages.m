//
//  UIImageView+JSQMessages.m
//  JSQMessages
//
//  Created by shrek wang on 3/26/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import "UIImageView+JSQMessages.h"

#import "UIImage+JSQMessages.h"

@implementation UIImageView (JSQMessages)

- (void)configAsAudioDurationAnimationWithColor:(UIColor *)color outgoing:(BOOL)outgoing
{
    NSMutableArray *animationImages = [[NSMutableArray alloc] init];
    
    NSArray *images = [self animationImagesForAudioAnimation];
    NSMutableArray *coloredImages = [[NSMutableArray alloc] init];
    // image -> color
    for (UIImage *image in images) {
        [coloredImages addObject:[image jsq_imageMaskedWithColor:color]];
    }
    if (!outgoing) {  // incoming
        // image -> flip horizontally
        for (UIImage *image in coloredImages) {
            [animationImages addObject:[self jsq_horizontallyFlippedImageFromImage:image]];
        }
    } else {
        animationImages = coloredImages;
    }
    
    self.image = [animationImages lastObject];
    self.animationImages = animationImages;
    self.animationDuration = 1.0f;
}

- (NSArray *)animationImagesForAudioAnimation
{
    return @[
                [UIImage imageNamed:@"VoiceNodePlaying000"],
                [UIImage imageNamed:@"VoiceNodePlaying001"],
                [UIImage imageNamed:@"VoiceNodePlaying002"],
                [UIImage imageNamed:@"VoiceNodePlaying003"],
             ];
}

- (UIImage *)jsq_horizontallyFlippedImageFromImage:(UIImage *)image
{
    return [UIImage imageWithCGImage:image.CGImage
                               scale:image.scale
                         orientation:UIImageOrientationUpMirrored];
}

@end
