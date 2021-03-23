#import "DevMenuRNGestureHandler.h"

#import "Handlers/DevMenuRNNativeViewHandler.h"

#import <UIKit/UIGestureRecognizerSubclass.h>

#import <React/UIView+React.h>

@interface UIGestureRecognizer (GestureHandler)
@property (nonatomic, readonly) DevMenuRNGestureHandler *gestureHandler;
@end


@implementation UIGestureRecognizer (GestureHandler)

- (DevMenuRNGestureHandler *)gestureHandler
{
    id delegate = self.delegate;
    if ([delegate isKindOfClass:[DevMenuRNGestureHandler class]]) {
        return (DevMenuRNGestureHandler *)delegate;
    }
    return nil;
}

@end

typedef struct DevMenuRNGHHitSlop {
    CGFloat top, left, bottom, right, width, height;
} DevMenuRNGHHitSlop;

static DevMenuRNGHHitSlop DevMenuRNGHHitSlopEmpty = { NAN, NAN, NAN, NAN, NAN, NAN };

#define DevMenuRNGH_HIT_SLOP_GET(key) (prop[key] == nil ? NAN : [prop[key] doubleValue])
#define DevMenuRNGH_HIT_SLOP_IS_SET(hitSlop) (!isnan(hitSlop.left) || !isnan(hitSlop.right) || \
                                        !isnan(hitSlop.top) || !isnan(hitSlop.bottom))
#define DevMenuRNGH_HIT_SLOP_INSET(key) (isnan(hitSlop.key) ? 0. : hitSlop.key)

CGRect DevMenuRNGHHitSlopInsetRect(CGRect rect, DevMenuRNGHHitSlop hitSlop) {
    rect.origin.x -= DevMenuRNGH_HIT_SLOP_INSET(left);
    rect.origin.y -= DevMenuRNGH_HIT_SLOP_INSET(top);

    if (!isnan(hitSlop.width)) {
        if (!isnan(hitSlop.right)) {
            rect.origin.x = rect.size.width - hitSlop.width + DevMenuRNGH_HIT_SLOP_INSET(right);
        }
        rect.size.width = hitSlop.width;
    } else {
        rect.size.width += (DevMenuRNGH_HIT_SLOP_INSET(left) + DevMenuRNGH_HIT_SLOP_INSET(right));
    }
    if (!isnan(hitSlop.height)) {
        if (!isnan(hitSlop.bottom)) {
            rect.origin.y = rect.size.height - hitSlop.height + DevMenuRNGH_HIT_SLOP_INSET(bottom);
        }
        rect.size.height = hitSlop.height;
    } else {
        rect.size.height += (DevMenuRNGH_HIT_SLOP_INSET(top) + DevMenuRNGH_HIT_SLOP_INSET(bottom));
    }
    return rect;
}

static NSHashTable<DevMenuRNGestureHandler *> *allGestureHandlers;

@implementation DevMenuRNGestureHandler {
    NSArray<NSNumber *> *_handlersToWaitFor;
    NSArray<NSNumber *> *_simultaneousHandlers;
    DevMenuRNGHHitSlop _hitSlop;
    uint16_t _eventCoalescingKey;
}

- (instancetype)initWithTag:(NSNumber *)tag
{
    if ((self = [super init])) {
        _tag = tag;
        _lastState = DevMenuRNGestureHandlerStateUndetermined;
        _hitSlop = DevMenuRNGHHitSlopEmpty;

        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            allGestureHandlers = [NSHashTable weakObjectsHashTable];
        });

        [allGestureHandlers addObject:self];
    }
    return self;
}

