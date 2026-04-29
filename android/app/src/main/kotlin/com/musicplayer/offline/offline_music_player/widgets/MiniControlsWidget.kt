package com.musicplayer.offline.offline_music_player.widgets

import android.appwidget.AppWidgetManager
import android.content.Context
import android.widget.RemoteViews
import com.musicplayer.offline.offline_music_player.R

/** Widget 1 — Mini Controls (4×1): prev, play/pause, next + song title */
class MiniControlsWidget : BaseMusicWidget() {
    override fun onUpdate(context: Context, mgr: AppWidgetManager, ids: IntArray) {
        for (id in ids) {
            val views = RemoteViews(context.packageName, R.layout.widget_mini_controls)
            views.setTextViewText(R.id.widget_song_title, getSongTitle(context))
            views.setImageViewResource(
                R.id.widget_play_pause,
                if (isPlaying(context)) R.drawable.ic_widget_pause else R.drawable.ic_widget_play
            )
            views.setOnClickPendingIntent(R.id.widget_prev, buildActionIntent(context, ACTION_PREV))
            views.setOnClickPendingIntent(R.id.widget_play_pause, buildActionIntent(context, ACTION_PLAY_PAUSE))
            views.setOnClickPendingIntent(R.id.widget_next, buildActionIntent(context, ACTION_NEXT))
            views.setOnClickPendingIntent(R.id.widget_root, buildOpenAppIntent(context))
            mgr.updateAppWidget(id, views)
        }
    }
}
