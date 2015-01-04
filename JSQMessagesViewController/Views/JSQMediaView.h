//
//  SKMediaView.h
//  JSQMessages
//
//  Created by shrek wang on 12/27/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JSQMediaView : UICollectionReusableView

@property (assign, nonatomic) BOOL appliesMediaViewMaskAsOutgoing;

+ (UINib *)nib;

+ (NSString *)reuseIdentifier;

@end
