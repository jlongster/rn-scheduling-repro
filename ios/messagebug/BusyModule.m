#import <React/RCTBridge.h>
#import "sqlite3.h"

@interface BusyModule : NSObject <RCTBridgeModule>
@end

@implementation BusyModule {
    sqlite3 *_db;
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(doSomething: (NSString *)str success:(RCTResponseSenderBlock)success error:(RCTResponseSenderBlock)error) {
    if(_db == nil) {
        int sqlOpenFlags = SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE;
        NSString *name = [NSTemporaryDirectory() stringByAppendingPathComponent:@"hello.sqlite"];
        sqlite3 *db;
        if(sqlite3_open_v2([name UTF8String], &db, sqlOpenFlags, NULL) != SQLITE_OK) {
            NSLog(@"Error opening");
            return;
        }
        _db = db;

        sqlite3_exec(_db, "CREATE TABLE foo (id INTEGER, value TEXT)", NULL, NULL, NULL);

        for(int i=0; i<1000; i++) {
            sqlite3_stmt *statement;
            sqlite3_prepare_v2(_db, "INSERT INTO foo (value) VALUES (\"test\")", -1, &statement, NULL);
            sqlite3_step(statement);
            sqlite3_finalize(statement);
        }
    }

    sqlite3_stmt *statement;
    sqlite3_prepare_v2(_db, "SELECT * FROM foo", -1, &statement, NULL);

    NSMutableArray *resultRows = [NSMutableArray arrayWithCapacity:0];
    BOOL keepGoing = YES;
    while (keepGoing) {
        int result = sqlite3_step(statement);

        switch (result) {
        case SQLITE_ROW: {
            int i = 0;
            NSMutableDictionary *entry = [NSMutableDictionary dictionaryWithCapacity:0];
            int count = sqlite3_column_count(statement);
        
            while (i < count) {
                NSObject *columnValue = nil;
                NSString *columnName = [NSString stringWithFormat:@"%s", sqlite3_column_name(statement, i)];
          
                int column_type = sqlite3_column_type(statement, i);
                switch (column_type) {
                case SQLITE_INTEGER:
                    columnValue = [NSNumber numberWithLongLong: sqlite3_column_int64(statement, i)];
                    break;
                case SQLITE_FLOAT:
                    columnValue = [NSNumber numberWithDouble: sqlite3_column_double(statement, i)];
                    break;
                case SQLITE_TEXT:
                    columnValue = [[NSString alloc] initWithBytes:(char *)sqlite3_column_text(statement, i)
                                                           length:sqlite3_column_bytes(statement, i)
                                                         encoding:NSUTF8StringEncoding];
#if !__has_feature(objc_arc)
                    [columnValue autorelease];
#endif
                    break;
                case SQLITE_NULL:
                    // just in case (should not happen):
                default:
                    columnValue = [NSNull null];
                    break;
                }
          
                if (columnValue) {
                    [entry setObject:columnValue forKey:columnName];
                }
          
                i++;
            }
            [resultRows addObject:entry];
            break;
        }
        case SQLITE_DONE:
            keepGoing = NO;
            break;
        
        default:
            keepGoing = NO;
        }
    }
    sqlite3_finalize(statement);

    success(@[resultRows]);
}

- (dispatch_queue_t)methodQueue {
    return dispatch_queue_create("com.actualbudget.sqlite.queue", DISPATCH_QUEUE_SERIAL);
}

@end
