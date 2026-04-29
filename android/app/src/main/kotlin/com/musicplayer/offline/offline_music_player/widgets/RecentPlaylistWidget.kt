package com.musicplayer.offline.offline_music_player.widgets

import android.appwidget.AppWidgetManager
import android.content.Context
import android.widget.RemoteViews
import com.musicplayer.offline.offline_music_player.R

/** Widget 5 — Recent Playlist (4×2): shows last played songs + play button */
class RecentPlaylistWidget : BaseMusicWidget() {
    override fun onUpdate(context: Context, mgr: AppWidgetManager, ids: IntArray) {
        for (id in ids) {
            val views = RemoteViews(context.packageName, R.layout.widget_recent_playlist)
            val title = getSongTitle(context)
            val playing = isPlaying(context)

            views.setTextViewText(R.id.widget_song_title, title)
            views.setTextViewText(R.id.widget_status, if (playing) "Playing" else "Tap to play")
            views.setImageViewResource(
                R.id.widget_play_pause,
                if (playing) R.drawable.ic_widget_pause else R.drawable.ic_widget_play
            )
            views.setOnClickPendingIntent(R.id.widget_play_pause, buildActionIntent(context, ACTION_PLAY_PAUSE))
            views.setOnClickPendingIntent(R.id.widget_root, buildOpenAppIntent(context))
            mgr.updateAppWidget(id, views)
        }
    }
}
