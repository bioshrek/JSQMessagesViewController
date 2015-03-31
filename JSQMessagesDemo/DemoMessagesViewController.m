//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "DemoMessagesViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>

#import "JSQAudioItem.h"

#import "JSQFileItem.h"

#import "JSQMessagesCollectionViewCellIncomingAudio.h"

#import "JSQMessagesInputToolbarEx.h"

@interface DemoMessagesViewController () <JSQMessagesInputToolbarExDelegate>

@property (weak, nonatomic) IBOutlet JSQMessagesInputToolbarEx *toolbar;

@end

@implementation DemoMessagesViewController

#pragma mark - View lifecycle

/**
 *  Override point for customization.
 *
 *  Customize your view.
 *  Look at the properties on `JSQMessagesViewController` and `JSQMessagesCollectionView` to see what is possible.
 *
 *  Customize your layout.
 *  Look at the properties on `JSQMessagesCollectionViewFlowLayout` to see what is possible.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"JSQMessages";
    
    /**
     *  You MUST set your senderId and display name
     */
    self.senderId = kJSQDemoAvatarIdSquires;
    self.senderDisplayName = kJSQDemoAvatarDisplayNameSquires;
    
    
    /**
     *  Load up our fake data for the demo
     */
    self.demoData = [[DemoModelData alloc] init];
    
    
    /**
     *  You can set custom avatar sizes
     */
    if (![NSUserDefaults incomingAvatarSetting]) {
        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    }
    
    if (![NSUserDefaults outgoingAvatarSetting]) {
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    }
    
    self.showLoadEarlierMessagesHeader = YES;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage jsq_defaultTypingIndicatorImage]
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(receiveMessagePressed:)];
    
    [self.toolbar configWithTextView:self.toolbar.contentView.textView adjustToolbarHeightWhenTextViewContentSizeChange:YES contextView:self.view scrollView:self.collectionView topLayoutGuide:self.topLayoutGuide bottomLayoutGuide:self.bottomLayoutGuide panGestureRecognizer:self.collectionView.panGestureRecognizer delegate:nil];
    self.toolbar.contentView.textView.placeHolder = NSLocalizedStringFromTable(@"New Message", @"JSQMessages", @"Placeholder text for the message input text view");
    self.toolbar.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.delegateModal) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                              target:self
                                                                                              action:@selector(closePressed:)];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /**
     *  Enable/disable springy bubbles, default is NO.
     *  You must set this from `viewDidAppear:`
     *  Note: this feature is mostly stable, but still experimental
     */
    self.collectionView.collectionViewLayout.springinessEnabled = [NSUserDefaults springinessSetting];
    
    [self.toolbar beginListeningForKeyboard];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.toolbar endListeningForKeyboard];
}

- (void)dealloc
{
    [_toolbar endListeningForKeyboard];
}

#pragma mark - Actions

- (void)finishSendingMessage
{
    [super finishSendingMessage];
    
        UITextView *textView = self.toolbar.contentView.textView;
        textView.attributedText = nil;
        [textView.undoManager removeAllActions];
    
        [self.toolbar toggleSendButtonEnabled];
        [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification object:textView];
}

