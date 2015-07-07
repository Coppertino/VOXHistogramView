//
//  VOXHistogramViewTests.m
//  VOXHistogramView
//
//  Created by Nickolay Sheika on 06.07.15.
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

#import "VOXHistogramView.h"
#import "FBSnapshotTestCase.h"
#import "EXPMatchers+FBSnapshotTest.h"
#import "UIImage+ImageWithColor.h"



@interface VOXHistogramViewTests : FBSnapshotTestCase


#pragma mark - SUT
@property(nonatomic, strong) VOXHistogramView *histogramView;
@end



@implementation VOXHistogramViewTests


- (void)setUp
{
    [super setUp];

    /* Setup histogram view */
    CGRect frame = (CGRect) {
            .origin = CGPointZero,
            .size.width = 320,
            .size.height = 100
    };

    self.histogramView = [[VOXHistogramView alloc] initWithFrame:frame];

    self.histogramView.completeColor = [UIColor yellowColor];
    self.histogramView.downloadedColor = [UIColor lightGrayColor];
    self.histogramView.notCompleteColor = [UIColor darkGrayColor];

    UIImage *imageWithColor = [UIImage imageWithColor:[UIColor blackColor] ofSize:frame.size];
    UIImage *imageTemplate = [imageWithColor imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.histogramView.image = imageTemplate;
}

#pragma mark - Tests

- (void)testDefaultProgress
{
    // given
    [self.histogramView updatePlaybackProgress:0.3f];
    [self.histogramView updateDownloadProgress:0.5f];

    // verifications
    expect(self.histogramView).to.haveValidSnapshotNamed(@"defaultProgress");
}

- (void)testFullProgress
{
    // given
    [self.histogramView updatePlaybackProgress:1.0f];
    [self.histogramView updateDownloadProgress:1.0f];

    // verifications
    expect(self.histogramView).to.haveValidSnapshotNamed(@"fullProgress");
}

- (void)testStartProgress
{
    // given
    [self.histogramView updatePlaybackProgress:0.0f];
    [self.histogramView updateDownloadProgress:0.0f];

    // verifications
    expect(self.histogramView).to.haveValidSnapshotNamed(@"startProgress");
}

- (void)testPlaybackMoreThanDownloadProgress
{
    // given
    [self.histogramView updatePlaybackProgress:0.7f];
    [self.histogramView updateDownloadProgress:0.5f];

    // verifications
    expect(self.histogramView).to.haveValidSnapshotNamed(@"playbackMoreThanDownloadProgress");
}

@end
