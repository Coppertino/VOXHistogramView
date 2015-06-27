//
// Created by Nickolay Sheika on 09.01.15.
// Copyright (c) 2015 Alterplay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class VOXHistogramRenderingConfiguration;



@interface VOXHistogramRenderingOperation : NSOperation


#pragma mark - Completion
/**
*   Block will be called when finished rendering
*/
@property(nonatomic, copy) void (^completion)(UIImage *image);

#pragma mark - Rendered Image
/**
*   Rendered image, nil until operation is finished
*/
@property(nonatomic, strong, readonly) UIImage *image;


#pragma mark - Init
- (instancetype)initWithLevels:(NSArray *)levels
        renderingConfiguration:(VOXHistogramRenderingConfiguration *)renderingConfiguration NS_DESIGNATED_INITIALIZER;
+ (instancetype)operationWithLevels:(NSArray *)levels
             renderingConfiguration:(VOXHistogramRenderingConfiguration *)renderingConfiguration;


@end



@interface VOXHistogramRenderingOperation (Unavailable)


- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end