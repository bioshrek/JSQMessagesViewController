//
//  SKPhotoMediaItem.m
//  JSQMessages
//
//  Created by shrek wang on 1/2/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import "SKPhotoMediaItem.h"

@implementation SKPhotoMediaItem

- (BOOL)shouldShowMediaTextInfoForMediaState:(SKMessageMediaState)mediaState
{
    BOOL shouldShowMediaTextInfo = YES;
    
    switch (mediaState) {
        case SKMessageMediaStateDownloaded:
        case SKMessageMediaStateReviewed:
        case SKMessageMediaStateUploaded:
        {
            shouldShowMediaTextInfo = NO;
        } break;
            
        default:
            break;
    }
    
    return shouldShowMediaTextInfo;
}

- (UIImage *)mediaIconForMediaState:(SKMessageMediaState)mediaState
{
    UIImage *mediaIcon = nil;
    
    switch (mediaState) {
        case SKMessageMediaStateUploadingFailure:
        case SKMessageMediaStateDownloadingFailure: {
            mediaIcon = [UIImage imageNamed:@"message_error"];
        } break;
        default:
            break;
    }
    
    return mediaIcon;
}

- (NSString *)mediaDescriptionForMediaState:(SKMessageMediaState)mediaState
{
    NSString *mediaDescription = nil;
    
    switch (mediaState) {
        case SKMessageMediaStateDownloadingFailure: {
            mediaDescription = @"Downloading failure, try again";
        } break;
        case SKMessageMediaStateUploadingFailure: {
            mediaDescription = @"Uploading failure, try again";
        } break;
        default:
            break;
    }
    
    return mediaDescription;
}

- (UIImage *)thumbnailForMediaState:(SKMessageMediaState)mediaState
{
    /*
    switch (mediaState) {
        case SKMessageMediaStateDownloaded: {
            // TODO:
        } break;
        case SKMessageMediaStateDownloading: {
            // TODO:
        } break;
        case SKMessageMediaStateDownloadingFailure: {
            // TODO:
        } break;
        case SKMessageMediaStateDraft: {
            // TODO:
        } break;
        case SKMessageMediaStateReviewed: {
            // TODO:
        } break;
        case SKMessageMediaStateToBeDownloaded: {
            // TODO:
        } break;
        case SKMessageMediaStateUploaded: {
            // TODO:
        } break;
        case SKMessageMediaStateUploading: {
            // TODO:
        } break;
        case SKMessageMediaStateUploadingFailure: {
            // TODO:
        } break;
        default:
            break;
    }
    */
    
    return self.thumbnail;
}

@end
