package com.example.control_bebe

import android.app.Notification
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import com.example.live_activities.LiveActivityManager

class CustomLiveActivityManager(context: Context) : LiveActivityManager(context) {
    private val appContext: Context = context.applicationContext
    private val contentIntent = PendingIntent.getActivity(
        appContext,
        201,
        Intent(appContext, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
        },
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
    )

    private val remoteViews = RemoteViews(appContext.packageName, R.layout.lactation_live_activity)

    override suspend fun buildNotification(
        notification: Notification.Builder,
        event: String,
        data: Map<String, Any>,
    ): Notification {
        val title = data["title"] as? String ?: appContext.getString(R.string.lactation_live_notification_title)
        val sideLabel = data["sideLabel"] as? String ?: "—"
        val startedAtMs = (data["startedAtMs"] as Number).toLong()

        remoteViews.setTextViewText(R.id.lactation_title, title)
        remoteViews.setTextViewText(R.id.lactation_side, sideLabel)

        val elapsedRealtime = android.os.SystemClock.elapsedRealtime()
        val currentTimeMillis = System.currentTimeMillis()
        val base = elapsedRealtime - (currentTimeMillis - startedAtMs)
        remoteViews.setChronometer(R.id.lactation_chronometer, base, null, true)

        return notification
            .setSmallIcon(R.mipmap.ic_launcher)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setContentIntent(contentIntent)
            .setContentTitle(title)
            .setContentText(sideLabel)
            .setStyle(Notification.DecoratedCustomViewStyle())
            .setCustomContentView(remoteViews)
            .setCustomBigContentView(remoteViews)
            .setPriority(Notification.PRIORITY_LOW)
            .setCategory(Notification.CATEGORY_SERVICE)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .build()
    }
}
