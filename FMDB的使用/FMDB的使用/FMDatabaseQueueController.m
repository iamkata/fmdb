//
//  FMDatabaseQueueController.m
//  FMDB的使用
//
//  Created by 徐金城 on 2019/11/7.
//  Copyright © 2019 xujincheng. All rights reserved.
//

#import "FMDatabaseQueueController.h"
#import "FMDB.h"

@interface FMDatabaseQueueController ()

@property(nonatomic,strong)FMDatabaseQueue *queue;

@end

@implementation FMDatabaseQueueController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"FMDB数据库队列";
    
    //1.获得数据库文件的路径
    NSString *doc=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName=[doc stringByAppendingPathComponent:@"person.sqlite"];
    //2.获得数据库队列
    FMDatabaseQueue *queue=[FMDatabaseQueue databaseQueueWithPath:fileName];
//    FMDatabase *db=[FMDatabase databaseWithPath:fileName];

    //3.打开数据库
    [queue inDatabase:^(FMDatabase *db) {
         BOOL result=[db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_person (id integer PRIMARY KEY AUTOINCREMENT, name text NOT NULL, age integer NOT NULL);"];
        if (result) {
            NSLog(@"创表成功");
        }else
        {
            NSLog(@"创表失败");
        }
    }];
    self.queue=queue;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //1. 插入数据
    //[self insertData];

    //2. 查询数据
    [self searchData];
}

- (void)insertData {
    [self.queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"INSERT INTO t_person (name, age) VALUES (?, ?);",@"wendingding", @22];
    }];
}

- (void)searchData {
    [self.queue inDatabase:^(FMDatabase *db) {
        // 1.执行查询语句
        FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM t_person"];
        
        // 2.遍历结果
        while ([resultSet next]) {
            int ID = [resultSet intForColumn:@"id"];
            NSString *name = [resultSet stringForColumn:@"name"];
            int age = [resultSet intForColumn:@"age"];
            NSLog(@"%d %@ %d", ID, name, age);
        }
    }];
}


- (void)shiwu1 {
    //插入数据
     [self.queue inDatabase:^(FMDatabase *db) {
         [db beginTransaction];
         [db executeUpdate:@"INSERT INTO t_person (name, age) VALUES (?, ?);",@"wendingding", @22];
         [db executeUpdate:@"INSERT INTO t_person (name, age) VALUES (?, ?);",@"wendingding", @23];
         [db executeUpdate:@"INSERT INTO t_person (name, age) VALUES (?, ?);",@"wendingding", @24];
         [db executeUpdate:@"INSERT INTO t_person (name, age) VALUES (?, ?);",@"wendingding", @25];
         [db commit];
     }];
    //如果中途出现问题，那么会自动回滚，也可以选择手动回滚。
}

- (void)shiwu2 {
    //插入数据
     [self.queue inDatabase:^(FMDatabase *db) {
        [db beginTransaction];
        [db executeUpdate:@"INSERT INTO t_person (name, age) VALUES (?, ?);",@"wendingding", @22];
        [db executeUpdate:@"INSERT INTO t_person (name, age) VALUES (?, ?);",@"wendingding", @23];
        [db executeUpdate:@"INSERT INTO t_person (name, age) VALUES (?, ?);",@"wendingding", @24];
        [db rollback];
        [db executeUpdate:@"INSERT INTO t_person (name, age) VALUES (?, ?);",@"wendingding", @25];
        [db commit];
    }];
    //上面的代码。前三条插入语句是作废的
}

- (void)siwu3 {
[self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"INSERT INTO t_person (name, age) VALUES (?, ?);",@"wendingding", @22];
        [db executeUpdate:@"INSERT INTO t_person (name, age) VALUES (?, ?);",@"wendingding", @23];
        [db executeUpdate:@"INSERT INTO t_person (name, age) VALUES (?, ?);",@"wendingding", @24];
    }];
    //说明：先开事务，再开始事务，之后执行block中的代码段，最后提交事务。
}

@end
