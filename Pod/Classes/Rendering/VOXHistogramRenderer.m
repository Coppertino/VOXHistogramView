//
// Created by Nickolay Sheika on 09.01.15.
// Copyright (c) 2015 Alterplay. All rights reserved.
//

#import "VOXHistogramRenderer.h"
#import "VOXHistogramRenderingOperation.h"
#import "VOXHistogramRenderingConfiguration.h"



@interface VOXHistogramRenderer ()


@property(nonatomic, strong) NSOperationQueue *renderingQueue;
@property(nonatomic, strong) VOXHistogramRenderingConfiguration *renderingConfiguration;

@end



@implementation VOXHistogramRenderer


#pragma mark - Init

- (instancetype)initWithRenderingConfiguration:(VOXHistogramRenderingConfiguration *)renderingConfiguration
{
    self = [super init];
    if (self) {
        self.renderingConfiguration = renderingConfiguration;

        // queue setup
        self.renderingQueue = [NSOperationQueue new];
    }
    return self;
}

+ (instancetype)rendererWithRenderingConfiguration:(VOXHistogramRenderingConfiguration *)renderingConfiguration
{
    return [[self alloc] initWithRenderingConfiguration:renderingConfiguration];
}

#pragma mark - Rendering

- (void)renderHistogramWithLevels:(NSArray *)levels
                       completion:(void (^)(UIImage *image))completion
{
    NSParameterAssert(levels);
    NSParameterAssert(completion);

    /* Cancel previous operation if any */
    [self.renderingQueue cancelAllOperations];

    /* Creating rendering operation */
    VOXHistogramRenderingOperation *renderingOperation;
    renderingOperation = [VOXHistogramRenderingOperation operationWithLevels:levels
                                                      renderingConfiguration:self.renderingConfiguration];
    renderingOperation.completion = completion;

    /* Run operation on rendering queue */
    [self.renderingQueue addOperation:renderingOperation];
}

#pragma mark - Canceling

- (void)cancelCurrentRendering
{
    [self.renderingQueue cancelAllOperations];
}

@end