//
//  FlickerManager.h
//  FlickrGallery
//
//  Created by Javier Delgado on 30/08/13.
//  Copyright (c) 2013 Javier Delgado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlickrPhoto.h"

@protocol jsonDownloadedDelegate <NSObject>
- (void)jsonFromFlickrFinished:(NSArray *)flickrPhotos;
@end

typedef void (^FlickrDownloadCompletionBlock)(NSArray *results, NSError *error);
typedef void (^FlickrPhotoCompletionBlock)(UIImage *photoImage, NSError *error);

@interface FlickrManager : NSObject

@property (nonatomic, weak) id<jsonDownloadedDelegate> delegate;

+ (id)sharedManager;
- (void)startDownloadPublicImages;

@end
