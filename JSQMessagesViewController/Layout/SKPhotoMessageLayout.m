//
//  SKPhotoMessageLayout.m
//  JSQMessages
//
//  Created by shrek wang on 3/20/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import "SKPhotoMessageLayout.h"

#import "SKPhotoMessageData.h"

@implementation SKPhotoMessageLayout

- (CGSize)messageBubbleSizeForMessageContent:(id<SKMessageContent>)messageContent maxWidth:(CGFloat)maxWidth
{
    NSParameterAssert([messageContent conformsToProtocol:@protocol(SKPhotoMessageData)]);
    
    id<SKPhotoMessageData> message = (id<SKPhotoMessageData>)messageContent;
    
    CGSize finalSize = [message photoDisplaySize];
    // TODO: consider max height, max widht
    
    return finalSize;
}

- (void)configCustomLayoutAttributes:(JSQMessagesCollectionViewLayoutAttributes *)layoutAttributes
{
    // nothing to do
}

@end