- (void)configure:(NSDictionary *)config
{
    _handlersToWaitFor = [RCTConvert NSNumberArray:config[@"waitFor"]];
    _simultaneousHandlers = [RCTConvert NSNumberArray:config[@"simultaneousHandlers"]];

    id prop = config[@"enabled"];
    if (prop != nil) {
        self.enabled = [RCTConvert BOOL:prop];
    } else {
        self.enabled = YES;
    }

    prop = config[@"shouldCancelWhenOutside"];
    if (prop != nil) {
        _shouldCancelWhenOutside = [RCTConvert BOOL:prop];
    } else {
        _shouldCancelWhenOutside = NO;
    }

    prop = config[@"hitSlop"];
    if ([prop isKindOfClass:[NSNumber class]]) {
        _hitSlop.left = _hitSlop.right = _hitSlop.top = _hitSlop.bottom = [prop doubleValue];
    } else if (prop != nil) {
        _hitSlop.left = _hitSlop.right = DevMenuRNGH_HIT_SLOP_GET(@"horizontal");
        _hitSlop.top = _hitSlop.bottom = DevMenuRNGH_HIT_SLOP_GET(@"vertical");
        _hitSlop.left = DevMenuRNGH_HIT_SLOP_GET(@"left");
        _hitSlop.right = DevMenuRNGH_HIT_SLOP_GET(@"right");
        _hitSlop.top = DevMenuRNGH_HIT_SLOP_GET(@"top");
        _hitSlop.bottom = DevMenuRNGH_HIT_SLOP_GET(@"bottom");
        _hitSlop.width = DevMenuRNGH_HIT_SLOP_GET(@"width");
        _hitSlop.height = DevMenuRNGH_HIT_SLOP_GET(@"height");
        if (isnan(_hitSlop.left) && isnan(_hitSlop.right) && !isnan(_hitSlop.width)) {
            RCTLogError(@"When width is set one of left or right pads need to be defined");
        }
        if (!isnan(_hitSlop.width) && !isnan(_hitSlop.left) && !isnan(_hitSlop.right)) {
            RCTLogError(@"Cannot have all of left, right and width defined");
        }
        if (isnan(_hitSlop.top) && isnan(_hitSlop.bottom) && !isnan(_hitSlop.height)) {
            RCTLogError(@"When height is set one of top or bottom pads need to be defined");
        }
        if (!isnan(_hitSlop.height) && !isnan(_hitSlop.top) && !isnan(_hitSlop.bottom)) {
            RCTLogError(@"Cannot have all of top, bottom and height defined");
        }
    }
}

- (void)setEnabled:(BOOL)enabled
{
    _enabled = enabled;
    self.recognizer.enabled = enabled;
}

- (void)bindToView:(UIView *)view
{
    view.userInteractionEnabled = YES;
    self.recognizer.delegate = self;
    [view addGestureRecognizer:self.recognizer];
}

- (void)unbindFromView
{
    [self.recognizer.view removeGestureRecognizer:self.recognizer];
    self.recognizer.delegate = nil;
}

- (DevMenuRNGestureHandlerEventExtraData *)eventExtraData:(UIGestureRecognizer *)recognizer
{
    return [DevMenuRNGestureHandlerEventExtraData
            forPosition:[recognizer locationInView:recognizer.view]
            withAbsolutePosition:[recognizer locationInView:recognizer.view.window]
            withNumberOfTouches:recognizer.numberOfTouches];
}

- (void)handleGesture:(UIGestureRecognizer *)recognizer
{
    DevMenuRNGestureHandlerEventExtraData *eventData = [self eventExtraData:recognizer];
    [self sendEventsInState:self.state forViewWithTag:recognizer.view.reactTag withExtraData:eventData];
}

- (void)sendEventsInState:(DevMenuRNGestureHandlerState)state
           forViewWithTag:(nonnull NSNumber *)reactTag
            withExtraData:(DevMenuRNGestureHandlerEventExtraData *)extraData
{
    if (state != _lastState) {
        if (state == DevMenuRNGestureHandlerStateActive) {
            // Generate a unique coalescing-key each time the gesture-handler becomes active. All events will have
            // the same coalescing-key allowing RCTEventDispatcher to coalesce DevMenuRNGestureHandlerEvents when events are
            // generated faster than they can be treated by JS thread
            static uint16_t nextEventCoalescingKey = 0;
            self->_eventCoalescingKey = nextEventCoalescingKey++;

        } else if (state == DevMenuRNGestureHandlerStateEnd && _lastState != DevMenuRNGestureHandlerStateActive) {
            [self.emitter sendStateChangeEvent:[[DevMenuRNGestureHandlerStateChange alloc] initWithReactTag:reactTag
                                                                                          handlerTag:_tag
                                                                                               state:DevMenuRNGestureHandlerStateActive
                                                                                           prevState:_lastState
                                                                                           extraData:extraData]];
            _lastState = DevMenuRNGestureHandlerStateActive;
        }
        id stateEvent = [[DevMenuRNGestureHandlerStateChange alloc] initWithReactTag:reactTag
                                                                   handlerTag:_tag
                                                                        state:state
                                                                    prevState:_lastState
                                                                    extraData:extraData];
        [self.emitter sendStateChangeEvent:stateEvent];
        _lastState = state;
    }

    if (state == DevMenuRNGestureHandlerStateActive) {
        id touchEvent = [[DevMenuRNGestureHandlerEvent alloc] initWithReactTag:reactTag
                                                             handlerTag:_tag
                                                                  state:state
                                                              extraData:extraData
                                                          coalescingKey:self->_eventCoalescingKey];
        [self.emitter sendTouchEvent:touchEvent];
    }
}

