#import <GoogleMobileAds/GoogleMobileAds.h>

#import "MPGoogleAdMobNativeAdAdapter.h"
#import "MPGoogleAdMobNativeCustomEvent.h"
#import "MPInstanceProvider.h"
#import "MPLogging.h"
#import "MPNativeAd.h"
#import "MPNativeAdConstants.h"
#import "MPNativeAdError.h"
#import "MPNativeAdUtils.h"

@interface MPGoogleAdMobNativeCustomEvent ()<
    GADAdLoaderDelegate, GADNativeAppInstallAdLoaderDelegate, GADNativeContentAdLoaderDelegate>

/// GADAdLoader instance.
@property(nonatomic, strong) GADAdLoader *adLoader;

@end

@implementation MPGoogleAdMobNativeCustomEvent

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info {
  UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
  UIViewController *rootViewController = window.rootViewController;
  while (rootViewController.presentedViewController) {
    rootViewController = rootViewController.presentedViewController;
  }
  GADRequest *request = [GADRequest request];
  request.requestAgent = @"MoPub";
  GADNativeAdImageAdLoaderOptions *nativeAdImageLoaderOptions =
      [[GADNativeAdImageAdLoaderOptions alloc] init];
  nativeAdImageLoaderOptions.disableImageLoading = YES;
  nativeAdImageLoaderOptions.shouldRequestMultipleImages = NO;
  nativeAdImageLoaderOptions.preferredImageOrientation =
      GADNativeAdImageAdLoaderOptionsOrientationAny;

  NSString *adUnitID = info[@"adunit"];
  if (!adUnitID) {
    [self.delegate nativeCustomEvent:self
            didFailToLoadAdWithError:MPNativeAdNSErrorForInvalidAdServerResponse(
                                         @"adUnit ID cannot be nil.")];

    return;
  }

  self.adLoader = [[GADAdLoader alloc]
        initWithAdUnitID:adUnitID
      rootViewController:rootViewController
                 adTypes:@[ kGADAdLoaderAdTypeNativeAppInstall, kGADAdLoaderAdTypeNativeContent ]
                 options:@[ nativeAdImageLoaderOptions ]];
  self.adLoader.delegate = self;
    
   // request.testDevices = @[ kGADSimulatorID ];
    
  [self.adLoader loadRequest:request];
}

#pragma mark GADAdLoaderDelegate implementation

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(GADRequestError *)error {
  [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:error];
}

#pragma mark GADNativeAppInstallAdLoaderDelegate implementation

- (void)adLoader:(GADAdLoader *)adLoader
    didReceiveNativeAppInstallAd:(GADNativeAppInstallAd *)nativeAppInstallAd {
  if (![self isValidAppInstallAd:nativeAppInstallAd]) {
    [self.delegate nativeCustomEvent:self
            didFailToLoadAdWithError:MPNativeAdNSErrorForInvalidAdServerResponse(
                                         @"Missing one or more required assets.")];
    return;
  }

  MPGoogleAdMobNativeAdAdapter *adapter =
      [[MPGoogleAdMobNativeAdAdapter alloc] initWithAdMobNativeAppInstallAd:nativeAppInstallAd];
  MPNativeAd *moPubNativeAd = [[MPNativeAd alloc] initWithAdAdapter:adapter];

  NSMutableArray *imageURLs = [NSMutableArray array];

  if ([moPubNativeAd.properties[kAdIconImageKey] length]) {
    if (![MPNativeAdUtils addURLString:moPubNativeAd.properties[kAdIconImageKey]
                            toURLArray:imageURLs]) {
      [self.delegate nativeCustomEvent:self
              didFailToLoadAdWithError:MPNativeAdNSErrorForInvalidImageURL()];
    }
  }

  if ([moPubNativeAd.properties[kAdMainImageKey] length]) {
    if (![MPNativeAdUtils addURLString:moPubNativeAd.properties[kAdMainImageKey]
                            toURLArray:imageURLs]) {
      [self.delegate nativeCustomEvent:self
              didFailToLoadAdWithError:MPNativeAdNSErrorForInvalidImageURL()];
    }
  }

  [super precacheImagesWithURLs:imageURLs
                completionBlock:^(NSArray *errors) {
                  if (errors) {
                    [self.delegate nativeCustomEvent:self
                            didFailToLoadAdWithError:MPNativeAdNSErrorForImageDownloadFailure()];
                  } else {
                    [self.delegate nativeCustomEvent:self didLoadAd:moPubNativeAd];
                  }
                }];
}

#pragma mark GADNativeContentAdLoaderDelegate implementation

- (void)adLoader:(GADAdLoader *)adLoader
    didReceiveNativeContentAd:(GADNativeContentAd *)nativeContentAd {
  if (![self isValidContentAd:nativeContentAd]) {
    [self.delegate nativeCustomEvent:self
            didFailToLoadAdWithError:MPNativeAdNSErrorForInvalidAdServerResponse(
                                         @"Missing one or more required assets.")];
    return;
  }

  MPGoogleAdMobNativeAdAdapter *adapter =
      [[MPGoogleAdMobNativeAdAdapter alloc] initWithAdMobNativeContentAd:nativeContentAd];
  MPNativeAd *interfaceAd = [[MPNativeAd alloc] initWithAdAdapter:adapter];

  NSMutableArray *imageURLs = [NSMutableArray array];

  if ([interfaceAd.properties[kAdIconImageKey] length]) {
    if (![MPNativeAdUtils addURLString:interfaceAd.properties[kAdIconImageKey]
                            toURLArray:imageURLs]) {
      [self.delegate nativeCustomEvent:self
              didFailToLoadAdWithError:MPNativeAdNSErrorForInvalidImageURL()];
    }
  }

  if ([interfaceAd.properties[kAdMainImageKey] length]) {
    if (![MPNativeAdUtils addURLString:interfaceAd.properties[kAdMainImageKey]
                            toURLArray:imageURLs]) {
      [self.delegate nativeCustomEvent:self
              didFailToLoadAdWithError:MPNativeAdNSErrorForInvalidImageURL()];
    }
  }

  [super precacheImagesWithURLs:imageURLs
                completionBlock:^(NSArray *errors) {
                  if (errors) {
                    [self.delegate nativeCustomEvent:self
                            didFailToLoadAdWithError:MPNativeAdNSErrorForImageDownloadFailure()];
                  } else {
                    [self.delegate nativeCustomEvent:self didLoadAd:interfaceAd];
                  }
                }];
}

#pragma mark - Private Methods

/// Checks the app install ad has required assets or not.
- (BOOL)isValidAppInstallAd:(GADNativeAppInstallAd *)appInstallAd {
  return (appInstallAd.headline && appInstallAd.body && appInstallAd.icon &&
          appInstallAd.images.count && appInstallAd.callToAction);
}

/// Checks the content ad has required assets or not.
- (BOOL)isValidContentAd:(GADNativeContentAd *)contentAd {
  return (contentAd.headline && contentAd.body && contentAd.logo && contentAd.images.count &&
          contentAd.callToAction);
}
@end