- (void)receiveMessagePressed:(UIBarButtonItem *)sender
{
    /**
     *  DEMO ONLY
     *
     *  The following is simply to simulate received messages for the demo.
     *  Do not actually do this.
     */
    
    
    /**
     *  Show the typing indicator to be shown
     */
    self.showTypingIndicator = !self.showTypingIndicator;
    
    /**
     *  Scroll to actually view the indicator
     */
    [self scrollToBottomAnimated:YES];
    
    /**
     *  Copy last sent message, this will be the new "received" message
     */
    JSQMessage *copyMessage = [[self.demoData.messages lastObject] copy];
    
    if (!copyMessage) {
        copyMessage = [JSQMessage messageWithSenderId:kJSQDemoAvatarIdJobs
                                              displayName:kJSQDemoAvatarDisplayNameJobs
                                       attributedText:[[NSAttributedString alloc] initWithString:@"First received!"
                                                                                      attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16.0f]}]];
    }
    
    /**
     *  Allow typing indicator to show
     */
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSMutableArray *userIds = [[self.demoData.users allKeys] mutableCopy];
        [userIds removeObject:self.senderId];
        NSString *randomUserId = userIds[arc4random_uniform((int)[userIds count])];
        
        JSQMessage *newMessage = nil;
        id<JSQMessageMediaData> newMediaData = nil;
        id newMediaAttachmentCopy = nil;
        
        switch (copyMessage.messageType) {
            case JSQMessageDataTypeText: {
                /**
                 *  Last message was a text message
                 */
                newMessage = [JSQMessage messageWithSenderId:randomUserId
                                                 displayName:self.demoData.users[randomUserId]
                                              attributedText:copyMessage.attributedText];
            } break;
            case JSQMessageDataTypeImage:
            case JSQMessageDataTypeVideo: {
                /**
                 *  Last message was a media message
                 */
                id<JSQMessageMediaData> copyMediaData = copyMessage.media;
                
                if ([copyMediaData isKindOfClass:[JSQPhotoMediaItem class]]) {
                    JSQPhotoMediaItem *photoItemCopy = [((JSQPhotoMediaItem *)copyMediaData) copy];
                    photoItemCopy.appliesMediaViewMaskAsOutgoing = NO;
                    newMediaAttachmentCopy = [UIImage imageWithCGImage:photoItemCopy.image.CGImage];
                    
                    /**
                     *  Set image to nil to simulate "downloading" the image
                     *  and show the placeholder view
                     */
                    photoItemCopy.image = nil;
                    
                    newMediaData = photoItemCopy;
                }
                else if ([copyMediaData isKindOfClass:[JSQLocationMediaItem class]]) {
                    JSQLocationMediaItem *locationItemCopy = [((JSQLocationMediaItem *)copyMediaData) copy];
                    locationItemCopy.appliesMediaViewMaskAsOutgoing = NO;
                    newMediaAttachmentCopy = [locationItemCopy.location copy];
                    
                    /**
                     *  Set location to nil to simulate "downloading" the location data
                     */
                    locationItemCopy.location = nil;
                    
                    newMediaData = locationItemCopy;
                }
                else if ([copyMediaData isKindOfClass:[JSQVideoMediaItem class]]) {
                    JSQVideoMediaItem *videoItemCopy = [((JSQVideoMediaItem *)copyMediaData) copy];
                    videoItemCopy.appliesMediaViewMaskAsOutgoing = NO;
                    newMediaAttachmentCopy = [videoItemCopy.fileURL copy];
                    
                    /**
                     *  Reset video item to simulate "downloading" the video
                     */
                    videoItemCopy.fileURL = nil;
                    videoItemCopy.isReadyToPlay = NO;
                    
                    newMediaData = videoItemCopy;
                }
                else {
                    NSLog(@"%s error: unrecognized media item", __PRETTY_FUNCTION__);
                }
                
                newMessage = [JSQMessage messageWithSenderId:randomUserId
                                                 displayName:self.demoData.users[randomUserId]
                                                       media:newMediaData];
            } break;
            case JSQMessageDataTypeAudio: {
                // max visible duration: 5 minutes
                JSQAudioItem *audioItem = [[JSQAudioItem alloc] initWithDuration:arc4random_uniform(6 * 60)];
                
                newMessage = [[JSQMessage alloc] initWithSenderId:randomUserId
                                                senderDisplayName:self.demoData.users[randomUserId]
                                                             date:[NSDate date]
                                                            audio:audioItem];
            } break;
            case JSQMessageDataTypeFile: {
                JSQFileItem *fileItem = [[JSQFileItem alloc] initWithFileName:@"Cocoa Touch Programming.pdf" bytes:12568478];
                newMessage = [[JSQMessage alloc] initWithSenderId:randomUserId
                                                senderDisplayName:self.demoData.users[randomUserId]
                                                             date:[NSDate date]
                                                             file:fileItem];
            } break;
            default:
                break;
        }
        
        /**
         *  Upon receiving a message, you should:
         *
         *  1. Play sound (optional)
         *  2. Add new id<JSQMessageData> object to your data source
         *  3. Call `finishReceivingMessage`
         */
        [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
        [self.demoData.messages addObject:newMessage];
        [self finishReceivingMessage];
        
        
        if (JSQMessageDataTypeImage == newMessage.messageType ||
            JSQMessageDataTypeVideo == newMessage.messageType) {
            /**
             *  Simulate "downloading" media
             */
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                /**
                 *  Media is "finished downloading", re-display visible cells
                 *
                 *  If media cell is not visible, the next time it is dequeued the view controller will display its new attachment data
                 *
                 *  Reload the specific item, or simply call `reloadData`
                 */
                
                if ([newMediaData isKindOfClass:[JSQPhotoMediaItem class]]) {
                    ((JSQPhotoMediaItem *)newMediaData).image = newMediaAttachmentCopy;
                    [self.collectionView reloadData];
                }
                else if ([newMediaData isKindOfClass:[JSQLocationMediaItem class]]) {
                    [((JSQLocationMediaItem *)newMediaData)setLocation:newMediaAttachmentCopy withCompletionHandler:^{
                        [self.collectionView reloadData];
                    }];
                }
                else if ([newMediaData isKindOfClass:[JSQVideoMediaItem class]]) {
                    ((JSQVideoMediaItem *)newMediaData).fileURL = newMediaAttachmentCopy;
                    ((JSQVideoMediaItem *)newMediaData).isReadyToPlay = YES;
                    [self.collectionView reloadData];
                }
                else {
                    NSLog(@"%s error: unrecognized media item", __PRETTY_FUNCTION__);
                }
                
            });
        }
        
    });
}

