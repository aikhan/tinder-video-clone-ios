/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2016 Google Inc.
 */

//
//  GTLQueryUser.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   user/v1
// Description:
//   This should be for movie quotes but it says User
// Classes:
//   GTLQueryUser (3 custom class methods, 8 custom properties)

#import "GTLQueryUser.h"

#import "GTLUserCollection.h"
#import "GTLUserUser.h"

@implementation GTLQueryUser

@dynamic age, entityKey, fields, gender, limit, order, pageToken, userBucket;

+ (NSDictionary *)parameterNameMap {
  NSDictionary *map = @{
    @"userBucket" : @"user_bucket"
  };
  return map;
}

#pragma mark - "user" methods
// These create a GTLQueryUser object.

+ (instancetype)queryForUserCreateWithObject:(GTLUserUser *)object {
  if (object == nil) {
    GTL_DEBUG_ASSERT(object != nil, @"%@ got a nil object", NSStringFromSelector(_cmd));
    return nil;
  }
  NSString *methodName = @"user.user.create";
  GTLQueryUser *query = [self queryWithMethodName:methodName];
  query.bodyObject = object;
  query.expectedObjectClass = [GTLUserUser class];
  return query;
}

+ (instancetype)queryForUserDeleteWithEntityKey:(NSString *)entityKey {
  NSString *methodName = @"user.user.delete";
  GTLQueryUser *query = [self queryWithMethodName:methodName];
  query.entityKey = entityKey;
  query.expectedObjectClass = [GTLUserUser class];
  return query;
}

+ (instancetype)queryForUserList {
  NSString *methodName = @"user.user.list";
  GTLQueryUser *query = [self queryWithMethodName:methodName];
  query.expectedObjectClass = [GTLUserCollection class];
  return query;
}

@end