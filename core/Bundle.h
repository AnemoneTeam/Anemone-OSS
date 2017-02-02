@interface NSBundle (Anemone)
+ (NSBundle *) anemoneBundleWithFile:(NSString *)path;
@end

@interface NSString (Anemone)
- (NSString *) anemoneThemedPath;
- (NSString *) anemoneThemedPath:(BOOL)enableLegacy;
@end