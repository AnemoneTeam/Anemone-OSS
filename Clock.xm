#import "core/ANEMSettingsManager.h"

@interface UIImage (Bundle)
+ (UIImage *)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle;
@end

@interface SBClockApplicationIconImageView : UIImageView
- (UIImage *)contentsImage;
- (void)_setAnimating:(BOOL)animating;
@end

static UIImage *hourHandImage;
static UIImage *minuteHandImage;
static UIImage *secondHandImage;
static UIImage *redDotImage;
static UIImage *blackDotImage;

static UIColor *hourHandColor;
static UIColor *minuteHandColor;
static UIColor *secondHandColor;
static UIColor *redDotColor;
static UIColor *blackDotColor;

static BOOL clockImagesLoaded = NO;
static BOOL clockIconNeedsUpdate = NO;

static void loadClockImages(){
	if (clockImagesLoaded)
		return;

	hourHandImage = [[UIImage imageNamed:@"ClockIconHourHand"] retain];
	minuteHandImage = [[UIImage imageNamed:@"ClockIconHourHand"] retain];
	secondHandImage = [[UIImage imageNamed:@"ClockIconHourHand"] retain];
	redDotImage = [[UIImage imageNamed:@"ClockIconHourHand"] retain];
	blackDotImage = [[UIImage imageNamed:@"ClockIconHourHand"] retain];

	clockImagesLoaded = YES;
}

%group all
%hook SBClockApplicationIconImageView
- (id)initWithFrame:(CGRect)frame {
	self = %orig;

	loadClockImages();

	CALayer *hours = [self valueForKey:@"_hours"];
	CALayer *minutes = [self valueForKey:@"_minutes"];
	CALayer *seconds = [self valueForKey:@"_seconds"];
	CALayer *redDot = [self valueForKey:@"_redDot"];
	CALayer *blackDot = [self valueForKey:@"_blackDot"];

	hourHandColor = [[UIColor alloc] initWithCGColor:hours.backgroundColor];
	minuteHandColor = [[UIColor alloc] initWithCGColor:minutes.backgroundColor];
	secondHandColor = [[UIColor alloc] initWithCGColor:seconds.backgroundColor];
	redDotColor = [[UIColor alloc] initWithCGColor:redDot.backgroundColor];
	blackDotColor = [[UIColor alloc] initWithCGColor:blackDot.backgroundColor];

	if (hourHandImage){
		hours.contents = (id)hourHandImage.CGImage;
		hours.backgroundColor = [[UIColor clearColor] CGColor];
	}
	if (minuteHandImage){
		minutes.contents = (id)minuteHandImage.CGImage;
		minutes.backgroundColor = [[UIColor clearColor] CGColor];
	}
	if (secondHandImage){
		seconds.contents = (id)secondHandImage.CGImage;
		seconds.backgroundColor = [[UIColor clearColor] CGColor];
	}
	if (redDotImage){
		redDot.contents = (id)redDotImage.CGImage;
		redDot.backgroundColor = [[UIColor clearColor] CGColor];
	}
	if (blackDotImage){
		blackDot.contents = (id)blackDotImage.CGImage;
		blackDot.backgroundColor = [[UIColor clearColor] CGColor];
	}
#pragma clang diagnostic push 
#pragma clang diagnostic ignored "-Wambiguous-macro"
#if TARGET_IPHONE_SIMULATOR
	[self _setAnimating:YES];
#endif
#pragma clang diagnostic pop

	clockIconNeedsUpdate = NO;
	return self;
}

- (void)updateAnimatingState {
	%orig;
	if (!clockIconNeedsUpdate)
		return;

	CALayer *hours = [self valueForKey:@"_hours"];
	CALayer *minutes = [self valueForKey:@"_minutes"];
	CALayer *seconds = [self valueForKey:@"_seconds"];
	CALayer *redDot = [self valueForKey:@"_redDot"];
	CALayer *blackDot = [self valueForKey:@"_blackDot"];
	if (hourHandImage){
		hours.contents = (id)hourHandImage.CGImage;
		hours.backgroundColor = [[UIColor clearColor] CGColor];
	} else {
		hours.contents = nil;
		hours.backgroundColor = [hourHandColor CGColor];
	}
	if (minuteHandImage){
		minutes.contents = (id)minuteHandImage.CGImage;
		minutes.backgroundColor = [[UIColor clearColor] CGColor];
	} else {
		minutes.contents = nil;
		minutes.backgroundColor = [minuteHandColor CGColor];
	}
	if (secondHandImage){
		seconds.contents = (id)secondHandImage.CGImage;
		seconds.backgroundColor = [[UIColor clearColor] CGColor];
	} else {
		seconds.contents = nil;
		seconds.backgroundColor = [secondHandColor CGColor];
	}
	if (redDotImage){
		redDot.contents = (id)redDotImage.CGImage;
		redDot.backgroundColor = [[UIColor clearColor] CGColor];
	} else {
		redDot.contents = nil;
		redDot.backgroundColor = [redDotColor CGColor];
	}
	if (blackDotImage){
		blackDot.contents = (id)blackDotImage.CGImage;
		blackDot.backgroundColor = [[UIColor clearColor] CGColor];
	} else {
		blackDot.contents = nil;
		blackDot.backgroundColor = [blackDotColor CGColor];
	}

	clockIconNeedsUpdate = NO;
}

