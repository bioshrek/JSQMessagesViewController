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

#import "SKMessage.h"

#import "SKMessagesCollectionViewCellOutgoing.h"

#import "SKMediaViewIncoming.h"
#import "SKMediaViewOutgoing.h"

#import "SKPhotoMediaItem.h"
#import "SKVideoMediaItem.h"

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
    // register nib for media view
    [self.collectionView registerNib:[SKMediaViewIncoming nib]
     forMediaViewWithReuseIdentifier:[SKMediaViewIncoming reuseIdentifier]];
    [self.collectionView registerNib:[SKMediaViewOutgoing nib]
     forMediaViewWithReuseIdentifier:[SKMediaViewOutgoing reuseIdentifier]];
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
}



#pragma mark - Actions

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
    SKMessage *copyMessage = [[self.demoData.messages lastObject] copy];
    
    if (!copyMessage) {
        NSString *uuid = [[NSUUID UUID] UUIDString];
        copyMessage = [[SKMessage alloc] initWithSenderId:kJSQDemoAvatarIdJobs
                                        senderDisplayName:kJSQDemoAvatarDisplayNameJobs
                                                     date:[NSDate date]
                                           attributedText:[[NSAttributedString alloc] initWithString:@"First received!"]
                                                     uuid:uuid
                                                    state:SKMessageStateReceived];
    }
    
    /**
     *  Allow typing indicator to show
     */
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSMutableArray *userIds = [[self.demoData.users allKeys] mutableCopy];
        [userIds removeObject:self.senderId];
        NSString *randomUserId = userIds[arc4random_uniform((int)[userIds count])];
        
        SKMessage *newMessage = nil;
        NSString *uuid = [[NSUUID UUID] UUIDString];
        
        if (copyMessage.isMediaMessage) {
            /**
             *  Last message was a media message
             */
            SKMediaItem *copyMediaData = copyMessage.media;
            
            if ([copyMediaData isKindOfClass:[SKPhotoMediaItem class]]) {
                newMessage = [self.demoData createPhotoMessageWithUUID:uuid senderId:randomUserId senderDisplayName:self.demoData.users[randomUserId]];
            }
            else if ([copyMediaData isKindOfClass:[SKVideoMediaItem class]]) {
                newMessage = [self.demoData createVideoMediaMessageWithUUID:uuid senderId:randomUserId senderDisplayName:self.demoData.users[randomUserId]];
            }
            else {
                NSLog(@"%s error: unrecognized media item", __PRETTY_FUNCTION__);
            }
            newMessage.state = SKMessageStateReceived;
            newMessage.media.mediaState = SKMessageMediaStateToBeDownloaded;
        }
        else {
            /**
             *  Last message was a text message
             */
            newMessage = [[SKMessage alloc] initWithSenderId:randomUserId
                                           senderDisplayName:self.demoData.users[randomUserId]
                                                        date:[NSDate date]
                                              attributedText:copyMessage.attributedText
                                                        uuid:uuid
                                                       state:SKMessageStateReceived];
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
        
        
        if (newMessage.isMediaMessage) {
            /**
             *  Simulate "downloading" media
             */
            [self receiveMediaMessageWithProgressTotalUnitCount:10 completedUnitCount:1 uuid:newMessage.uuid];
        }
        
    });
}

