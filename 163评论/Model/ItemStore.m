//
//  ItemStore.m
//  163评论
//
//  Created by zhaofuqiang on 14-4-28.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "ItemStore.h"
#import "FQConnection.h"
#import "Tag.h"
#import "Post.h"
#import "Content.h"
#import "Contents.h"
#import "MacroDefinition.h"
#import <FMDB.h>

#define kPLPostTable @"PLPost"  //Post表
#define kPLCommentTable @"PLComment"    //Comment表
#define kPLTagTable @"PLTag"    //Tag表
#define kPLAuthor @"PLAuthor"   //Author表


@interface ItemStore()
{
    FQConnection *_currConnection;
}
@end

@implementation ItemStore

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (ItemStore*)sharedItemStore
{
    static ItemStore *sharedItemStore = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedItemStore = [[ItemStore alloc] init];
    });
    return sharedItemStore;
}

+ (NSString *)databasePath
{
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    return [documentPath stringByAppendingPathComponent:@"163pinglun.db"];
}

+ (FMDatabaseQueue *)dbQueue
{
    static FMDatabaseQueue *dbQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self databasePath]];
    });
    
    return dbQueue;
}

+ (BOOL)initDB
{
    //打开数据库
    FMDatabase *db = [FMDatabase databaseWithPath:[self databasePath]];
    if (![db open]) return NO;
    
    ZFQLog(@"%@",[self databasePath]);
    ZFQLog(@"%@",[FMDatabase sqliteLibVersion]);
    //
    [[self dbQueue] inDatabase:^(FMDatabase *db) {
       
        //创建表格
        NSString *postSQL = @" \
        CREATE TABLE IF NOT EXISTS PLPost \
        ( \
        postID TEXT PRIMARY KEY, \
        nextPostID TEXT, \
        prePostID TEXT, \
        date TEXT, \
        excerpt TEXT, \
        tag TEXT, \
        title TEXT, \
        views INTEGER \
        );";
        
        if ([db executeUpdate:postSQL]) {
            NSLog(@"建表post成功");
        } else {
            NSLog(@"建表post失败");
        }
        
        /*
        NSString *commentSQL = @" \
        CREATE TABLE IF NOT EXISTS PLComment \
        ( \
        content TEXT , \
        currRows INTEGER, \
        email TEXT, \
        floorIndex INTEGER, \
        groupID INTEGER, \
        postID TEXT, \
        preAllRows TEXT, \
        time TEXT, \
        user TEXT \
        );";*/
        
        NSString *commentSQL = @" \
        CREATE TABLE IF NOT EXISTS PLComment \
        ( \
        postID TEXT PRIMARY KEY, \
        jsonStr BLOB \
        );";
        
        if ([db executeUpdate:commentSQL]) {
            NSLog(@"建表comment成功");
        } else {
            NSLog(@"建表comment失败");
        }
        
        NSString *tagSQL = @" \
        CREATE TABLE IF NOT EXISTS PLTag \
        ( \
        tagID INTEGER PRIMARY KEY, \
        tagIndex INTEGER, \
        tagName TEXT, \
        count INTEGER, \
        tagSlug TEXT \
        );";
        
        if ([db executeUpdate:tagSQL]) {
            NSLog(@"建表tag成功");
        } else {
            NSLog(@"建表tag失败");
        }

        NSString *authorSQL = @" \
        CREATE TABLE IF NOT EXISTS PLAuthor \
        ( \
        authorID TEXT PRIMARY KEY, \
        authorName TEXT, \
        authorSlug TEXT \
        );";
        
        if ([db executeUpdate:authorSQL]) {
            NSLog(@"建表author成功");
        } else {
            NSLog(@"建表author失败");
        }
    }];
    return YES;
}

+ (BOOL)savePost:(NSArray<Post *> *)posts {return YES;};