- (DevMenuRNGestureHandlerState)state
{
    switch (_recognizer.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStatePossible:
            return DevMenuRNGestureHandlerStateBegan;
        case UIGestureRecognizerStateEnded:
            return DevMenuRNGestureHandlerStateEnd;
        case UIGestureRecognizerStateFailed:
            return DevMenuRNGestureHandlerStateFailed;
        case UIGestureRecognizerStateCancelled:
            return DevMenuRNGestureHandlerStateCancelled;
        case UIGestureRecognizerStateChanged:
            return DevMenuRNGestureHandlerStateActive;
    }
    return DevMenuRNGestureHandlerStateUndetermined;
}

#pragma mark UIGestureRecognizerDelegate

+ (DevMenuRNGestureHandler *)findGestureHandlerByRecognizer:(UIGestureRecognizer *)recognizer
{
    DevMenuRNGestureHandler *handler = recognizer.gestureHandler;
    if (handler != nil) {
        return handler;
    }

    // We may try to extract "DummyGestureHandler" in case when "otherGestureRecognizer" belongs to
    // a native view being wrapped with "NativeViewGestureHandler"
    UIView *reactView = recognizer.view;
    while (reactView != nil && reactView.reactTag == nil) {
        reactView = reactView.superview;
    }

    for (UIGestureRecognizer *recognizer in reactView.gestureRecognizers) {
        if ([recognizer isKindOfClass:[DevMenuRNDummyGestureRecognizer class]]) {
            return recognizer.gestureHandler;
        }
    }

    return nil;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    DevMenuRNGestureHandler *handler = [DevMenuRNGestureHandler findGestureHandlerByRecognizer:otherGestureRecognizer];
    if ([handler isKindOfClass:[DevMenuRNNativeViewGestureHandler class]]) {
        for (NSNumber *handlerTag in handler->_handlersToWaitFor) {
            if ([_tag isEqual:handlerTag]) {
                return YES;
            }
        }
    }

    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([_handlersToWaitFor count]) {
        DevMenuRNGestureHandler *handler = [DevMenuRNGestureHandler findGestureHandlerByRecognizer:otherGestureRecognizer];
        if (handler != nil) {
            for (NSNumber *handlerTag in _handlersToWaitFor) {
                if ([handler.tag isEqual:handlerTag]) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (_recognizer.state == UIGestureRecognizerStateBegan && _recognizer.state == UIGestureRecognizerStatePossible) {
        return YES;
    }
    if ([_simultaneousHandlers count]) {
        DevMenuRNGestureHandler *handler = [DevMenuRNGestureHandler findGestureHandlerByRecognizer:otherGestureRecognizer];
        if (handler != nil) {
            for (NSNumber *handlerTag in _simultaneousHandlers) {
                if ([handler.tag isEqual:handlerTag]) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (void)reset
{
    _lastState = DevMenuRNGestureHandlerStateUndetermined;
}

 - (BOOL)containsPointInView
 {
     CGPoint pt = [_recognizer locationInView:_recognizer.view];
     CGRect hitFrame = DevMenuRNGHHitSlopInsetRect(_recognizer.view.bounds, _hitSlop);
     return CGRectContainsPoint(hitFrame, pt);
 }

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([_handlersToWaitFor count]) {
        for (DevMenuRNGestureHandler *handler in [allGestureHandlers allObjects]) {
            if (handler != nil
                && (handler.state == DevMenuRNGestureHandlerStateActive || handler->_recognizer.state == UIGestureRecognizerStateBegan)) {
                for (NSNumber *handlerTag in _handlersToWaitFor) {
                    if ([handler.tag isEqual:handlerTag]) {
                        return NO;
                    }
                }
            }
        }
    }

    [self reset];
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // If hitSlop is set we use it to determine if a given gesture recognizer should start processing
    // touch stream. This only works for negative values of hitSlop as this method won't be triggered
    // unless touch startes in the bounds of the attached view. To acheve similar effect with positive
    // values of hitSlop one should set hitSlop for the underlying view. This limitation is due to the
    // fact that hitTest method is only available at the level of UIView
    if (DevMenuRNGH_HIT_SLOP_IS_SET(_hitSlop)) {
        CGPoint location = [touch locationInView:gestureRecognizer.view];
        CGRect hitFrame = DevMenuRNGHHitSlopInsetRect(gestureRecognizer.view.bounds, _hitSlop);
        return CGRectContainsPoint(hitFrame, location);
    }
    return YES;
}

@end
