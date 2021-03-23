package host.exp.exponent.notifications;

import android.content.Context;
import android.util.Pair;

import androidx.annotation.Nullable;
import expo.modules.notifications.notifications.model.Notification;
import expo.modules.notifications.notifications.model.NotificationRequest;
import expo.modules.notifications.notifications.model.NotificationResponse;
import host.exp.exponent.kernel.ExperienceId;
import host.exp.exponent.services.ScopedExpoNotificationsService;

public class ScopedNotificationsUtils {
  private ExponentNotificationManager mExponentNotificationManager;

  public ScopedNotificationsUtils(Context context) {
    mExponentNotificationManager = new ExponentNotificationManager(context);
  }

  public boolean shouldHandleNotification(Notification notification, ExperienceId experienceId) {
    return shouldHandleNotification(notification.getNotificationRequest(), experienceId);
  }

  public boolean shouldHandleNotification(NotificationRequest notificationRequest, ExperienceId experienceId) {
    // expo-notifications notification
    if (notificationRequest instanceof ScopedNotificationRequest) {
      ScopedNotificationRequest scopedNotificationRequest = (ScopedNotificationRequest) notificationRequest;
      return scopedNotificationRequest.checkIfBelongsToExperience(experienceId);
    }

    // legacy or foreign notification
    Pair<String, Integer> foreignNotification = ScopedExpoNotificationsService.parseNotificationIdentifier(notificationRequest.getIdentifier());
    if (foreignNotification != null) {
      boolean notificationBelongsToSomeExperience = mExponentNotificationManager.getAllNotificationsIds(foreignNotification.first).contains(foreignNotification.second);
      boolean notificationExperienceIsCurrentExperience = experienceId.get().equals(foreignNotification.first);
      // If notification doesn't belong to any experience it's a foreign notification
      // and we want to deliver it to all the experiences. If it does belong to some experience,
      // we want to handle it only if it belongs to "current" experience.
      return !notificationBelongsToSomeExperience || notificationExperienceIsCurrentExperience;
    }

    // fallback
    return true;
  }

  public static String getExperienceId(@Nullable NotificationResponse notificationResponse) {
    if (notificationResponse == null || notificationResponse.getNotification() == null) {
      return null;
    }

    NotificationRequest notificationRequest = notificationResponse.getNotification().getNotificationRequest();
    if (notificationRequest instanceof ScopedNotificationRequest) {
      ScopedNotificationRequest scopedNotificationRequest = (ScopedNotificationRequest) notificationRequest;
      return scopedNotificationRequest.getExperienceIdString();
    }

    return null;
  }
}
