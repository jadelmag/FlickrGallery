//
//  PendingOperations.m
//  Prueba
//
//  Created by Javier Delgado on 04/07/13.
//  Copyright (c) 2013 Javier Delgado. All rights reserved.
//

#import "PendingOperations.h"

@implementation PendingOperations

-(NSMutableDictionary *)downloadsInProgress
{
    if (!_downloadsInProgress) {
        _downloadsInProgress = [[NSMutableDictionary alloc] init];
    }
    return _downloadsInProgress;
}

-(NSOperationQueue *)downloadsQueue
{
    if (!_downloadsQueue) {
        _downloadsQueue = [[NSOperationQueue alloc] init];
        _downloadsQueue.name = @"Downloads Queue";
#warning max operation concurrent 1
        _downloadsQueue.maxConcurrentOperationCount = 1;
    }
    return _downloadsQueue;
}

@end
