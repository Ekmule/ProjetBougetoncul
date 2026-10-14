package com.mya.mya



import android.appwidget.AppWidgetManager

import android.content.Context

import android.content.SharedPreferences

import android.os.Bundle

import android.view.View

import android.widget.RemoteViews

import es.antonborri.home_widget.HomeWidgetLaunchIntent

import es.antonborri.home_widget.HomeWidgetPlugin

import es.antonborri.home_widget.HomeWidgetProvider



// Widget MYA redimensionnable 1×1 (compact) ou 2×2 (étendu).

class MyaHomeWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(

        context: Context,

        appWidgetManager: AppWidgetManager,

        appWidgetIds: IntArray,

        widgetData: SharedPreferences,

    ) {

        appWidgetIds.forEach { widgetId ->

            publishWidget(context, appWidgetManager, widgetId, widgetData)

        }

    }



    override fun onAppWidgetOptionsChanged(

        context: Context,

        appWidgetManager: AppWidgetManager,

        appWidgetId: Int,

        newOptions: Bundle,

    ) {

        publishWidget(

            context,

            appWidgetManager,

            appWidgetId,

            HomeWidgetPlugin.getData(context),

        )

    }



    private fun publishWidget(

        context: Context,

        appWidgetManager: AppWidgetManager,

        widgetId: Int,

        widgetData: SharedPreferences,

    ) {

        val iconId = widgetData.getString(KEY_ICON_ID, DEFAULT_ICON_ID) ?: DEFAULT_ICON_ID

        val showSyncBadge = widgetData.getBoolean(KEY_SYNC_BADGE_VISIBLE, false)

        val showTodayBadge = widgetData.getBoolean(KEY_TODAY_ATTENTION_VISIBLE, false)

        val todayHeadline = widgetData.getString(KEY_TODAY_HEADLINE, "") ?: ""

        val iconRes = iconDrawableFor(iconId)

        val expanded = isExpandedLayout(appWidgetManager, widgetId)



        val layoutId =

            if (expanded) R.layout.mya_home_widget_large else R.layout.mya_home_widget

        val views = RemoteViews(context.packageName, layoutId).apply {

            setImageViewResource(R.id.mya_widget_icon, iconRes)

            setViewVisibility(

                R.id.mya_widget_sync_badge,

                if (showSyncBadge) View.VISIBLE else View.GONE,

            )

            setViewVisibility(

                R.id.mya_widget_today_badge,

                if (showTodayBadge) View.VISIBLE else View.GONE,

            )



            if (expanded) {

                val hasToday = todayHeadline.isNotBlank()

                setViewVisibility(

                    R.id.mya_widget_section_label,

                    if (hasToday) View.VISIBLE else View.GONE,

                )

                setTextViewText(

                    R.id.mya_widget_headline,

                    if (hasToday) {

                        todayHeadline

                    } else {

                        context.getString(R.string.mya_widget_idle_hint)

                    },

                )

                setViewVisibility(

                    R.id.mya_widget_attention_ring,

                    if (showTodayBadge) View.VISIBLE else View.GONE,

                )

            }



            val launchIntent = HomeWidgetLaunchIntent.getActivity(

                context,

                MainActivity::class.java,

            )

            setOnClickPendingIntent(R.id.mya_widget_root, launchIntent)

        }



        appWidgetManager.updateAppWidget(widgetId, views)

    }



    private fun isExpandedLayout(

        appWidgetManager: AppWidgetManager,

        widgetId: Int,

    ): Boolean {

        val options = appWidgetManager.getAppWidgetOptions(widgetId)

        val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 0)

        val minHeight = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 0)

        return minWidth >= EXPANDED_MIN_DP && minHeight >= EXPANDED_MIN_DP

    }



    private fun iconDrawableFor(iconId: String): Int {

        return when (iconId) {

            "icon02" -> R.drawable.mya_icon_02

            "icon03" -> R.drawable.mya_icon_03

            else -> R.drawable.mya_icon_01

        }

    }



    companion object {

        const val KEY_ICON_ID = "mya_icon_id"

        const val KEY_SYNC_BADGE_VISIBLE = "mya_sync_badge_visible"

        const val KEY_TODAY_ATTENTION_VISIBLE = "mya_today_attention_visible"

        const val KEY_TODAY_HEADLINE = "mya_today_headline"



        private const val DEFAULT_ICON_ID = "icon01"

        private const val EXPANDED_MIN_DP = 90

    }

}


