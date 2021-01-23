//
//  DBHelper.h
//  Omniguider
//
//  Created by OC on 2011/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
@interface DBHelper : NSObject
{
//	sqlite3 *database;
}
@property(nonatomic) sqlite3 *database;
@property(strong,nonatomic) NSString *DB_NAME;
@property(strong,nonatomic) NSString *DB_EXT;
- (void) openDatabase;
- (void) closeDatabase;
- (NSString *) getDatabaseFullPath;
- (void) copyDatabaseIfNeeded;
- (sqlite3_stmt *) executeQuery:(NSString *) query;
@end
