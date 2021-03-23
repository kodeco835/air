/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "ABI23_0_0RCTTouchEvent.h"

#import "ABI23_0_0RCTAssert.h"

@implementation ABI23_0_0RCTTouchEvent
{
  NSArray<NSDictionary *> *_ReactABI23_0_0Touches;
  NSArray<NSNumber *> *_changedIndexes;
  uint16_t _coalescingKey;
}

@synthesize eventName = _eventName;
@synthesize viewTag = _viewTag;

- (instancetype)initWithEventName:(NSString *)eventName
                         ReactABI23_0_0Tag:(NSNumber *)ReactABI23_0_0Tag
                     ReactABI23_0_0Touches:(NSArray<NSDictionary *> *)ReactABI23_0_0Touches
                   changedIndexes:(NSArray<NSNumber *> *)changedIndexes
                    coalescingKey:(uint16_t)coalescingKey
{
  if (self = [super init]) {
    _viewTag = ReactABI23_0_0Tag;
    _eventName = eventName;
    _ReactABI23_0_0Touches = ReactABI23_0_0Touches;
    _changedIndexes = changedIndexes;
    _coalescingKey = coalescingKey;
  }
  return self;
}

ABI23_0_0RCT_NOT_IMPLEMENTED(- (instancetype)init)

#pragma mark - ABI23_0_0RCTEvent

- (BOOL)canCoalesce
{
  return [_eventName isEqual:@"touchMove"];
}

// We coalesce only move events, while holding some assumptions that seem reasonable but there are no explicit guarantees about them.
- (id<ABI23_0_0RCTEvent>)coalesceWithEvent:(id<ABI23_0_0RCTEvent>)newEvent
{
  ABI23_0_0RCTAssert([newEvent isKindOfClass:[ABI23_0_0RCTTouchEvent class]], @"Touch event cannot be coalesced with any other type of event, such as provided %@", newEvent);
  ABI23_0_0RCTTouchEvent *newTouchEvent = (ABI23_0_0RCTTouchEvent *)newEvent;
  ABI23_0_0RCTAssert([_ReactABI23_0_0Touches count] == [newTouchEvent->_ReactABI23_0_0Touches count], @"Touch events have different number of touches. %@ %@", self, newEvent);

  BOOL newEventIsMoreRecent = NO;
  BOOL oldEventIsMoreRecent = NO;
  NSInteger count = _ReactABI23_0_0Touches.count;
  for (int i = 0; i<count; i++) {
    NSDictionary *touch = _ReactABI23_0_0Touches[i];
    NSDictionary *newTouch = newTouchEvent->_ReactABI23_0_0Touches[i];
    ABI23_0_0RCTAssert([touch[@"identifier"] isEqual:newTouch[@"identifier"]], @"Touch events doesn't have touches in the same order. %@ %@", touch, newTouch);
    if ([touch[@"timestamp"] doubleValue] > [newTouch[@"timestamp"] doubleValue]) {
      oldEventIsMoreRecent = YES;
    } else {
      newEventIsMoreRecent = YES;
    }
  }
  ABI23_0_0RCTAssert(!(oldEventIsMoreRecent && newEventIsMoreRecent), @"Neither touch event is exclusively more recent than the other one. %@ %@", _ReactABI23_0_0Touches, newTouchEvent->_ReactABI23_0_0Touches);
  return newEventIsMoreRecent ? newEvent : self;
}

+ (NSString *)moduleDotMethod
{
  return @"ABI23_0_0RCTEventEmitter.receiveTouches";
}

- (NSArray *)arguments
{
  return @[ABI23_0_0RCTNormalizeInputEventName(_eventName), _ReactABI23_0_0Touches, _changedIndexes];
}

- (uint16_t)coalescingKey
{
  return _coalescingKey;
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"<%@: %p; name = %@; coalescing key = %hu>", [self class], self, _eventName, _coalescingKey];
}

@end
