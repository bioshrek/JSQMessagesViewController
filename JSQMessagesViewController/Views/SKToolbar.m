//
//  SKToolbar.m
//  JSQMessages
//
//  Created by shrek wang on 3/31/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import "SKToolbar.h"

#import "UIDevice+JSQMessages.h"

NSString * const SKToolbarKeyboardUserInfoKeyKeyboardDidChangeFrame = @"SKToolbarKeyboardUserInfoKeyKeyboardDidChangeFrame";

NSString * const SKToolbarKeyboardNotificationKeyboardDidChangeFrame = @"SKToolbarKeyboardNotificationKeyboardDidChangeFrame";

static void * kJSQMessagesKeyboardControllerKeyValueObservingContext = &kJSQMessagesKeyboardControllerKeyValueObservingContext;

const CGFloat kSKToolbarHeightDefault = 44.0f;

typedef void (^JSQAnimationCompletionBlock)(BOOL finished);

@interface SKToolbar () <UIGestureRecognizerDelegate>

@property (assign, nonatomic) BOOL sk_isObserving;
@property (assign, nonatomic) BOOL sk_isObservingTextContentSize;

@property (weak, nonatomic) UIView *keyboardView;

@property (assign, nonatomic) UIEdgeInsets originalScrollViewContentInsets;
@property (assign, nonatomic) UIEdgeInsets originalScrollViewIndicatorInsets;

@property (assign, nonatomic) BOOL shouldadjustToolbarHeightWhenTextViewContentSizeChange;

@end

@implementation SKToolbar

#pragma mark - Life cycle

- (void)configWithTextView:(UITextView *)textView
adjustToolbarHeightWhenTextViewContentSizeChange:(BOOL)should
               contextView:(UIView *)contextView
                scrollView:(UIScrollView *)scrollView
            topLayoutGuide:(id<UILayoutSupport>)topLayoutGuide
         bottomLayoutGuide:(id<UILayoutSupport>)bottomLayoutGuide
      panGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer
                  delegate:(id<SKToolbarKeyboardDelegate>)delegate

{
    NSParameterAssert(textView != nil);
    NSParameterAssert(contextView != nil);
    NSParameterAssert(scrollView);
    NSParameterAssert(topLayoutGuide);
    NSParameterAssert(bottomLayoutGuide);
    NSParameterAssert(panGestureRecognizer != nil);
    
    self.shouldadjustToolbarHeightWhenTextViewContentSizeChange = should;
    _sk_isObservingTextContentSize = NO;
    self.textView = textView;
    _contextView = contextView;
    _scrollView = scrollView;
    _topLayoutGuide = topLayoutGuide;
    _bottomLayoutGuide = bottomLayoutGuide;
    _panGestureRecognizer = panGestureRecognizer;
    _keyboardDelegate = delegate;
    _sk_isObserving = NO;
}

- (void)dealloc
{
    [self endListeningForKeyboard];
}

#pragma mark - Setters

- (void)setKeyboardView:(UIView *)keyboardView
{
    if (_keyboardView) {
        [self jsq_removeKeyboardFrameObserver];
    }
    
    _keyboardView = keyboardView;
    
    if (keyboardView && !_sk_isObserving) {
        [_keyboardView addObserver:self
                        forKeyPath:NSStringFromSelector(@selector(frame))
                           options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew)
                           context:kJSQMessagesKeyboardControllerKeyValueObservingContext];
        
        _sk_isObserving = YES;
    }
}

- (void)setTextView:(UITextView *)textView
{
    if (_textView) {
        [self jsq_removeTextViewObserver];
    }
    
    _textView = textView;
    
    if (self.shouldadjustToolbarHeightWhenTextViewContentSizeChange && textView && !_sk_isObserving) {
        [textView addObserver:self
                   forKeyPath:NSStringFromSelector(@selector(contentSize))
                      options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                      context:kJSQMessagesKeyboardControllerKeyValueObservingContext];
        
        _sk_isObservingTextContentSize = YES;
    }
}

#pragma mark - Getters

- (BOOL)keyboardIsVisible
{
    return self.keyboardView != nil;
}

- (CGRect)currentKeyboardFrame
{
    if (!self.keyboardIsVisible) {
        return CGRectNull;
    }
    
    return self.keyboardView.frame;
}

#pragma mark - Keyboard controller

- (void)beginListeningForKeyboard
{
    self.textView.inputAccessoryView = [[UIView alloc] init];
    [self jsq_registerForNotifications];
    
    self.originalScrollViewContentInsets = self.scrollView.contentInset;
    self.originalScrollViewIndicatorInsets = self.scrollView.scrollIndicatorInsets;
}

