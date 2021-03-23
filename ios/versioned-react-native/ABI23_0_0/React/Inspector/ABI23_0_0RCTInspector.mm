
#import "ABI23_0_0RCTInspector.h"

#if ABI23_0_0RCT_DEV

#include <ABI23_0_0jschelpers/ABI23_0_0InspectorInterfaces.h>
#include <ABI23_0_0jschelpers/ABI23_0_0JavaScriptCore.h>

#import "ABI23_0_0RCTDefines.h"
#import "ABI23_0_0RCTInspectorPackagerConnection.h"
#import "ABI23_0_0RCTLog.h"
#import "ABI23_0_0RCTSRWebSocket.h"
#import "ABI23_0_0RCTUtils.h"

using namespace facebook::ReactABI23_0_0;

// This is a port of the Android impl, at
// ReactABI23_0_0-native-github/ReactABI23_0_0Android/src/main/java/com/facebook/ReactABI23_0_0/bridge/Inspector.java
// ReactABI23_0_0-native-github/ReactABI23_0_0Android/src/main/jni/ReactABI23_0_0/jni/JInspector.cpp
// please keep consistent :)

class RemoteConnection : public IRemoteConnection {
public:
RemoteConnection(ABI23_0_0RCTInspectorRemoteConnection *connection) :
  _connection(connection) {}

  virtual void onMessage(std::string message) override {
    [_connection onMessage:@(message.c_str())];
  }

  virtual void onDisconnect() override {
    [_connection onDisconnect];
  }
private:
  const ABI23_0_0RCTInspectorRemoteConnection *_connection;
};

@interface ABI23_0_0RCTInspectorPage () {
  NSInteger _id;
  NSString *_title;
}
- (instancetype)initWithId:(NSInteger)id
                     title:(NSString *)title;
@end

@interface ABI23_0_0RCTInspectorLocalConnection () {
  std::unique_ptr<ILocalConnection> _connection;
}
- (instancetype)initWithConnection:(std::unique_ptr<ILocalConnection>)connection;
@end

// Only safe to call with Custom JSC. Custom JSC check must occur earlier
// in the stack
static IInspector *getInstance()
{
  static dispatch_once_t onceToken;
  static IInspector *s_inspector;
  dispatch_once(&onceToken, ^{
    s_inspector = customJSCWrapper()->JSInspectorGetInstance();
  });

  return s_inspector;
}

@implementation ABI23_0_0RCTInspector

ABI23_0_0RCT_NOT_IMPLEMENTED(- (instancetype)init)

+ (NSArray<ABI23_0_0RCTInspectorPage *> *)pages
{
  std::vector<InspectorPage> pages = getInstance()->getPages();
  NSMutableArray<ABI23_0_0RCTInspectorPage *> *array = [NSMutableArray arrayWithCapacity:pages.size()];
  for (size_t i = 0; i < pages.size(); i++) {
    ABI23_0_0RCTInspectorPage *pageWrapper = [[ABI23_0_0RCTInspectorPage alloc] initWithId:pages[i].id
                                                                   title:@(pages[i].title.c_str())];
    [array addObject:pageWrapper];

  }
  return array;
}

+ (ABI23_0_0RCTInspectorLocalConnection *)connectPage:(NSInteger)pageId
                         forRemoteConnection:(ABI23_0_0RCTInspectorRemoteConnection *)remote
{
  auto localConnection = getInstance()->connect(pageId, std::make_unique<RemoteConnection>(remote));
  return [[ABI23_0_0RCTInspectorLocalConnection alloc] initWithConnection:std::move(localConnection)];
}

@end

@implementation ABI23_0_0RCTInspectorPage

ABI23_0_0RCT_NOT_IMPLEMENTED(- (instancetype)init)

- (instancetype)initWithId:(NSInteger)id
                     title:(NSString *)title
{
  if (self = [super init]) {
    _id = id;
    _title = title;
  }
  return self;
}

@end

@implementation ABI23_0_0RCTInspectorLocalConnection

ABI23_0_0RCT_NOT_IMPLEMENTED(- (instancetype)init)

- (instancetype)initWithConnection:(std::unique_ptr<ILocalConnection>)connection
{
  if (self = [super init]) {
    _connection = std::move(connection);
  }
  return self;
}

- (void)sendMessage:(NSString *)message
{
  _connection->sendMessage([message UTF8String]);
}

- (void)disconnect
{
  _connection->disconnect();
}

@end

#endif
