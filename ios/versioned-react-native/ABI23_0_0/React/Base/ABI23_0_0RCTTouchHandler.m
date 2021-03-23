/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "ABI23_0_0RCTTouchHandler.h"

#import <UIKit/UIGestureRecognizerSubclass.h>

#import "ABI23_0_0RCTAssert.h"
#import "ABI23_0_0RCTBridge.h"
#import "ABI23_0_0RCTEventDispatcher.h"
#import "ABI23_0_0RCTLog.h"
#import "ABI23_0_0RCTTouchEvent.h"
#import "ABI23_0_0RCTUIManager.h"
#import "ABI23_0_0RCTUtils.h"
#import "UIView+ReactABI23_0_0.h"

@interface ABI23_0_0RCTTouchHandler () <UIGestureRecognizerDelegate>
@end

// TODO: this class behaves a lot like a module, and could be implemented as a
// module if we were to assume that modules and RootViews had a 1:1 relationship
@implementation ABI23_0_0RCTTouchHandler
{
  __weak ABI23_0_0RCTEventDispatcher *_eventDispatcher;

  /**
   * Arrays managed in parallel tracking native touch object along with the
   * native view that was touched, and the ReactABI23_0_0 touch data dictionary.
   * These must be kept track of because `UIKit` destroys the touch targets
   * if touches are canceled, and we have no other way to recover this info.
   */
  NSMutableOrderedSet<UITouch *> *_nativeTouches;
  NSMutableArray<NSMutableDictionary *> *_ReactABI23_0_0Touches;
  NSMutableArray<UIView *> *_touchViews;

  uint16_t _coalescingKey;
}

- (instancetype)initWithBridge:(ABI23_0_0RCTBridge *)bridge
{
  ABI23_0_0RCTAssertParam(bridge);

  if ((self = [super initWithTarget:nil action:NULL])) {
    _eventDispatcher = [bridge moduleForClass:[ABI23_0_0RCTEventDispatcher class]];

    _nativeTouches = [NSMutableOrderedSet new];
    _ReactABI23_0_0Touches = [NSMutableArray new];
    _touchViews = [NSMutableArray new];

    // `cancelsTouchesInView` and `delaysTouches*` are needed in order to be used as a top level
    // event delegated recognizer. Otherwise, lower-level components not built
    // using ABI23_0_0RCT, will fail to recognize gestures.
    self.cancelsTouchesInView = NO;
    self.delaysTouchesBegan = NO; // This is default value.
    self.delaysTouchesEnded = NO;

    self.delegate = self;
  }

  return self;
}

ABI23_0_0RCT_NOT_IMPLEMENTED(- (instancetype)initWithTarget:(id)target action:(SEL)action)

- (void)attachToView:(UIView *)view
{
  ABI23_0_0RCTAssert(self.view == nil, @"ABI23_0_0RCTTouchHandler already has attached view.");

  [view addGestureRecognizer:self];
}

- (void)detachFromView:(UIView *)view
{
  ABI23_0_0RCTAssertParam(view);
  ABI23_0_0RCTAssert(self.view == view, @"ABI23_0_0RCTTouchHandler attached to another view.");

  [view removeGestureRecognizer:self];
}

#pragma mark - Bookkeeping for touch indices

- (void)_recordNewTouches:(NSSet<UITouch *> *)touches
{
  for (UITouch *touch in touches) {

    ABI23_0_0RCTAssert(![_nativeTouches containsObject:touch],
              @"Touch is already recorded. This is a critical bug.");

    // Find closest ReactABI23_0_0-managed touchable view
    UIView *targetView = touch.view;
    while (targetView) {
      if (targetView.ReactABI23_0_0Tag && targetView.userInteractionEnabled) {
        break;
      }
      targetView = targetView.superview;
    }

    NSNumber *ReactABI23_0_0Tag = [targetView ReactABI23_0_0TagAtPoint:[touch locationInView:targetView]];
    if (!ReactABI23_0_0Tag || !targetView.userInteractionEnabled) {
      continue;
    }

    // Get new, unique touch identifier for the ReactABI23_0_0 touch
    const NSUInteger ABI23_0_0RCTMaxTouches = 11; // This is the maximum supported by iDevices
    NSInteger touchID = ([_ReactABI23_0_0Touches.lastObject[@"identifier"] integerValue] + 1) % ABI23_0_0RCTMaxTouches;
    for (NSDictionary *ReactABI23_0_0Touch in _ReactABI23_0_0Touches) {
      NSInteger usedID = [ReactABI23_0_0Touch[@"identifier"] integerValue];
      if (usedID == touchID) {
        // ID has already been used, try next value
        touchID ++;
      } else if (usedID > touchID) {
        // If usedID > touchID, touchID must be unique, so we can stop looking
        break;
      }
    }

    // Create touch
    NSMutableDictionary *ReactABI23_0_0Touch = [[NSMutableDictionary alloc] initWithCapacity:ABI23_0_0RCTMaxTouches];
    ReactABI23_0_0Touch[@"target"] = ReactABI23_0_0Tag;
    ReactABI23_0_0Touch[@"identifier"] = @(touchID);

    // Add to arrays
    [_touchViews addObject:targetView];
    [_nativeTouches addObject:touch];
    [_ReactABI23_0_0Touches addObject:ReactABI23_0_0Touch];
  }
}

