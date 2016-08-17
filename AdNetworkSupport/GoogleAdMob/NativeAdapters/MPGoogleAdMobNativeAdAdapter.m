#import "MPGoogleAdMobNativeAdAdapter.h"

#import "MPCoreInstanceProvider.h"
#import "MPLogging.h"
#import "MPNativeAdConstants.h"
#import "MPNativeAdError.h"

static NSString *const kGADMAdvertiserKey = @"advertiser";
static NSString *const kGADMPriceKey = @"price";
static NSString *const kGADMStoreKey = @"store";

@implementation MPGoogleAdMobNativeAdAdapter

@synthesize properties = _properties;
@synthesize defaultActionURL = _defaultActionURL;

- (instancetype)initWithAdMobNativeContentAd:(GADNativeContentAd *)adMobNativeContentAd {
  if (self = [super init]) {
    self.adMobNativeContentAd = adMobNativeContentAd;

    NSMutableDictionary *properties = [NSMutableDictionary dictionary];

    if (adMobNativeContentAd.headline) {
      properties[kAdTitleKey] = adMobNativeContentAd.headline;
    }

    if (adMobNativeContentAd.body) {
      properties[kAdTextKey] = adMobNativeContentAd.body;
    }

    if (adMobNativeContentAd.callToAction) {
      properties[kAdCTATextKey] = adMobNativeContentAd.callToAction;
    }

    GADNativeAdImage *mainImage = (GADNativeAdImage *)adMobNativeContentAd.images.firstObject;
    if ([mainImage.imageURL absoluteString]) {
      properties[kAdMainImageKey] = mainImage.imageURL.absoluteString;
    }

    if (adMobNativeContentAd.logo.image) {
      properties[kAdIconImageKey] = adMobNativeContentAd.logo.image;
    }

    if (adMobNativeContentAd.advertiser) {
      properties[kGADMAdvertiserKey] = adMobNativeContentAd.advertiser;
    }

    _properties = properties;
  }

  return self;
}

- (instancetype)initWithAdMobNativeAppInstallAd:(GADNativeAppInstallAd *)adMobNativeAppInstallAd {
  if (self = [super init]) {
    self.adMobNativeAppInstallAd = adMobNativeAppInstallAd;

    NSMutableDictionary *properties = [NSMutableDictionary dictionary];

    if (adMobNativeAppInstallAd.headline) {
      properties[kAdTitleKey] = adMobNativeAppInstallAd.headline;
    }

    GADNativeAdImage *mainImage = (GADNativeAdImage *)adMobNativeAppInstallAd.images.firstObject;
    if ([mainImage.imageURL absoluteString]) {
      properties[kAdMainImageKey] = mainImage.imageURL.absoluteString;
    }

    if ([adMobNativeAppInstallAd.icon.imageURL absoluteString]) {
      properties[kAdIconImageKey] = adMobNativeAppInstallAd.icon.imageURL.absoluteString;
    }

    if (adMobNativeAppInstallAd.body) {
      properties[kAdTextKey] = adMobNativeAppInstallAd.body;
    }

    if (adMobNativeAppInstallAd.starRating) {
      properties[kAdStarRatingKey] = adMobNativeAppInstallAd.starRating;
    }

    if (adMobNativeAppInstallAd.callToAction) {
      properties[kAdCTATextKey] = adMobNativeAppInstallAd.callToAction;
    }

    if (adMobNativeAppInstallAd.price) {
      properties[kGADMPriceKey] = adMobNativeAppInstallAd.price;
    }

    if (adMobNativeAppInstallAd.store) {
      properties[kGADMStoreKey] = adMobNativeAppInstallAd.store;
    }

    _properties = properties;
  }

  return self;
}

#pragma mark - <MPNativeAdAdapter>

- (BOOL)enableThirdPartyClickTracking {
  return YES;
}

@end
