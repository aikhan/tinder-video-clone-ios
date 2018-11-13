/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2016 Google Inc.
 */

//
//  GTLUserUser.m
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   user/v1
// Description:
//   This should be for movie quotes but it says User
// Classes:
//   GTLUserUser (0 custom class methods, 26 custom properties)

#import "GTLUserUser.h"

// ----------------------------------------------------------------------------
//
//   GTLUserUser
//

@implementation GTLUserUser
@dynamic age, ageHigh, ageLow, ageRange, bio, confirmationCode, dating,
         distanceAway, distanceOfSearch, email, entityKey, firstName, gender,
         lat, likedYou, likedArray, lon, lookingFor, matchedArray, password,
         phoneNumber, profileGif, profileVideoUrls, skippedArray, userBucket,
         userLocation;

+ (NSDictionary *)propertyToJSONKeyMap {
  NSDictionary *map = @{
    @"ageHigh" : @"age_high",
    @"ageLow" : @"age_low",
    @"ageRange" : @"age_range",
    @"confirmationCode" : @"confirmation_code",
    @"distanceAway" : @"distance_away",
    @"distanceOfSearch" : @"distance_of_search",
    @"firstName" : @"first_name",
    @"likedYou" : @"liked_you",
    @"lookingFor" : @"looking_for",
    @"phoneNumber" : @"phone_number",
    @"profileGif" : @"profile_gif",
    @"profileVideoUrls" : @"profile_video_urls",
    @"userBucket" : @"user_bucket",
    @"userLocation" : @"user_location"
  };
  return map;
}

+ (NSDictionary *)arrayPropertyToClassMap {
  NSDictionary *map = @{
    @"age_range" : [NSNumber class],
    @"likedArray" : [NSString class],
    @"matchedArray" : [NSString class],
    @"profile_gif" : [NSString class],
    @"profile_video_urls" : [NSString class],
    @"skippedArray" : [NSString class]
  };
  return map;
}

@end