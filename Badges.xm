#import "core/ANEMSettingsManager.h"
#import "UIColor+HTMLColors.h"

static NSMutableDictionary *badgeSettings = nil;
static BOOL badgeSettingsLoaded = NO;

static NSString *badgeFont = nil;
static CGFloat badgeFontSize = 16.0f;
static CGFloat badgeHeightChange = 0.0f; //0.0f for classic
static CGFloat badgeWidthChange = 0.0f; //2.0f for classic
static CGFloat badgeXoffset = 0.0f; //2.0f for classic
static CGFloat badgeYoffset = 0.0f; //-2.0f for classic
static CGFloat badgeTextShadowXoffset = 0.0f;
static CGFloat badgeTextShadowYoffset = 0.0f;
static CGFloat badgeTextShadowBlurRadius = 0.0f;
static UIColor *badgeTextColor = nil;
static UIColor *badgeTextShadowColor = nil;
static NSString *badgeTextCase = nil;

static void getBadgeSettings()
{
	badgeSettingsLoaded = YES;
	NSArray *themes = [[%c(ANEMSettingsManager) sharedManager] themeSettings];
	NSString *themesDir = [[%c(ANEMSettingsManager) sharedManager] themesDir];

	for (NSString *theme in themes)
	{
		NSString *path = [NSString stringWithFormat:@"%@/%@.theme/Info.plist",themesDir,theme];
		if (SupportsNoExtensionDir && ![[NSFileManager defaultManager] fileExistsAtPath:path]){
			path = [NSString stringWithFormat:@"%@/%@/Info.plist",themesDir,theme];
		}
		NSDictionary *themeDict = [NSDictionary dictionaryWithContentsOfFile:path];
		if (themeDict[@"BadgeSettings"] != nil)
		{
			badgeSettings = [themeDict[@"BadgeSettings"] mutableCopy];
			return;
		}
		if (themeDict[@"ThemeLib-BadgeSettings"] != nil)
		{
			badgeSettings = [themeDict[@"ThemeLib-BadgeSettings"] mutableCopy];
			return;
		}
	}
}

static void loadBadgeSettings(){
	if (badgeSettingsLoaded)
		return;

	[badgeTextCase release];
	badgeTextCase = nil;

	badgeFont = @"HelveticaNeue";
	if (kCFCoreFoundationVersionNumber > 1240)
		badgeFont = @".SFUIText-Regular";
	if (kCFCoreFoundationVersionNumber > 1333)
		badgeFont = @".SFUIText";

	badgeTextColor = [UIColor whiteColor];
	badgeTextShadowColor = [UIColor clearColor];

	getBadgeSettings();
	if ([badgeSettings objectForKey:@"FontName"])
		badgeFont = [badgeSettings objectForKey:@"FontName"];
	if ([badgeSettings objectForKey:@"FontSize"])
		badgeFontSize = [[badgeSettings objectForKey:@"FontSize"] floatValue];
	if ([badgeSettings objectForKey:@"HeightChange"])
		badgeHeightChange = [[badgeSettings objectForKey:@"HeightChange"] floatValue];
	if ([badgeSettings objectForKey:@"WidthChange"])
		badgeWidthChange = [[badgeSettings objectForKey:@"WidthChange"] floatValue];
	if ([badgeSettings objectForKey:@"TextXoffset"])
		badgeXoffset = [[badgeSettings objectForKey:@"TextXoffset"] floatValue];
	if ([badgeSettings objectForKey:@"TextYoffset"])
		badgeYoffset = [[badgeSettings objectForKey:@"TextYoffset"] floatValue];
	if ([badgeSettings objectForKey:@"RawTextColor"] && [[badgeSettings objectForKey:@"RawTextColor"] isKindOfClass:[UIColor class]])
		badgeTextColor = [badgeSettings objectForKey:@"RawTextColor"];
	else if ([badgeSettings objectForKey:@"TextColor"]){
		badgeTextColor = [UIColor anem_colorWithCSS:[badgeSettings objectForKey:@"TextColor"]];
		[badgeSettings setObject:badgeTextColor forKey:@"RawTextColor"];
	}
	if ([badgeSettings objectForKey:@"TextCase"])
		badgeTextCase = [[[badgeSettings objectForKey:@"TextCase"] lowercaseString] retain];
	if ([badgeSettings objectForKey:@"ShadowXoffset"])
		badgeTextShadowXoffset = [[badgeSettings objectForKey:@"ShadowXoffset"] floatValue];
	if ([badgeSettings objectForKey:@"ShadowYoffset"])
		badgeTextShadowYoffset = [[badgeSettings objectForKey:@"ShadowYoffset"] floatValue];
	if ([badgeSettings objectForKey:@"ShadowBlurRadius"])
		badgeTextShadowBlurRadius = [[badgeSettings objectForKey:@"ShadowBlurRadius"] floatValue];
	if ([badgeSettings objectForKey:@"RawShadowColor"] && [[badgeSettings objectForKey:@"RawShadowColor"] isKindOfClass:[UIColor class]])
		badgeTextShadowColor = [badgeSettings objectForKey:@"RawShadowColor"];
	else if ([badgeSettings objectForKey:@"ShadowColor"]){
		badgeTextShadowColor = [UIColor anem_colorWithCSS:[badgeSettings objectForKey:@"ShadowColor"]];
		[badgeSettings setObject:badgeTextShadowColor forKey:@"RawShadowColor"];
	}
}