- (void)receiveMediaMessageWithProgressTotalUnitCount:(NSUInteger)totalUnitCount
                                   completedUnitCount:(NSUInteger)completedUnitCount
                                                 uuid:(NSString *)uuid
{
    __weak DemoMessagesViewController *weakSelf = self;
    
    if (completedUnitCount <= totalUnitCount) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // update sending progress
            NSInteger index = NSNotFound;
            for (NSInteger i = 0; i < [self.demoData.messages count]; i++) {
                @autoreleasepool {
                    SKMessage *message = [weakSelf.demoData.messages objectAtIndex:i];
                    if ([message.uuid isEqualToString:uuid]) {
                        index = i;
                        break;
                    }
                }
            }
            
            if (NSNotFound == index) return;
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            NSProgress *progress = [NSProgress progressWithTotalUnitCount:totalUnitCount];
            progress.completedUnitCount = completedUnitCount;
            [self updateMediaState:SKMessageMediaStateDownloading forItemAtIndexPath:indexPath];
            [self updateMediaProgress:progress forItemAtIndexPath:indexPath];
            
            [weakSelf receiveMediaMessageWithProgressTotalUnitCount:totalUnitCount completedUnitCount:(completedUnitCount + 1) uuid:uuid];
        });
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // update sending progress
            NSInteger index = NSNotFound;
            for (NSInteger i = 0; i < [self.demoData.messages count]; i++) {
                @autoreleasepool {
                    SKMessage *message = [weakSelf.demoData.messages objectAtIndex:i];
                    if ([message.uuid isEqualToString:uuid]) {
                        index = i;
                        break;
                    }
                }
            }
            
            if (NSNotFound == index) return;
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self updateMediaState:SKMessageMediaStateDownloaded forItemAtIndexPath:indexPath];
        });
    }
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

    NSString *uuid = [[NSUUID UUID] UUIDString];
    SKMessage *message = [[SKMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          attributedText:attributedText
                                                        uuid:uuid
                                                       state:SKMessageStateSending];
    [self sendTextMessage:message finalState:SKMessageStateSent];
}

