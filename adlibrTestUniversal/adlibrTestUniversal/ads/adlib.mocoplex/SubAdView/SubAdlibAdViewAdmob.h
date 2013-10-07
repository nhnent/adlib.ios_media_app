/*
 * adlibr - Library for mobile AD mediation.
 * http://adlibr.com
 * Copyright (c) 2012-2013 Mocoplex, Inc.  All rights reserved.
 * Licensed under the BSD open source license.
 */

/*
 * confirmed compatible with admob SDK 6.5.0
 */

#import <UIKit/UIKit.h>
#import "SubAdlibAdViewCore.h"
#import "GADBannerView.h"
#import "GADInterstitial.h"

@interface SubAdlibAdViewAdmob : SubAdlibAdViewCore<GADBannerViewDelegate>
{
    BOOL iPad;    
    GADBannerView *ad;
}

@end
