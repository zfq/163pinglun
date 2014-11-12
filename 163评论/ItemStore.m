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
#import "Tags.h"
#import "Post.h"
#import "Posts.h"
#import "Content.h"
#import "Contents.h"
#import "RandomPost.h"
#import "RandomPosts.h"

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

#pragma mark - create
- (Tag *)createTag
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Tag"
                                         inManagedObjectContext:self.managedObjectContext];
}

- (Post *)createPost
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Post" inManagedObjectContext:self.managedObjectContext];;
}

- (Content *)createContent
{
    return [NSEntityDescription insertNewObjectForEntityForName:@"Content"
                                         inManagedObjectContext:self.managedObjectContext];
}

- (Author *)createAuthorWithAuthorID:(NSNumber *)authorID
{
    Author *author = [self searchAuthorWithAuthorID:authorID];
    if (author == nil) {
        author = [NSEntityDescription insertNewObjectForEntityForName:@"Author" inManagedObjectContext:self.managedObjectContext];
        [self saveContext];
        return author;
    } else {
        return author;
    }
}

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
        DNSLog(@"查询Author失败:%@",[error localizedDescription]);
        return nil;
    } else {
        return [fetchedObjects firstObject];
    }
}

- (void)deleteAllContentByPostID:(NSNumber *)postID
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Content" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"postID == %@",postID];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        DNSLog(@"查询content失败:%@",[error localizedDescription]);
    } else {
        if (fetchedObjects.count > 0) {
            for (Content *content in fetchedObjects) {
                [self.managedObjectContext deleteObject:content];
            }
            [self saveContext];
        }
    }

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
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:entityName];
    NSError *error;
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (results == nil) {
        DNSLog(@"删除%@失败:%@",entityName,[error localizedDescription]);
    } else {
        for (NSManagedObject *obj in results) {
            [self.managedObjectContext deleteObject:obj];
        }
    }
    
    [self saveContext];
}

#pragma mark - fetch data from network
- (void)fetchTagsWithCompletion:(void(^)(Tags * tags,NSError *error))block
{
    NSString *requestString = @"http://163pinglun.com/wp-json/posts/types/post/taxonomies/post_tag/terms";
    NSURL *url = [NSURL URLWithString:requestString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = 40;
    [request setHTTPMethod:@"GET"];
    Tags *t = [[Tags alloc] init];
    if (_currConnection == nil) {
        _currConnection = [[FQConnection alloc] initWithRequest:request];
    } else {
        _currConnection.request = request;
    }
    _currConnection.isDictionary = NO;
    [_currConnection setCompletionBlock:block];
    [_currConnection setJsonRootObject:t];
    [_currConnection start];
}

- (void)fetchPostsWithCompletion:(void (^)(Posts *posts,NSError *error))block
{
//    NSString *requestString = @"http://163pinglun.com/wp-json/posts";
    NSURL *url = [NSURL URLWithString:_cotentsURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = 40;
    [request setHTTPMethod:@"GET"];
    Posts *posts = [[Posts alloc] init];
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

- (void)fetchRandomPostsWithCompletion:(void (^)(RandomPosts *randomPosts,NSError *error))block
{
    NSString *requestURL = @"http://163pinglun.com/wp-admin/admin-ajax.php?action=random_post";
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

- (void)cancelCurrentRequtest
{
    [_currConnection cancel];
}

- (void)saveContext
{
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges]) { // && ![managedObjectContext save:&error]
            NSError *error = nil;
            if ( ![managedObjectContext save:&error]) {
                DNSLog(@"保存失败:%@",[error userInfo]);
            }
        }
    }
}

#pragma mark - Core Data stack

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
        DNSLog(@"创建数据库失败:%@",[error userInfo]);
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
        DNSLog(@"查询%@失败:%@",itemName,[error localizedDescription]);
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

- (NSArray *)fetchContentsFromDatabaseWithPostID:(NSNumber *)postID
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"postID == %@",postID];
    NSArray *contents = [self fetchAllItemsFromDBWithItemName:@"Content" sortKey:@"floorIndex" ascending:YES predicate:predicate];
    NSMutableArray *contentItems = [[NSMutableArray alloc] init];
    NSMutableArray *groupIDs = [[NSMutableArray alloc] init];
    NSNumber *groupID = nil;
    for (Content *content in contents) {
        if (groupID.intValue != content.groupID.intValue) {
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

- (void)fetchContentsFromDatabaseWithPostID:(NSNumber *)postID completion:(void (^)(NSArray *contents))completion
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


@end