- (void)sendTextMessage:(SKMessage *)textMessage finalState:(SKMessageState)state
{
    [self.demoData.messages addObject:textMessage];
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    [self finishSendingMessage];
    
    // sending status change
    __weak DemoMessagesViewController *weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // update sending progress
        NSInteger index = NSNotFound;
        for (NSInteger i = 0; i < [self.demoData.messages count]; i++) {
            @autoreleasepool {
                SKMessage *message = [weakSelf.demoData.messages objectAtIndex:i];
                if ([message.uuid isEqualToString:[textMessage uuid]]) {
                    index = i;
                    break;
                }
            }
        }
        
        if (NSNotFound == index) return;
        
        [self updateMessageState:state forItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    });
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Media messages"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Send photo", @"Send photo failed", @"Send video", @"Send video failed", @"Send text emoji mixture", @"Input text emoji mixture", @"Send text failed", nil];
    
    [sheet showFromToolbar:self.inputToolbar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    switch (buttonIndex) {
        case 0: {  // send photo
            NSString *uuid = [[NSUUID UUID] UUIDString];
            SKMessage *photoMessage = [self.demoData createPhotoMessageWithUUID:uuid senderId:self.senderId senderDisplayName:self.senderDisplayName];
            [self sendMediaMessage:photoMessage failed:NO];
        } break;
        
        case 1: {  // send photo failed
            NSString *uuid = [[NSUUID UUID] UUIDString];
            SKMessage *photoMessage = [self.demoData createPhotoMessageWithUUID:uuid senderId:self.senderId senderDisplayName:self.senderDisplayName];
            [self sendMediaMessage:photoMessage failed:YES];
        } break;
            
        case 2: {  // send video message
            NSString *uuid = [[NSUUID UUID] UUIDString];
            SKMessage *videoMessage = [self.demoData createVideoMediaMessageWithUUID:uuid senderId:self.senderId senderDisplayName:self.senderDisplayName];
            [self sendMediaMessage:videoMessage failed:NO];
        } break;
            
        case 3: {  // send video failed
            NSString *uuid = [[NSUUID UUID] UUIDString];
            SKMessage *videoMessage = [self.demoData createVideoMediaMessageWithUUID:uuid senderId:self.senderId senderDisplayName:self.senderDisplayName];
            [self sendMediaMessage:videoMessage failed:YES];
        } break;
            
        case 4: {  // send emoji text
            UIImage *emojiImage = [UIImage imageNamed:@"smiley"];
            NSTextAttachment *attach = [[NSTextAttachment alloc] initWithData:UIImagePNGRepresentation(emojiImage)
                                                                       ofType:(__bridge NSString *)kUTTypePNG];
            
            NSMutableAttributedString *mutableAttrText = [[NSMutableAttributedString alloc] init];
            [mutableAttrText appendAttributedString:[NSAttributedString attributedStringWithAttachment:attach]];
            [mutableAttrText appendAttributedString:[[NSAttributedString alloc] initWithString:@" This is a sentence with custome emoji "]];
            [mutableAttrText appendAttributedString:[NSAttributedString attributedStringWithAttachment:attach]];
            [mutableAttrText appendAttributedString:[[NSAttributedString alloc] initWithString:@", enjoy! xxxx eeea eea ega a ee ae33sss"]];
            [mutableAttrText appendAttributedString:[NSAttributedString attributedStringWithAttachment:attach]];
            [mutableAttrText appendAttributedString:[NSAttributedString attributedStringWithAttachment:attach]];
            [mutableAttrText appendAttributedString:[[NSAttributedString alloc] initWithString:@", enjoy! xxxx eeea eea ega a ee ae33sss"]];
            [mutableAttrText appendAttributedString:[NSAttributedString attributedStringWithAttachment:attach]];
            [mutableAttrText appendAttributedString:[[NSAttributedString alloc] initWithString:@", enjoy! xxxx eeea eea ega a ee ae33sss"]];
            [mutableAttrText appendAttributedString:[NSAttributedString attributedStringWithAttachment:attach]];
            
            NSString *uuid = [[NSUUID UUID] UUIDString];
            SKMessage *message = [[SKMessage alloc] initWithSenderId:self.senderId
                                                   senderDisplayName:self.senderDisplayName
                                                                date:[NSDate distantFuture]
                                                      attributedText:mutableAttrText
                                                                uuid:uuid
                                                               state:SKMessageStateSending];
            [self sendTextMessage:message finalState:SKMessageStateSent];
        } break;
            
        case 5: {  // input emoji text
            UIImage *emojiImage = [UIImage imageNamed:@"smiley"];
            NSTextAttachment *attach = [[NSTextAttachment alloc] initWithData:UIImagePNGRepresentation(emojiImage)
                                                                       ofType:(__bridge NSString *)kUTTypePNG];
            
            NSMutableAttributedString *mutableAttrText = [[NSMutableAttributedString alloc] init];
            [mutableAttrText appendAttributedString:[NSAttributedString attributedStringWithAttachment:attach]];
            [mutableAttrText appendAttributedString:[[NSAttributedString alloc] initWithString:@" This is a sentence with custome emoji "]];
            [mutableAttrText appendAttributedString:[NSAttributedString attributedStringWithAttachment:attach]];
            [mutableAttrText appendAttributedString:[[NSAttributedString alloc] initWithString:@", enjoy! xxxx eeea eea ega a ee ae33sss"]];
            [mutableAttrText appendAttributedString:[NSAttributedString attributedStringWithAttachment:attach]];
            
            [self.inputToolbar.contentView.textView.textStorage appendAttributedString:mutableAttrText];
            [self.inputToolbar toggleSendButtonEnabled];  // change text view programmatically
        } break;
        
        case 6: {  // send text failed
            NSAttributedString *text = [[NSAttributedString alloc] initWithString:@"Bilibili bon si wa."];
            NSString *uuid = [[NSUUID UUID] UUIDString];
            SKMessage *message = [[SKMessage alloc] initWithSenderId:self.senderId
                                                   senderDisplayName:self.senderDisplayName
                                                                date:[NSDate distantFuture]
                                                      attributedText:text
                                                                uuid:uuid
                                                               state:SKMessageStateSending];
            [self sendTextMessage:message finalState:SKMessageStateSendingFailure];
        } break;
    }
}

- (void)sendMediaMessage:(SKMessage *)mediaMessage failed:(BOOL)failed
{
    NSString *uuid = [mediaMessage uuid];
    
    [self.demoData.messages addObject:mediaMessage];
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    [self finishSendingMessage];
    
    // sending progress change
    mediaMessage.media.progress.totalUnitCount = 10;
    [self sendMediaMessageWithProgressTotalUnitCount:10 completedUnitCount:1 uuid:uuid failed:failed];
}

