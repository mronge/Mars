#import <Foundation/Foundation.h>

#define CTLog(fmt, ...) [[CTLogger logger] log:fmt, ##__VA_ARGS__];

@interface CTLogger : NSObject
+ (id)logger;
- (void)log:(NSString *)format, ...;
- (NSString *)logFilePath;
- (void)truncate;
@end