//
//  FlickrPhoto.h
//  FlickrGallery
//
//  Created by Javier Delgado on 30/08/13.
//  Copyright (c) 2013 Javier Delgado. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlickrPhoto : NSObject

// UIImages
@property(nonatomic,strong) UIImage *thumbnail;
@property(nonatomic,strong) UIImage *largeImage;

// http://www.flickr.com/services/api/flickr.photos.getContactsPublicPhotos.html
// Response
@property (nonatomic) long long idPhoto;
@property (nonatomic, strong) NSString *owner;
@property (nonatomic, strong) NSString *secret;
@property (nonatomic, strong) NSString *title;
@property (nonatomic) int server;
@property (nonatomic) int farm;
@property (nonatomic) BOOL isFamily;
@property (nonatomic) BOOL isFriend;
@property (nonatomic) BOOL isPublic;

// NSURL images
@property (nonatomic, strong) NSURL *thumbnailURL;
@property (nonatomic, strong) NSURL *largeImageURL;
@property (nonatomic, readonly) BOOL hasImage;
@property (nonatomic, getter = isFailed) BOOL failed;

@end
