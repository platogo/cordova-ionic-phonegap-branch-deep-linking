#import "CDVSceneDelegate+BranchSDK.h"
#import "BranchNPM.h"
#import <objc/runtime.h>

#ifdef BRANCH_NPM
#import "Branch.h"
#else
#import <BranchSDK/Branch.h>
#endif

// CDVSceneDelegate only forwards NSUserActivity via scene:continueUserActivity: (warm resume),
// not the universal link captured on cold launch in connectionOptions.userActivities. The app's
// generated SceneDelegate.swift is an empty subclass of CDVSceneDelegate, so swizzling this
// selector here — instead of patching that generated file — is inherited transparently, as long
// as the generated subclass never overrides `scene:willConnectToSession:options:` itself. Runs
// from +load, before any scene connects, and stacks safely with any other plugin swizzling the
// same selector (e.g. cordova-plugin-notification-router), since each swizzle chains to whatever
// implementation was already installed.
@implementation CDVSceneDelegate (BranchSDK)

+ (void)load {
    Class class = [CDVSceneDelegate class];
    SEL originalSelector = @selector(scene:willConnectToSession:options:);
    SEL swizzledSelector = @selector(branchSdk_scene:willConnectToSession:options:);

    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

- (void)branchSdk_scene:(UIScene *)scene
    willConnectToSession:(UISceneSession *)session
                 options:(UISceneConnectionOptions *)connectionOptions {
    [self branchSdk_scene:scene willConnectToSession:session options:connectionOptions];

    for (NSUserActivity *activity in connectionOptions.userActivities) {
        if ([activity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
            [[Branch getInstance] continueUserActivity:activity];
            break;
        }
    }
}

@end
