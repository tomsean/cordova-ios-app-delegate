
#import "AppDelegate+notification.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation AppDelegate (notification)

void MethodSwizzle(Class c, SEL originalSelector) {
    NSString *selectorString = NSStringFromSelector(originalSelector);
    SEL newSelector = NSSelectorFromString([@"swizzled_" stringByAppendingString:selectorString]);
    SEL noopSelector = NSSelectorFromString([@"noop_" stringByAppendingString:selectorString]);
    Method originalMethod, newMethod, noop;
    originalMethod = class_getInstanceMethod(c, originalSelector);
    newMethod = class_getInstanceMethod(c, newSelector);
    noop = class_getInstanceMethod(c, noopSelector);
    if (class_addMethod(c, originalSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(c, newSelector, method_getImplementation(originalMethod) ?: method_getImplementation(noop), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
}

+ (void)load
{
    MethodSwizzle([self class], @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:));
    MethodSwizzle([self class], @selector(application:didReceiveRemoteNotification:));
     MethodSwizzle([self class], @selector(application:didFinishLaunchingWithOptions:));
}
- (BOOL)noop_application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions{
    
   
    return  YES;
}
- (BOOL)swizzled_application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions{
    BOOL  result= [self swizzled_application:application didFinishLaunchingWithOptions:launchOptions];
    [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateDidFinishLaunchingNotification object:launchOptions];
    return  result;
}
- (void)noop_application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken
{
    
}

- (void)swizzled_application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken
{
    // Call existing method
    [self swizzled_application:application didRegisterForRemoteNotificationsWithDeviceToken:newDeviceToken];
    [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateRegisterForRemoteNotification object:newDeviceToken];
}

- (void)noop_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
}

- (void)swizzled_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // Call existing method
    [self swizzled_application:application didReceiveRemoteNotification:userInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateReceiveRemoteNotification object:userInfo];
}

@end