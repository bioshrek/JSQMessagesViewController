//
//  DemoToolbarViewController.m
//  JSQMessages
//
//  Created by Shrek Wang on 3/31/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import "DemoToolbarViewController.h"

#import "UIView+JSQMessages.h"
#import "SKMessagesInputToolbar.h"

@interface DemoToolbarViewController () <UITableViewDataSource, SKMessagesInputToolbarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet SKMessagesInputToolbar *toolbar;

@property (weak, nonatomic) IBOutlet UIView *mediaKeyboardView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mediaKeyboardViewHeightConstraint;

@property (strong, nonatomic) UIView *emoticonKeyboardView;

@property (weak, nonatomic) NSTimer *voicePowerPeakTimer;
@property (copy, nonatomic) void (^peakPowerBlock)();

@end

@implementation DemoToolbarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.dataSource = self;
    
    [self.toolbar configWithTextView:self.toolbar.contentView.textView adjustToolbarHeightWhenTextViewContentSizeChange:YES contextView:self.view scrollView:self.tableView topLayoutGuide:self.topLayoutGuide bottomLayoutGuide:self.bottomLayoutGuide panGestureRecognizer:self.tableView.panGestureRecognizer];
    self.toolbar.delegate = self;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    view.backgroundColor = [UIColor blueColor];
    self.emoticonKeyboardView = view;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.toolbar beginListeningForKeyboard];
    
    // config media keyboard view
    [self configMediaKeyboardView];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.toolbar endListeningForKeyboard];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = @"shrek wang";
    
    return cell;
}

#pragma mark - Toolbar Delegate

- (void)sendButtonDidPressed:(UITextView *)textView
{
    NSLog(@"send button pressed.");
}

- (void)configMediaKeyboardView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    view.backgroundColor = [UIColor greenColor];
    [self.mediaKeyboardView addSubview:view];
    self.mediaKeyboardViewHeightConstraint.constant = 100;
    [self.mediaKeyboardView jsq_pinAllEdgesOfSubview:view];
    self.mediaKeyboardView.hidden = YES;
}

- (void)showMediaKeyboardViewWithCompeltion:(void (^)(CGFloat))completionHandler
{
    if (self.mediaKeyboardView.hidden) {
        self.mediaKeyboardView.hidden = NO;
        if (completionHandler) completionHandler(self.mediaKeyboardViewHeightConstraint.constant);
    }
}

- (void)hideMediaKeyboardView
{
    if (!self.mediaKeyboardView.hidden) {
        self.mediaKeyboardView.hidden = YES;
    }
}

- (void)resumeRecordingAudioWithVoiceVolumn:(void (^)(CGFloat))voiceVolumBlock errorHandler:(void (^)())errorHandler
{
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        if (errorHandler) errorHandler();
//    });
    
    self.peakPowerBlock = voiceVolumBlock;
    
    if (!self.voicePowerPeakTimer) {
        NSTimer *timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(updatePowerPeak) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        self.voicePowerPeakTimer = timer;
    }
    [self.voicePowerPeakTimer fire];
    
    NSLog(@"resume recording voice");
}

- (void)updatePowerPeak
{
    if (self.peakPowerBlock) {
        self.peakPowerBlock(arc4random_uniform(100) / 100.0);
    }
}

- (void)pauseRecordingAudio
{
    [self.voicePowerPeakTimer invalidate];
    
    NSLog(@"pause recording voice");
}

- (void)endRecordingAudioWithCompletionHandler:(void (^)())completionHandler
{
    [self.voicePowerPeakTimer invalidate];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (completionHandler) completionHandler();
    });
    NSLog(@"end recording voice");
}

- (void)cancelRecordingAudioWithCompletionHandler:(void (^)())completionHandler
{
    [self.voicePowerPeakTimer invalidate];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (completionHandler) completionHandler();
    });
    
    NSLog(@"cancel recording voice");
}

@end
