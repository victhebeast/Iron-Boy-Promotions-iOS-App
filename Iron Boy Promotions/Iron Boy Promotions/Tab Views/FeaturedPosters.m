//
//  FeaturedPosters.m
//  Iron Boy Promotions
//
//  Created by Victor Ilisei on 4/8/15.
//  Copyright (c) 2015 Tech Genius. All rights reserved.
//

#import <Parse/Parse.h>

#import "FeaturedPosters.h"

@interface FeaturedPosters ()

@end

@implementation FeaturedPosters

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"Featured";
        self.tabBarItem.image = [UIImage imageNamed:@"featuredPosters"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    posterScroller = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height - 37)];
    posterScroller.delegate = self;
    [posterScroller setContentInset:UIEdgeInsetsZero];
    posterScroller.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    posterScroller.contentSize = CGSizeMake(0, posterScroller.frame.size.height);
    posterScroller.pagingEnabled = YES;
    posterScroller.showsHorizontalScrollIndicator = NO;
    posterScroller.showsVerticalScrollIndicator = NO;
    [self.view addSubview:posterScroller];
    
    // Status Bar Blur
    if ([UIVisualEffectView class]) {
        @autoreleasepool {
            UIVisualEffectView *blurredEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
            [blurredEffectView setFrame:[[UIApplication sharedApplication] statusBarFrame]];
            blurredEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            
            [self.view insertSubview:blurredEffectView aboveSubview:posterScroller];
        }
    } else {
        @autoreleasepool {
            UIToolbar *blurredBar = [[UIToolbar alloc] initWithFrame:[[UIApplication sharedApplication] statusBarFrame]];
            blurredBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            
            [self.view insertSubview:blurredBar aboveSubview:posterScroller];
        }
    }
    
    posterScrollerDots = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height - 37, self.view.frame.size.width, 37)];
    posterScrollerDots.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [posterScrollerDots addTarget:self action:@selector(changedPage:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:posterScrollerDots];
    
    [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
        if (config && !error) {
            NSArray *featuredPosterURLs = config[@"featuredPosterURLs"];
            posterScrollerDots.numberOfPages = featuredPosterURLs.count;
            for (NSString *posterStringURL in featuredPosterURLs) {
                @autoreleasepool {
                    UIImageView *posterView = [[UIImageView alloc] initWithFrame:CGRectMake(posterScroller.contentSize.width, 0, posterScroller.frame.size.width, posterScroller.frame.size.height)];
                    posterView.contentMode = UIViewContentModeScaleAspectFit;
                    posterView.clipsToBounds = YES;
                    posterView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
                    posterScroller.contentSize = CGSizeMake(posterScroller.contentSize.width + posterView.frame.size.width, posterScroller.frame.size.height);
                    [posterScroller addSubview:posterView];
                    
                    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:posterStringURL]];
                    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                        if (data && !connectionError) {
                            posterView.image = [UIImage imageWithData:data];
                        }
                    }];
                }
            }
        }
    }];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    UIImageView *poster1 = (UIImageView *)[posterScroller.subviews firstObject];
    posterScroller.contentSize = CGSizeMake(poster1.bounds.size.width * posterScroller.subviews.count, posterScroller.frame.size.height);
    [posterScroller setContentOffset:CGPointMake(poster1.bounds.size.width * posterScrollerDots.currentPage, 0) animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == posterScroller) {
        posterScrollerDots.currentPage = lroundf(scrollView.contentOffset.x / scrollView.frame.size.width);
    }
}

- (void)changedPage:(UIPageControl *)sender {
    [posterScroller setContentOffset:CGPointMake(posterScroller.frame.size.width * sender.currentPage, 0) animated:YES];
}

@end