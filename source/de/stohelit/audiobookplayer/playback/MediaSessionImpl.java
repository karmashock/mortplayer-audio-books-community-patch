// SPDX-License-Identifier: MIT
// Part of the MortPlayer community patch kit. Written by the community, NOT by Mort;
// it is added to MortPlayer 1.0.1 by the patches in ../patches. MortPlayer itself remains Mort's.
// Note: the shipped smali in new-files/ was compiled from this file before these explanatory
// comments were added, so recompiling only changes debug line numbers, not behaviour.
package de.stohelit.audiobookplayer.playback;

import android.app.PendingIntent;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.media.MediaMetadata;
import android.media.session.MediaSession;
import android.media.session.PlaybackState;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.view.KeyEvent;

/**
 * The real MediaSession (Android 5.0 / API 21+ only). Only reached through MediaSessionHelper's
 * SDK_INT guard, so old phones never load this class (it would fail to verify there).
 *
 * How it works in one paragraph: MortPlayer's own player code keeps calling its old
 * RemoteControlWrapperICS; patch 02 makes that wrapper forward open/close/state/metadata here.
 * We publish a modern MediaSession so Android, Bluetooth devices and the lock screen see a proper
 * player, and when a button arrives we translate it into the "button" command intent that
 * MortPlayer's PlaybackService already understands. No player logic is duplicated.
 */
final class MediaSessionImpl {
    private static final String TAG = MediaSessionHelper.TAG;
    // MortPlayer's own components, addressed by name (we cannot import closed-source classes).
    private static final String RECEIVER = "de.stohelit.audiobookplayer.PlayerBroadcastReceiver";
    private static final String SERVICE = "de.stohelit.audiobookplayer.playback.PlaybackService";
    // Which transport buttons we advertise to the system / Bluetooth device.
    private static final long ACTIONS = PlaybackState.ACTION_PLAY | PlaybackState.ACTION_PAUSE
            | PlaybackState.ACTION_PLAY_PAUSE | PlaybackState.ACTION_SKIP_TO_NEXT
            | PlaybackState.ACTION_SKIP_TO_PREVIOUS | PlaybackState.ACTION_STOP;

    // State is static because MortPlayer creates/destroys its wrapper often; one session per process.
    private static MediaSession session;
    private static Context appContext;
    private static int lastState = 1;           // MortPlayer's own state code: 1=stopped 2=playing 3=paused
    private static MediaMetadata lastMetadata; // remembered so a re-created session shows the title at once

    private MediaSessionImpl() {
    }

    static synchronized boolean isOpen() {
        return session != null;
    }

    static synchronized void open(Context context) {
        if (session != null) return;
        Log.i(TAG, "creating MediaSession (SDK " + android.os.Build.VERSION.SDK_INT + ")");
        appContext = context.getApplicationContext();
        // FLAG_HANDLES_*: tell Android we want media buttons and transport controls (needed before API 26).
        MediaSession s = new MediaSession(appContext, "MortPlayerAudioBooks");
        s.setFlags(MediaSession.FLAG_HANDLES_MEDIA_BUTTONS | MediaSession.FLAG_HANDLES_TRANSPORT_CONTROLS);
        s.setCallback(new Callback(), new Handler(Looper.getMainLooper()));
        // Media-button receiver: lets Android restart us with a button press after the session is gone.
        try {
            Intent mb = new Intent(Intent.ACTION_MEDIA_BUTTON);
            mb.setComponent(new ComponentName(appContext.getPackageName(), RECEIVER));
            s.setMediaButtonReceiver(PendingIntent.getBroadcast(appContext, 1, mb, 0));
        } catch (Throwable t) {
            Log.w(TAG, "setMediaButtonReceiver failed", t);
        }
        session = s;
        // Replay the last known state/metadata, then go active so we receive the keys.
        applyState(lastState);
        if (lastMetadata != null) s.setMetadata(lastMetadata);
        s.setActive(true);
        Log.i(TAG, "MediaSession created and active=" + s.isActive() + ", state=" + lastState);
    }

    /** Called when MortPlayer drops its remote control: give the media keys back to the system. */
    static synchronized void close() {
        if (session == null) return;
        session.setActive(false);
        session.release();
        session = null;
        Log.i(TAG, "MediaSession released");
    }

    /** Mirror MortPlayer's playing/paused/stopped state into the session (shown on lock screen, car, etc.). */
    static synchronized void setPlaybackState(int appState) {
        if (appState != lastState || session == null) Log.i(TAG, "app state " + appState + (session == null ? " (no session yet)" : ""));
        lastState = appState;
        if (session != null) applyState(appState);
    }

