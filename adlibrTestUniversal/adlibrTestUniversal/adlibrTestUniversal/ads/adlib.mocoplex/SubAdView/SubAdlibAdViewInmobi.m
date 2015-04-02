/*
 * adlibr - Library for mobile AD mediation.
 * http://adlibr.com
 * Copyright (c) 2012-2013 Mocoplex, Inc.  All rights reserved.
 * Licensed under the BSD open source license.
 */

/*
 * confirmed compatible with Inmobi SDK 4.5.1
 */

#import "SubAdlibAdViewInmobi.h"

// 여기에 인모비에서 발급받은 key 를 입력하세요.
#define INMOBI_ID              @"INSERT_YOUR_INMOBI_ID"
#define INMOBI_INTERSTITIAL_ID INMOBI_ID

#define kBannerSizePhone CGSizeMake(320, 50)
#define kBannerSizePad   CGSizeMake(728, 90)

static BOOL bInmobiInitialized = NO;

@interface SubAdlibAdViewInmobi () <IMInterstitialDelegate>

@property (nonatomic, strong) IMInterstitial *interstitial;

@end

@implementation SubAdlibAdViewInmobi

// 객체를 전역적으로 하나만 생성합니다.
+ (BOOL)isStaticObject
{
    return YES;
}

- (void)query:(UIViewController*)parent
{
    [super query:parent];
    
    if(!bInmobiInitialized)
    {
        // Inmobi Initialize
        [InMobi initialize:INMOBI_ID];
        [InMobi setLogLevel:IMLogLevelNone]; // IMLogLevelDebug (test mode)
        bInmobiInitialized = YES;
    }
    
    if (_adView == nil) {
        
        self.view.autoresizesSubviews = NO;
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            iPad = NO;
        else
            iPad = YES;
        
        // only iPhone size
        iPad = NO;
        
        IMBanner *bannerView = nil;
        CGPoint origin = [self getInmobiViewOrigin];
        
        if(iPad)
            bannerView = [[IMBanner alloc] initWithFrame:CGRectMake(origin.x, origin.y, kBannerSizePad.width, kBannerSizePad.height)
                                                   appId:INMOBI_ID
                                                  adSize:IM_UNIT_728x90];
        else
            bannerView = [[IMBanner alloc] initWithFrame:CGRectMake(origin.x, origin.y, kBannerSizePhone.width, kBannerSizePhone.height)
                                                   appId:INMOBI_ID
                                                  adSize:IM_UNIT_320x50];
        
        self.adView = bannerView;
        [self.view addSubview:_adView];
        
        _adView.refreshInterval = 20;
    }
    
    _adView.delegate = self;
    [self queryAd];
    
    [_adView loadBanner];
}

- (void)clearAdView
{
    if(_adView != nil)
    {
        _adView.refreshInterval = REFRESH_INTERVAL_OFF;
        _adView.delegate = nil;
        [_adView stopLoading];
    }
    
    [super clearAdView];
}

- (CGSize)size
{
    if(iPad)
        return kBannerSizePad;
    else
        return kBannerSizePhone;
}

- (void)orientationChanged
{
    [super orientationChanged];
    
    CGFloat width  = kBannerSizePad.width;
    CGFloat height = kBannerSizePad.height;
    
    if (!iPad) {
        width = kBannerSizePhone.width;
        height = kBannerSizePhone.height;
    }
    
    CGPoint origin = [self getInmobiViewOrigin];
    CGFloat ptX = origin.x;
    
    if(iPad)
        _adView.frame = CGRectMake(ptX, 0, width, height);
    else
        _adView.frame = CGRectMake(ptX, 0, width, height);
}

- (CGPoint)getInmobiViewOrigin
{
    CGFloat containerViewWidth, adViewWidth = 0;
    
    containerViewWidth = self.view.bounds.size.width;
    
    if (iPad) {
        adViewWidth = kBannerSizePad.width;
    }
    else
    {
        adViewWidth = kBannerSizePhone.width;
    }
    
    CGFloat originX = (containerViewWidth-adViewWidth)/2;
    if (originX < 0) {
        originX = 0;
    }
    
    CGFloat containerViewHeight, adViewHeight = 0;
    
    containerViewHeight = self.view.bounds.size.height;
    
    if (iPad) {
        adViewHeight = kBannerSizePad.height;
    }
    else
    {
        adViewHeight = kBannerSizePhone.height;
    }
    
    CGFloat originY = (containerViewHeight-adViewHeight)/2;
    if (originY < 0) {
        originY = 0;
    }
    
    return CGPointMake(originX, originY);
}

- (void)subAdlibViewLoadInterstitial:(UIViewController*)viewController
{
    if(!bInmobiInitialized)
    {
        // Inmobi Initialize
        [InMobi initialize:INMOBI_ID];
        [InMobi setLogLevel:IMLogLevelDebug];
        bInmobiInitialized = YES;
    }
    
    IMInterstitial *interstitial = [[IMInterstitial alloc] initWithAppId:INMOBI_INTERSTITIAL_ID];
    self.interstitial = interstitial;
    
    interstitial.delegate = self;
    [interstitial loadInterstitial];
}

#pragma mark - Banner Request Notifications

// Sent when an ad request was successful
- (void)bannerDidReceiveAd:(IMBanner *)banner {
    
    NSLog(@"banner receiveAd inmobi");
    
    // 화면에 광고를 보여줍니다.
    [self queryAd];
    [self gotAd];
}

// Sent when the ad request failed. Please check the error code and
// localizedDescription for more information on wy this occured
- (void)banner:(IMBanner *)banner didFailToReceiveAdWithError:(IMError *)error {
    
    NSString *errorMessage = [NSString stringWithFormat:@"Loading ad failed. Error code: %zd, message: %@", [error code], [error localizedDescription]];
    NSLog(@"%@", errorMessage);
    
    // 광고 수신에 실패하였습니다.
    [self failed];
}

- (void)bannerWillPresentScreen:(IMBanner *)banner
{
    ;
}

- (void)bannerDidDismissScreen:(IMBanner *)banner
{
    ;
}

- (void)interstitialDidReceiveAd:(IMInterstitial *)ad
{
    if (ad.state == kIMInterstitialStateReady) {
        
        // 전면광고 성공을 알린다.
        [self subAdlibViewInterstitialReceived:@"inmobi"];
        [ad presentInterstitialAnimated:YES];
        
    } else {
        [self subAdlibViewInterstitialFailed:@"inmobi"];
        self.interstitial = nil;
    }
}

- (void)interstitial:(IMInterstitial *)ad didFailToReceiveAdWithError:(IMError *)error
{
    // 전면광고 실패를 알린다.
    [self subAdlibViewInterstitialFailed:@"inmobi"];
    self.interstitial = nil;
}

- (void)interstitialDidDismissScreen:(IMInterstitial *)ad
{
    // 전면광고 닫힘을 알린다.
    [self subAdlibViewInterstitialClosed:@"inmobi"];
    self.interstitial = nil;
}

- (void)interstitialWillLeaveApplication:(IMInterstitial *)ad
{
    // 전면 광고 클릭 리포팅
    [self reportInterstitialClickEvent];
}

@end
