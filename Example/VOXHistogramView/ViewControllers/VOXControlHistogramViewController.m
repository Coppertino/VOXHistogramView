//
// Created by Nickolay Sheika on 24.06.15.
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

#import "VOXControlHistogramViewController.h"
#import "VOXJSONConverter.h"
#import "VOXPlayerWrapper.h"
#import <VOXHistogramView/VOXHistogramControlView.h>



@interface VOXControlHistogramViewController () <VOXHistogramControlViewDelegate, VOXPlayerWrapperDelegate>


#pragma mark - Outlets
@property(weak, nonatomic) IBOutlet UIButton *playButton;
@property(weak, nonatomic) IBOutlet VOXHistogramControlView *histogramControlView;
@property(weak, nonatomic) IBOutlet UILabel *scrubbingSpeedLabel;

#pragma mark - Player Wrapper
@property(nonatomic, strong) VOXPlayerWrapper *playerWrapper;
@end



@implementation VOXControlHistogramViewController


#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.histogramControlView.delegate = self;

    self.playerWrapper = [[VOXPlayerWrapper alloc] initWithPlayer:[APAudioPlayer new]];
    self.playerWrapper.delegate = self;

    self.scrubbingSpeedLabel.alpha = 0.0f;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    /* Load levels JSON */
    NSArray *levels = [VOXJSONConverter jsonObjectWithFileName:@"levels.json"];
    self.histogramControlView.levels = levels;

    NSString *path = [[NSBundle mainBundle] pathForResource:@"pink20silence20" ofType:@"mp3"];
    [self.playerWrapper startPlayingTrackWithURL:[NSURL URLWithString:path]];
}

- (void)dealloc
{
    [self.playerWrapper cleanUp];
}


#pragma mark - Actions

- (IBAction)playButtonTap:(id)sender
{
    if ([self.playerWrapper isPlaying]) {
        [self.playerWrapper pause];
    }
    else {
        [self.playerWrapper play];
    }
}

#pragma mark - VOXPlayerWrapperDelegate

- (void)playerDidPause:(VOXPlayerWrapper *)playerWrapper
{
    [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
    [self.histogramControlView hideHistogramViewAnimated:YES];
}

- (void)playerDidStartPlaying:(VOXPlayerWrapper *)playerWrapper
{
    [self.playButton setTitle:@"Pause" forState:UIControlStateNormal];
    [self.histogramControlView showHistogramViewAnimated:YES];
}

- (void)playerDidFinishCurrentTrack:(VOXPlayerWrapper *)playerWrapper
{
    self.histogramControlView.playbackProgress = 0.0f;
}

- (void)  playerWrapper:(VOXPlayerWrapper *)playerWrapper
downloadProgressChanged:(CGFloat)downloadProgress
{
    self.histogramControlView.downloadProgress = downloadProgress;
}

- (void)  playerWrapper:(VOXPlayerWrapper *)playerWrapper
playbackProgressChanged:(CGFloat)playbackProgress
{
    self.histogramControlView.playbackProgress = playbackProgress;
}

#pragma mark - VOXHistogramControlViewDelegate

- (void)histogramControlViewDidFinishRendering:(VOXHistogramControlView *)controlView
{
    [self.histogramControlView showHistogramViewAnimated:YES];
}

- (void)histogramControlView:(VOXHistogramControlView *)controlView
     didChangeScrubbingSpeed:(CGFloat)scrubbingSpeed
{
    [self _updateScrubbingSpeedLabel:scrubbingSpeed];
}

- (void)histogramControlViewDidStartTracking:(VOXHistogramControlView *)controlView
{
    [self.histogramControlView showHistogramViewAnimated:YES];
    [self _animateScrubbingSpeedLabel:YES];
    [self _updateScrubbingSpeedLabel:controlView.scrubbingSpeed];
}

- (void) histogramControlView:(VOXHistogramControlView *)controlView
didFinishTrackingWithProgress:(CGFloat)value
{
    if (! [self.playerWrapper isPlaying]) {
        [self.histogramControlView hideHistogramViewAnimated:YES];
    }
    [self _animateScrubbingSpeedLabel:NO];
    self.playerWrapper.position = value;
}

#pragma mark - Private

- (void)_updateScrubbingSpeedLabel:(CGFloat)scrubbingSpeed
{
    self.scrubbingSpeedLabel.text = [NSString stringWithFormat:@"%@: %.0f%%", NSLocalizedString(@"Scrubbing speed", nil),
                                                               scrubbingSpeed * 100];
}

- (void)_animateScrubbingSpeedLabel:(BOOL)show
{
    [UIView animateWithDuration:0.25f animations:^{
        self.scrubbingSpeedLabel.alpha = show ? 1.0f : 0.0f;
    }];
}

@end