+ (NSArray *)filterPost:(NSArray<Post *> *)newPosts originAllPosts:(NSArray<Post *> *)originPosts
{
    //筛选出交集和新增的post
    NSMutableArray *insertPosts = [[NSMutableArray alloc] init];
    NSMutableArray *existPosts = [[NSMutableArray alloc] init];
    
    NSArray *A = newPosts;
    NSArray *B = originPosts;
    
    NSInteger pA = 0,pB = 0;
    
    NSString *tempIdA, *tempIdB;
    
    while (pA < A.count) {
        tempIdA = [(Post *)A[pA] postID];
        
        if (pB < B.count) {
            tempIdB = [(Post *)B[pB] postID];
        } else {
            [insertPosts addObject:A[pA]];
            pA++;
        }
        
        NSComparisonResult result = (tempIdB == nil) ? NSOrderedDescending : [tempIdA compare:tempIdB];
        if (result == NSOrderedAscending) {  //如果b大
            pB++;
        } else if (result == NSOrderedDescending) { //如果a大,说明此时pA所指的post是新增的
            [insertPosts addObject:A[pA]];
            pA++;
        } else {
            [existPosts addObject:A[pA]];
            
            pA++;
            pB++;
        }
    }

    return @[insertPosts,existPosts];
}

+ (BOOL)savePost:(NSArray<Post *> *)newPosts originAllPosts:(NSArray<Post *> *)originPosts
{
    //筛选出交集和新增的post
    NSArray *array = [self filterPost:newPosts originAllPosts:originPosts];
    NSArray *insertPosts = array[0];
    NSArray *existPosts = array[1];
    
    //执行SQL
    [[self dbQueue] inDatabase:^(FMDatabase *db) {
       
        //1.只插入新增的帖子
        
        if (insertPosts.count > 0) {
            NSMutableString *mutStr = [[NSMutableString alloc] init];
            [mutStr appendString:@"INSERT INTO PLPost (postID,nextPostID,prePostID,date,excerpt,tag,title,views)"];
            
            Post *obj = insertPosts[0];
            [mutStr appendFormat:@"select '%@' AS postID,'%@' AS nextPostID, '%@' AS prePostID, '%@' AS date, '%@' AS excerpt, '%@' AS tag, '%@' AS title, %ld AS views",obj.postID,obj.nextPostID,obj.prevPostID,obj.date,obj.excerpt,obj.tag,obj.title,obj.views];
            for (NSInteger i = 1; i < insertPosts.count; i++) {
                obj = insertPosts[i];
                [mutStr appendFormat:@" UNION SELECT '%@','%@','%@','%@','%@','%@','%@','%ld'",obj.postID,obj.nextPostID,obj.prevPostID,obj.date,obj.excerpt,obj.tag,obj.title,obj.views];
            }
            [mutStr appendString:@";"];
            
            if ([db executeUpdate:mutStr]) {
                ZFQLog(@"插入post成功");
            } else {
                ZFQLog(@"插入post失败");
            }
        }
        
        //2.更新已存在的帖子的浏览量
        if (existPosts.count > 0) {
            NSMutableString *mutStr = [[NSMutableString alloc] init];
            NSMutableString *tmpMulStr = [[NSMutableString alloc] init];
            [mutStr appendString:@"UPDATE PLPost SET views = CASE postID"];
            Post *obj = nil;
            for (NSInteger i = 0; i < existPosts.count; i++) {
                obj = existPosts[i];
                [mutStr appendFormat:@" WHEN %@ THEN %ld",obj.postID,(long)obj.views];
                
                if (i == 0 || i == existPosts.count - 1) {
                    [tmpMulStr appendFormat:@"%@",obj.postID];
                } else {
                    [tmpMulStr appendFormat:@"%@,",obj.postID];
                }
            }
            [mutStr appendString:@" END "];
            [mutStr appendFormat:@" WHERE postID IN (%@);",tmpMulStr];
            
            if ([db executeUpdate:mutStr]) {
                ZFQLog(@"插入post成功");
            } else {
                ZFQLog(@"插入post失败");
            }
        }
        
    }];
    return YES;
}

+ (NSArray<Post *> *)readPostsFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
    NSMutableArray<Post *> *posts = [[NSMutableArray alloc] init];
    NSString *sql = nil;
    if (toIndex == 0) {
        sql = @"SELECT * FROM PLPost ORDER BY CAST (postID AS INTEGER) DESC;";
    } else {
        sql = [NSString stringWithFormat:@"SELECT * FROM PLPost ORDER BY CAST (postID AS INTEGER) DESC LIMIT %ld,%ld;",fromIndex,toIndex];
    }
    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:sql];
        while ([set next]) {
            Post *p = [Post instanceFromFMResultSet:set];
            [posts addObject:p];
        }
    }];
    return posts;
}

