package host.exp.exponent.services;

import android.os.Parcel;

import expo.modules.notifications.notifications.model.NotificationRequest;
import expo.modules.notifications.notifications.service.ExpoNotificationsService;
import host.exp.exponent.notifications.ScopedNotificationRequest;

public class ScopedExpoNotificationsService extends ExpoNotificationsService {
  @Override
  protected NotificationRequest reconstructNotificationRequest(Parcel parcel) {
    return (NotificationRequest) ScopedNotificationRequest.CREATOR.createFromParcel(parcel);
  }
}
