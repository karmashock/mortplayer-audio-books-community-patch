// SPDX-License-Identifier: MIT
// Part of the MortPlayer community patch kit. Written by the community, NOT by Mort;
// it is added to MortPlayer 1.0.1 by the patches in ../patches. MortPlayer itself remains Mort's.
// Note: the shipped smali in new-files/ was compiled from this file before these explanatory
// comments were added, so recompiling only changes debug line numbers, not behaviour.
package de.stohelit.audiobookplayer.playback;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.os.Build;
import android.util.Log;

/**
 * Community patch: with targetSdkVersion >= 19, AlarmManager.set() is inexact and may fire late.
 * The alarm-clock and snooze alarms use this instead: setAlarmClock() on API 21+ (exact, works in Doze,
 * shows the alarm icon), setExact() on API 19-20, plain set() below that or on any error.
 */
public final class AlarmCompat {
    private static final String TAG = "MortAlarm";

    private AlarmCompat() {}

    public static void setWakeAlarm(AlarmManager am, int type, long triggerAt, PendingIntent op) {
        try {
            if (Build.VERSION.SDK_INT >= 21 && type == AlarmManager.RTC_WAKEUP) {
                am.setAlarmClock(new AlarmManager.AlarmClockInfo(triggerAt, null), op);
                Log.i(TAG, "setAlarmClock at " + triggerAt);
                return;
            }
            if (Build.VERSION.SDK_INT >= 19) {
                am.setExact(type, triggerAt, op);
                Log.i(TAG, "setExact type " + type + " at " + triggerAt);
                return;
            }
        } catch (Throwable t) {
            Log.w(TAG, "exact alarm failed, using set()", t);
        }
        am.set(type, triggerAt, op);
    }
}
