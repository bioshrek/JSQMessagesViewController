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

@protocol SKMessagesInputToolbarDelegate <UIToolbarDelegate>

@required

- (UIView *)emoticonKeyboardView;

- (void)showMediaKeyboardViewWithCompeltion:(void (^)(CGFloat keyboardHeight))completionHandler;
- (void)hideMediaKeyboardView;

- (void)pauseRecordingAudio;
- (void)resumeRecordingAudioWithVoiceVolumn:(void (^)(CGFloat peakPower))voiceVolumBlock
                               errorHandler:(void (^)())errorHandler;
- (void)endRecordingAudioWithCompletionHandler:(void (^)())completionHandler;
- (void)cancelRecordingAudioWithCompletionHandler:(void (^)())completionHandler;

- (void)sendButtonDidPressed:(UITextView *)textView;

@end

@interface SKMessagesInputToolbar : SKToolbar

@property (weak, nonatomic) id<SKMessagesInputToolbarDelegate> delegate;

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
