@interface LSResourceProxy : NSObject
- (NSDictionary *)iconsDictionary;
@end

@interface LSApplicationProxy : LSResourceProxy
+ (LSApplicationProxy *)applicationProxyForIdentifier:(NSString *)arg1;
- (NSURL *)bundleURL;
- (id)_plistValueForKey:(NSString *)key;
- (NSString *)applicationIdentifier;
- (NSString *)localizedName;
- (BOOL)iconIsPrerendered;
@end

@interface LSApplicationWorkspace : NSObject
+ (LSApplicationWorkspace *) defaultWorkspace;
- (NSArray *)allInstalledApplications; //7.0 and higher
@end