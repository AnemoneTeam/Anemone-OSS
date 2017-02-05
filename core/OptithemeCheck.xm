#import "ANEMSettingsManager.h"

#pragma clang diagnostic push 
#pragma clang diagnostic ignored "-Wambiguous-macro"
#if TARGET_IPHONE_SIMULATOR
#define HOMEDIR NSHomeDirectory()
#else
#define HOMEDIR @"/var/mobile"
#endif
#pragma clang diagnostic pop
#define optiThemeTouchFilePath [HOMEDIR stringByAppendingPathComponent:@"Library/Preferences/com.anemoneteam.optithemereloaded"]

%hook UIApplication
- (void)applicationDidResume {
	%orig;
	NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:optiThemeTouchFilePath error:nil];
	NSDate *date = [attributes fileModificationDate];
	if ([date timeIntervalSinceDate:[[ANEMSettingsManager sharedManager] optiThemeReloadDate]] > 0){
		[[ANEMSettingsManager sharedManager] setOptithemeEnabled:NO];
	}
}
%end