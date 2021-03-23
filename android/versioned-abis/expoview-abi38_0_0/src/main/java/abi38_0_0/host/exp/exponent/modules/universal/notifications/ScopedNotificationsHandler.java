package abi38_0_0.host.exp.exponent.modules.universal.notifications;

import android.content.Context;

import abi38_0_0.expo.modules.notifications.notifications.handling.NotificationsHandler;
import expo.modules.notifications.notifications.model.Notification;
import expo.modules.notifications.notifications.model.NotificationResponse;
import host.exp.exponent.kernel.ExperienceId;
import host.exp.exponent.notifications.ScopedNotificationsUtils;

public class ScopedNotificationsHandler extends NotificationsHandler {
  private ExperienceId mExperienceId;

  public ScopedNotificationsHandler(Context context, ExperienceId experienceId) {
    super(context);
    mExperienceId = experienceId;
  }

  @Override
  public void onNotificationReceived(Notification notification) {
    if (ScopedNotificationsUtils.shouldHandleNotification(notification, mExperienceId)) {
      super.onNotificationReceived(notification);
    }
  }

  @Override
  public void onNotificationResponseReceived(NotificationResponse response) {
    if (ScopedNotificationsUtils.shouldHandleNotification(response.getNotification(), mExperienceId)) {
      super.onNotificationResponseReceived(response);
    }
  }
}
