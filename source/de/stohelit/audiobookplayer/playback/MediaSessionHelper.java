// SPDX-License-Identifier: MIT
// Part of the MortPlayer community patch kit. Written by the community, NOT by Mort;
// it is added to MortPlayer 1.0.1 by the patches in ../patches. MortPlayer itself remains Mort's.
// Note: the shipped smali in new-files/ was compiled from this file before these explanatory
// comments were added, so recompiling only changes debug line numbers, not behaviour.
package de.stohelit.audiobookplayer.playback;

import android.content.Context;
import android.os.Build;
import android.util.Log;

/**
 * Entry point called from RemoteControlWrapperICS. Contains no API-21 types,
 * so it is safe to load on old devices; everything real lives in MediaSessionImpl.
 */
public final class MediaSessionHelper {
    static final String TAG = "MortBT";

    private MediaSessionHelper() {
    }

    private static boolean supported() {
        return Build.VERSION.SDK_INT >= 21;
    }

    public static void open(Context context) {
        if (!supported()) return;
        try {
            MediaSessionImpl.open(context);
        } catch (Throwable t) {
            Log.w(TAG, "open failed", t);
        }
    }

    /**
     * Called first thing in RemoteControlWrapperICS.open(). Returns true when our MediaSession is up,
     * so the caller skips the legacy RemoteControlClient/registerMediaButtonEventReceiver path
     * (on Android 14 that legacy path creates a second framework session that steals the media keys
     * and then drops them).
     */
    public static boolean takeOver(Context context) {
        if (!supported()) return false;
        try {
            MediaSessionImpl.open(context);
            boolean ok = MediaSessionImpl.isOpen();
            Log.i(TAG, "takeOver: " + (ok ? "MediaSession active, legacy RemoteControlClient skipped" : "session not open, falling back to legacy path"));
            return ok;
        } catch (Throwable t) {
            Log.w(TAG, "takeOver failed, falling back to legacy path", t);
            return false;
        }
    }

    public static void close() {
        if (!supported()) return;
        try {
            MediaSessionImpl.close();
        } catch (Throwable t) {
            Log.w(TAG, "close failed", t);
        }
    }

    /** appState: MortPlayer's own state (1 = stopped, 2 = playing, 3 = paused). */
    public static void setPlaybackState(int appState) {
        if (!supported()) return;
        try {
            MediaSessionImpl.setPlaybackState(appState);
        } catch (Throwable t) {
            Log.w(TAG, "setPlaybackState failed", t);
        }
    }

    /** Same leading params as RemoteControlWrapper.setMetadata so smali can use invoke-static/range {p1 .. p7}. */
    public static void setMetadata(String artist, String album, String track, int cdNo, int trackNo, long trackLength) {
        if (!supported()) return;
        try {
            MediaSessionImpl.setMetadata(artist, album, track, trackLength);
        } catch (Throwable t) {
            Log.w(TAG, "setMetadata failed", t);
        }
    }
}
