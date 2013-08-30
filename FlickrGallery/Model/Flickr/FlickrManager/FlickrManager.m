//
//  FlickerManager.m
//  FlickrGallery
//
//  Created by Javier Delgado on 30/08/13.
//  Copyright (c) 2013 Javier Delgado. All rights reserved.
//

#import "FlickrManager.h"

#define kFlickrAPIKey @"15998b27fb6ffec654339aaf0319e20e"
#define kUserID @"29096781@N02"

@implementation FlickrManager

#pragma mark - Singleton

+ (id)sharedManager
{
    static FlickrManager *sharedMyManager = nil;
    @synchronized(self) {
        if (sharedMyManager == nil)
            sharedMyManager = [[self alloc] init];
    }
    return sharedMyManager;
}

#pragma mark - Start Download

- (void)startDownloadPublicImages
{
    [self downloadPublicImagesWithcompletionBlock:^(NSArray *results, NSError *error) {
            [self.delegate jsonFromFlickrFinished:results];
    }];
}

#pragma mark - Search JSON

+ (NSString *)flickrSearchURL
{
    return [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?&method=flickr.people.getPublicPhotos&api_key=%@&user_id=%@&per_page=20&format=json&nojsoncallback=1",kFlickrAPIKey,kUserID];
}

#pragma mark - Download

+ (NSURL *)downloadFlickrPhoto:(FlickrPhoto *)flickrPhoto withSize:(char)size
{
    if (size == 'm')
        return [NSURL URLWithString:[NSString stringWithFormat:@"http://farm%d.staticflickr.com/%d/%lld_%@_m.jpg",flickrPhoto.farm,flickrPhoto.server,flickrPhoto.idPhoto,flickrPhoto.secret]];
    else //if (size == 'b')
        return [NSURL URLWithString:[NSString stringWithFormat:@"http://farm%d.staticflickr.com/%d/%lld_%@_b.jpg",flickrPhoto.farm,flickrPhoto.server,flickrPhoto.idPhoto,flickrPhoto.secret]];
}

- (void)downloadPublicImagesWithcompletionBlock:(FlickrDownloadCompletionBlock)completionBlock
{
    NSString *searchURL = [FlickrManager flickrSearchURL];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        
        NSError *error = nil;
        NSString *searchResultString = [NSString stringWithContentsOfURL:[NSURL URLWithString:searchURL]
                                                                encoding:NSUTF8StringEncoding
                                                                   error:&error];
        if (error != nil) {
            completionBlock(nil,error);
        }
        else
        {
            // Parse the JSON Response
            NSData *jsonData = [searchResultString dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *searchResultsDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                              options:kNilOptions
                                                                                error:&error];
            if(error != nil) {
                completionBlock(nil,error);
            }
            else
            {
                NSString * status = searchResultsDict[@"stat"];
                if ([status isEqualToString:@"fail"])
                {
                    NSError * error = [[NSError alloc] initWithDomain:@"FlickrSearch" code:0 userInfo:@{NSLocalizedFailureReasonErrorKey: searchResultsDict[@"message"]}];
                    completionBlock(nil, error);
                } else {
                    
                    NSArray *objPhotos = searchResultsDict[@"photos"][@"photo"];
                    NSMutableArray *flickrPhotos = [@[] mutableCopy];
                    
                    for(NSMutableDictionary *objPhoto in objPhotos)
                    {
                        FlickrPhoto *photo = [[FlickrPhoto alloc] init];
                        photo.idPhoto = [objPhoto[@"id"] longLongValue];
                        photo.owner = objPhoto[@"owner"];
                        photo.secret = objPhoto[@"secret"];
                        photo.title = objPhoto[@"title"];
                        photo.server = [objPhoto[@"server"] intValue];
                        photo.farm = [objPhoto[@"farm"] intValue];
                        photo.isFamily = [objPhoto[@"isfamily"] boolValue];
                        photo.isFriend = [objPhoto[@"isfriend"] boolValue];
                        photo.isPublic = [objPhoto[@"ispublic"] boolValue];
                        
                        photo.thumbnailURL = [FlickrManager downloadFlickrPhoto:photo withSize:'m'];
                        photo.largeImageURL = [FlickrManager downloadFlickrPhoto:photo withSize:'b'];
                        
                        [flickrPhotos addObject:photo];
                    }
                    
                    completionBlock(flickrPhotos,nil);
                }
            }
        }
    });
}

@end