    /** Mirror title/artist/album/length so Bluetooth displays and the lock screen show the current book. */
    static synchronized void setMetadata(String artist, String album, String track, long trackLength) {
        MediaMetadata.Builder b = new MediaMetadata.Builder();
        if (artist != null) b.putString(MediaMetadata.METADATA_KEY_ARTIST, artist);
        if (album != null) b.putString(MediaMetadata.METADATA_KEY_ALBUM, album);
        if (track != null) b.putString(MediaMetadata.METADATA_KEY_TITLE, track);
        if (trackLength > 0) b.putLong(MediaMetadata.METADATA_KEY_DURATION, trackLength);
        lastMetadata = b.build();
        if (session != null) session.setMetadata(lastMetadata);
    }

    /** Translate MortPlayer's state code into a PlaybackState the system understands. */
    private static void applyState(int appState) {
        int st;
        switch (appState) {
            case 2: st = PlaybackState.STATE_PLAYING; break;
            case 3: st = PlaybackState.STATE_PAUSED; break;
            default: st = PlaybackState.STATE_STOPPED; break;
        }
        Log.i(TAG, "PlaybackState set: " + st + " (3=PLAYING 2=PAUSED 1=STOPPED)");
        session.setPlaybackState(new PlaybackState.Builder()
                .setActions(ACTIONS)
                .setState(st, PlaybackState.PLAYBACK_POSITION_UNKNOWN, st == PlaybackState.STATE_PLAYING ? 1.0f : 0.0f)
                .build());
    }

    /**
     * Hardware/Bluetooth keys, handled directly on key-up via the service's "button" command path
     * (bypasses PlayerBroadcastReceiver and its "Use as default player" gate).
     * PLAY_PAUSE/HEADSETHOOK use the service's own multi-press logic ("headset"), so 1x/2x/3x prefs still apply.
     */
    static String actionForKey(int keyCode) {
        switch (keyCode) {
            case KeyEvent.KEYCODE_HEADSETHOOK:      // 79
            case KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE: // 85
                return "headset";
            case KeyEvent.KEYCODE_MEDIA_PLAY:       // 126
                return "playForce";
            case KeyEvent.KEYCODE_MEDIA_PAUSE:      // 127
                return "pauseForce";
            case KeyEvent.KEYCODE_MEDIA_STOP:       // 86
                return "stop";
            case KeyEvent.KEYCODE_MEDIA_NEXT:       // 87
                return "next";
            case KeyEvent.KEYCODE_MEDIA_PREVIOUS:   // 88
                return "prev";
            case KeyEvent.KEYCODE_MEDIA_REWIND:     // 89
                return "rew";
            case KeyEvent.KEYCODE_MEDIA_FAST_FORWARD: // 90
                return "ffwd";
            default:
                return null;
        }
    }

    /** Transport controls (no KeyEvent): call the service's existing "button" command path. */
    static void sendButton(String action) {
        if (appContext == null) return;
        Intent i = new Intent();
        i.setComponent(new ComponentName(appContext.getPackageName(), SERVICE));
        i.putExtra("button", action);
        i.putExtra("longPress", false);
        ComponentName started = appContext.startService(i);
        Log.i(TAG, "command sent to PlaybackService: button=" + action + " -> " + started);
    }

    /** Receives button presses and transport commands from Android and forwards them to the player. */
    static final class Callback extends MediaSession.Callback {
        @Override
        public boolean onMediaButtonEvent(Intent mediaButtonIntent) {
            try {
                KeyEvent k = mediaButtonIntent.getParcelableExtra(Intent.EXTRA_KEY_EVENT);
                Log.i(TAG, "callback received key " + k);
                if (k == null) return super.onMediaButtonEvent(mediaButtonIntent);
                String action = actionForKey(k.getKeyCode());
                if (action == null) {
                    Log.i(TAG, "unhandled keyCode " + k.getKeyCode() + ", passing to default handling");
                    return super.onMediaButtonEvent(mediaButtonIntent);
                }
                // Act once per press: on key-up. Key-down/repeat are swallowed so nothing fires twice.
                if (k.getAction() == KeyEvent.ACTION_UP) {
                    safe(action);
                } else {
                    Log.i(TAG, "key down/repeat for " + action + ", acting on key up");
                }
                return true;
            } catch (Throwable t) {
                Log.w(TAG, "onMediaButtonEvent failed", t);
                return true;
            }
        }

        private void safe(String action) {
            try {
                Log.i(TAG, "handling " + action);
                sendButton(action);
            } catch (Throwable t) {
                Log.w(TAG, "sendButton failed", t);
            }
        }

        // Transport controls (lock screen, Android Auto, smart watches) have no KeyEvent.
        @Override public void onPlay() { safe("playForce"); }
        @Override public void onPause() { safe("pauseForce"); }
        @Override public void onSkipToNext() { safe("next"); }
        @Override public void onSkipToPrevious() { safe("prev"); }
        @Override public void onStop() { safe("stop"); }
    }
}
