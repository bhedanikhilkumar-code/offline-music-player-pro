package com.musicplayer.offline.offline_music_player.widgets

import android.appwidget.AppWidgetManager
import android.content.Context
import android.widget.RemoteViews
import com.musicplayer.offline.offline_music_player.R

/** Widget 3 — Full Player (4×3): large album art + full info + controls + progress label */
class FullPlayerWidget : BaseMusicWidget() {
    override fun onUpdate(context: Context, mgr: AppWidgetManager, ids: IntArray) {
        for (id in ids) {
            val views = RemoteViews(context.packageName, R.layout.widget_full_player)
            val title = getSongTitle(context)
            val artist = getPrefString(context, "last_played_artist", "Unknown Artist")
            val playing = isPlaying(context)

            views.setTextViewText(R.id.widget_song_title, title)
            views.setTextViewText(R.id.widget_artist, artist)
            views.setTextViewText(R.id.widget_status, if (playing) "▶ Now Playing" else "⏸ Paused")
            views.setImageViewResource(
                R.id.widget_play_pause,
                if (playing) R.drawable.ic_widget_pause else R.drawable.ic_widget_play
            )
            views.setOnClickPendingIntent(R.id.widget_prev, buildActionIntent(context, ACTION_PREV))
            views.setOnClickPendingIntent(R.id.widget_play_pause, buildActionIntent(context, ACTION_PLAY_PAUSE))
            views.setOnClickPendingIntent(R.id.widget_next, buildActionIntent(context, ACTION_NEXT))
            views.setOnClickPendingIntent(R.id.widget_root, buildOpenAppIntent(context))
            mgr.updateAppWidget(id, views)
        }
    }
}
