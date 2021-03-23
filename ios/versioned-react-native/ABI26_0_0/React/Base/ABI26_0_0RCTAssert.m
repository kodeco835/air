/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "ABI26_0_0RCTAssert.h"
#import "ABI26_0_0RCTLog.h"

NSString *const ABI26_0_0RCTErrorDomain = @"ABI26_0_0RCTErrorDomain";
NSString *const ABI26_0_0RCTJSStackTraceKey = @"ABI26_0_0RCTJSStackTraceKey";
NSString *const ABI26_0_0RCTJSRawStackTraceKey = @"ABI26_0_0RCTJSRawStackTraceKey";
NSString *const ABI26_0_0RCTFatalExceptionName = @"ABI26_0_0RCTFatalException";

static NSString *const ABI26_0_0RCTAssertFunctionStack = @"ABI26_0_0RCTAssertFunctionStack";

ABI26_0_0RCTAssertFunction ABI26_0_0RCTCurrentAssertFunction = nil;
ABI26_0_0RCTFatalHandler ABI26_0_0RCTCurrentFatalHandler = nil;

NSException *_ABI26_0_0RCTNotImplementedException(SEL, Class);
NSException *_ABI26_0_0RCTNotImplementedException(SEL cmd, Class cls)
{
  NSString *msg = [NSString stringWithFormat:@"%s is not implemented "
                   "for the class %@", sel_getName(cmd), cls];
  return [NSException exceptionWithName:@"ABI26_0_0RCTNotDesignatedInitializerException"
                                 reason:msg userInfo:nil];
}

void ABI26_0_0RCTSetAssertFunction(ABI26_0_0RCTAssertFunction assertFunction)
{
  ABI26_0_0RCTCurrentAssertFunction = assertFunction;
}

ABI26_0_0RCTAssertFunction ABI26_0_0RCTGetAssertFunction(void)
{
  return ABI26_0_0RCTCurrentAssertFunction;
}

void ABI26_0_0RCTAddAssertFunction(ABI26_0_0RCTAssertFunction assertFunction)
{
  ABI26_0_0RCTAssertFunction existing = ABI26_0_0RCTCurrentAssertFunction;
  if (existing) {
    ABI26_0_0RCTCurrentAssertFunction = ^(NSString *condition,
                                 NSString *fileName,
                                 NSNumber *lineNumber,
                                 NSString *function,
                                 NSString *message) {

      existing(condition, fileName, lineNumber, function, message);
      assertFunction(condition, fileName, lineNumber, function, message);
    };
  } else {
    ABI26_0_0RCTCurrentAssertFunction = assertFunction;
  }
}

/**
 * returns the topmost stacked assert function for the current thread, which
 * may not be the same as the current value of ABI26_0_0RCTCurrentAssertFunction.
 */
static ABI26_0_0RCTAssertFunction ABI26_0_0RCTGetLocalAssertFunction()
{
  NSMutableDictionary *threadDictionary = [NSThread currentThread].threadDictionary;
  NSArray<ABI26_0_0RCTAssertFunction> *functionStack = threadDictionary[ABI26_0_0RCTAssertFunctionStack];
  ABI26_0_0RCTAssertFunction assertFunction = functionStack.lastObject;
  if (assertFunction) {
    return assertFunction;
  }
  return ABI26_0_0RCTCurrentAssertFunction;
}

void ABI26_0_0RCTPerformBlockWithAssertFunction(void (^block)(void), ABI26_0_0RCTAssertFunction assertFunction)
{
  NSMutableDictionary *threadDictionary = [NSThread currentThread].threadDictionary;
  NSMutableArray<ABI26_0_0RCTAssertFunction> *functionStack = threadDictionary[ABI26_0_0RCTAssertFunctionStack];
  if (!functionStack) {
    functionStack = [NSMutableArray new];
    threadDictionary[ABI26_0_0RCTAssertFunctionStack] = functionStack;
  }
  [functionStack addObject:assertFunction];
  block();
  [functionStack removeLastObject];
}

NSString *ABI26_0_0RCTCurrentThreadName(void)
{
  NSThread *thread = [NSThread currentThread];
  NSString *threadName = ABI26_0_0RCTIsMainQueue() || thread.isMainThread ? @"main" : thread.name;
  if (threadName.length == 0) {
    const char *label = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL);
    if (label && strlen(label) > 0) {
      threadName = @(label);
    } else {
      threadName = [NSString stringWithFormat:@"%p", thread];
    }
  }
  return threadName;
}

void _ABI26_0_0RCTAssertFormat(
  const char *condition,
  const char *fileName,
  int lineNumber,
  const char *function,
  NSString *format, ...)
{
  ABI26_0_0RCTAssertFunction assertFunction = ABI26_0_0RCTGetLocalAssertFunction();
  if (assertFunction) {
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);

    assertFunction(@(condition), @(fileName), @(lineNumber), @(function), message);
  }
}

void ABI26_0_0RCTFatal(NSError *error)
{
  _ABI26_0_0RCTLogNativeInternal(ABI26_0_0RCTLogLevelFatal, NULL, 0, @"%@", error.localizedDescription);

  ABI26_0_0RCTFatalHandler fatalHandler = ABI26_0_0RCTGetFatalHandler();
  if (fatalHandler) {
    fatalHandler(error);
  } else {
#if DEBUG
    @try {
#endif
      NSString *name = [NSString stringWithFormat:@"%@: %@", ABI26_0_0RCTFatalExceptionName, error.localizedDescription];
      NSString *message = ABI26_0_0RCTFormatError(error.localizedDescription, error.userInfo[ABI26_0_0RCTJSStackTraceKey], 75);
      @throw [[NSException alloc]  initWithName:name reason:message userInfo:nil];
#if DEBUG
    } @catch (NSException *e) {}
#endif
  }
}

void ABI26_0_0RCTSetFatalHandler(ABI26_0_0RCTFatalHandler fatalhandler)
{
  ABI26_0_0RCTCurrentFatalHandler = fatalhandler;
}

ABI26_0_0RCTFatalHandler ABI26_0_0RCTGetFatalHandler(void)
{
  return ABI26_0_0RCTCurrentFatalHandler;
}

NSString *ABI26_0_0RCTFormatError(NSString *message, NSArray<NSDictionary<NSString *, id> *> *stackTrace, NSUInteger maxMessageLength)
{
  if (maxMessageLength > 0 && message.length > maxMessageLength) {
    message = [[message substringToIndex:maxMessageLength] stringByAppendingString:@"..."];
  }

  NSMutableString *prettyStack = [NSMutableString string];
  if (stackTrace) {
    [prettyStack appendString:@", stack:\n"];

    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^(\\d+\\.js)$"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:NULL];
    for (NSDictionary<NSString *, id> *frame in stackTrace) {
      NSString *fileName = [frame[@"file"] lastPathComponent];
      if (fileName && [regex numberOfMatchesInString:fileName options:0 range:NSMakeRange(0, [fileName length])]) {
        fileName = [fileName stringByAppendingString:@":"];
      } else {
        fileName = @"";
      }

      [prettyStack appendFormat:@"%@@%@%@:%@\n", frame[@"methodName"], fileName, frame[@"lineNumber"], frame[@"column"]];
    }
  }

  return [NSString stringWithFormat:@"%@%@", message, prettyStack];
}
