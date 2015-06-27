//
// Created by Nickolay Sheika on 10/9/14.
// Copyright (c) 2014 Coppertino Inc. All rights reserved. (http://coppertino.com/)
//
// VOX, VOX Player, LOOP for VOX are registered trademarks of Coppertino Inc in US.
// Coppertino Inc. 910 Foulk Road, Suite 201, Wilmington, County of New Castle, DE, 19803, USA.
// Contact phone: +1 (888) 765-7069
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "VOXHistogramLevelsConverter.h"
#import "macros_blocks.h"


static NSUInteger const averagingWindow = 3;



@implementation VOXHistogramLevelsConverter


#pragma mark - Public

- (void)updateLevels:(NSArray *)levels
{
    _levels = levels;
}

- (void)calculateLevelsForSamplingRate:(NSUInteger)samplingRate
                            completion:(void (^)(NSArray *levels))completion;
{
    NSUInteger samplesCount = [self.levels count];

    if (samplingRate == 0 || self.levels == nil) {
        safe_block(completion, nil);
    }

    if (samplingRate == samplesCount) {
        safe_block(completion, self.levels);
        return;
    }

    if (samplingRate > samplesCount) {
        [NSException raise:NSInvalidArgumentException format:@"samplingRate cannot be more than levels count!"];
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {

        NSMutableArray *result = [NSMutableArray array];
        @autoreleasepool {

            CGFloat downSamplingRatio = (CGFloat) samplesCount / samplingRate;
            for (NSUInteger i = 1; i <= samplingRate; i ++) {

                NSUInteger windowPosition = (NSUInteger) floorf(i * downSamplingRatio - downSamplingRatio / 2);

                NSInteger windowStart = windowPosition - (NSInteger) floorf(averagingWindow / 2);
                NSInteger windowFinish = windowStart + averagingWindow - 1;
                NSUInteger windowStartNormalized = (NSUInteger) (windowStart < 0 ? 0 : windowStart);
                NSUInteger windowFinishNormalized = windowFinish > (samplesCount - 1) ? samplesCount - 1 : (NSUInteger) windowFinish;
                NSRange windowRange = NSMakeRange(windowStartNormalized, windowFinishNormalized - windowStartNormalized + 1);

                NSArray *subArray = [self.levels subarrayWithRange:windowRange];
                NSNumber *average = [subArray valueForKeyPath:@"@avg.self"];
                [result addObject:average];
            }
        }

        main_queue_block(completion, [result copy]);
    });
}

@end