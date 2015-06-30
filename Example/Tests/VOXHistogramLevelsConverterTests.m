//
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

#import <XCTest/XCTest.h>
#import "VOXHistogramLevelsConverter.h"
#import "Expecta.h"


@interface VOXHistogramLevelsConverterTests : XCTestCase


#pragma mark - SUT
@property(nonatomic, strong) VOXHistogramLevelsConverter *converter;
@end



@implementation VOXHistogramLevelsConverterTests


- (void)setUp
{
    [super setUp];

    self.converter = [VOXHistogramLevelsConverter new];

    NSArray *levels = [self buildLevelsForTesting];
    [self.converter updateLevels:levels];
}

- (void)tearDown
{
    self.converter = nil;
    [super tearDown];
}

#pragma mark - Update levels

- (void)testUpdateLevels
{
    expect(self.converter.levels).to.haveCountOf(15);

    [self.converter updateLevels:nil];
    expect(self.converter.levels).to.beNil();
}

#pragma mark - Calculate Levels

- (void)testCalculateLevelsForSamplingRate_ShouldRaiseExceptionIfSamplingMoreThanLevelsCount
{
    expect(^{
        [self.converter calculateLevelsForSamplingRate:20 completion:nil];
    }).to.raiseAny();
}

- (void)testCalculateLevelsForSamplingRate_3_Samples
{
    [self runAsyncCalculateLevelsForSamplingRate:3 withExpectationsBlock:^(NSArray *levels) {
        expect(levels).to.haveCountOf(3);
        expect(levels[0]).to.beCloseTo(@0.36666666666667);
        expect(levels[1]).to.equal(@0.0);
        expect(levels[2]).to.equal(@0.8);
    }];
}

- (void)testCalculateLevelsForSamplingRate_5_Samples
{
    [self runAsyncCalculateLevelsForSamplingRate:5 withExpectationsBlock:^(NSArray *levels) {
        expect(levels).to.haveCountOf(5);
        expect(levels[0]).to.beCloseTo(@0.43333333333333);
        expect(levels[1]).to.beCloseTo(@0.26666666666667);
        expect(levels[2]).to.equal(@0.0);
        expect(levels[3]).to.beCloseTo(@0.86666666666667);
        expect(levels[4]).to.beCloseTo(@0.56666666666667);
    }];
}

- (void)testCalculateLevelsForSamplingRate_8_Samples
{
    [self runAsyncCalculateLevelsForSamplingRate:8 withExpectationsBlock:^(NSArray *levels) {
        expect(levels).to.haveCountOf(8);
        expect(levels[0]).to.equal(@0.6);
    }];
}

#pragma mark - Helpers

- (void)runAsyncCalculateLevelsForSamplingRate:(NSUInteger)samplingRate withExpectationsBlock:(void (^)(NSArray *levels))expectationsBlock
{
    XCTestExpectation *expectation = [self expectationWithDescription:nil];
    [self.converter calculateLevelsForSamplingRate:samplingRate completion:^(NSArray *levels) {
        expectationsBlock(levels);
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:3.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"testCalculateLevelsForSamplingRate failed: %@", error);
        }
    }];
}

- (NSArray *)buildLevelsForTesting
{
    return @[
            @0.5, @0.7, @0.1, @0.3, @0.5,
            @0.0, @0.0, @0.0, @0.0, @1.0,
            @0.8, @0.8, @0.8, @0.8, @0.1
    ];
}
@end
