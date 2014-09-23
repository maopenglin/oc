//
//  DBUtil.m
//  sqlTest
//
//  Created by maopenglin on 14-5-14.
//  Copyright (c) 2014年 maopenglin. All rights reserved.
//

#import "DBUtil.h"


@implementation DBUtil

static sqlite3 *database;

//插入或者更新
+(void)insertOrUpdate:(NSString*)tableName andFieldsCount:(NSArray*)values andWhereKeyValue:(NSArray*)wherekey{
        NSString *sql=[NSString stringWithFormat:@"DELETE FROM  %@  WHERE ",tableName];
        for(int i=0;i<[wherekey count];i++){
            
            NSDictionary *dic=[wherekey objectAtIndex:i];
             NSString *key= [[dic allKeys] objectAtIndex:0];
            NSString *value=[dic valueForKey:key];
            if(i< [wherekey count]-1){
                sql=[NSString stringWithFormat:@"%@ %@='%@' AND ",sql,key,value];
            }else{
                sql=[NSString stringWithFormat:@"%@ %@='%@'",sql,key,value];

            }
        }
        sql=[NSString stringWithFormat:@"%@ %@",sql,@";"];
        if(ShowSql){
            NSLog(@"aaa:%@",sql);
        }
        [DBUtil UpdateSql:sql];
             // [db executeUpdate:sql];
              [DBUtil createInsertSql:tableName andFieldsCount:values];
            
        
                  
        
    
}
//生成  创建 table sql 语句
+(void)createTableSql:(NSString*)tableName andKeyTypeField:(NSArray*)fileds{
   NSString *sql=[NSString stringWithFormat:@" CREATE TABLE IF NOT EXISTS %@ (",tableName];
   for(int i=0;i<[fileds count];i++){
        NSString *key=[fileds objectAtIndex:i];
        if (i<[fileds count]-1) {
             sql=[NSString stringWithFormat:@"%@ %@ , ",sql,key];
        }else{
             sql=[NSString stringWithFormat:@"%@ %@  ",sql,key];
        }
    }
    sql=[NSString stringWithFormat:@"%@ %@",sql,@" );"];
    if (ShowSql) {
        NSLog(@":%@",sql);
    }
    [DBUtil UpdateSql:sql];
   
}
//insert 语句
+(void)createInsertSql:(NSString*)tableName andFieldsCount:(NSArray*)values{
    NSString *sql=[NSString stringWithFormat:@"INSERT INTO %@ VALUES (",tableName];
    for(int i=0;i<[values count];i++){
        if (i<[values count]-1) {
            sql=[NSString stringWithFormat:@"%@ '%@',",sql,[values objectAtIndex:i]];
        }else{
            sql=[NSString stringWithFormat:@"%@ '%@'",sql,[values objectAtIndex:i]];
        }
    }
    sql=[NSString stringWithFormat:@"%@ %@",sql,@");"];
    if (ShowSql) {
        NSLog(@":%@",sql);
    }
    [DBUtil UpdateSql:sql];

}
+(void)UpdateSql:(NSString*)sql{
 
    char *errMsg;
    sqlite3_stmt *statement;
      sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL);
    
    if (sqlite3_step(statement) == SQLITE_DONE) {
       
    }else{
        NSLog(@"error");
    }
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    return;
    
     

}
// update 语句
/*
    updatekey   要更新的 key
    updateValue 要更新的值
    wherekey 条件key
    wherevalue 条件值
 */
+(void)createUpdateSql:(NSString*)tableName andUpdateKey:(NSString*)updatekey andUpdateValue:(NSString*)updateValue  andWhereKeyValue:(NSArray*)wherekey{
    NSString *sql=[NSString stringWithFormat:@"UPDATE %@ set %@='%@' WHERE ",tableName,updatekey,updateValue];
    for(int i=0;i<[wherekey count];i++){
        
        NSDictionary *dic=[wherekey objectAtIndex:i];
        NSString *key= [[dic allKeys] objectAtIndex:0];
        NSString *value=[dic valueForKey:key];
        if(i< [wherekey count]-1){
            sql=[NSString stringWithFormat:@"%@ %@='%@' AND ",sql,key,value];
        }else{
            sql=[NSString stringWithFormat:@"%@ %@='%@'",sql,key,value];
            
        }
    }
    sql=[NSString stringWithFormat:@"%@ %@",sql,@";"];
    if (ShowSql) {
        NSLog(@":%@",sql);
    }
    [DBUtil UpdateSql:sql];
   
}
//删除
+(void)createDeleteSql:(NSString*)tableName  andWhereKeyValue:(NSArray*)wherekey{
    NSString *sql=[NSString stringWithFormat:@"DELETE FROM %@ WHERE ",tableName];
    for(int i=0;i<[wherekey count];i++){
        
        NSDictionary *dic=[wherekey objectAtIndex:i];
        NSString *key= [[dic allKeys] objectAtIndex:0];
        NSString *value=[dic valueForKey:key];
        if(i< [wherekey count]-1){
            sql=[NSString stringWithFormat:@"%@ %@='%@' AND ",sql,key,value];
        }else{
            sql=[NSString stringWithFormat:@"%@ %@='%@'",sql,key,value];
            
        }
    }
    sql=[NSString stringWithFormat:@"%@ %@",sql,@";"];

    if (ShowSql) {
        NSLog(@":%@",sql);
    }
    [DBUtil UpdateSql:sql];
   
}
//清空表数据
+(void)createClearTableDataSql:(NSString*)tableName{
    NSString *sql=[NSString stringWithFormat:@"DELETE FROM %@ ;",tableName];
    
    if (ShowSql) {
        NSLog(@":%@",sql);
    }
    [DBUtil UpdateSql:sql];
   
}
//查询
+(NSString*)createSelectSql:(NSString*)tableName{
    NSString *sql=[NSString stringWithFormat:@"SELECT * FROM %@ ;",tableName];
    if (ShowSql) {
        NSLog(@":%@",sql);
    }
    return sql;
}
//查询
+(NSString*)createSelectSql:(NSString*)tableName andWhereKeyValue:(NSArray*)wherekey{
    NSString *sql=[NSString stringWithFormat:@"SELECT * FROM %@  WHERE",tableName];
    
    for(int i=0;i<[wherekey count];i++){
        
        NSDictionary *dic=[wherekey objectAtIndex:i];
        NSString *key= [[dic allKeys] objectAtIndex:0];
        NSString *value=[dic valueForKey:key];
        if(i< [wherekey count]-1){
            sql=[NSString stringWithFormat:@"%@ %@='%@' AND ",sql,key,value];
        }else{
            sql=[NSString stringWithFormat:@"%@ %@='%@'",sql,key,value];
            
        }
    }
    sql=[NSString stringWithFormat:@"%@ %@",sql,@";"];
    if (ShowSql) {
        NSLog(@":%@",sql);
    }
    return sql;
}
@end
