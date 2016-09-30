//
//  ItemStore.h
//  163评论
//
//  Created by zhaofuqiang on 14-4-28.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class Tag,Post,Content,Tags,Posts,Contents,Author,RandomPosts;

@interface ItemStore : NSObject

@property (nonatomic,strong) NSString *cotentsURL;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (ItemStore*)sharedItemStore;

/**
 *  数据库文件的路径
 *
 *  @return 数据库文件的路径
 */
+ (NSString *)databasePath;

/**
 *  从指定的数组中筛选出
 *
 *  @param newPosts    从服务器端拉取的数据
 *  @param originPosts 本地当前显示的数据
 *
 *  @return 返回一个数组，这个数组包含两个数组，第一个数组存放的是新增的post,第二个数组存放的是newPosts中的与originPosts中postID相同的post,注意这个post是在newPosts中的。
 */
+ (NSArray *)filterPost:(NSArray<Post *> *)newPosts originAllPosts:(NSArray<Post *> *)originPosts;

/**
 *  保存posts到数据库中，并更新对应浏览量
 *
 *  @param newPosts    待存入数据库中的数组
 *  @param originPosts 当前显示的post数组
 *
 *  @return 是否保存成功
 */
+ (BOOL)savePost:(NSArray<Post *> *)newPosts originAllPosts:(NSArray<Post *> *)originPosts;

/**
 *  从数据库中读取一定区间内的post
 *
 *  @param fromIndex 起始行数
 *  @param toIndex   终止行数
 *
 *  @return 数组
 */
+ (NSArray<Post *> *)readPostsFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

/**
 *  初始化数据库、建表
 *
 *  @return 初始化是否成功
 */
+ (BOOL)initDB;

/**
 *  保存tag
 *
 *  @param tags 待存入数据库中的tag
 *
 *  @return 是否保存成功
 */
+ (BOOL)saveTags:(NSArray<Tag *> *)tags;

/**
 *  从数据库中读出所有的Tag
 *
 *  @return tag对象数组
 */
+ (NSArray<Tag *> *)readTagsFromDB;

/**
 *  保存评论内容，如果数据库中已存在就替换，不存在就添加
 *
 *  @param jsonData 从服务器端拉回来的comment的json数据
 *  @param postID   对应的帖子ID
 */
+ (void)insertOrReplaceComments:(NSData *)jsonData postID:(NSString *)postID;

/**
 *  保存评论内容，这个为json字符串
 *
 *  @param jsonStr 从服务器端拉回来的json数据
 *  @param postID  对应的帖子ID
 */
+ (void)saveComments:(NSData *)jsonData postID:(NSString *)postID;

/**
 *  从数据库中读取
 *
 *  @param postID 帖子id
 *
 *  @return json字符串
 */
+ (NSData *)readCommentsFromDBWithPostID:(NSString *)postID;

/**
 *  获取数据库中所有的postID
 *
 *  @return 数据中所有的postID,降序排列
 */
+ (NSArray<NSString *> *)allPostIDFromDB;

/*

//删除数据对象
- (void)deleteAllContentByPostID:(NSNumber *)postID;
- (void)deleteAllTags;

//网络部分操作
- (void)fetchTagsWithCompletion:(void(^)(Tags *tags,NSError *error))block;
- (void)fetchPostsWithCompletion:(void (^)(Posts *posts,NSError *error))block;
- (void)fetchContentsWithCompletion:(void (^)(Contents *contents,NSError *error))block;
- (void)fetchRandomPostsWithCompletion:(void (^)(RandomPosts *randomPosts,NSError *error))block;
- (void)cancelCurrentRequtest;

- (NSURL *)cacheDataDirectory;

//本地数据库操作
- (NSArray *)fetchTagsFromDatabase;
- (NSArray *)fetchAllPostsFromDatabase;
- (NSArray *)fetchAllPostsFromDatabaseWithTagName:(NSString *)tagName;
- (NSArray *)fetchContentsFromDatabaseWithPostID:(NSString *)postID;    //同步
- (void)fetchContentsFromDatabaseWithPostID:(NSString *)postID completion:(void (^)(NSArray *contents))completion; //异步

- (void)deleteAllContents;
*/

@end
