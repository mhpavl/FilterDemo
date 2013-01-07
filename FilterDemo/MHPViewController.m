//
//  MHPViewController.m
//  FilterDemo
//
//  Created by Mark H Pavlidis on 1/6/2013.
//  Copyright (c) 2013 Grok Software. All rights reserved.
//

#import "MHPViewController.h"
#import <CoreImage/CoreImage.h>

@interface MHPViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) UIImage *sourceImage;
@property (strong, nonatomic) NSDate *startTime;
@property (strong, nonatomic) CIContext *context;

- (IBAction)tappedSource:(id)sender;
- (IBAction)tappedMono:(id)sender;
- (IBAction)tappedChain:(id)sender;

@end

@implementation MHPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.context = [CIContext contextWithOptions:nil];
    [self showSourceImage];
}

#pragma mark - Displayed Image Methods

- (UIImage *)sourceImage
{
    if (_sourceImage == nil) {
        _sourceImage = [UIImage imageNamed:@"sourceImage"];
    }
    return _sourceImage;
}

- (void)showSourceImage
{
    [self tick];
    self.imageView.image = self.sourceImage;
    [self tock];
}

#pragma mark IBAction methods

- (IBAction)tappedSource:(id)sender {
    [self showSourceImage];
}

- (IBAction)tappedMono:(id)sender {
    CIImage *sourceImage = [CIImage imageWithCGImage:self.sourceImage.CGImage];
    
    [self tick];
    CIImage *monoImage = [CIFilter filterWithName:@"CIColorMonochrome"
                                    keysAndValues:
                          kCIInputImageKey, sourceImage,
                          @"inputIntensity", @(1.0),
                          @"inputColor", [CIColor colorWithRed:0.75 green:0.75 blue:0.75],
                          nil
                          ].outputImage;
    CGImageRef cgImage = [self.context createCGImage:monoImage fromRect:monoImage.extent];
    [self tock];
    
    self.imageView.image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
}

- (IBAction)tappedChain:(id)sender {
    CIImage *sourceImage = [CIImage imageWithCGImage:self.sourceImage.CGImage];
    
    [self tick];
    CIImage *outputImage = [CIFilter filterWithName:@"CIColorMonochrome"
                                      keysAndValues:
                            kCIInputImageKey, sourceImage,
                            @"inputIntensity", @(1.0),
                            @"inputColor", [CIColor colorWithRed:0.75 green:0.75 blue:0.75],
                            nil
                            ].outputImage;
    outputImage = [CIFilter filterWithName:@"CIVignette"
                             keysAndValues:
                   kCIInputImageKey, outputImage,
                   @"inputIntensity", @(1.0),
                   @"inputRadius", @(2.0),
                   nil
                   ].outputImage;
    outputImage = [CIFilter filterWithName:@"CIBloom"
                             keysAndValues:
                   kCIInputImageKey, outputImage,
                   nil
                   ].outputImage;
    CGImageRef cgImage = [self.context createCGImage:outputImage fromRect:sourceImage.extent];
    [self tock];
    
    self.imageView.image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);

}

#pragma mark Timing 

- (void)tick
{
    self.startTime = [NSDate date];
    self.timeLabel.text = @"";
}

- (void)tock
{
    self.timeLabel.text = [NSString stringWithFormat:@"%0.3fms", self.startTime.timeIntervalSinceNow * -1000.0];
    self.startTime = nil;
}

@end