@interface SBIconAccessoryImage : UIImage
- (id)initWithImage:(UIImage *)image;
@end

@interface AnemoneBadgesEventHandler: NSObject <AnemoneEventHandler>
- (void)reloadTheme;
@end

@implementation AnemoneBadgesEventHandler
- (void)reloadTheme {
	badgeFont = nil;

	badgeFontSize = 16.0f;
	badgeHeightChange = 0.0f; //0.0f for classic
	badgeWidthChange = 0.0f; //2.0f for classic
	badgeXoffset = 0.0f; //2.0f for classic
	badgeYoffset = 0.0f; //-2.0f for classic
	badgeTextShadowXoffset = 0.0f;
	badgeTextShadowYoffset = 0.0f;
	badgeTextShadowBlurRadius = 0.0f;

	badgeTextColor = nil;

	badgeTextShadowColor = nil;

	if (badgeTextCase)
		[badgeTextCase release];
	badgeTextCase = nil;

	if (badgeSettings)
		[badgeSettings release];
	badgeSettings = nil;
	badgeSettingsLoaded = NO;

	loadBadgeSettings();
}
@end

@interface SBDarkeningImageView
@property (nonatomic, retain) UIImage *image;
@end

@interface SBIconBadgeView : UIView
+ (SBIconAccessoryImage *)_checkoutBackgroundImage;
- (void)prepareForReuse;
@end

%hook SBIconView
- (void)prepareForReuse {
	%orig;
	SBIconBadgeView *badgeView = [self valueForKey:@"_accessoryView"];
	if ([badgeView respondsToSelector:@selector(prepareForReuse)])
		[badgeView prepareForReuse];
}
%end

%hook SBIconBadgeView

+ (SBIconAccessoryImage *)_checkoutBackgroundImage {
	if ([UIImage imageNamed:@"SBBadgeBG.png"])
		return [[[%c(SBIconAccessoryImage) alloc] initWithImage:[UIImage imageNamed:@"SBBadgeBG.png"]] autorelease];
	else
		return %orig;
}

+ (SBIconAccessoryImage *)_checkoutImageForText:(NSString *)text highlighted:(BOOL)highlighted {
	loadBadgeSettings();

	UIFont *font = [UIFont fontWithName:badgeFont size:badgeFontSize];
	CGSize size = [text sizeWithAttributes:@{NSFontAttributeName:font}];
	if (size.height != 0)
		size.height += badgeHeightChange;
	if (size.width != 0)
		size.width += badgeWidthChange;
	if (size.width == 0 || size.height == 0)
		return %orig;
	UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSetShadowWithColor(ctx, CGSizeMake(badgeTextShadowXoffset,badgeTextShadowYoffset), badgeTextShadowBlurRadius, badgeTextShadowColor.CGColor);
	
	if ([badgeTextCase isEqualToString:@"lowercase"])
		text = [text lowercaseString];
	else if ([badgeTextCase isEqualToString:@"uppercase"])
		text = [text uppercaseString];

	[text drawAtPoint:CGPointMake(badgeXoffset,badgeYoffset) withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:badgeTextColor}];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return [[[%c(SBIconAccessoryImage) alloc] initWithImage:image] autorelease];
}

- (void)prepareForReuse {
	%orig;
	
	BOOL isiOS70 = (kCFCoreFoundationVersionNumber < 847.24);

	SBDarkeningImageView *backgroundView = [self valueForKey:@"_backgroundView"];

	SBIconAccessoryImage *backgroundImage = [%c(SBIconBadgeView) _checkoutBackgroundImage];
	
	UIImage *currentBackgroundImage = backgroundView.image;
	if (isiOS70)
		currentBackgroundImage = [self valueForKey:@"_backgroundImage"];
	else
		currentBackgroundImage = backgroundView.image;

	[self setValue:backgroundImage forKey:@"_backgroundImage"];

	if (isiOS70)
		backgroundView.image = backgroundImage;
	else {
		UIEdgeInsets capInsets = currentBackgroundImage.capInsets;
		backgroundView.image = [backgroundImage resizableImageWithCapInsets:capInsets];
	}
}

%end

%ctor {
	if (kCFCoreFoundationVersionNumber > MaxSupportedCFVersion)
		return;
	if (objc_getClass("ANEMSettingsManager") == nil){
		dlopen("/Library/MobileSubstrate/DynamicLibraries/AnemoneCore.dylib",RTLD_LAZY);
	}
	[[%c(ANEMSettingsManager) sharedManager] addEventHandler:[AnemoneBadgesEventHandler new]];
}