//
//  ItemStore.h
//  163评论
//
//  Created by zhaofuqiang on 14-4-28.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Tag,Post,Content,Tags,Posts,Contents,Author;

@interface ItemStore : NSObject

@property (nonatomic,strong) NSString *cotentsURL;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (ItemStore*)sharedItemStore;

- (Tag *)createTag;
- (Post *)createPost;
- (Content *)createContent;
- (Author *)createAuthorWithAuthorID:(NSNumber *)authorID;
- (Author *)searchAuthorWithAuthorID:(NSNumber *)authorID;
- (void)deleteAllContentByPostID:(NSNumber *)postID;

- (void)fetchTagsWithCompletion:(void(^)(Tags *tags,NSError *error))block;
- (void)fetchPostsWithCompletion:(void (^)(Posts *posts,NSError *error))block;
- (void)fetchContentsWithCompletion:(void (^)(Contents *contents,NSError *error))block;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (NSArray *)fetchTagsFromDatabase;
- (NSArray *)fetchPostsFromDatabase;
- (NSArray *)fetchContentsFromDatabaseWithPostID:(NSNumber *)postID;

@end
