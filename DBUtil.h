//
//  DBUtil.h
//  sqlTest
//
//  Created by maopenglin on 14-5-14.
//  Copyright (c) 2014年 maopenglin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define sqlText(name,size)  [NSString stringWithFormat:@"%@  TEXT(%i)   DEFAULT NULL",name,size]
#define sqlInteger(name) [NSString stringWithFormat:@"%@ integer ",name] 
#define ShowSql TRUE
#define DBPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"/pro.db"]
@interface DBUtil : NSObject

+(void)createTableSql:(NSString*)tableName andKeyTypeField:(NSArray*)fileds;
+(void)createInsertSql:(NSString*)tableName andFieldsCount:(NSArray*)values;
+(void)createUpdateSql:(NSString*)tableName andUpdateKey:(NSString*)updatekey andUpdateValue:(NSString*)updateValue  andWhereKeyValue:(NSArray*)wherekey;
+(void)createDeleteSql:(NSString*)tableName  andWhereKeyValue:(NSArray*)wherekey;
+(void)createClearTableDataSql:(NSString*)tableName;
+(NSString*)createSelectSql:(NSString*)tableName;
+(NSString*)createSelectSql:(NSString*)tableName andWhereKeyValue:(NSArray*)wherekey;
+(void)insertOrUpdate:(NSString*)tableName andFieldsCount:(NSArray*)values andWhereKeyValue:(NSArray*)wherekey;

@end