- (void)sendMediaMessageWithProgressTotalUnitCount:(NSUInteger)totalUnitCount completedUnitCount:(NSUInteger)completedUnitCount uuid:(NSString *)uuid failed:(BOOL)failed
{
    __weak DemoMessagesViewController *weakSelf = self;
    
    if (completedUnitCount <= totalUnitCount) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // update sending progress
            NSInteger index = NSNotFound;
            for (NSInteger i = 0; i < [self.demoData.messages count]; i++) {
                @autoreleasepool {
                    SKMessage *message = [weakSelf.demoData.messages objectAtIndex:i];
                    if ([message.uuid isEqualToString:uuid]) {
                        index = i;
                        break;
                    }
                }
            }
            
            if (NSNotFound == index) return;
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            NSProgress *progress = [NSProgress progressWithTotalUnitCount:totalUnitCount];
            progress.completedUnitCount = completedUnitCount;
            [self updateMessageState:SKMessageStateSending forItemAtIndexPath:indexPath];
            [self updateMediaState:SKMessageMediaStateUploading forItemAtIndexPath:indexPath];
            [self updateMediaProgress:progress forItemAtIndexPath:indexPath];
            
            [weakSelf sendMediaMessageWithProgressTotalUnitCount:totalUnitCount completedUnitCount:(completedUnitCount + 1) uuid:uuid failed:failed];
        });
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // update sending progress
            NSInteger index = NSNotFound;
            for (NSInteger i = 0; i < [self.demoData.messages count]; i++) {
                @autoreleasepool {
                    SKMessage *message = [weakSelf.demoData.messages objectAtIndex:i];
                    if ([message.uuid isEqualToString:uuid]) {
                        index = i;
                        break;
                    }
                }
            }
            
            if (NSNotFound == index) return;
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            SKMessageState finalMessageState = failed ? SKMessageStateSendingFailure : SKMessageStateSent;
            SKMessageMediaState finalMediaState = failed ? SKMessageMediaStateUploadingFailure : SKMessageMediaStateUploaded;
            [self updateMessageState:finalMessageState forItemAtIndexPath:indexPath];
            [self updateMediaState:finalMediaState forItemAtIndexPath:indexPath];
        });
    }
}

#pragma mark - SKMessages CollectionView DataSource

// sender id
- (NSString *)collectionView:(JSQMessagesCollectionView *)collectionView senderIdForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SKMessage *message = [self.demoData.messages objectAtIndex:indexPath.row];
    return message.senderId;
}

// sender display name
- (NSString *)collectionView:(JSQMessagesCollectionView *)collectionView senderDisplayNameForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SKMessage *message = [self.demoData.messages objectAtIndex:indexPath.row];
    return message.senderDisplayName;
}

// date
- (NSDate *)collectionView:(JSQMessagesCollectionView *)collectionView dateForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SKMessage *message = [self.demoData.messages objectAtIndex:indexPath.row];
    return message.date;
}

// hash
- (NSUInteger)collectionView:(JSQMessagesCollectionView *)collectionView hashForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SKMessage *message = [self.demoData.messages objectAtIndex:indexPath.row];
    return message.hash;
}

// is media message
- (BOOL)collectionView:(JSQMessagesCollectionView *)collectionView isMediaMessageForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SKMessage *message = [self.demoData.messages objectAtIndex:indexPath.row];
    return message.isMediaMessage;
}

// attributed text
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SKMessage *message = [self.demoData.messages objectAtIndex:indexPath.row];
    return message.attributedText;
}

// message state
- (SKMessageState)collectionView:(JSQMessagesCollectionView *)collectionView messageStateForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SKMessage *message = [self.demoData.messages objectAtIndex:indexPath.row];
    SKMessageState state = message.state;
    return state;
}

// update message state
- (void)collectionView:(JSQMessagesCollectionView *)collectionView updateMessageState:(SKMessageState)textMessageState forItemAtIndexPath:(NSIndexPath *)indexPath
{
    SKMessage *message = [self.demoData.messages objectAtIndex:indexPath.row];
    if (nil != message) {
        message.state = textMessageState;
    }
}

