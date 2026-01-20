package com.amrabdelhameed.ella_lyaabdoon

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import android.app.PendingIntent
import android.content.Intent
import android.net.Uri
import android.util.Log
import es.antonborri.home_widget.HomeWidgetBackgroundIntent

class PrayerRewardWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val ACTION_REFRESH = "com.amrabdelhameed.ella_lyaabdoon.ACTION_REFRESH"
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        Log.d("PRAYER_WIDGET", "onUpdate called for ${appWidgetIds.size} widgets")

        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        
        if (intent.action == ACTION_REFRESH) {
            Log.d("PRAYER_WIDGET", "Refresh button clicked!")
            
            // Trigger Flutter background callback
            val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(
                context, 
                Uri.parse("homeWidget://refresh")
            )
            backgroundIntent.send()
            
            // Immediately update all widgets
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(
                android.content.ComponentName(context, PrayerRewardWidgetProvider::class.java)
            )
            onUpdate(context, appWidgetManager, appWidgetIds)
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        try {
            val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
            
            val period = prefs.getString("current_period", null)
            val title = prefs.getString("reward_title", null)
            val description = prefs.getString("reward_description", null)
            val updateTime = prefs.getString("update_time", null)
            
            Log.d("PRAYER_WIDGET", "Widget data: period=$period, title=$title")
            
            val displayPeriod = period ?: "إلا ليعبدون"
            val displayTitle = title ?: "افتح التطبيق للتحديث"
            val displayDesc = description ?: "اضغط على زر التحديث لعرض فضيلة جديدة"
            val displayTime = if (!updateTime.isNullOrEmpty()) {
                "آخر تحديث: $updateTime"
            } else {
                "انتظار التحديث..."
            }
            
            val views = RemoteViews(context.packageName, R.layout.prayer_reward_widget)
            
            views.setTextViewText(R.id.widget_period_name, displayPeriod)
            views.setTextViewText(R.id.widget_reward_title, displayTitle)
            views.setTextViewText(R.id.widget_reward_description, displayDesc)
            views.setTextViewText(R.id.widget_update_time, displayTime)
            
            // Refresh button click intent
            val refreshIntent = Intent(context, PrayerRewardWidgetProvider::class.java).apply {
                action = ACTION_REFRESH
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, intArrayOf(appWidgetId))
            }
            val refreshPendingIntent = PendingIntent.getBroadcast(
                context,
                appWidgetId * 100, // Unique request code
                refreshIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_refresh_button, refreshPendingIntent)
            
            // Main widget click to open app
            val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            if (launchIntent != null) {
                launchIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    appWidgetId,
                    launchIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_content, pendingIntent)
            }
            
            appWidgetManager.updateAppWidget(appWidgetId, views)
            Log.d("PRAYER_WIDGET", "✅ Widget $appWidgetId updated successfully")
            
        } catch (e: Exception) {
            Log.e("PRAYER_WIDGET", "❌ Error updating widget: ${e.message}", e)
        }
    }
}