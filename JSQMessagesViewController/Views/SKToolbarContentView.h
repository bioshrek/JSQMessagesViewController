//
//  SKToolbarContentView.h
//  JSQMessages
//
//  Created by Shrek Wang on 3/31/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  The `JSQMessagesInputToolbarDelegate` protocol defines methods for interacting with
 *  a `JSQMessagesInputToolbar` object.
 */
@protocol SKToolbarCotentViewDelegate <UIToolbarDelegate>

@required

- (UIView *)emoticonKeyboardView;

- (void)showMediaKeyboardView;
- (void)hideMediaKeyboardView;

- (void)startRecordingAudioWithErrorHandler:(void (^)())errorHandler;
- (void)endRecordingAudioWithCompletionHandler:(void (^)())completionHandler;
- (void)cancelRecordingAudioWithCompletionHandler:(void (^)())completionHandler;

- (void)sendButtonDidPressed;

@end

@interface SKToolbarContentView : UIView

@property (weak, nonatomic, readonly) UIButton *voiceRecordTriggerButton;
@property (weak, nonatomic, readonly) UIButton *voiceRecordStarterButton;

@property (weak, nonatomic, readonly) UIButton *emoticonTriggerButton;

@property (weak, nonatomic, readonly) UITextView *textView;

@property (weak, nonatomic, readonly) UIButton *mediaTriggerButton;
@property (weak, nonatomic, readonly) UIButton *sendButton;

@property (weak, nonatomic) id<SKToolbarCotentViewDelegate> delegate;

+ (instancetype)loadFromNib;

@end
