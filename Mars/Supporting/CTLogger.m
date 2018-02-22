//
//  Created by mronge on 9/28/12.
//


#import "CTLogger.h"

@implementation CTLogger {
    dispatch_queue_t queue;
    NSFileHandle *log;
    NSDateFormatter *formatter;
}

+ (id)logger {
    static CTLogger *sharedLogger;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedLogger = [[self alloc] init];
    });
    return sharedLogger;
}

- (id)init {
    self = [super init];
    if (self) {
        queue = dispatch_queue_create([[NSString stringWithFormat:@"%@", self] UTF8String], NULL);

        NSString *logPath = [self logFilePath];
        NSFileManager *fm = [NSFileManager defaultManager];

        if (![fm fileExistsAtPath:logPath]) {
            // NSFileHandle can't create files so we do this instead
            [fm createFileAtPath:logPath contents:nil attributes:nil];
        }

        NSDictionary *fileAttrs = [fm attributesOfItemAtPath:logPath error:nil];
        if (fileAttrs) {
            unsigned long long int fileSize = [fileAttrs fileSize];
            // If the file is greater than 10mb then clear the file
            if (fileSize > 1024*1024*10) {
                [self truncate];
            }
        }

        log = [NSFileHandle fileHandleForWritingAtPath:logPath];
        [log seekToEndOfFile];
        formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeZone:[NSTimeZone systemTimeZone]];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ssssZ"];
    }
    return self;
}

- (void)log:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *msg = [[NSString alloc] initWithFormat:format arguments:args];
    NSString *line = [NSString stringWithFormat:@"[%@] %@\n", [formatter stringFromDate:[NSDate date]], msg];
    va_end(args);
    dispatch_sync(queue, ^() {
        [log writeData:[line dataUsingEncoding:NSUTF8StringEncoding]];
#if defined(DEBUG)
        NSLog(@"%@", msg);
#endif
    });
}

- (NSString *)logFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDir = [paths objectAtIndex:0];
    return [cacheDir stringByAppendingPathComponent:@"app.log"];
}

- (void)truncate {
    [log truncateFileAtOffset:0];
}
@end
