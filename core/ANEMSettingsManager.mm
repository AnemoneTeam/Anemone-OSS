#import "ANEMSettingsManager.h"
#import <objc/runtime.h>

#pragma clang diagnostic push 
#pragma clang diagnostic ignored "-Wambiguous-macro"
#if TARGET_IPHONE_SIMULATOR
#define HOMEDIR NSHomeDirectory()
#else
#define HOMEDIR @"/var/mobile"
#endif
#pragma clang diagnostic pop

#define preferenceFilePath [HOMEDIR stringByAppendingPathComponent:@"Library/Preferences/com.anemoneteam.anemone.plist"]
#define preferenceOrderingFilePath [HOMEDIR stringByAppendingPathComponent:@"Library/Preferences/com.anemoneteam.anemoneordering.plist"]
#define optiThemeTouchFilePath [HOMEDIR stringByAppendingPathComponent:@"Library/Preferences/com.anemoneteam.optithemereloaded"]

@interface SBIconViewMap : NSObject
+ (SBIconViewMap *)homescreenMap;
- (void)recycleAndPurgeAll;
@end

@interface SBIconController : NSObject 
+ (instancetype)sharedInstance;
- (SBIconViewMap *)homescreenIconViewMap;
@end

@implementation ANEMSettingsManager
- (instancetype)init {
	self = [super init];
	if (self){
		_CGImageHookEnabled = YES;
	}
	return self;
}

+ (instancetype)sharedManager {
	static ANEMSettingsManager *sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});

	return sharedInstance;
}

- (NSString *)themesDir {
#pragma clang diagnostic push 
#pragma clang diagnostic ignored "-Wambiguous-macro"
#if TARGET_IPHONE_SIMULATOR
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
		return @"/Library/Themes/iPad";
	else
		return @"/Library/Themes/iPhone";
#endif
#pragma clang diagnostic pop
	return @"/Library/Themes";
}

- (void)forceReloadNow {
	if (kCFCoreFoundationVersionNumber > MaxSupportedCFVersion)
		return;
	if (_themeSettings)
		[_themeSettings release];
	_themeSettings = nil;

#ifndef NO_OPTITHEME
	if (_optiThemeReloadDate)
		[_optiThemeReloadDate release];
	_optiThemeReloadDate = nil;
#endif

	[self themeSettings];
	for (NSObject<AnemoneEventHandler> *handler in _eventHandlers){
		[handler reloadTheme];
	}

	SBIconController *iconController = [objc_getClass("SBIconController") sharedInstance];
	SBIconViewMap *map = nil;
	if ([iconController respondsToSelector:@selector(homescreenIconViewMap)])
		map = [iconController homescreenIconViewMap];
	else
		map = [objc_getClass("SBIconViewMap") homescreenMap];
	[map recycleAndPurgeAll];
}

- (BOOL)isCGImageHookEnabled {
	return _CGImageHookEnabled;
}

- (void)setCGImageHookEnabled:(BOOL)enabled {
	_CGImageHookEnabled = enabled;
}

- (BOOL)onlyLoadThemedCGImages {
	return _loadOnlyThemedCGImages;
}

- (void)setOnlyLoadThemedCGImages:(BOOL)load {
	_loadOnlyThemedCGImages = load;
}

- (BOOL)masksOnly {
	return NO;
}

#ifndef NO_OPTITHEME
- (NSDate *)optiThemeReloadDate {
	return _optiThemeReloadDate;
}

- (BOOL)optithemeEnabled {
	return _optithemeEnabled;
}

- (void)setOptithemeEnabled:(BOOL)enabled {
	_optithemeEnabled = enabled;
}
#endif

- (void)addEventHandler:(NSObject<AnemoneEventHandler> *)handler {
	if (!_eventHandlers){
		_eventHandlers = [[NSMutableArray alloc] init];
	}
	[_eventHandlers addObject:handler];
}

- (NSArray *)themeSettings {
	if (kCFCoreFoundationVersionNumber > MaxSupportedCFVersion)
		return nil;
	if (!_themeSettings){
		NSDictionary *settingsPlist = [NSDictionary dictionaryWithContentsOfFile:preferenceFilePath];
		NSMutableArray *rawthemes = [NSMutableArray arrayWithContentsOfFile:preferenceOrderingFilePath];
		NSMutableArray *themes = nil;
		if (rawthemes){
			themes = [NSMutableArray array];
			for (NSString *theme in rawthemes){
				[themes addObject:[[theme componentsSeparatedByString:@".theme"] objectAtIndex:0]];
			}
		}
		if (!themes)
			themes = (NSMutableArray *)[settingsPlist allKeys];
		NSMutableArray *themeSettings = [[NSMutableArray alloc] init];
		for (NSString *themeName in themes) {
			BOOL activeTheme = [[[settingsPlist objectForKey:themeName] objectForKey:@"Enabled"] boolValue];
			if (activeTheme) {
				[themeSettings addObject:themeName];
			}
		}
		_themeSettings = themeSettings;
		_loadOnlyThemedCGImages = NO;
#ifndef NO_OPTITHEME
		_optithemeEnabled = YES;
		NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:optiThemeTouchFilePath error:nil];
		NSDate *date = [attributes fileModificationDate];
		_optiThemeReloadDate = [date retain];
#endif
	}
	return _themeSettings;
}
@end