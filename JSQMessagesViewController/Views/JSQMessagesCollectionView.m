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

#import "JSQMessagesCollectionView.h"

#import "JSQMessagesCollectionViewFlowLayout.h"
#import "JSQMessagesCollectionViewCellIncoming.h"
#import "JSQMessagesCollectionViewCellOutgoing.h"

#import "JSQMessagesTypingIndicatorFooterView.h"
#import "JSQMessagesLoadEarlierHeaderView.h"

#import "UIColor+JSQMessages.h"


@interface JSQMessagesCollectionView () <JSQMessagesLoadEarlierHeaderViewDelegate>

- (void)jsq_configureCollectionView;

// Map<ReusableIdentifier, Map<layout, List<ReusableMediaView>>>
@property (nonatomic, strong) NSMutableDictionary *mediaViewReusableQueue;

// Map<identifier, nib>
@property (nonatomic, strong) NSMutableDictionary *mediaViewNibMap;

// Map<identifier, class>
@property (nonatomic, strong) NSMutableDictionary *mediaViewClassMap;

@end


@implementation JSQMessagesCollectionView

#pragma mark - Initialization

- (void)jsq_configureCollectionView
{
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.backgroundColor = [UIColor whiteColor];
    self.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    self.alwaysBounceVertical = YES;
    self.bounces = YES;
    
    [self registerNib:[JSQMessagesCollectionViewCellIncoming nib]
          forCellWithReuseIdentifier:[JSQMessagesCollectionViewCellIncoming cellReuseIdentifier]];
    
    [self registerNib:[JSQMessagesCollectionViewCellOutgoing nib]
          forCellWithReuseIdentifier:[JSQMessagesCollectionViewCellOutgoing cellReuseIdentifier]];
    
    [self registerNib:[JSQMessagesCollectionViewCellIncoming nib]
          forCellWithReuseIdentifier:[JSQMessagesCollectionViewCellIncoming mediaCellReuseIdentifier]];
    
    [self registerNib:[JSQMessagesCollectionViewCellOutgoing nib]
          forCellWithReuseIdentifier:[JSQMessagesCollectionViewCellOutgoing mediaCellReuseIdentifier]];
    
    [self registerNib:[JSQMessagesTypingIndicatorFooterView nib]
          forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
          withReuseIdentifier:[JSQMessagesTypingIndicatorFooterView footerReuseIdentifier]];
    
    [self registerNib:[JSQMessagesLoadEarlierHeaderView nib]
          forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
          withReuseIdentifier:[JSQMessagesLoadEarlierHeaderView headerReuseIdentifier]];

    _typingIndicatorDisplaysOnLeft = YES;
    _typingIndicatorMessageBubbleColor = [UIColor jsq_messageBubbleLightGrayColor];
    _typingIndicatorEllipsisColor = [_typingIndicatorMessageBubbleColor jsq_colorByDarkeningColorWithValue:0.3f];

    _loadEarlierMessagesHeaderTextColor = [UIColor jsq_messageBubbleBlueColor];
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self jsq_configureCollectionView];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self jsq_configureCollectionView];
}

#pragma mark - getter

- (NSMutableDictionary *)mediaViewReusableQueue
{
    if (!_mediaViewReusableQueue) {
        _mediaViewReusableQueue = [[NSMutableDictionary alloc] init];
    }
    return _mediaViewReusableQueue;
}

- (NSMutableDictionary *)mediaViewNibMap
{
    if (!_mediaViewNibMap) {
        _mediaViewNibMap = [[NSMutableDictionary alloc] init];
    }
    return _mediaViewNibMap;
}

- (NSMutableDictionary *)mediaViewClassMap
{
    if (!_mediaViewClassMap) {
        _mediaViewClassMap = [[NSMutableDictionary alloc] init];
    }
    return _mediaViewClassMap;
}

#pragma mark - Typing indicator

- (JSQMessagesTypingIndicatorFooterView *)dequeueTypingIndicatorFooterViewForIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesTypingIndicatorFooterView *footerView = [super dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                                 withReuseIdentifier:[JSQMessagesTypingIndicatorFooterView footerReuseIdentifier]
                                                                                        forIndexPath:indexPath];

    [footerView configureWithEllipsisColor:self.typingIndicatorEllipsisColor
                        messageBubbleColor:self.typingIndicatorMessageBubbleColor
                       shouldDisplayOnLeft:self.typingIndicatorDisplaysOnLeft
                         forCollectionView:self];

    return footerView;
}

#pragma mark - Load earlier messages header

- (JSQMessagesLoadEarlierHeaderView *)dequeueLoadEarlierMessagesViewHeaderForIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesLoadEarlierHeaderView *headerView = [super dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                             withReuseIdentifier:[JSQMessagesLoadEarlierHeaderView headerReuseIdentifier]
                                                                                    forIndexPath:indexPath];

    headerView.loadButton.tintColor = self.loadEarlierMessagesHeaderTextColor;
    headerView.delegate = self;

    return headerView;
}

#pragma mark - Load earlier messages header delegate

- (void)headerView:(JSQMessagesLoadEarlierHeaderView *)headerView didPressLoadButton:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(collectionView:header:didTapLoadEarlierMessagesButton:)]) {
        [self.delegate collectionView:self header:headerView didTapLoadEarlierMessagesButton:sender];
    }
}

#pragma mark - Messages collection view cell delegate

