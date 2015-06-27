//
// Created by Nickolay Sheika on 23.11.14.
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

#import "VOXProgressLineView.h"



@interface VOXProgressLineView ()


@property(nonatomic, assign) CGFloat playbackProgress;
@property(nonatomic, assign) CGFloat downloadProgress;

@end



@implementation VOXProgressLineView


#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark - Setup

- (void)setup
{
    // default colors for debugging
    self.notCompleteColor = [UIColor greenColor];
    self.completeColor = [UIColor redColor];
    self.downloadedColor = [UIColor yellowColor];

    // background should be clear
    self.backgroundColor = [UIColor clearColor];
}

#pragma mark - Public

- (void)updatePlaybackProgress:(CGFloat)playbackProgress
{
    self.playbackProgress = [self _normalizedValue:playbackProgress];
    [self setNeedsDisplay];
}

- (void)updateDownloadProgress:(CGFloat)downloadProgress
{
    self.downloadProgress = [self _normalizedDownloadProgressValue:downloadProgress];
    [self setNeedsDisplay];
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    /* Taking graphic context */
    CGContextRef context = UIGraphicsGetCurrentContext();

    /* Please, no antialiasing */
    CGContextSetShouldAntialias(context, NO);

    // Setting line width
    CGContextSetLineWidth(context, rect.size.height);

    // calculate slider line Y position
    CGFloat yPosition = rect.size.height / 2;

    // get current rect width
    CGFloat rectWidth = rect.size.width;



    /* Drawing complete part of slider */

    // setting line color
    CGContextSetStrokeColorWithColor(context, self.completeColor.CGColor);

    // start to draw line from left
    CGContextMoveToPoint(context, 0, yPosition);

    // calculating line width for current cursor position
    CGFloat lineWidth = self.playbackProgress * rectWidth;

    // drawing line with calculated width
    CGContextAddLineToPoint(context, lineWidth, yPosition);

    // draw stroke
    CGContextStrokePath(context);



    /* Drawing downloaded part of slider */

    if (self.downloadProgress > self.playbackProgress) {

        // move ahead
        CGContextMoveToPoint(context, lineWidth, yPosition);

        // setting line color
        CGContextSetStrokeColorWithColor(context, self.downloadedColor.CGColor);

        // calculating line width for current downloaded position
        lineWidth = self.downloadProgress * rectWidth;

        // drawing line with calculated width
        CGContextAddLineToPoint(context, lineWidth, yPosition);

        // draw stroke
        CGContextStrokePath(context);
    }



    /* Drawing not complete part of slider */

    // setting line color
    CGContextSetStrokeColorWithColor(context, self.notCompleteColor.CGColor);

    // move ahead
    CGContextMoveToPoint(context, lineWidth, yPosition);

    // calculating line width for current downloaded position
    lineWidth = rectWidth;

    // drawing line with calculated width
    CGContextAddLineToPoint(context, lineWidth, yPosition);

    // draw stroke
    CGContextStrokePath(context);
}

#pragma mark - Helpers

- (CGFloat)_normalizedValue:(CGFloat)value
{
    return MAX(MIN(value, 1), 0);
}

- (CGFloat)_normalizedDownloadProgressValue:(CGFloat)downloadProgressValue
{
    return MAX(MIN(downloadProgressValue, 1), self.playbackProgress);
}

@end