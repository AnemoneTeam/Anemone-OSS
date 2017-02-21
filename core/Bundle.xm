#import "ANEMSettingsManager.h"
#import "Bundle.h"
#import <objc/runtime.h>
#import <dlfcn.h>

//sysctl needed for legacy support (check iPad vs iPhone)
#include <sys/types.h>
#include <sys/sysctl.h>

#ifndef NO_OPTITHEME
#import "../common/CPDistributedMessagingCenter.h"
#import <rocketbootstrap/rocketbootstrap.h>
#endif

static NSMutableDictionary *cachedBundles = nil;

@implementation NSBundle (Anemone)
+ (NSBundle *) anemoneBundleWithFile:(NSString *)path {
	path = [path stringByDeletingLastPathComponent];
	if (path == nil || [path length] == 0 || [path isEqualToString:@"/"])
		return nil;
	NSBundle *bundle = nil;
	if (!cachedBundles)
		cachedBundles = [[NSMutableDictionary alloc] initWithCapacity:5];

	bundle = [cachedBundles objectForKey:path];
	if ((NSNull *)bundle == [NSNull null])
		return nil;
	else if (bundle == nil){
		if ([[NSFileManager defaultManager] fileExistsAtPath:[path stringByAppendingPathComponent:@"Info.plist"]])
			bundle = [NSBundle bundleWithPath:path];
		if (bundle == nil)
			bundle = [NSBundle anemoneBundleWithFile:path];
		[cachedBundles setObject:(bundle == nil ? [NSNull null] : bundle) forKey:path];
	}
	return bundle;
}
@end

@implementation NSString (Anemone)
- (NSString *) anemoneThemedPath {
	return [self anemoneThemedPath:NO];
}