- (void)messagesCollectionViewCellDidTapAvatar:(JSQMessagesCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self indexPathForCell:cell];
    if (indexPath == nil) {
        return;
    }
    
    [self.delegate collectionView:self
            didTapAvatarImageView:cell.avatarImageView
                      atIndexPath:indexPath];
}

- (void)messagesCollectionViewCellDidTapMessageBubble:(JSQMessagesCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self indexPathForCell:cell];
    if (indexPath == nil) {
        return;
    }
    
    [self.delegate collectionView:self didTapMessageBubbleAtIndexPath:indexPath];
}

- (void)messagesCollectionViewCellDidTapCell:(JSQMessagesCollectionViewCell *)cell atPosition:(CGPoint)position
{
    NSIndexPath *indexPath = [self indexPathForCell:cell];
    if (indexPath == nil) {
        return;
    }
    
    [self.delegate collectionView:self
            didTapCellAtIndexPath:indexPath
                    touchLocation:position];
}

#pragma mark - reuse media view

- (void)registerNib:(UINib *)nib forMediaViewWithReuseIdentifier:(NSString *)identifier
{
    NSParameterAssert(nil != nib && [identifier length]);
    
    [self.mediaViewNibMap setValue:nib forKey:identifier];
}

- (void)registerClass:(Class)cellClass forMediaViewWithReuseIdentifier:(NSString *)identifier
{
    NSParameterAssert(nil != cellClass && [identifier length]);
    
    [self.mediaViewClassMap setValue:cellClass forKey:identifier];
}

- (SKMediaView *)createMediaViewWithReuseIdentifier:(NSString *)identifier withFrame:(CGRect)frame
{
    // nib, or class
    
    UINib *nib = [self.mediaViewNibMap valueForKey:identifier];
    Class class = [self.mediaViewClassMap valueForKey:identifier];
    
    SKMediaView *mediaView = nil;
    if (nib) {
        mediaView = [[nib instantiateWithOwner:nil options:kNilOptions] firstObject];
    } else {
        if (class) {
            mediaView = [(SKMediaView *)[class alloc] initWithFrame:frame];
        }
    }
    
    return mediaView;
}

- (SKMediaView *)dequeueReusableMediaViewWithReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath
{
    id<JSQMessagesCollectionViewDataSource> messageDataSource = self.dataSource;
    
    CGSize mediaViewDisplaySize = [messageDataSource collectionView:self mediaViewDisplaySizeForItemAtIndexPath:indexPath];
    SKMediaView *mediaView = [self dqueueMediaViewForMediaViewDisplaySize:mediaViewDisplaySize inMediaViewReusableQueue:[self mediaViewReusableQueueForReuseIdentifier:identifier]];
    if (mediaView) {  // reusable media view available
        [mediaView prepareForReuse];
    } else {  // new instance
        mediaView = [self createMediaViewWithReuseIdentifier:identifier withFrame:CGRectMake(0, 0, mediaViewDisplaySize.width, mediaViewDisplaySize.height)];
    }
    
    return mediaView;
}

- (NSMutableDictionary *)mediaViewReusableQueueForReuseIdentifier:(NSString *)identifier
{
    NSMutableDictionary *mediaViewReusableQueue = [self.mediaViewReusableQueue valueForKey:identifier];
    if (nil == mediaViewReusableQueue) {
        mediaViewReusableQueue = [[NSMutableDictionary alloc] init];
        [self.mediaViewReusableQueue setValue:mediaViewReusableQueue forKey:identifier];
    }
    
    return mediaViewReusableQueue;
}

// Map<size, List<mediaView>>
- (SKMediaView *)dqueueMediaViewForMediaViewDisplaySize:(CGSize)mediaViewDisplaySize
                                      inMediaViewReusableQueue:(NSMutableDictionary *)mediaViewReusableQueue
{
    NSParameterAssert(nil != mediaViewReusableQueue);
    
    NSValue *sizeKey = [NSValue valueWithCGSize:mediaViewDisplaySize];
    NSMutableArray *mediaViews = [mediaViewReusableQueue objectForKey:sizeKey];
    if (nil == mediaViews) {
        mediaViews = [[NSMutableArray alloc] init];
        [mediaViewReusableQueue setObject:mediaViews forKey:sizeKey];
    }
    
    SKMediaView *mediaView = nil;
    if ([mediaViews count]) {
        mediaView = [mediaViews firstObject];
        [mediaViews removeObjectAtIndex:0];
    }
    
    return mediaView;
}

// Map<size, List<mediaView>>
- (void)enqueueMediaView:(UICollectionReusableView *)mediaView inMediaViewReusableQueue:(NSMutableDictionary *)mediaViewReusableQueue
{
    NSParameterAssert(nil != mediaView && nil != mediaViewReusableQueue);
    
    CGSize mediaViewDisplaySize = mediaView.bounds.size;
    
    NSValue *sizeKey = [NSValue valueWithCGSize:mediaViewDisplaySize];
    NSMutableArray *mediaViews = [mediaViewReusableQueue objectForKey:sizeKey];
    if (nil == mediaViews) {
        mediaViews = [[NSMutableArray alloc] init];
        [mediaViewReusableQueue setObject:mediaViews forKey:sizeKey];
    }
    
    [mediaViews addObject:mediaView];
}

- (void)recycleMediaView:(SKMediaView *)mediaView
{
    if (nil == mediaView) {
        return;
    }
    
    [self enqueueMediaView:mediaView inMediaViewReusableQueue:[self mediaViewReusableQueueForReuseIdentifier:mediaView.reuseIdentifier]];
}

@end