+ (BOOL)saveTags:(NSArray<Tag *> *)tags
{
    if (tags.count == 0) {
        return YES;
    }
    
    //先删除所有的tags,然后再存入
    NSString *sql = @"DELETE FROM PLTag";
    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql];
    }];
    
    //插入数据
    Tag *tag = tags[0];
    
    NSMutableString *mutStr = [[NSMutableString alloc] init];
    [mutStr appendString:@"INSERT OR REPLACE INTO PLTag (tagID,tagIndex,tagName,count,tagSlug)"];
    [mutStr appendFormat:@" SELECT %ld AS tagID, %ld AS tagIndex, '%@' AS tagName, %ld AS count, '%@' AS tagSlug",tag.tagID.integerValue,tag.index,tag.tagName,tag.count,tag.tagSlug];
    if (tags.count > 1) {
        for (NSInteger i = 0; i < tags.count; i++) {
            tag = tags[i];
            [mutStr appendFormat:@" UNION SELECT %ld , %ld, '%@' , %ld, '%@' ",tag.tagID.integerValue,tag.index,tag.tagName,tag.count,tag.tagSlug];
        }
    }
    [mutStr appendString:@";"];
    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        [db executeUpdate:mutStr];
    }];
    return YES;
}

#pragma mark - create

/*
- (Author *)searchAuthorWithAuthorID:(NSNumber *)authorID
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Author" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSString *IDStr = [NSString stringWithFormat:@"%ld",(long)[authorID integerValue]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"authorID == %@",IDStr];
    [fetchRequest setPredicate:predicate];

    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        ZFQLog(@"查询Author失败:%@",[error localizedDescription]);
        return nil;
    } else {
        return [fetchedObjects firstObject];
    }
}
*/
- (void)deleteAllContentByPostID:(NSNumber *)postID
{
    /*
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Content" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"postID == %@",postID];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        ZFQLog(@"查询content失败:%@",[error localizedDescription]);
    } else {
        if (fetchedObjects.count > 0) {
            for (Content *content in fetchedObjects) {
                [self.managedObjectContext deleteObject:content];
            }
            [self saveContext];
        }
    }
*/
}

- (void)deleteAllContents
{
    [self deleteAllIEntityWithName:@"Content"];
}

- (void)deleteAllTags
{
    [self deleteAllIEntityWithName:@"Tag"];
}

- (void)deleteAllIEntityWithName:(NSString *)entityName
{
    if (entityName == nil || [entityName isEqualToString:@""]) {
        return;
    }
    /*
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:entityName];
    NSError *error;
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (results == nil) {
        ZFQLog(@"删除%@失败:%@",entityName,[error localizedDescription]);
    } else {
        for (NSManagedObject *obj in results) {
            [self.managedObjectContext deleteObject:obj];
        }
    }
    
    [self saveContext];
     */
}

+ (NSArray<Tag *> *)readTagsFromDB
{
    NSString *sql = @"SELECT * FROM PLTag ORDER BY CAST (tagIndex AS INTEGER) ASC";
    NSMutableArray *tags = [[NSMutableArray alloc] init];
    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:sql];
        while ([set next]) {
            Tag *tag = [Tag instanceFromFMResultSet:set];
            [tags addObject:tag];
        }
    }];
    return tags;
}

+ (void)insertOrReplaceComments:(NSData *)jsonData postID:(NSString *)postID
{
    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"INSERT OR REPLACE INTO PLComment VALUES(?,?);",postID,jsonData];
    }];
}

+ (void)saveComments:(NSData *)jsonData postID:(NSString *)postID
{
    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"INSERT INTO PLComment VALUES(?,?);",postID,jsonData];
    }];
}

+ (NSData *)readCommentsFromDBWithPostID:(NSString *)postID
{
    __block NSData *jsonData = nil;
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM PLComment WHERE postID = '%@'",postID];
    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:sql];
        while ([set next]) {
            jsonData = [set dataForColumnIndex:1];
        }
    }];
    return jsonData;
}

+ (NSArray<NSString *> *)allExistComment
{
    NSString *sql = @"SELECT postID FROM PLComment ORDER BY CAST (postID AS INTEGER) DESC";
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [[self dbQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *set = [db executeQuery:sql];
        while ([set next]) {
            [array addObject:[set stringForColumnIndex:0]];
        }
    }];
    return array;
}

#pragma mark - fetch data from network

