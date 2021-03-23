#import "ABI33_0_0RNCUIWebViewManager.h"

#import <ReactABI33_0_0/ABI33_0_0RCTBridge.h>
#import <ReactABI33_0_0/ABI33_0_0RCTUIManager.h>
#import <ReactABI33_0_0/UIView+ReactABI33_0_0.h>

@interface ABI33_0_0RNCUIWebViewManager ()

@end

@implementation ABI33_0_0RNCUIWebViewManager

ABI33_0_0RCT_EXPORT_MODULE()

- (UIView *)view
{
  ABI33_0_0RCTLogWarn(@"RCTWebView had to be removed from SDK35-compatible "
  "Expo Client in order to comply with latest App Review"
  "guidelines. Plain empty view will be rendered instead.");
  return [[UIView alloc] initWithFrame:CGRectZero];
}

ABI33_0_0RCT_EXPORT_METHOD(goBack:(nonnull NSNumber *)ReactABI33_0_0Tag)
{
}

ABI33_0_0RCT_EXPORT_METHOD(goForward:(nonnull NSNumber *)ReactABI33_0_0Tag)
{
}

ABI33_0_0RCT_EXPORT_METHOD(reload:(nonnull NSNumber *)ReactABI33_0_0Tag)
{
}

ABI33_0_0RCT_EXPORT_METHOD(stopLoading:(nonnull NSNumber *)ReactABI33_0_0Tag)
{
}

ABI33_0_0RCT_EXPORT_METHOD(postMessage:(nonnull NSNumber *)ReactABI33_0_0Tag message:(NSString *)message)
{
}

ABI33_0_0RCT_EXPORT_METHOD(injectJavaScript:(nonnull NSNumber *)ReactABI33_0_0Tag script:(NSString *)script)
{
}

#pragma mark - Exported synchronous methods

ABI33_0_0RCT_EXPORT_METHOD(startLoadWithResult:(BOOL)result lockIdentifier:(NSInteger)lockIdentifier)
{
}

@end
