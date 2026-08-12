const fs = require("fs");
const path = require("path");

const SCENE_DELEGATE_PATH = "platforms/ios/App/SceneDelegate.swift";

const PATCHED_SCENE_DELEGATE = `import Cordova

class SceneDelegate: CDVSceneDelegate {
    /// Stores the universal link user activity from cold boot for plugins to consume.
    @objc static var launchUserActivity: NSUserActivity?

    override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        super.scene(scene, willConnectTo: session, options: connectionOptions)

        // CDVSceneDelegate only forwards URLContexts, not userActivities.
        // Buffer any universal link for plugins to pick up after initialization.
        for activity in connectionOptions.userActivities {
            if activity.activityType == NSUserActivityTypeBrowsingWeb {
                SceneDelegate.launchUserActivity = activity
                break
            }
        }
    }

    override func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        super.scene(scene, continue: userActivity)
        // Clear launch activity if the same link is delivered again via continueUserActivity
        if SceneDelegate.launchUserActivity?.webpageURL == userActivity.webpageURL {
            SceneDelegate.launchUserActivity = nil
        }
    }
}
`;

function patchSceneDelegate(projectRoot) {
  const sceneDelegatePath = path.join(projectRoot, SCENE_DELEGATE_PATH);

  if (!fs.existsSync(sceneDelegatePath)) {
    console.log("ℹ️ SceneDelegate.swift not found, skipping patch (not an iOS build).");
    return;
  }

  fs.writeFileSync(sceneDelegatePath, PATCHED_SCENE_DELEGATE, "utf8");
  console.log("✅ Patched SceneDelegate.swift with universal link cold boot support.");
}

module.exports = function (context) {
  const { projectRoot } = context.opts;
  patchSceneDelegate(projectRoot);
};
