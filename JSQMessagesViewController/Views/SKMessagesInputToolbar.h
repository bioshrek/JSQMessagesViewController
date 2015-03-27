//
//  SKMessagesInputToolbar.h
//  JSQMessages
//
//  Created by Shrek Wang on 3/27/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SKMessagesInputToolbar;

#import "JSQMessagesToolbarContentView.h"

/**
 *  The `JSQMessagesInputToolbarDelegate` protocol defines methods for interacting with
 *  a `JSQMessagesInputToolbar` object.
 */
@protocol SKMessagesInputToolbarDelegate <UIToolbarDelegate>

@required

/**
 *  Tells the delegate that the toolbar's `rightBarButtonItem` has been pressed.
 *
 *  @param toolbar The object representing the toolbar sending this information.
 *  @param sender  The button that received the touch event.
 */
- (void)messagesInputToolbar:(SKMessagesInputToolbar *)toolbar
      didPressRightBarButton:(UIButton *)sender;

/**
 *  Tells the delegate that the toolbar's `leftBarButtonItem` has been pressed.
 *
 *  @param toolbar The object representing the toolbar sending this information.
 *  @param sender  The button that received the touch event.
 */
- (void)messagesInputToolbar:(SKMessagesInputToolbar *)toolbar
       didPressLeftBarButton:(UIButton *)sender;

@end

@interface SKMessagesInputToolbar : UIToolbar

@property (weak, nonatomic) id<SKMessagesInputToolbarDelegate> delegate;

/**
 *  Returns the content view of the toolbar. This view contains all subviews of the toolbar.
 */
@property (weak, nonatomic, readonly) JSQMessagesToolbarContentView *contentView;

/**
 *  Enables or disables the send button based on whether or not its `textView` has text.
 *  That is, the send button will be enabled if there is text in the `textView`, and disabled otherwise.
 */
- (void)toggleSendButtonEnabled;

@end