- (void)endListeningForKeyboard
{
    self.textView.inputAccessoryView = nil;
    
    [self jsq_unregisterForNotifications];
    
    [self jsq_removeKeyboardFrameObserver];
    [self jsq_removeTextViewObserver];
    
    [self jsq_setKeyboardViewHidden:NO];
    self.keyboardView = nil;
}

#pragma mark - Notifications

- (void)jsq_registerForNotifications
{
    [self jsq_unregisterForNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(jsq_didReceiveKeyboardDidShowNotification:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(jsq_didReceiveKeyboardWillChangeFrameNotification:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(jsq_didReceiveKeyboardDidChangeFrameNotification:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(jsq_didReceiveKeyboardDidHideNotification:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(jsq_handleDidChangeStatusBarFrameNotification:)
                                                 name:UIApplicationDidChangeStatusBarFrameNotification
                                               object:nil];
}

- (void)jsq_unregisterForNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)jsq_didReceiveKeyboardDidShowNotification:(NSNotification *)notification
{
    self.keyboardView = self.textView.inputAccessoryView.superview;
    [self jsq_setKeyboardViewHidden:NO];
    
    [self jsq_handleKeyboardNotification:notification completion:^(BOOL finished) {
        [self.panGestureRecognizer addTarget:self action:@selector(jsq_handlePanGestureRecognizer:)];
    }];
}

- (void)jsq_didReceiveKeyboardWillChangeFrameNotification:(NSNotification *)notification
{
    [self jsq_handleKeyboardNotification:notification completion:nil];
}

- (void)jsq_didReceiveKeyboardDidChangeFrameNotification:(NSNotification *)notification
{
    [self jsq_setKeyboardViewHidden:NO];
    
    [self jsq_handleKeyboardNotification:notification completion:nil];
}

- (void)jsq_didReceiveKeyboardDidHideNotification:(NSNotification *)notification
{
    self.keyboardView = nil;
    
    [self jsq_handleKeyboardNotification:notification completion:^(BOOL finished) {
        [self.panGestureRecognizer removeTarget:self action:NULL];
    }];
}

- (void)jsq_handleDidChangeStatusBarFrameNotification:(NSNotification *)notification
{
    if (self.keyboardIsVisible) {
        [self jsq_setToolbarBottomLayoutGuideConstant:CGRectGetHeight(self.currentKeyboardFrame)];
    }
}

- (void)jsq_handleKeyboardNotification:(NSNotification *)notification completion:(JSQAnimationCompletionBlock)completion
{
    NSDictionary *userInfo = [notification userInfo];
    
    CGRect keyboardEndFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if (CGRectIsNull(keyboardEndFrame)) {
        return;
    }
    
    UIViewAnimationCurve animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    NSInteger animationCurveOption = (animationCurve << 16);
    
    double animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGRect keyboardEndFrameConverted = [self.contextView convertRect:keyboardEndFrame fromView:nil];
    
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:animationCurveOption
                     animations:^{
                         [self jsq_notifyKeyboardFrameNotificationForFrame:keyboardEndFrameConverted];
                     }
                     completion:^(BOOL finished) {
                         if (completion) {
                             completion(finished);
                         }
                     }];
}

#pragma mark - Utilities

- (void)jsq_setKeyboardViewHidden:(BOOL)hidden
{
    self.keyboardView.hidden = hidden;
    self.keyboardView.userInteractionEnabled = !hidden;
}

- (void)jsq_notifyKeyboardFrameNotificationForFrame:(CGRect)frame
{
    [self adjustToolbarFrameWithKeyboardFrame:frame];
    
    [self.keyboardDelegate keyboardDidChangeFrame:frame];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SKToolbarKeyboardNotificationKeyboardDidChangeFrame
                                                        object:self
                                                      userInfo:@{ SKToolbarKeyboardUserInfoKeyKeyboardDidChangeFrame : [NSValue valueWithCGRect:frame] }];
}

#pragma mark - Key-value observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kJSQMessagesKeyboardControllerKeyValueObservingContext) {
        
        if (object == self.keyboardView && [keyPath isEqualToString:NSStringFromSelector(@selector(frame))]) {
            
            CGRect oldKeyboardFrame = [[change objectForKey:NSKeyValueChangeOldKey] CGRectValue];
            CGRect newKeyboardFrame = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
            
            if (CGRectEqualToRect(newKeyboardFrame, oldKeyboardFrame) || CGRectIsNull(newKeyboardFrame)) {
                return;
            }
            
            //  do not convert frame to contextView coordinates here
            //  KVO is triggered during panning (see below)
            //  panning occurs in contextView coordinates already
            [self jsq_notifyKeyboardFrameNotificationForFrame:newKeyboardFrame];
        } else if (object == self.textView
            && [keyPath isEqualToString:NSStringFromSelector(@selector(contentSize))]) {
            
            CGSize oldContentSize = [[change objectForKey:NSKeyValueChangeOldKey] CGSizeValue];
            CGSize newContentSize = [[change objectForKey:NSKeyValueChangeNewKey] CGSizeValue];
            
            CGFloat dy = newContentSize.height - oldContentSize.height;
            
            [self jsq_adjustInputToolbarForComposerTextViewContentSizeChange:dy];
            [self adjustScrollInsets];
        }
    }
}

