package com.amrabdelhameed.ella_lyaabdoon

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.*
import androidx.glance.action.ActionParameters
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.provideContent
import androidx.glance.appwidget.cornerRadius
import androidx.glance.layout.*
import androidx.glance.text.*
import androidx.glance.unit.ColorProvider
import androidx.glance.state.GlanceStateDefinition
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetGlanceWidgetReceiver

class PrayerRewardGlanceWidget : GlanceAppWidget() {

    override val stateDefinition: GlanceStateDefinition<*>?
        get() = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            val state = currentState<HomeWidgetGlanceState>()
            val prefs = state.preferences

            val period = prefs.getString("current_period", null) ?: "إلا ليعبدون"
            val title = prefs.getString("reward_title", null) ?: "افتح التطبيق"
            val desc = prefs.getString("reward_description", null) ?: "اضغط للتحديث"
            val time = prefs.getString("update_time", null) ?: "..."

            CompactWidgetContent(period, title, desc, time)
        }
    }
}

@Composable
private fun CompactWidgetContent(period: String, title: String, desc: String, time: String) {
    val primaryGreen = Color(0xFF2D5F3F)
    val accentGreen = Color(0xFF4A9B6A)
    val surfaceGreen = Color(0xFF1C4430)

    val white = ColorProvider(Color.White)
    val whiteAlpha90 = ColorProvider(Color(0xE6FFFFFF))
    val whiteAlpha70 = ColorProvider(Color(0xB3FFFFFF))
    val whiteAlpha30 = ColorProvider(Color(0x4DFFFFFF))
    val goldAccent = ColorProvider(Color(0xFFFFD700))

    Box(
        modifier = GlanceModifier
            .fillMaxSize()
            .background(primaryGreen)
    ) {
        Column(
            modifier = GlanceModifier.fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalAlignment = Alignment.Top
        ) {

            Spacer(
                modifier = GlanceModifier
                    .fillMaxWidth()
                    .height(2.dp)
                    .background(goldAccent)
            )

            Column(
                modifier = GlanceModifier
                    .fillMaxSize()
                    .padding(10.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalAlignment = Alignment.Top
            ) {

                // HEADER
                Row(
                    modifier = GlanceModifier
                        .fillMaxWidth()
                        .background(surfaceGreen)
                        .cornerRadius(12.dp)
                        .padding(horizontal = 12.dp, vertical = 8.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Text("🕌", style = TextStyle(fontSize = 20.sp))
                    Spacer(modifier = GlanceModifier.width(8.dp))
                    Text(
                        text = period,
                        style = TextStyle(
                            color = goldAccent,
                            fontSize = 16.sp,
                            fontWeight = FontWeight.Bold,
                            textAlign = TextAlign.Center
                        )
                    )
                }

                Spacer(modifier = GlanceModifier.height(10.dp))

                // CLICKABLE CONTENT AREA
                Box(
                    modifier = GlanceModifier
                        .fillMaxWidth()
                        .defaultWeight()
                        .background(ColorProvider(Color(0x01000000)))
                        .cornerRadius(14.dp)
                        .clickable(actionRunCallback<LaunchAppCallback>())
                        .padding(8.dp)
                ) {

                    // Visual card
                    Box(
                        modifier = GlanceModifier
                            .fillMaxSize()
                            .background(ColorProvider(Color(0x1AFFFFFF)))
                            .cornerRadius(14.dp)
                            .padding(12.dp),
                        contentAlignment = Alignment.Center
                    ) {

                        Column(
                            modifier = GlanceModifier.fillMaxSize(),
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalAlignment = Alignment.Top
                        ) {

                            Text(
                                text = title,
                                style = TextStyle(
                                    color = white,
                                    fontSize = 17.sp,
                                    fontWeight = FontWeight.Bold,
                                    textAlign = TextAlign.Center
                                )
                            )

                            Spacer(modifier = GlanceModifier.height(6.dp))

                            Spacer(
                                modifier = GlanceModifier
                                    .width(60.dp)
                                    .height(1.5.dp)
                                    .background(whiteAlpha30)
                            )

                            Spacer(modifier = GlanceModifier.height(6.dp))

                            // Dynamic font size based on description length
                            val descFontSize = when {
                                desc.length > 100 -> 14.sp  // Very long text
                                desc.length > 60 -> 15.sp   // Long text
                                desc.length > 30 -> 16.sp   // Medium text
                                else -> 20.sp               // Short text
                            }

                            Text(
                                text = desc,
                                style = TextStyle(
                                    color = whiteAlpha90,
                                    fontSize = descFontSize,
                                    textAlign = TextAlign.Center,
                                ),
                                maxLines = 8
                            )
                        }
                    }
                }

                Spacer(modifier = GlanceModifier.height(8.dp))

                // FOOTER
                Row(
                    modifier = GlanceModifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically
                ) {

                    Text(
                        text = "⏰ $time",
                        style = TextStyle(
                            color = whiteAlpha70,
                            fontSize = 15.sp,
                            fontWeight = FontWeight.Medium
                        )
                    )

                    Spacer(modifier = GlanceModifier.defaultWeight())

                    Box(
                        modifier = GlanceModifier
                            .height(34.dp)
                            .background(accentGreen)
                            .cornerRadius(17.dp)
                            .clickable(actionRunCallback<RefreshActionCallback>())
                            .padding(horizontal = 14.dp, vertical = 8.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalAlignment = Alignment.CenterHorizontally
                        ) {
                            Text("🔄", style = TextStyle(fontSize = 12.sp))
                            Spacer(modifier = GlanceModifier.width(4.dp))
                            Text(
                                text = "تحديث",
                                style = TextStyle(
                                    color = white,
                                    fontSize = 12.sp,
                                    fontWeight = FontWeight.Bold
                                )
                            )
                        }
                    }
                }
            }
        }
    }
}

// Simple callback to launch app
class LaunchAppCallback : ActionCallback {
    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters
    ) {
        val intent = Intent(context, MainActivity::class.java).apply {
            // Use NEW_TASK only - this allows splash screen to show properly
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
            // Add action to ensure fresh launch
            action = Intent.ACTION_MAIN
            addCategory(Intent.CATEGORY_LAUNCHER)
        }
        context.startActivity(intent)
    }
}

class RefreshActionCallback : ActionCallback {
    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters
    ) {
        val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(
            context,
            Uri.parse("homeWidget://refresh")
        )
        backgroundIntent.send()
    }
}

class PrayerRewardWidgetProvider :
    HomeWidgetGlanceWidgetReceiver<PrayerRewardGlanceWidget>() {
    override val glanceAppWidget = PrayerRewardGlanceWidget()
}