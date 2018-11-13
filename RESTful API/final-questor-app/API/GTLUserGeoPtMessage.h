/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2016 Google Inc.
 */

//
//  GTLUserGeoPtMessage.h
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   user/v1
// Description:
//   This should be for movie quotes but it says User
// Classes:
//   GTLUserGeoPtMessage (0 custom class methods, 2 custom properties)

#if GTL_BUILT_AS_FRAMEWORK
  #import "GTL/GTLObject.h"
#else
  #import "GTLObject.h"
#endif

// ----------------------------------------------------------------------------
//
//   GTLUserGeoPtMessage
//

// ProtoRPC container for GeoPt instances. Attributes: lat: Float; The latitude
// of the point. lon: Float; The longitude of the point.

@interface GTLUserGeoPtMessage : GTLObject
@property (nonatomic, retain) NSNumber *lat;  // doubleValue
@property (nonatomic, retain) NSNumber *lon;  // doubleValue
@end