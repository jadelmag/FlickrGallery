//
//  ViewController.h
//  FlickrGallery
//
//  Created by Javier Delgado on 30/08/13.
//  Copyright (c) 2013 Javier Delgado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlickrPhoto.h"
#import "FlickrManager.h"
#import "PendingOperations.h"
#import "ImageDownloader.h"
#import "Reachability.h"

@interface ViewController : UITableViewController <ImageDownloaderDelegate, jsonDownloadedDelegate> {
    Reachability *internetReachable;
}

@end
