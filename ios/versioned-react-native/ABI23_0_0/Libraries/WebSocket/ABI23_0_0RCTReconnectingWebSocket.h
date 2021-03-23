/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <ReactABI23_0_0/ABI23_0_0RCTDefines.h>

#if ABI23_0_0RCT_DEV // Only supported in dev mode

@class ABI23_0_0RCTSRWebSocket;

@protocol ABI23_0_0RCTWebSocketProtocolDelegate

- (void)webSocketDidOpen:(ABI23_0_0RCTSRWebSocket *)webSocket;

- (void)webSocket:(ABI23_0_0RCTSRWebSocket *)webSocket didReceiveMessage:(id)message;

- (void)webSocket:(ABI23_0_0RCTSRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;

@end

@interface ABI23_0_0RCTReconnectingWebSocket : NSObject

- (instancetype)initWithURL:(NSURL *)url;
@property (nonatomic, weak) id<ABI23_0_0RCTWebSocketProtocolDelegate> delegate;
/** @brief Must be set before -start to have effect */
@property (nonatomic, strong) dispatch_queue_t delegateDispatchQueue;
- (void)send:(id)data;
- (void)start;
- (void)stop;

@end

#endif
