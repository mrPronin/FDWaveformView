//
//  ViewController.m
//  FDWaveformViewExample
//
//  Created by William Entriken on 10/6/13.
//  Copyright (c) 2013 William Entriken. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <FDWaveformViewDelegate>
@property (nonatomic, strong) NSDate *startRendering;
@property (nonatomic, strong) NSDate *endRendering;
@property (nonatomic, strong) NSDate *startLoading;
@property (nonatomic, strong) NSDate *endLoading;
@property (nonatomic, strong) UIAlertView *profilingAlert;
@property (nonatomic, strong) NSMutableString *profileResult;
@end

@implementation ViewController
@synthesize startRendering = _startRendering;

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
    //NSString *filePath = [thisBundle pathForResource:@"Submarine" ofType:@"aiff"];
    //NSString *filePath = [thisBundle pathForResource:@"Sample01" ofType:@"wav"];
    NSString *filePath = [thisBundle pathForResource:@"Tool_Jambi" ofType:@"caf"];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    
    // We wish to animate the waveformv iew in when it is rendered
    self.waveform.delegate = self;
    self.waveform.alpha = 0.0f;
    
    self.waveform.audioURL = url;
    self.waveform.progressSamples = 10000;
    self.waveform.doesAllowScrubbing = YES;
    self.waveform.doesAllowStretchAndScroll = YES;
}

- (void)doAnimation
{
    [UIView animateWithDuration:0.3 animations:^{
        NSInteger randomNumber = arc4random() % self.waveform.totalSamples;
        self.waveform.progressSamples = randomNumber;
    }];
}

- (void)doZoomIn
{
    self.waveform.zoomStartSamples = 0;
    self.waveform.zoomEndSamples = self.waveform.totalSamples / 4;
}

- (void)doZoomOut
{
    self.waveform.zoomStartSamples = 0;
    self.waveform.zoomEndSamples = self.waveform.totalSamples;
}

- (IBAction)doRunPerformanceProfile {
    NSLog(@"RUNNING PERFORMANCE PROFILE");
    self.profilingAlert = [[UIAlertView alloc] initWithTitle:@"PROFILING BEGIN" message:@"Profiling will begin, please don't touch anything. This will take less than 30 seconds" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [self.profilingAlert show];
    self.profileResult = [NSMutableString stringWithString:@""];
    
    // Delay execution of my block for 1 seconds.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.profileResult appendString:@"AAC:"];
        [self doLoadAAC];
    });

    // Delay execution of my block for 5 seconds.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.profileResult appendString:@" MP3:"];
        [self doLoadMP3];
    });
    
    // Delay execution of my block for 9 seconds.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 9 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.profileResult appendString:@" OGG:"];
        [self doLoadOGG];
    });
    
    // Delay execution of my block for 14 seconds.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 14 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.profilingAlert dismissWithClickedButtonIndex:-1 animated:NO];
        self.profilingAlert = [[UIAlertView alloc] initWithTitle:@"PLEASE POST TO github.com/fulldecent/FDWaveformView/wiki" message:self.profileResult delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil];
        [self.profilingAlert show];
    });
}

- (IBAction)doLoadAAC {
    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
    NSString *filePath = [thisBundle pathForResource:@"TchaikovskyExample2" ofType:@"m4a"];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    self.waveform.audioURL = url;
}

- (IBAction)doLoadMP3 {
    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
    NSString *filePath = [thisBundle pathForResource:@"TchaikovskyExample2" ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    self.waveform.audioURL = url;
}

- (IBAction)doLoadOGG {
    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
    NSString *filePath = [thisBundle pathForResource:@"TchaikovskyExample2" ofType:@"ogg"];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    self.waveform.audioURL = url;
}

#pragma mark -
#pragma mark FDWaveformViewDelegate

- (void)waveformViewWillRender:(FDWaveformView *)waveformView
{
    self.startRendering = [NSDate date];
}

- (void)waveformViewDidRender:(FDWaveformView *)waveformView
{
    self.endRendering = [NSDate date];
    NSLog(@"FDWaveformView rendering done, took %f seconds", [self.endRendering timeIntervalSinceDate:self.startRendering]);
    [self.profileResult appendFormat:@" render %f", [self.endRendering timeIntervalSinceDate:self.startRendering]];
    [UIView animateWithDuration:0.25f animations:^{
        waveformView.alpha = 1.0f;
    }];
}

- (void)waveformViewWillLoad:(FDWaveformView *)waveformView
{
    self.startLoading = [NSDate date];
}

- (void)waveformViewDidLoad:(FDWaveformView *)waveformView
{
    self.endLoading = [NSDate date];
    NSLog(@"FDWaveformView loading done, took %f seconds", [self.endLoading timeIntervalSinceDate:self.startLoading]);
    [self.profileResult appendFormat:@" load %f", [self.endLoading timeIntervalSinceDate:self.startLoading]];
}

@end