- (void)_recordRemovedTouches:(NSSet<UITouch *> *)touches
{
  for (UITouch *touch in touches) {
    NSUInteger index = [_nativeTouches indexOfObject:touch];
    if (index == NSNotFound) {
      continue;
    }

    [_touchViews removeObjectAtIndex:index];
    [_nativeTouches removeObjectAtIndex:index];
    [_ReactABI23_0_0Touches removeObjectAtIndex:index];
  }
}

- (void)_updateReactABI23_0_0TouchAtIndex:(NSInteger)touchIndex
{
  UITouch *nativeTouch = _nativeTouches[touchIndex];
  CGPoint windowLocation = [nativeTouch locationInView:nativeTouch.window];
  CGPoint rootViewLocation = [nativeTouch.window convertPoint:windowLocation toView:self.view];

  UIView *touchView = _touchViews[touchIndex];
  CGPoint touchViewLocation = [nativeTouch.window convertPoint:windowLocation toView:touchView];

  NSMutableDictionary *ReactABI23_0_0Touch = _ReactABI23_0_0Touches[touchIndex];
  ReactABI23_0_0Touch[@"pageX"] = @(ABI23_0_0RCTSanitizeNaNValue(rootViewLocation.x, @"touchEvent.pageX"));
  ReactABI23_0_0Touch[@"pageY"] = @(ABI23_0_0RCTSanitizeNaNValue(rootViewLocation.y, @"touchEvent.pageY"));
  ReactABI23_0_0Touch[@"locationX"] = @(ABI23_0_0RCTSanitizeNaNValue(touchViewLocation.x, @"touchEvent.locationX"));
  ReactABI23_0_0Touch[@"locationY"] = @(ABI23_0_0RCTSanitizeNaNValue(touchViewLocation.y, @"touchEvent.locationY"));
  ReactABI23_0_0Touch[@"timestamp"] =  @(nativeTouch.timestamp * 1000); // in ms, for JS

  // TODO: force for a 'normal' touch is usually 1.0;
  // should we expose a `normalTouchForce` constant somewhere (which would
  // have a value of `1.0 / nativeTouch.maximumPossibleForce`)?
  if (ABI23_0_0RCTForceTouchAvailable()) {
    ReactABI23_0_0Touch[@"force"] = @(ABI23_0_0RCTZeroIfNaN(nativeTouch.force / nativeTouch.maximumPossibleForce));
  }
}

/**
 * Constructs information about touch events to send across the serialized
 * boundary. This data should be compliant with W3C `Touch` objects. This data
 * alone isn't sufficient to construct W3C `Event` objects. To construct that,
 * there must be a simple receiver on the other side of the bridge that
 * organizes the touch objects into `Event`s.
 *
 * We send the data as an array of `Touch`es, the type of action
 * (start/end/move/cancel) and the indices that represent "changed" `Touch`es
 * from that array.
 */
