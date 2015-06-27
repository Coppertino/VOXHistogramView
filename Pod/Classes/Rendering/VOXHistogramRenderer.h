//
// Created by Nickolay Sheika on 09.01.15.
// Copyright (c) 2015 Alterplay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class VOXHistogramRenderingConfiguration;



@interface VOXHistogramRenderer : NSObject


#pragma mark - Init
- (instancetype)initWithRenderingConfiguration:(VOXHistogramRenderingConfiguration *)renderingConfiguration NS_DESIGNATED_INITIALIZER;
+ (instancetype)rendererWithRenderingConfiguration:(VOXHistogramRenderingConfiguration *)renderingConfiguration;


#pragma mark - Rendering
/**
*   Will render histogram image on background
*
*   @param levels - array of NSNumbers from @0.0f to @1.0f
*   @param completion - block will be called when finished rendering
*/
- (void)renderHistogramWithLevels:(NSArray *)levels
                       completion:(void (^)(UIImage *image))completion;


#pragma mark - Canceling
/**
*   Cancel any rendering process
*/
- (void)cancelCurrentRendering;

@end



@interface VOXHistogramRenderer (Unavailable)


- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end