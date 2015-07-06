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

@property(nonatomic, weak) UIView *completeView;
@property(nonatomic, weak) UIView *notCompleteView;
@property(nonatomic, weak) UIView *downloadedView;
@end



@implementation VOXProgressLineView


#pragma mark - Accessors

- (void)setCompleteColor:(UIColor *)completeColor
{
    _completeColor = completeColor;
    self.completeView.backgroundColor = completeColor;
}

- (void)setNotCompleteColor:(UIColor *)notCompleteColor
{
    _notCompleteColor = notCompleteColor;
    self.notCompleteView.backgroundColor = notCompleteColor;
}

- (void)setDownloadedColor:(UIColor *)downloadedColor
{
    _downloadedColor = downloadedColor;
    self.downloadedView.backgroundColor = downloadedColor;
}

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

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.notCompleteView.frame = self.bounds;
    self.completeView.frame = (CGRect) {
            .origin = CGPointZero,
            .size.width = CGRectGetWidth(self.bounds) * self.playbackProgress,
            .size.height = CGRectGetHeight(self.bounds)
    };
    self.downloadedView.frame = (CGRect) {
            .origin = CGPointZero,
            .size.width = CGRectGetWidth(self.bounds) * self.downloadProgress,
            .size.height = CGRectGetHeight(self.bounds)
    };
}

#pragma mark - Setup

- (void)setup
{
    // build view hierarchy
    self.notCompleteView = [self _buildView];
    self.downloadedView = [self _buildView];
    self.completeView = [self _buildView];
}

- (UIView *)_buildView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.clipsToBounds = YES;
    view.contentMode = UIViewContentModeLeft;
    [self addSubview:view];
    return view;
}

#pragma mark - Public

- (void)updatePlaybackProgress:(CGFloat)playbackProgress
{
    self.playbackProgress = [self _normalizedValue:playbackProgress];
    [self setNeedsLayout];
}

- (void)updateDownloadProgress:(CGFloat)downloadProgress
{
    self.downloadProgress = [self _normalizedDownloadProgressValue:downloadProgress];
    [self setNeedsLayout];
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