- (void)_updateAndDispatchTouches:(NSSet<UITouch *> *)touches
                        eventName:(NSString *)eventName
{
  // Update touches
  NSMutableArray<NSNumber *> *changedIndexes = [NSMutableArray new];
  for (UITouch *touch in touches) {
    NSInteger index = [_nativeTouches indexOfObject:touch];
    if (index == NSNotFound) {
      continue;
    }

    [self _updateReactABI23_0_0TouchAtIndex:index];
    [changedIndexes addObject:@(index)];
  }

  if (changedIndexes.count == 0) {
    return;
  }

  // Deep copy the touches because they will be accessed from another thread
  // TODO: would it be safer to do this in the bridge or executor, rather than trusting caller?
  NSMutableArray<NSDictionary *> *ReactABI23_0_0Touches =
  [[NSMutableArray alloc] initWithCapacity:_ReactABI23_0_0Touches.count];
  for (NSDictionary *touch in _ReactABI23_0_0Touches) {
    [ReactABI23_0_0Touches addObject:[touch copy]];
  }

  BOOL canBeCoalesced = [eventName isEqualToString:@"touchMove"];

  // We increment `_coalescingKey` twice here just for sure that
  // this `_coalescingKey` will not be reused by ahother (preceding or following) event
  // (yes, even if coalescing only happens (and makes sense) on events of the same type).

  if (!canBeCoalesced) {
    _coalescingKey++;
  }

  ABI23_0_0RCTTouchEvent *event = [[ABI23_0_0RCTTouchEvent alloc] initWithEventName:eventName
                                                         ReactABI23_0_0Tag:self.view.ReactABI23_0_0Tag
                                                     ReactABI23_0_0Touches:ReactABI23_0_0Touches
                                                   changedIndexes:changedIndexes
                                                    coalescingKey:_coalescingKey];

  if (!canBeCoalesced) {
    _coalescingKey++;
  }

  [_eventDispatcher sendEvent:event];
}

#pragma mark - Gesture Recognizer Delegate Callbacks

static BOOL ABI23_0_0RCTAllTouchesAreCancelledOrEnded(NSSet<UITouch *> *touches)
{
  for (UITouch *touch in touches) {
    if (touch.phase == UITouchPhaseBegan ||
        touch.phase == UITouchPhaseMoved ||
        touch.phase == UITouchPhaseStationary) {
      return NO;
    }
  }
  return YES;
}

static BOOL ABI23_0_0RCTAnyTouchesChanged(NSSet<UITouch *> *touches)
{
  for (UITouch *touch in touches) {
    if (touch.phase == UITouchPhaseBegan ||
        touch.phase == UITouchPhaseMoved) {
      return YES;
    }
  }
  return NO;
}

#pragma mark - `UIResponder`-ish touch-delivery methods

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
  [super touchesBegan:touches withEvent:event];

  // "start" has to record new touches *before* extracting the event.
  // "end"/"cancel" needs to remove the touch *after* extracting the event.
  [self _recordNewTouches:touches];

  [self _updateAndDispatchTouches:touches eventName:@"touchStart"];

  if (self.state == UIGestureRecognizerStatePossible) {
    self.state = UIGestureRecognizerStateBegan;
  } else if (self.state == UIGestureRecognizerStateBegan) {
    self.state = UIGestureRecognizerStateChanged;
  }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
  [super touchesMoved:touches withEvent:event];

  [self _updateAndDispatchTouches:touches eventName:@"touchMove"];
  self.state = UIGestureRecognizerStateChanged;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
  [super touchesEnded:touches withEvent:event];

  [self _updateAndDispatchTouches:touches eventName:@"touchEnd"];

  if (ABI23_0_0RCTAllTouchesAreCancelledOrEnded(event.allTouches)) {
    self.state = UIGestureRecognizerStateEnded;
  } else if (ABI23_0_0RCTAnyTouchesChanged(event.allTouches)) {
    self.state = UIGestureRecognizerStateChanged;
  }

  [self _recordRemovedTouches:touches];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
  [super touchesCancelled:touches withEvent:event];

  [self _updateAndDispatchTouches:touches eventName:@"touchCancel"];

  if (ABI23_0_0RCTAllTouchesAreCancelledOrEnded(event.allTouches)) {
    self.state = UIGestureRecognizerStateCancelled;
  } else if (ABI23_0_0RCTAnyTouchesChanged(event.allTouches)) {
    self.state = UIGestureRecognizerStateChanged;
  }

  [self _recordRemovedTouches:touches];
}

- (BOOL)canPreventGestureRecognizer:(__unused UIGestureRecognizer *)preventedGestureRecognizer
{
  return NO;
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer
{
  // We fail in favour of other external gesture recognizers.
  // iOS will ask `delegate`'s opinion about this gesture recognizer little bit later.
  return ![preventingGestureRecognizer.view isDescendantOfView:self.view];
}

- (void)reset
{
  if (_nativeTouches.count != 0) {
    [self _updateAndDispatchTouches:_nativeTouches.set eventName:@"touchCancel"];

    [_nativeTouches removeAllObjects];
    [_ReactABI23_0_0Touches removeAllObjects];
    [_touchViews removeAllObjects];
  }
}

#pragma mark - Other

- (void)cancel
{
  self.enabled = NO;
  self.enabled = YES;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(__unused UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
  // Same condition for `failure of` as for `be prevented by`.
  return [self canBePreventedByGestureRecognizer:otherGestureRecognizer];
}

@end
