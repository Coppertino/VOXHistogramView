//
// Created by Nickolay Sheika on 26.06.15.
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

#import <APAudioPlayer/APAudioPlayer.h>
#import "VOXPlayerWrapper.h"


static NSUInteger const VOXDownloadTicksCount = 10;



@interface VOXPlayerWrapper () <APAudioPlayerDelegate>


#pragma mark - Player
@property(nonatomic, strong) APAudioPlayer *player;

#pragma mark - Helpers
@property(nonatomic, strong) NSTimer *progressTimer;
@property(nonatomic, strong) NSTimer *downloadTimer;
@property(nonatomic, assign) NSUInteger downloadTicksCount;
@property(nonatomic, assign) CGFloat downloadProgress;

@end



@implementation VOXPlayerWrapper


#pragma mark - Accessors

- (CGFloat)position
{
    return self.player.position;
}

- (void)setPosition:(CGFloat)position
{
    [self.player setPosition:position];
}

#pragma mark - Init

- (instancetype)initWithPlayer:(APAudioPlayer *)player
{
    self = [super init];
    if (self) {
        self.player = player;
        self.player.delegate = self;
    }
    return self;
}

+ (instancetype)wrapperWithPlayer:(APAudioPlayer *)player
{
    return [[self alloc] initWithPlayer:player];
}

- (void)dealloc
{
    [self _killDownloadTimer];
    [self _killTimer];
}

#pragma mark - Public

- (void)startPlayingTrackWithURL:(NSURL *)url
{
    [self.player loadItemWithURL:url autoPlay:NO];
    [self play];
    [self _startDownloadTimer];
}

- (BOOL)isPlaying
{
    return self.player.isPlaying;
}

- (void)play
{
    if (self.progressTimer) {
        [self _killTimer];
    }

    [self.player play];
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f
                                                          target:self
                                                        selector:@selector(progressTimerFired:)
                                                        userInfo:nil
                                                         repeats:YES];
}

- (void)pause
{
    [self.player pause];
    [self _killTimer];
}

- (void)cleanUp
{
    [self _killDownloadTimer];
    [self _killTimer];
}

#pragma mark - APAudioPlayerDelegate

- (void)playerDidChangePlayingStatus:(APAudioPlayer *)player
{
    if ([player isPlaying]) {
        if ([self.delegate respondsToSelector:@selector(playerDidStartPlaying:)]) {
            [self.delegate playerDidStartPlaying:self];
        }
    }
    else if (player.position != 1.0f) {
        if ([self.delegate respondsToSelector:@selector(playerDidPause:)]) {
            [self.delegate playerDidPause:self];
        }
    }
}

- (void)playerDidFinishPlaying:(APAudioPlayer *)player
{
    [self _startDownloadTimer];
    if ([self.delegate respondsToSelector:@selector(playerDidFinishCurrentTrack:)]) {
        [self.delegate playerDidFinishCurrentTrack:self];
    }
    [self play];
}

- (void)playerBeginInterruption:(APAudioPlayer *)player
{
    [self pause];
}

- (void)playerEndInterruption:(APAudioPlayer *)player
                 shouldResume:(BOOL)should
{
    [self play];
}

#pragma mark - Timers

- (void)progressTimerFired:(NSTimer *)sender
{
    CGFloat playbackProgress = self.player.position;
    if ([self.delegate respondsToSelector:@selector(playerWrapper:playbackProgressChanged:)]) {
        [self.delegate playerWrapper:self playbackProgressChanged:playbackProgress];
    }
}

- (void)downloadTimerFired:(NSTimer *)sender
{
    self.downloadTicksCount --;
    self.downloadProgress += 1.0f / VOXDownloadTicksCount;
    if ([self.delegate respondsToSelector:@selector(playerWrapper:downloadProgressChanged:)]) {
        [self.delegate playerWrapper:self downloadProgressChanged:self.downloadProgress];
    }
    if (self.downloadTicksCount == 0) {
        [self _killDownloadTimer];
    }
}

#pragma mark - Helpers

- (void)_killTimer
{
    [self.progressTimer invalidate];
    self.progressTimer = nil;
}

- (void)_startDownloadTimer
{
    self.downloadTicksCount = VOXDownloadTicksCount;
    self.downloadProgress = 0.0f;
    self.downloadTimer = [NSTimer scheduledTimerWithTimeInterval:0.3f
                                                          target:self
                                                        selector:@selector(downloadTimerFired:)
                                                        userInfo:nil
                                                         repeats:YES];
}

- (void)_killDownloadTimer
{
    [self.downloadTimer invalidate];
    self.downloadTimer = nil;
}


@end