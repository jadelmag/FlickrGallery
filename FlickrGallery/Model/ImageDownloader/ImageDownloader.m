//
//  ImageDownloader.m
//  Prueba
//
//  Created by Javier Delgado on 04/07/13.
//  Copyright (c) 2013 Javier Delgado. All rights reserved.
//

#import "ImageDownloader.h"

@interface ImageDownloader ()
@property (nonatomic, readwrite, strong) NSIndexPath *indexPathInTableView;
@property (nonatomic, readwrite, strong) FlickrPhoto *flickrPhotoRecord;
@end

@implementation ImageDownloader

- (id)initWithFlickrPhoto:(FlickrPhoto *)flickrPhoto atIndexPath:(NSIndexPath *)indexPath withDelegate:(id<ImageDownloaderDelegate>)delegate
{
    if (self = [super init]) {
        _flickrPhotoRecord = flickrPhoto;
        _indexPathInTableView = indexPath;
        _delegate = delegate;
    }
    return self;
}

#pragma mark -
#pragma mark - Main operation

- (void)main
{
    @autoreleasepool {
        
        if (self.isCancelled) return;
        NSData *imageDataSmall = [[NSData alloc] initWithContentsOfURL:self.flickrPhotoRecord.thumbnailURL];
        
        if (self.isCancelled) {
            imageDataSmall = nil;
            return;
        }
        
        if (imageDataSmall) {
            UIImage *downloadedImage = [UIImage imageWithData:imageDataSmall];
            self.flickrPhotoRecord.thumbnail = downloadedImage;
            self.flickrPhotoRecord.failed = NO;
        }
        else {
            self.flickrPhotoRecord.failed = YES;
        }
        
        if (self.isCancelled) return;
        NSData *imageDataLarge = [[NSData alloc] initWithContentsOfURL:self.flickrPhotoRecord.largeImageURL];
        
        if (self.isCancelled) {
            imageDataLarge = nil;
            return;
        }
        
        if (imageDataLarge) {
            UIImage *downloadedImage = [UIImage imageWithData:imageDataLarge];
            self.flickrPhotoRecord.largeImage = downloadedImage;
            self.flickrPhotoRecord.failed = NO;
        }
        else {
            self.flickrPhotoRecord.failed = YES;
        }
        
        if (self.isCancelled) return;
        
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(imageDownloaderFinished:) withObject:self waitUntilDone:NO];
    }
}

@end
