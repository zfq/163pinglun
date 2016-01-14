//
//  ItemStore.h
//  163评论
//
//  Created by zhaofuqiang on 14-4-28.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Tag,Post,Content,Tags,Posts,Contents,Author,RandomPosts;

@interface ItemStore : NSObject

@property (nonatomic,strong) NSString *cotentsURL;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (ItemStore*)sharedItemStore;

/* 创建数据对象 */
- (Tag *)createTag;
- (Post *)createPost;
- (Content *)createContent;
- (Author *)createAuthorWithAuthorID:(NSNumber *)authorID;
- (Author *)searchAuthorWithAuthorID:(NSNumber *)authorID;

/*删除数据对象*/
- (void)deleteAllContentByPostID:(NSNumber *)postID;
- (void)deleteAllTags;

/* 网络部分操作 */
- (void)fetchTagsWithCompletion:(void(^)(Tags *tags,NSError *error))block;
- (void)fetchPostsWithCompletion:(void (^)(Posts *posts,NSError *error))block;
- (void)fetchContentsWithCompletion:(void (^)(Contents *contents,NSError *error))block;
- (void)fetchRandomPostsWithCompletion:(void (^)(RandomPosts *randomPosts,NSError *error))block;
- (void)cancelCurrentRequtest;

- (void)saveContext;
- (NSURL *)cacheDataDirectory;

/* 本地数据库操作 */
- (NSArray *)fetchTagsFromDatabase;
- (NSArray *)fetchAllPostsFromDatabase;
- (NSArray *)fetchAllPostsFromDatabaseWithTagName:(NSString *)tagName;
- (NSArray *)fetchContentsFromDatabaseWithPostID:(NSNumber *)postID;    //同步
- (void)fetchContentsFromDatabaseWithPostID:(NSNumber *)postID completion:(void (^)(NSArray *contents))completion; //异步

- (void)deleteAllContents;
@end
