//
//  PendingOperations.h
//  Prueba
//
//  Created by Javier Delgado on 04/07/13.
//  Copyright (c) 2013 Javier Delgado. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PendingOperations : NSObject

@property (nonatomic, strong) NSMutableDictionary *downloadsInProgress;
@property (nonatomic, strong) NSOperationQueue *downloadsQueue;

@end