- (NSString *) anemoneThemedPath:(BOOL)enableLegacy {
	if (kCFCoreFoundationVersionNumber > MaxSupportedCFVersion)
		return self;
	NSString *themesDir = [[ANEMSettingsManager sharedManager] themesDir];

	if ([self hasPrefix:@"/var/stash/anemonecache"])
		return self;
	if ([self hasPrefix:themesDir])
		return self;
	if ([self hasPrefix:@"/var/mobile/Library/Caches"])
		return self;
	if ([self hasSuffix:@".artwork"])
		return self;
	if ([self hasSuffix:@".car"])
		return self;
	self = [self stringByResolvingSymlinksInPath];
	NSString *fileName = [self lastPathComponent];
	NSArray *themes = [[ANEMSettingsManager sharedManager] themeSettings];

	NSBundle *bundle = [NSBundle anemoneBundleWithFile:self];
	if ([[ANEMSettingsManager sharedManager] masksOnly]){
		if (![[bundle bundleIdentifier] isEqualToString:@"com.apple.mobileicons.framework"]){
			return self;
		}
	}

	NSString *fileEnding = fileName;
	if (bundle){
		NSString *prefix = [[bundle bundlePath] stringByResolvingSymlinksInPath];
		if ([self hasPrefix:prefix])
			fileEnding = [self substringFromIndex:[prefix length]+1];
	}

	BOOL useOptithemeInstead = NO;
	#ifndef NO_OPTITHEME
	if ([[ANEMSettingsManager sharedManager] optithemeEnabled]){
		if (bundle){
			NSString *cacheFolder = [@"/var/stash/anemonecache/" stringByAppendingPathComponent:[bundle bundleIdentifier]];
			NSString *completeName = [cacheFolder stringByAppendingPathComponent:@".complete"];

			if ([[NSFileManager defaultManager] fileExistsAtPath:completeName]){
				useOptithemeInstead = YES;
				NSString *path = [NSString stringWithFormat:@"%@/%@",cacheFolder,fileEnding];
				if ([[NSFileManager defaultManager] fileExistsAtPath:path])
					return path;

				if (enableLegacy){
					size_t size;
					sysctlbyname("hw.machine", NULL, &size, NULL, 0);
					char *machine = (char *)malloc(size);
					sysctlbyname("hw.machine", machine, &size, NULL, 0);
					NSString *platform = [NSString stringWithUTF8String:machine];
					free(machine);

					//this is slow and should be avoided
					NSString *suffixToStrip = @"~iphone";
					if ([platform rangeOfString:@"iPad"].location != NSNotFound)
						suffixToStrip = @"~ipad";
					if ([path rangeOfString:suffixToStrip].location != NSNotFound){
						NSString *noSuffixPath = [path stringByReplacingOccurrencesOfString:suffixToStrip withString:@""];
						if ([[NSFileManager defaultManager] fileExistsAtPath:noSuffixPath])
							return noSuffixPath;
					} else {
						NSString *suffixToAdd = [suffixToStrip stringByAppendingString:@".png"];
						NSString *suffixedPath = [path stringByReplacingOccurrencesOfString:@".png" withString:suffixToAdd];
						if ([[NSFileManager defaultManager] fileExistsAtPath:suffixedPath])
							return suffixedPath;
					}
				}
			} else {
				if ([bundle bundlePath] != nil){
					dlopen("/System/Library/PrivateFrameworks/AppSupport.framework/AppSupport", RTLD_NOW);
					CPDistributedMessagingCenter *client = [objc_getClass("CPDistributedMessagingCenter") centerNamed:@"com.anemonetheming.anemone.optitheme"];
					rocketbootstrap_distributedmessagingcenter_apply(client);
					NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[bundle bundlePath],@"Path",nil];
					[client sendMessageName:@"cacheCarWithOptions" userInfo:dict];
				}
			}
		}
	}
	#endif

	NSString *folderName = [[self stringByDeletingLastPathComponent] lastPathComponent];

	for (NSString *theme in themes)
		{
		if (bundle && !useOptithemeInstead){
			NSString *path = [NSString stringWithFormat:@"%@/%@.theme/Bundles/%@/%@",themesDir,theme,bundle.bundleIdentifier,fileEnding];
			if ([[NSFileManager defaultManager] fileExistsAtPath:path])
				return path;

			if (enableLegacy){
				size_t size;
				sysctlbyname("hw.machine", NULL, &size, NULL, 0);
				char *machine = (char *)malloc(size);
				sysctlbyname("hw.machine", machine, &size, NULL, 0);
				NSString *platform = [NSString stringWithUTF8String:machine];
				free(machine);

				//this is slow and should be avoided
				NSString *suffixToStrip = @"~iphone";
				if ([platform rangeOfString:@"iPad"].location != NSNotFound)
					suffixToStrip = @"~ipad";
				if ([path rangeOfString:suffixToStrip].location != NSNotFound){
					NSString *noSuffixPath = [path stringByReplacingOccurrencesOfString:suffixToStrip withString:@""];
					if ([[NSFileManager defaultManager] fileExistsAtPath:noSuffixPath])
						return noSuffixPath;
				} else {
					NSString *suffixToAdd = [suffixToStrip stringByAppendingString:@".png"];
					NSString *suffixedPath = [path stringByReplacingOccurrencesOfString:@".png" withString:suffixToAdd];
					if ([[NSFileManager defaultManager] fileExistsAtPath:suffixedPath])
						return suffixedPath;
				}
			}

			if (SupportsNoExtensionDir){
				path = [NSString stringWithFormat:@"%@/%@/Bundles/%@/%@",themesDir,theme,bundle.bundleIdentifier,fileEnding];
				if ([[NSFileManager defaultManager] fileExistsAtPath:path])
					return path;
			}

			if (enableLegacy){
				size_t size;
				sysctlbyname("hw.machine", NULL, &size, NULL, 0);
				char *machine = (char *)malloc(size);
				sysctlbyname("hw.machine", machine, &size, NULL, 0);
				NSString *platform = [NSString stringWithUTF8String:machine];
				free(machine);

				//this is slow and should be avoided
				NSString *suffixToStrip = @"~iphone";
				if ([platform rangeOfString:@"iPad"].location != NSNotFound)
					suffixToStrip = @"~ipad";
				if ([path rangeOfString:suffixToStrip].location != NSNotFound){
					NSString *noSuffixPath = [path stringByReplacingOccurrencesOfString:suffixToStrip withString:@""];
					if ([[NSFileManager defaultManager] fileExistsAtPath:noSuffixPath])
						return noSuffixPath;
				} else {
					NSString *suffixToAdd = [suffixToStrip stringByAppendingString:@".png"];
					NSString *suffixedPath = [path stringByReplacingOccurrencesOfString:@".png" withString:suffixToAdd];
					if ([[NSFileManager defaultManager] fileExistsAtPath:suffixedPath])
						return suffixedPath;
				}
			}
		}
		NSString *pathFolders = [NSString stringWithFormat:@"%@/%@.theme/Folders/%@/%@",themesDir,theme,folderName,fileName];
		if ([[NSFileManager defaultManager] fileExistsAtPath:pathFolders])
			return pathFolders;
		if (SupportsNoExtensionDir){
			pathFolders = [NSString stringWithFormat:@"%@/%@/Folders/%@/%@",themesDir,theme,folderName,fileName];
			if ([[NSFileManager defaultManager] fileExistsAtPath:pathFolders])
				return pathFolders;
		}
		NSString *pathFallback = [NSString stringWithFormat:@"%@/%@.theme/Fallback/%@",themesDir,theme,fileName];
		if ([[NSFileManager defaultManager] fileExistsAtPath:pathFallback])
			return pathFallback;
		if (SupportsNoExtensionDir){
			pathFallback = [NSString stringWithFormat:@"%@/%@/Fallback/%@",themesDir,theme,fileName];
			if ([[NSFileManager defaultManager] fileExistsAtPath:pathFallback])
				return pathFallback;
		}
	}
	return self;
}
@end

