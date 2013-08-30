//
//  FlickrPhoto.m
//  FlickrGallery
//
//  Created by Javier Delgado on 30/08/13.
//  Copyright (c) 2013 Javier Delgado. All rights reserved.
//

#import "FlickrPhoto.h"

@implementation FlickrPhoto

- (BOOL)isFailed
{
    return _failed;
}

- (BOOL)hasImage
{
    if (_thumbnail != nil && _largeImage != nil)
        return YES;
    return NO;
}

@end
