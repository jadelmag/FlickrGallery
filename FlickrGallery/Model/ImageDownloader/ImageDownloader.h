//
//  ImageDownloader.h
//  Prueba
//
//  Created by Javier Delgado on 04/07/13.
//  Copyright (c) 2013 Javier Delgado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlickrPhoto.h"

@protocol ImageDownloaderDelegate;

@interface ImageDownloader : NSOperation

@property (nonatomic, weak) id<ImageDownloaderDelegate> delegate;

@property (nonatomic, readonly, strong) NSIndexPath *indexPathInTableView;
@property (nonatomic, readonly, strong) FlickrPhoto *flickrPhotoRecord;

- (id)initWithFlickrPhoto:(FlickrPhoto *)flickrPhoto atIndexPath:(NSIndexPath *)indexPath withDelegate:(id<ImageDownloaderDelegate>)delegate;

@end

@protocol ImageDownloaderDelegate <NSObject>
- (void)imageDownloaderFinished:(ImageDownloader *)downloader;
@end