- (void)jsq_removeKeyboardFrameObserver
{
    if (!_sk_isObserving) {
        return;
    }
    
    @try {
        [_keyboardView removeObserver:self
                           forKeyPath:NSStringFromSelector(@selector(frame))
                              context:kJSQMessagesKeyboardControllerKeyValueObservingContext];
    }
    @catch (NSException * __unused exception) { }
    
    _sk_isObserving = NO;
}

- (void)jsq_removeTextViewObserver
{
    if (!_sk_isObservingTextContentSize) {
        return;
    }
    
    @try {
        [_textView removeObserver:self
                       forKeyPath:NSStringFromSelector(@selector(contentSize))
                          context:kJSQMessagesKeyboardControllerKeyValueObservingContext];
    }
    @catch (NSException * __unused exception) { }
    
    _sk_isObservingTextContentSize = NO;
}

#pragma mark - Pan gesture recognizer

- (void)jsq_handlePanGestureRecognizer:(UIPanGestureRecognizer *)pan
{
    CGPoint touch = [pan locationInView:self.contextView];
    
    //  system keyboard is added to a new UIWindow, need to operate in window coordinates
    //  also, keyboard always slides from bottom of screen, not the bottom of a view
    CGFloat contextViewWindowHeight = CGRectGetHeight(self.contextView.window.frame);
    
    if ([UIDevice jsq_isCurrentDeviceBeforeiOS8]) {
        //  handle iOS 7 bug when rotating to landscape
        if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            contextViewWindowHeight = CGRectGetWidth(self.contextView.window.frame);
        }
    }
    
    CGFloat keyboardViewHeight = CGRectGetHeight(self.keyboardView.frame);
    
    CGFloat dragThresholdY = (contextViewWindowHeight - keyboardViewHeight - self.keyboardTriggerPoint.y);
    
    CGRect newKeyboardViewFrame = self.keyboardView.frame;
    
    BOOL userIsDraggingNearThresholdForDismissing = (touch.y > dragThresholdY);
    
    self.keyboardView.userInteractionEnabled = !userIsDraggingNearThresholdForDismissing;
    
    switch (pan.state) {
        case UIGestureRecognizerStateChanged:
        {
            newKeyboardViewFrame.origin.y = touch.y + self.keyboardTriggerPoint.y;
            
            //  bound frame between bottom of view and height of keyboard
            newKeyboardViewFrame.origin.y = MIN(newKeyboardViewFrame.origin.y, contextViewWindowHeight);
            newKeyboardViewFrame.origin.y = MAX(newKeyboardViewFrame.origin.y, contextViewWindowHeight - keyboardViewHeight);
            
            if (CGRectGetMinY(newKeyboardViewFrame) == CGRectGetMinY(self.keyboardView.frame)) {
                return;
            }
            
            [UIView animateWithDuration:0.0
                                  delay:0.0
                                options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionTransitionNone
                             animations:^{
                                 self.keyboardView.frame = newKeyboardViewFrame;
                             }
                             completion:nil];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            BOOL keyboardViewIsHidden = (CGRectGetMinY(self.keyboardView.frame) >= contextViewWindowHeight);
            if (keyboardViewIsHidden) {
                return;
            }
            
            CGPoint velocity = [pan velocityInView:self.contextView];
            BOOL userIsScrollingDown = (velocity.y > 0.0f);
            BOOL shouldHide = (userIsScrollingDown && userIsDraggingNearThresholdForDismissing);
            
            newKeyboardViewFrame.origin.y = shouldHide ? contextViewWindowHeight : (contextViewWindowHeight - keyboardViewHeight);
            
            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationCurveEaseOut
                             animations:^{
                                 self.keyboardView.frame = newKeyboardViewFrame;
                             }
                             completion:^(BOOL finished) {
                                 self.keyboardView.userInteractionEnabled = !shouldHide;
                                 
                                 if (shouldHide) {
                                     [self jsq_setKeyboardViewHidden:YES];
                                     [self jsq_removeKeyboardFrameObserver];
                                     [self.textView resignFirstResponder];
                                 }
                             }];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Adjust toolbar position

- (void)jsq_setToolbarBottomLayoutGuideConstant:(CGFloat)constant
{
    self.toolbarBottomSpacingConstraint.constant = constant;
    [self.contextView setNeedsUpdateConstraints];
    [self.contextView layoutIfNeeded];
    
    [self adjustScrollInsets];
}

- (void)adjustToolbarFrameWithKeyboardFrame:(CGRect)keyboardFrame
{
    // adjust toolbar frame
    CGFloat heightFromBottom = CGRectGetMaxY(self.contextView.frame) - CGRectGetMinY(keyboardFrame);
    heightFromBottom = MAX(0.0f, heightFromBottom);
    
    [self jsq_setToolbarBottomLayoutGuideConstant:heightFromBottom];
}

- (void)adjustScrollInsets
{
//    CGFloat toolbarMinY = CGRectGetMaxY(self.contextView.frame) - self.toolbarBottomSpacingConstraint.constant - CGRectGetHeight(self.bounds);
    CGFloat toolbarMinY = CGRectGetMinY(self.frame);
    CGFloat bottomInset = CGRectGetMaxY(self.scrollView.frame) - toolbarMinY;
    bottomInset = MAX(bottomInset, self.originalScrollViewContentInsets.bottom);
    UIEdgeInsets originalInsets = self.originalScrollViewContentInsets;
    self.scrollView.contentInset = UIEdgeInsetsMake(originalInsets.top, originalInsets.left,bottomInset, originalInsets.right);
    
    UIEdgeInsets originalScrollIndicatorInsets = self.originalScrollViewIndicatorInsets;
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(originalScrollIndicatorInsets.top, originalScrollIndicatorInsets.left, bottomInset, originalScrollIndicatorInsets.right);
}

#pragma mark - Adjust Toolbar height

- (void)jsq_adjustInputToolbarForComposerTextViewContentSizeChange:(CGFloat)dy
{
    BOOL contentSizeIsIncreasing = (dy > 0);
    
    if ([self jsq_inputToolbarHasReachedMaximumHeight]) {
        BOOL contentOffsetIsPositive = (self.textView.contentOffset.y > 0);
        
        if (contentSizeIsIncreasing || contentOffsetIsPositive) {
            [self jsq_scrollComposerTextViewToBottomAnimated:YES];
            return;
        }
    }
    
    CGFloat toolbarOriginY = CGRectGetMinY(self.frame);
    CGFloat newToolbarOriginY = toolbarOriginY - dy;
    
    //  attempted to increase origin.Y above topLayoutGuide
    if (newToolbarOriginY <= self.topLayoutGuide.length) {
        dy = toolbarOriginY - self.topLayoutGuide.length;
        [self jsq_scrollComposerTextViewToBottomAnimated:YES];
    }
    
    [self jsq_adjustInputToolbarHeightConstraintByDelta:dy];
    
    [self jsq_updateKeyboardTriggerPoint];
    
    if (dy < 0) {
        [self jsq_scrollComposerTextViewToBottomAnimated:NO];
    }
}

- (BOOL)jsq_inputToolbarHasReachedMaximumHeight
{
    return (CGRectGetMinY(self.frame) == self.topLayoutGuide.length);
}

- (void)jsq_scrollComposerTextViewToBottomAnimated:(BOOL)animated
{
    UITextView *textView = self.textView;
    CGPoint contentOffsetToShowLastLine = CGPointMake(0.0f, textView.contentSize.height - CGRectGetHeight(textView.bounds));
    
    if (!animated) {
        textView.contentOffset = contentOffsetToShowLastLine;
        return;
    }
    
    [UIView animateWithDuration:0.01
                          delay:0.01
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         textView.contentOffset = contentOffsetToShowLastLine;
                     }
                     completion:nil];
}

- (void)jsq_adjustInputToolbarHeightConstraintByDelta:(CGFloat)dy
{
    self.toolbarHeightConstraint.constant += dy;
    
    if (self.toolbarHeightConstraint.constant < kSKToolbarHeightDefault) {
        self.toolbarHeightConstraint.constant = kSKToolbarHeightDefault;
    }
    
    [self.contextView setNeedsUpdateConstraints];
    [self.contextView layoutIfNeeded];
}

- (void)jsq_updateKeyboardTriggerPoint
{
    self.keyboardTriggerPoint = CGPointMake(0.0f, CGRectGetHeight(self.bounds));
}

@end
