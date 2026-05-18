/**
 * EntryAbility - 应用入口
 * 负责应用生命周期管理和窗口配置
 */

import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';
import wantAgent from '@ohos.wantAgent';
import notificationManager from '@ohos.notificationManager';
import backgroundTaskManager from '@ohos.backgroundTaskManager';

export default class EntryAbility extends UIAbility {
  private windowStage: window.WindowStage | null = null;

  onCreate(want, launchParam) {
    console.info("EntryAbility onCreate");
    this.requestPermissions();
  }

  onDestroy() {
    console.info("EntryAbility onDestroy");
    backgroundTaskManager.stopBackgroundTask("flexible_clock_timer");
  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    console.info("EntryAbility onWindowStageCreate");
    this.windowStage = windowStage;

    windowStage.loadContent("pages/Index", (err, data) => {
      if (err.code) {
        console.error("Failed to load the content. Cause:", JSON.stringify(err));
        return;
      }
      console.info("Succeeded in loading the content. Data:", JSON.stringify(data));
    });

    this.setupWindow();
  }

  async setupWindow() {
    if (!this.windowStage) return;

    try {
      const mainWindow = await this.windowStage.getMainWindow();
      await mainWindow.setLayoutFullScreen(true);
      await mainWindow.setImmersiveStatusBar(true);
    } catch (e) {
      console.error("Setup window error:", e);
    }
  }

  onWindowStageDestroy() {
    console.info("EntryAbility onWindowStageDestroy");
  }

  onForeground() {
    console.info("EntryAbility onForeground");
  }

  onBackground() {
    console.info("EntryAbility onBackground");
  }

  private async requestPermissions() {
    try {
      console.info("Requesting permissions for flexible clock app");
    } catch (e) {
      console.error("Permission request error:", e);
    }
  }
}
