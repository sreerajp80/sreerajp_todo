package `in`.sreerajp.sreerajp_todo

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import androidx.core.app.NotificationCompat
import java.util.Calendar

class AlarmReceiver : BroadcastReceiver() {

    companion object {
        const val ACTION_PENDING_ALERT = "in.sreerajp.todo.ACTION_PENDING_ALERT"
        const val PENDING_CHANNEL_ID = "pending_todo_reminder_channel"
        const val PENDING_NOTIFICATION_ID = 1002
        const val ALARM_REQUEST_CODE = 4720

        private const val PREFS_NAME = "sreerajp_todo_alarm_prefs"
        private const val KEY_ENABLED = "alarm_enabled"
        private const val KEY_DAY_START_ENABLED = "alarm_day_start_enabled"
        private const val KEY_DAY_START_HOUR = "alarm_day_start_hour"
        private const val KEY_DAY_START_MINUTE = "alarm_day_start_minute"
        private const val KEY_INTERVAL_MINUTES = "alarm_interval_minutes"
        private const val KEY_PENDING_COUNT = "alarm_pending_count"

        fun scheduleNextAlarm(context: Context) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val enabled = prefs.getBoolean(KEY_ENABLED, false)
            if (!enabled) {
                cancelAlarm(context)
                return
            }

            val dayStartEnabled = prefs.getBoolean(KEY_DAY_START_ENABLED, true)
            val dayStartHour = prefs.getInt(KEY_DAY_START_HOUR, 9)
            val dayStartMinute = prefs.getInt(KEY_DAY_START_MINUTE, 0)
            val intervalMinutes = prefs.getInt(KEY_INTERVAL_MINUTES, 120)

            val now = Calendar.getInstance()
            var nextTriggerMillis: Long = Long.MAX_VALUE

            // 1. Check interval trigger
            if (intervalMinutes > 0) {
                val intervalTrigger = now.timeInMillis + (intervalMinutes * 60 * 1000L)
                if (intervalTrigger < nextTriggerMillis) {
                    nextTriggerMillis = intervalTrigger
                }
            }

            // 2. Check day start trigger
            if (dayStartEnabled) {
                val dayStart = Calendar.getInstance().apply {
                    set(Calendar.HOUR_OF_DAY, dayStartHour)
                    set(Calendar.MINUTE, dayStartMinute)
                    set(Calendar.SECOND, 0)
                    set(Calendar.MILLISECOND, 0)
                }
                if (dayStart.timeInMillis <= now.timeInMillis) {
                    dayStart.add(Calendar.DAY_OF_YEAR, 1)
                }
                if (dayStart.timeInMillis < nextTriggerMillis) {
                    nextTriggerMillis = dayStart.timeInMillis
                }
            }

            if (nextTriggerMillis == Long.MAX_VALUE) {
                cancelAlarm(context)
                return
            }

            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return
            val intent = Intent(context, AlarmReceiver::class.java).apply {
                action = ACTION_PENDING_ALERT
            }
            val pendingIntentFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                ALARM_REQUEST_CODE,
                intent,
                pendingIntentFlags
            )

            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && !alarmManager.canScheduleExactAlarms()) {
                        alarmManager.setAndAllowWhileIdle(
                            AlarmManager.RTC_WAKEUP,
                            nextTriggerMillis,
                            pendingIntent
                        )
                    } else {
                        alarmManager.setExactAndAllowWhileIdle(
                            AlarmManager.RTC_WAKEUP,
                            nextTriggerMillis,
                            pendingIntent
                        )
                    }
                } else {
                    alarmManager.setExact(
                        AlarmManager.RTC_WAKEUP,
                        nextTriggerMillis,
                        pendingIntent
                    )
                }
            } catch (e: SecurityException) {
                alarmManager.set(
                    AlarmManager.RTC_WAKEUP,
                    nextTriggerMillis,
                    pendingIntent
                )
            }
        }

        fun cancelAlarm(context: Context) {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return
            val intent = Intent(context, AlarmReceiver::class.java).apply {
                action = ACTION_PENDING_ALERT
            }
            val pendingIntentFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                ALARM_REQUEST_CODE,
                intent,
                pendingIntentFlags
            )
            alarmManager.cancel(pendingIntent)
        }

        fun saveAndSchedule(
            context: Context,
            enabled: Boolean,
            dayStartEnabled: Boolean,
            dayStartHour: Int,
            dayStartMinute: Int,
            intervalMinutes: Int,
            pendingCount: Int
        ) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            prefs.edit().apply {
                putBoolean(KEY_ENABLED, enabled)
                putBoolean(KEY_DAY_START_ENABLED, dayStartEnabled)
                putInt(KEY_DAY_START_HOUR, dayStartHour)
                putInt(KEY_DAY_START_MINUTE, dayStartMinute)
                putInt(KEY_INTERVAL_MINUTES, intervalMinutes)
                putInt(KEY_PENDING_COUNT, pendingCount)
                apply()
            }
            if (enabled) {
                scheduleNextAlarm(context)
            } else {
                cancelAlarm(context)
            }
        }

        fun showNotification(context: Context, title: String, body: String, count: Int) {
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager ?: return

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel = NotificationChannel(
                    PENDING_CHANNEL_ID,
                    "Pending Task Reminders",
                    NotificationManager.IMPORTANCE_DEFAULT
                ).apply {
                    description = "Alerts and reminders for pending tasks"
                    setShowBadge(true)
                    enableVibration(true)
                }
                notificationManager.createNotificationChannel(channel)
            }

            val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
                ?: Intent(context, MainActivity::class.java)
            launchIntent.flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP

            val pendingIntentFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }

            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                launchIntent,
                pendingIntentFlags
            )

            val builder = NotificationCompat.Builder(context, PENDING_CHANNEL_ID)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle(title)
                .setContentText(body)
                .setStyle(NotificationCompat.BigTextStyle().bigText(body))
                .setNumber(count)
                .setAutoCancel(true)
                .setShowWhen(true)
                .setContentIntent(pendingIntent)
                .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                .setCategory(NotificationCompat.CATEGORY_REMINDER)

            notificationManager.notify(PENDING_NOTIFICATION_ID, builder.build())
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            ACTION_PENDING_ALERT -> {
                val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                val enabled = prefs.getBoolean(KEY_ENABLED, false)
                if (!enabled) return

                val count = prefs.getInt(KEY_PENDING_COUNT, 1)
                val title = "Pending Tasks Reminder"
                val body = if (count > 1) {
                    "You have $count pending tasks waiting today"
                } else {
                    "You have a pending task waiting today"
                }

                showNotification(context, title, body, count)
                scheduleNextAlarm(context)
            }
            Intent.ACTION_BOOT_COMPLETED -> {
                scheduleNextAlarm(context)
            }
        }
    }
}
