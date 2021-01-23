//
//  DBHelper.m
//  Omniguider
//
//  Created by OC on 2011/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DBHelper.h"


@implementation DBHelper

@synthesize DB_EXT;
@synthesize DB_NAME;

@synthesize database;

//initial
-(id) init 
{
	self = [super init];
	return self;
}

//開啟資料庫
- (void) openDatabase
{
    //NSLog(@"dbname %@",self.DB_NAME);
    
	//判斷資料庫是否開啟
    if (!database)//資料庫尚未開啟
	{
        [self copyDatabaseIfNeeded];
		
		//開啟資料庫
		int result = sqlite3_open([[self getDatabaseFullPath] UTF8String], &database);
		
        //判斷是否成功開啟
		if (result != SQLITE_OK)
		{
			NSAssert(0, @"Failed to open database");
		}
        else {
//            NSLog(@"OK");
        }
	}
}

//關閉資料庫
- (void) closeDatabase
{
	//判斷資料庫是否開啟
    if (database)//資料庫已開啟
	{
        //關閉資料庫
        
        sqlite3_close(database);
        database = nil;
    }
}

//複製資料庫
- (void) copyDatabaseIfNeeded
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString *dbPath = [self getDatabaseFullPath];
    BOOL success = [fileManager fileExistsAtPath:dbPath]; 
    NSLog(@"dbpath %@",dbPath);
	//是否成功取得資料庫資料
    if(!success) //沒有
	{
        //讀取資料庫資料
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", DB_NAME, DB_EXT]];
        success = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
		
		//如果失敗
        if (!success)
		{
            NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
        }
    }
}

//獲得資料庫全部路徑
- (NSString *) getDatabaseFullPath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", DB_NAME, DB_EXT]];
	return path;
}

//傳送命令
- (sqlite3_stmt *) executeQuery:(NSString *) query
{
    
	sqlite3_stmt *statement;
	
    if(sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK)//否
	{
//        NSLog(@"Error while creating statement. '%s'", sqlite3_errmsg(database));
        //sqlite3_bind_text(statement, 1, <#const char *#>, <#int n#>, <#void (*)(void *)#>)
	}
    else
    {
        int err = SQLITE_ERROR;
        
        NSLog(@"error %d",err);
    }
	return statement;
}

//解構子
-(void)dealloc
{
	//[super dealloc];
}
@end