- (void)closePressed:(UIBarButtonItem *)sender
{
    [self.delegateModal didDismissJSQDemoViewController:self];
}




#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
 withMessageAttributedText:(NSAttributedString *)attributedText
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    /**
     *  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          attributedText:attributedText];
    
    [self.demoData.messages addObject:message];
    [self finishSendingMessage];
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Media messages"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Send photo", @"Send location", @"Send video", @"Send text emoji mixture", @"Input text emoji mixture", @"Send voice", @"Send file", nil];
    
    [sheet showFromToolbar:self.toolbar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    switch (buttonIndex) {
        case 0:
            [self.demoData addPhotoMediaMessage];
            [JSQSystemSoundPlayer jsq_playMessageSentSound];
            [self finishSendingMessage];
            break;
            
        case 1: {
            __weak UICollectionView *weakView = self.collectionView;
            
            [self.demoData addLocationMediaMessageCompletion:^{
                [weakView reloadData];
            }];
            [JSQSystemSoundPlayer jsq_playMessageSentSound];
            [self finishSendingMessage];
        } break;
            
        case 2:
            [self.demoData addVideoMediaMessage];
            [JSQSystemSoundPlayer jsq_playMessageSentSound];
            [self finishSendingMessage];
            break;
        
        case 3: {
            UIImage *emojiImage = [UIImage imageNamed:@"smiley"];
            NSTextAttachment *attach = [[NSTextAttachment alloc] initWithData:UIImagePNGRepresentation(emojiImage)
                                                                       ofType:(__bridge NSString *)kUTTypePNG];
            
            NSMutableAttributedString *mutableAttrText = [[NSMutableAttributedString alloc] init];
            [mutableAttrText appendAttributedString:[NSAttributedString attributedStringWithAttachment:attach]];
            [mutableAttrText appendAttributedString:[[NSAttributedString alloc] initWithString:@" This is a sentence with custome emoji "]];
            [mutableAttrText appendAttributedString:[NSAttributedString attributedStringWithAttachment:attach]];
            [mutableAttrText appendAttributedString:[[NSAttributedString alloc] initWithString:@", enjoy! xxxx eeea eea ega a ee ae33sss"]];
            [mutableAttrText appendAttributedString:[NSAttributedString attributedStringWithAttachment:attach]];
            [self ensureFont:[UIFont systemFontOfSize:16.0f] forAttributedText:mutableAttrText];
            
            JSQMessage *message = [[JSQMessage alloc] initWithSenderId:self.senderId
                                                             senderDisplayName:self.senderDisplayName
                                                                          date:[NSDate distantFuture]
                                                                attributedText:mutableAttrText];
            [self.demoData.messages addObject:message];
            [self finishSendingMessage];
        } break;
            
        case 4: {
            UIImage *emojiImage = [UIImage imageNamed:@"smiley"];
            NSTextAttachment *attach = [[NSTextAttachment alloc] initWithData:UIImagePNGRepresentation(emojiImage)
                                                                       ofType:(__bridge NSString *)kUTTypePNG];
            
            NSMutableAttributedString *mutableAttrText = [[NSMutableAttributedString alloc] init];
            [mutableAttrText appendAttributedString:[NSAttributedString attributedStringWithAttachment:attach]];
            [mutableAttrText appendAttributedString:[[NSAttributedString alloc] initWithString:@" This is a sentence with custome emoji "]];
            [mutableAttrText appendAttributedString:[NSAttributedString attributedStringWithAttachment:attach]];
            [mutableAttrText appendAttributedString:[[NSAttributedString alloc] initWithString:@", enjoy! xxxx eeea eea ega a ee ae33sss"]];
            [mutableAttrText appendAttributedString:[NSAttributedString attributedStringWithAttachment:attach]];
            [self ensureFont:[UIFont systemFontOfSize:16.0f] forAttributedText:mutableAttrText];
            
            [self.toolbar.contentView.textView.textStorage appendAttributedString:mutableAttrText];
            [self.toolbar toggleSendButtonEnabled];  // change text view programmatically
        } break;
            
        case 5: {
            JSQAudioItem *audioItem = [[JSQAudioItem alloc] initWithDuration:arc4random_uniform(90)];
            JSQMessage *voiceMessage = [[JSQMessage alloc] initWithSenderId:self.senderId senderDisplayName:self.senderDisplayName date:[NSDate date] audio:audioItem];
            [self.demoData.messages addObject:voiceMessage];
            [self finishSendingMessage];
        } break;
        
        case 6: {
            JSQFileItem *fileItem = [[JSQFileItem alloc] initWithFileName:@"Fifty degree dark.pdf" bytes:12568478];
            JSQMessage *fileMessage = [[JSQMessage alloc] initWithSenderId:self.senderId senderDisplayName:self.senderDisplayName date:[NSDate date] file:fileItem];
            [self.demoData.messages addObject:fileMessage];
            [self finishSendingMessage];
        } break;
        default: break;
    }
}

- (void)ensureFont:(UIFont *)font forAttributedText:(NSMutableAttributedString *)attributedText
{
    NSParameterAssert(font);
    NSParameterAssert(attributedText);
    
    NSRange range = NSMakeRange(0, [attributedText length]);
    [attributedText removeAttribute:@"NSOriginalFont" range:range];
    [attributedText addAttribute:NSFontAttributeName value:font range:range];
}


#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.demoData.messages objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.demoData.outgoingBubbleImageData;
    }
    
    return self.demoData.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */
    
    /**
     *  Return your previously created avatar image data objects.
     *
     *  Note: these the avatars will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        if (![NSUserDefaults outgoingAvatarSetting]) {
            return nil;
        }
    }
    else {
        if (![NSUserDefaults incomingAvatarSetting]) {
            return nil;
        }
    }
    
    
    return [self.demoData.avatars objectForKey:message.senderId];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.demoData.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.demoData.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    JSQMessage *msg = [self.demoData.messages objectAtIndex:indexPath.item];
    
    if (JSQMessageDataTypeText == msg.messageType) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}



#pragma mark - JSQMessages collection view Delegate

- (void)collectionView:(JSQMessagesCollectionView *)collectionView willDisplayingCell:(JSQMessagesCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<JSQMessageData> messageItem = [self collectionView:collectionView messageDataForItemAtIndexPath:indexPath];
    
    BOOL isOutgoing = [messageItem senderId] == self.senderId;
    
    // view will appear: enter STATE MACHINE
    // STATE1: render view
    // STATE1 -> STATE2: if view visible, enter STATE MACHINE
    
    // config cell
    switch ([messageItem messageType]) {
        case JSQMessageDataTypeText:
            // text status: received/sent, sending, sending failure
            // 1. sending(outgoing message): show progress. hide failure mark.
            // 2. sending failure:(outgoing message): hide progress. show failure mark.
            // 3. received/sent: hide progress, failure mark(outgoing).
            // 4. user tap under status 'sending failure': ask user to confirm resending message.
            break;
        case JSQMessageDataTypeImage: {
            // image status: not downloaded/uploaded, downloading/uploading, downloaded/uploaded, uploading failure.
            // 1. not downloade/uploaded: hide progress. hide failure mark. trigger downloading.
            // 2. downloading/uploading: show progress. hide failure mark.
            // 3. downloaded/uploaded: hide progress. hide failure mark. lazily load image from cache.
            // 4. uploading failure(outgoing message): hide progress. show failure mark.
            // 5. user tap under status 'not downloaded': trigger downloading.
            // 6. user tap under status 'uploading failure': ask user to confirm resending message.
        } break;
        case JSQMessageDataTypeVideo:
            // same as image message
            break;
        case JSQMessageDataTypeAudio: {
            // audio status: not downloaded/uploaded, downloading/uploading, uploading failure, not yet played, playing, played
            // 1. not downloaded/uploaded: hide animate, duration label, play mark. hide progress, failure mark. trigger downloading.
            // 2. downloading/uploading: hide animate, duration label, play mark. show progress. hide failure mark.
            // 3. uploading failure(outgoing message): hide animate, duration label, play mark. hide progress. show failure mark.
            // 3. not yet played: show animate, duration label, play mark(incoming message). hide progress. hide failure mark.
            // 4. playing: start animating. hide play mark, progress, failure mark.
            // 5. played: stop animating. hide play mark, progress, failure mark.
            // 6. user tap under status 'not yet played', 'played': play current audio, stop playing other audio.
            // 7. user tap under status 'playing': stop playing current audio.
            // 9. user tap under status 'not downloaded': trigger downloading.
            // 10. user tap under status 'uploading failure': ask user to confirm resending message.
        } break;
        case JSQMessageDataTypeFile:
            // file status: not downloaded/uploaded, downloading/uploading, uploading failure.
            // 1. not downloade/uploaded: hide progress. hide failure mark. lazily load icon from cache. trigger downloading.
            // 2. downloading/uploading: show progress. hide failure mark. lazily load icon from cache.
            // 3. downloaded/uploaded: hide progress. hide failure mark. lazily load icon from cache.
            // 4. uploading failure(outgoing message): hide progress. show failure mark. lazily load icon from cache.
            // 5. user tap under status 'not downloaded': trigger downloading.
            // 6. user tap under status 'uploading failure': ask user to confirm resending message.
            break;
        default:
            break;
    }
    
}

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [self.demoData.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.demoData.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped message bubble!");
    
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}

#pragma mark - input toolbar delegate

- (void)messagesInputToolbar:(JSQMessagesInputToolbarEx *)toolbar didPressLeftBarButton:(UIButton *)sender
{
    if (toolbar.sendButtonOnRight) {
        [self didPressAccessoryButton:sender];
    }
    else {
        [self didPressSendButton:sender
       withMessageAttributedText:[self jsq_currentlyComposedMessageAttributedText]
                        senderId:self.senderId
               senderDisplayName:self.senderDisplayName
                            date:[NSDate date]];
    }
}

- (void)messagesInputToolbar:(JSQMessagesInputToolbarEx *)toolbar didPressRightBarButton:(UIButton *)sender
{
    if (toolbar.sendButtonOnRight) {
        [self didPressSendButton:sender
       withMessageAttributedText:[self jsq_currentlyComposedMessageAttributedText]
                        senderId:self.senderId
               senderDisplayName:self.senderDisplayName
                            date:[NSDate date]];
    }
    else {
        [self didPressAccessoryButton:sender];
    }
}

- (NSAttributedString *)jsq_currentlyComposedMessageAttributedText
{
    //  add a space to accept any auto-correct suggestions
    NSMutableAttributedString *editor = self.toolbar.contentView.textView.textStorage;
    [editor appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    [editor deleteCharactersInRange:NSMakeRange([editor length] - 1, 1)];
    return editor;
}

@end
