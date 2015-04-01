//
//  XHVoiceRecordHUD.h
//  MessageDisplayExample
//
//  Created by qtone-1 on 14-5-13.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XHVoiceRecordHUD : UIView

@property (nonatomic, assign) CGFloat peakPower;

/**
 *  开始显示录音HUD控件在某个view
 *
 *  @param view 具体要显示的View
 */
- (void)startRecordingHUDAtView:(UIView *)view;

/**
 *  提示取消录音
 */
- (void)didCanceling;

- (void)showError;

- (void)dismissCompleted:(void(^)(BOOL fnished))completion;

+ (instancetype)instance;

@end