- (void)fetchContentsWithCompletion:(void (^)(Contents *contents,NSError *error))block
{
    NSString *requestString = _cotentsURL;
    NSURL *url = [NSURL URLWithString:requestString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = 40;
    [request setHTTPMethod:@"GET"];
    Contents *contents = [[Contents alloc] init];
    if (_currConnection == nil) {
        _currConnection = [[FQConnection alloc] initWithRequest:request];
    } else {
        _currConnection.request = request;
    }
    [_currConnection setCompletionBlock:block];
    [_currConnection setJsonRootObject:contents];
    _currConnection.isDictionary = NO;
    [_currConnection start];
}
/*
- (void)fetchRandomPostsWithCompletion:(void (^)(RandomPosts *randomPosts,NSError *error))block
{
    NSString *requestURL = [HOSTURL stringByAppendingString:@"/wp-json/163pinglun/v1/random_posts"];
    NSURL *url = [NSURL URLWithString:requestURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = 40;
    RandomPosts *posts = [[RandomPosts alloc] init];
    if (_currConnection == nil) {
        _currConnection = [[FQConnection alloc] initWithRequest:request];
    } else {
        _currConnection.request = request;
    }
    [_currConnection setCompletionBlock:block];
    [_currConnection setJsonRootObject:posts];
    _currConnection.isDictionary = NO;
    [_currConnection start];
}
*/
- (void)cancelCurrentRequtest
{
    [_currConnection cancel];
}


#pragma mark - Core Data stack
/*
// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"163pinglun" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self cacheDataDirectory] URLByAppendingPathComponent:@"163pinglun.sqlite"];
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        ZFQLog(@"创建数据库失败:%@",[error userInfo]);
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)cacheDataDirectory
{
    NSURL *docURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    return docURL;
}

#pragma mark - fetch data from database
- (NSArray *)fetchAllItemsFromDBWithItemName:(NSString *)itemName sortKey:(NSString *)sortKey ascending:(BOOL)ascending predicate:(NSPredicate *)predicate
{
    if (itemName == nil || [itemName isEqualToString:@""])
        return nil;
    
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:itemName];
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:sortKey ascending:ascending];
    [request setSortDescriptors:[NSArray arrayWithObject:sd]];
    if (predicate != nil)
        [request setPredicate:predicate];
    NSArray *items = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (error != nil) {
        ZFQLog(@"查询%@失败:%@",itemName,[error localizedDescription]);
    }
    return items;
}

- (NSArray *)fetchTagsFromDatabase
{
    return [self fetchAllItemsFromDBWithItemName:@"Tag" sortKey:@"index" ascending:YES predicate:nil];
}

- (NSArray *)fetchAllPostsFromDatabase
{
    return [self fetchAllItemsFromDBWithItemName:@"Post" sortKey:@"postID" ascending:NO predicate:nil];
}

- (NSArray *)fetchAllPostsFromDatabaseWithTagName:(NSString *)tagName
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"tag == %@",tagName];
    return [self fetchAllItemsFromDBWithItemName:@"Post" sortKey:@"postID" ascending:NO predicate:predicate];
}

- (NSArray *)fetchContentsFromDatabaseWithPostID:(NSString *)postID
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"postID == %@",postID];
    NSArray *contents = [self fetchAllItemsFromDBWithItemName:@"Content" sortKey:@"floorIndex" ascending:YES predicate:predicate];
    NSMutableArray *contentItems = [[NSMutableArray alloc] init];
    NSMutableArray *groupIDs = [[NSMutableArray alloc] init];
    NSNumber *groupID = nil;
    for (Content *content in contents) {
        if ((groupID !=nil) || (groupID.intValue != content.groupID.intValue)) {
            groupID = content.groupID;
            [groupIDs addObject:content.groupID];
        }
    }
    for (int i=0; i<groupIDs.count; i++) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [contentItems addObject:array];
    }
    for (Content *content in contents) {
        NSUInteger index = [groupIDs indexOfObject:content.groupID];
        NSMutableArray *tempArray = [contentItems objectAtIndex:index];
        [tempArray addObject:content];
    }
    return contentItems;
}

- (void)fetchContentsFromDatabaseWithPostID:(NSString *)postID completion:(void (^)(NSArray *contents))completion
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSArray *contents = [self fetchContentsFromDatabaseWithPostID:postID];
        dispatch_async(dispatch_get_main_queue(), ^{
            void (^result)(NSArray *contents);
            result = completion;
            if (result != nil) {
                result(contents);
            }
        });
    });
}
*/

@end