%group BundleHook
%hook NSBundle
/*- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName {
	//XXX: This is broken and needs to be fixed before it can be re-enabled
	// There hasn't been a huge demand to support theming locale strings, so keep this disabled until there is one.
	NSLocale *locale = [NSLocale currentLocale];
	NSString *language = [locale objectForKey:NSLocaleLanguageCode];
	if (!tableName)
		tableName = @"Localizable";

	NSArray *themes = [[ANEMSettingsManager sharedManager] themeSettings];

	for (NSString *theme in themes)
	{
		NSString *path = [NSString stringWithFormat:@"/Library/Themes/%@.theme/Bundles/%@/%@.lproj/%@.strings",theme,self.bundleIdentifier,language,tableName];
		if (![[NSFileManager defaultManager] fileExistsAtPath:path]){
			if (SupportsNoExtensionDir){
				path = [NSString stringWithFormat:@"/Library/Themes/%@/Bundles/%@/%@.lproj/%@.strings",theme,self.bundleIdentifier,language,tableName];
				if (![[NSFileManager defaultManager] fileExistsAtPath:path])
					continue;
			}
		}
		NSDictionary *localizationFile = [NSDictionary dictionaryWithContentsOfFile:path];
		if ([localizationFile objectForKey:key])
			return [localizationFile objectForKey:key];
	}
	return %orig;
}*/

- (NSString *)pathForResource:(NSString *)resource ofType:(NSString *)type {
	if (kCFCoreFoundationVersionNumber > MaxSupportedCFVersion)
		return %orig;
	NSString *themesDir = [[ANEMSettingsManager sharedManager] themesDir];

	NSString *fileName;
	if (type != nil && [type length] != 0 && ![type isEqualToString:@""])
		fileName = [resource stringByAppendingFormat:@".%@",type];
	else
		fileName = resource;
	NSArray *themes = [[ANEMSettingsManager sharedManager] themeSettings];

	#ifndef NO_OPTITHEME
	NSString *cacheFolder = [@"/var/stash/anemonecache/" stringByAppendingPathComponent:[self bundleIdentifier]];
	NSString *completeName = [cacheFolder stringByAppendingPathComponent:@".complete"];

	if ([[ANEMSettingsManager sharedManager] optithemeEnabled]){
		if ([[NSFileManager defaultManager] fileExistsAtPath:completeName]){
			//load optithemed image
			NSString *path = [NSString stringWithFormat:@"%@/%@",cacheFolder,fileName];
			if ([[NSFileManager defaultManager] fileExistsAtPath:path])
				return path;
		} else {
			if ([self bundlePath] != nil){
				dlopen("/System/Library/PrivateFrameworks/AppSupport.framework/AppSupport", RTLD_NOW);
				CPDistributedMessagingCenter *client = [objc_getClass("CPDistributedMessagingCenter") centerNamed:@"com.anemonetheming.anemone.optitheme"];
				rocketbootstrap_distributedmessagingcenter_apply(client);
				NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[self bundlePath],@"Path",nil];
				[client sendMessageName:@"cacheCarWithOptions" userInfo:dict];
			}
		}
	}
	#endif

	for (NSString *theme in themes)
	{
		NSString *path = [NSString stringWithFormat:@"%@/%@.theme/Bundles/%@/%@",themesDir,theme,self.bundleIdentifier,fileName];
		if ([[NSFileManager defaultManager] fileExistsAtPath:path])
			return path;
		if (SupportsNoExtensionDir){
			path = [NSString stringWithFormat:@"%@/%@/Bundles/%@/%@",themesDir,theme,self.bundleIdentifier,fileName];
			if ([[NSFileManager defaultManager] fileExistsAtPath:path])
				return path;
		}
	}
	return %orig;
}
%end
%end

%ctor {
	if (![[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"org.coolstar.anemone"]){
		%init(BundleHook);
	}
}
