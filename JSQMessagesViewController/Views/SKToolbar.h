//
//  SKToolbar.h
//  JSQMessages
//
//  Created by shrek wang on 3/31/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Posted when the system keyboard frame changes.
 *  The object of the notification is the `JSQMessagesKeyboardController` object.
 *  The `userInfo` dictionary contains the new keyboard frame for key
 *  `JSQMessagesKeyboardControllerUserInfoKeyKeyboardDidChangeFrame`.
 */
FOUNDATION_EXPORT NSString * const SKToolbarKeyboardNotificationKeyboardDidChangeFrame;

/**
 *  Contains the new keyboard frame wrapped in an `NSValue` object.
 */
FOUNDATION_EXPORT NSString * const SKToolbarKeyboardUserInfoKeyKeyboardDidChangeFrame;

@protocol SKToolbarKeyboardDelegate <NSObject>

@required

/**
 *  Tells the delegate that the keyboard frame has changed.
 *
 *  @param keyboardController The keyboard controller that is notifying the delegate.
 *  @param keyboardFrame      The new frame of the keyboard in the coordinate system of the `contextView`.
 */
- (void)keyboardDidChangeFrame:(CGRect)keyboardFrame;

@end

@interface SKToolbar : UIToolbar

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarBottomSpacingConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarHeightConstraint;

/**
 *  The object that acts as the delegate of the keyboard controller.
 */
@property (weak, nonatomic) id<SKToolbarKeyboardDelegate> keyboardDelegate;

/**
 *  The text view in which the user is editing with the system keyboard.
 */
@property (weak, nonatomic, readonly) UITextView *textView;

/**
 *  The view in which the keyboard will be shown. This should be the parent or a sibling of `textView`.
 */
@property (weak, nonatomic, readonly) UIView *contextView;

@property (weak, nonatomic, readonly) UIScrollView *scrollView;

@property (weak, nonatomic, readonly) id<UILayoutSupport> topLayoutGuide;
@property (weak, nonatomic, readonly) id<UILayoutSupport> bottomLayoutGuide;

/**
 *  The pan gesture recognizer responsible for handling user interaction with the system keyboard.
 */
@property (weak, nonatomic, readonly) UIPanGestureRecognizer *panGestureRecognizer;

/**
 *  Specifies the distance from the keyboard at which the `panGestureRecognizer`
 *  should trigger user interaction with the keyboard by panning.
 *
 *  @discussion The x value of the point is not used.
 */
@property (assign, nonatomic) CGPoint keyboardTriggerPoint;

/**
 *  Returns `YES` if the keyboard is currently visible, `NO` otherwise.
 */
@property (assign, nonatomic, readonly) BOOL keyboardIsVisible;

/**
 *  Returns the current frame of the keyboard if it is visible, otherwise `CGRectNull`.
 */
@property (assign, nonatomic, readonly) CGRect currentKeyboardFrame;

- (void)configWithTextView:(UITextView *)textView
adjustToolbarHeightWhenTextViewContentSizeChange:(BOOL)should
               contextView:(UIView *)contextView
                scrollView:(UIScrollView *)scrollView
            topLayoutGuide:(id<UILayoutSupport>)topLayoutGuide
         bottomLayoutGuide:(id<UILayoutSupport>)bottomLayoutGuide
      panGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer
                  delegate:(id<SKToolbarKeyboardDelegate>)delegate;

/**
 *  Tells the keyboard controller that it should begin listening for system keyboard notifications.
 */
- (void)beginListeningForKeyboard;

/**
 *  Tells the keyboard controller that it should end listening for system keyboard notifications.
 */
- (void)endListeningForKeyboard;

@end