- (BOOL)isAnimationAllowed {
#pragma clang diagnostic push 
#pragma clang diagnostic ignored "-Wambiguous-macro"
#if TARGET_IPHONE_SIMULATOR
	return YES;
#else
	return %orig;
#endif
#pragma clang diagnostic pop
}

- (UIImage *)contentsImage {
	UIImage *origImage = %orig;

	CGSize origImageSize = origImage.size;
	if (origImage.scale == 1){
		CGFloat scale = [[UIScreen mainScreen] scale];
		origImageSize.width /= scale;
		origImageSize.height /= scale;
	}

	UIImage *ret = [UIImage imageNamed:@"ClockIconBackgroundSquare"];

	UIGraphicsBeginImageContextWithOptions(origImageSize, NO, 0.0);
	
	CGSize imageSize = CGSizeMake(60, 60);
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
		if (MAX([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) == 1366){ //iPad Pro
			imageSize = CGSizeMake(83.5, 83.5);
		} else
			imageSize = CGSizeMake(76, 76);
	}
	
	[ret drawInRect:CGRectMake((origImageSize.width-imageSize.width)/2.0,(origImageSize.height-imageSize.height)/2.0,imageSize.width,imageSize.height)];
	ret = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	if (ret != nil){
		UIImage *maskImage = nil;
		NSBundle *mobileIconsBundle = [NSBundle bundleWithIdentifier:@"com.apple.mobileicons.framework"];
		if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad)
			maskImage = [UIImage imageNamed:@"AppIconMask~iphone" inBundle:mobileIconsBundle];
		else {
			maskImage = [UIImage imageNamed:@"AppIconMask~ipad" inBundle:mobileIconsBundle];
			if (MAX([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) == 1366)
				maskImage = [UIImage imageNamed:@"AppIconMask-RFB~ipad" inBundle:mobileIconsBundle];
		}
		if (maskImage){
			UIGraphicsBeginImageContextWithOptions(origImageSize, YES, 0.0);
			[[UIColor whiteColor] setFill];
			UIRectFill(CGRectMake(0,0,origImageSize.width,origImageSize.height));
			[maskImage drawAtPoint:CGPointMake((origImageSize.width-maskImage.size.width)/2.0,(origImageSize.height-maskImage.size.height)/2.0)];
			maskImage = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();
			CGImageRef maskRef = maskImage.CGImage;
			CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
												CGImageGetHeight(maskRef),
												CGImageGetBitsPerComponent(maskRef),
												CGImageGetBitsPerPixel(maskRef),
												CGImageGetBytesPerRow(maskRef),
												CGImageGetDataProvider(maskRef),
												NULL, false);
			CGImageRef masked = CGImageCreateWithMask([ret CGImage], mask);
			CGImageRelease(mask);
			ret = [UIImage imageWithCGImage:masked scale:ret.scale orientation:ret.imageOrientation];
			CGImageRelease(masked);
		}
	} else {
		ret = %orig;
	}
	return ret;
}
%end
%end

@interface AnemoneClockEventHandler: NSObject <AnemoneEventHandler>
- (void)reloadTheme;
@end

@implementation AnemoneClockEventHandler
- (void)reloadTheme {
	if (hourHandImage)
		[hourHandImage release];
	hourHandImage = nil;

	if (minuteHandImage)
		[minuteHandImage release];
	minuteHandImage = nil;

	if (secondHandImage)
		[secondHandImage release];
	secondHandImage = nil;

	if (redDotImage)
		[redDotImage release];
	redDotImage = nil;

	if (blackDotImage)
		[blackDotImage release];
	blackDotImage = nil;

	clockImagesLoaded = NO;
	loadClockImages();
	clockIconNeedsUpdate = YES;
}
@end

%ctor {
	if (kCFCoreFoundationVersionNumber > MaxSupportedCFVersion)
		return;
	%init(all);
	if (objc_getClass("ANEMSettingsManager") == nil){
		dlopen("/Library/MobileSubstrate/DynamicLibraries/AnemoneCore.dylib",RTLD_LAZY);
	}
	[[%c(ANEMSettingsManager) sharedManager] addEventHandler:[AnemoneClockEventHandler new]];
}
