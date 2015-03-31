//
//  SKMessagesInputToolbar.h
//  JSQMessages
//
//  Created by Shrek Wang on 3/27/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SKToolbar.h"

#import "SKToolbarContentView.h"

//@protocol SKMessagesInputToolbarDelegate <NSObject>
//
//- (UIView *)emoticonKeyboardView;
//
//- (UIView *)mediaKeyboardView;
//
//- (void)startRecordingAudioWithErrorHandler:(void (^)())errorHandler;
//- (void)endRecordingAudioWithCompletionHandler:(void (^)())completionHandler;
//- (void)cancelRecordingAudioWithCompletionHandler:(void (^)())completionHandler;
//
//- (void)sendButtonDidPressed;
//
//@end

@interface SKMessagesInputToolbar : SKToolbar

@property (weak, nonatomic) id<SKToolbarCotentViewDelegate> delegate;

/**
 *  Returns the content view of the toolbar. This view contains all subviews of the toolbar.
 */
@property (weak, nonatomic, readonly) SKToolbarContentView *contentView;

/**
 *  Enables or disables the send button based on whether or not its `textView` has text.
 *  That is, the send button will be enabled if there is text in the `textView`, and disabled otherwise.
 */
- (void)toggleSendButtonEnabled;

@end