// media view display size
- (CGSize)collectionView:(JSQMessagesCollectionView *)collectionView mediaViewDisplaySizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SKMessage *message = [self.demoData.messages objectAtIndex:indexPath.row];
    return message.media.mediaDisplaySize;
}

// media hash
- (NSUInteger)collectionView:(JSQMessagesCollectionView *)collectionView mediaHashForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SKMessage *message = [self.demoData.messages objectAtIndex:indexPath.row];
    return [[message media] hash];
}

// media progress
- (NSProgress *)collectionView:(JSQMessagesCollectionView *)collectionView mediaProgressForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SKMessage *message = [self.demoData.messages objectAtIndex:indexPath.row];
    return message.media.progress;
}

// update media progress
- (void)collectionView:(JSQMessagesCollectionView *)collectionView updateMediaProgress:(NSProgress *)progress forItemAtIndexPath:(NSIndexPath *)indexPath
{
    SKMessage *message = [self.demoData.messages objectAtIndex:indexPath.row];
    message.media.progress = progress;
}

// media title
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView mediaNameAttributedTextForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SKMessage *message = [self.demoData.messages objectAtIndex:indexPath.row];
    return [[NSAttributedString alloc] initWithString:message.media.mediaTitle
                                           attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16.0f]}];
}

// media size
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView mediaSizeAttributedTextForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SKMessage *message = [self.demoData.messages objectAtIndex:indexPath.row];
    NSString *mediaSize = [NSByteCountFormatter stringFromByteCount:message.media.mediaSize countStyle:NSByteCountFormatterCountStyleFile];
    return [[NSAttributedString alloc] initWithString:mediaSize
                                           attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12.0f]}];
}

// should show media title, size for states
- (BOOL)collectionView:(JSQMessagesCollectionView *)collectionView shouldShowMediaTextInfoForMediaState:(SKMessageMediaState)mediaState forItemAtIndexPath:(NSIndexPath *)indexPath
{
    SKMessage *message = [self.demoData.messages objectAtIndex:indexPath.row];
    return [message.media shouldShowMediaTextInfoForMediaState:mediaState];
}

// media icon for states
- (UIImage *)collectionView:(JSQMessagesCollectionView *)collectionView mediaIconForMediaState:(SKMessageMediaState)mediaState forItemAtIndexPath:(NSIndexPath *)indexPath
{
    SKMessage *message = [self.demoData.messages objectAtIndex:indexPath.row];
    return [message.media mediaIconForMediaState:mediaState];
}

// media description for states
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView mediaDescriptionForMediaState:(SKMessageMediaState)mediaState forItemAtIndexPath:(NSIndexPath *)indexPath
{
    SKMessage *message = [self.demoData.messages objectAtIndex:indexPath.row];
    NSString *description = [message.media mediaDescriptionForMediaState:mediaState];
    return description ?
        [[NSAttributedString alloc] initWithString:description
                                        attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14.0f]}] :
        nil;
}

// media thumbnail
- (UIImage *)collectionView:(JSQMessagesCollectionView *)collectionView thumbnailForMediaState:(SKMessageMediaState)mediaState forItemAtIndexPath:(NSIndexPath *)indexPath
{
    SKMessage *message = [self.demoData.messages objectAtIndex:indexPath.row];
    return [message.media thumbnailForMediaState:mediaState];
}

// media state
- (SKMessageMediaState)collectionView:(JSQMessagesCollectionView *)collectionView mediaStateForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SKMessage *message = [self.demoData.messages objectAtIndex:indexPath.row];
    return message.media.mediaState;
}

// update media state
- (void)collectionView:(JSQMessagesCollectionView *)collectionView updateMediaState:(SKMessageMediaState)mediaState forItemAtIndexPath:(NSIndexPath *)indexPath
{
    SKMessage *message = [self.demoData.messages objectAtIndex:indexPath.row];
    message.media.mediaState = mediaState;
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    SKMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
    
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
    SKMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
    
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
        SKMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    SKMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        SKMessage *previousMessage = [self.demoData.messages objectAtIndex:indexPath.item - 1];
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
    
    if (!msg.isMediaMessage) {
        
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



#pragma mark - JSQMessages collection view flow layout delegate

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

@end
