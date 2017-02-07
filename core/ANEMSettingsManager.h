#include "AnemoneEventHandler.h"
#define SupportsNoExtensionDir YES
#define MaxSupportedCFVersion 1348.22 // Only support up to iOS 10.2

@interface ANEMSettingsManager : NSObject {
	NSArray *_themeSettings;
	BOOL _CGImageHookEnabled;
	BOOL _loadOnlyThemedCGImages;
	BOOL _optithemeEnabled;

	NSMutableArray *_eventHandlers;

#ifndef NO_OPTITHEME
	NSDate *_optiThemeReloadDate;
#endif
}
+ (instancetype)sharedManager;
- (NSArray *)themeSettings;
- (NSString *)themesDir;
- (void)forceReloadNow;

- (BOOL)onlyLoadThemedCGImages;
- (void)setOnlyLoadThemedCGImages:(BOOL)load;

- (BOOL)isCGImageHookEnabled;
- (void)setCGImageHookEnabled:(BOOL)enabled;

- (BOOL)masksOnly;

#ifndef NO_OPTITHEME
- (NSDate *)optiThemeReloadDate;
- (BOOL)optithemeEnabled;
- (void)setOptithemeEnabled:(BOOL)enabled;
#endif

- (void)addEventHandler:(NSObject<AnemoneEventHandler> *)handler;
@end
