// SPDX-License-Identifier: MIT
// Part of the MortPlayer community patch kit. Written by the community, NOT by Mort;
// it is added to MortPlayer 1.0.1 by the patches in ../patches. MortPlayer itself remains Mort's.
// Note: the shipped smali in new-files/ was compiled from this file before these explanatory
// comments were added, so recompiling only changes debug line numbers, not behaviour.
package de.stohelit.audiobookplayer;

import android.app.Activity;
import android.content.pm.PackageManager;
import android.os.Build;
import android.util.Log;
import android.widget.Toast;

import java.util.ArrayList;

/**
 * Community patch: runtime permissions for targetSdkVersion 24 (Android 15+ refuses to install < 24).
 * Hooked from MainPlayer.onResume() and MainPlayer.onRequestPermissionsResult().
 * Only acts for the MainPlayer activity itself (LockScreen/AlarmScreen subclass it).
 */
public final class PermissionHelper {
    private static final String TAG = "MortPerm";
    public static final int REQUEST_CODE = 0x4d50;
    private static final String MAIN = "de.stohelit.audiobookplayer.MainPlayer";

    // App targets 24 (< 33), so READ_EXTERNAL_STORAGE is the right request on every version:
    // on Android 13+ the system maps it to the media permissions (READ_MEDIA_AUDIO is a split of it).
    // Legacy storage (target < 29) means this gives normal file-path access to the shared storage.
    private static final String[] WANTED = {
            "android.permission.READ_EXTERNAL_STORAGE",
            "android.permission.WRITE_EXTERNAL_STORAGE", // covers, MortPlayer folder, bookmark export
            "android.permission.READ_PHONE_STATE",       // pause during calls
    };

    private static boolean askedThisProcess = false;

    private PermissionHelper() {}

    private static boolean isMain(Activity a) {
        return a != null && MAIN.equals(a.getClass().getName());
    }

    private static boolean granted(Activity a, String p) {
        return a.checkSelfPermission(p) == PackageManager.PERMISSION_GRANTED;
    }

    private static boolean vmPolicyRelaxed = false;

    /**
     * targetSdkVersion 24+ makes passing file:// URIs to other apps throw FileUriExposedException.
     * MortPlayer's "send track by mail" (SendMp3Mail) does that, so restore the pre-24 behaviour.
     */
    private static void relaxFileUriPolicy() {
        if (vmPolicyRelaxed || Build.VERSION.SDK_INT < 24) return;
        vmPolicyRelaxed = true;
        try {
            android.os.StrictMode.setVmPolicy(new android.os.StrictMode.VmPolicy.Builder().build());
            Log.i(TAG, "file:// URI exposure check disabled (legacy SendMp3Mail)");
        } catch (Throwable t) {
            Log.w(TAG, "could not relax VmPolicy", t);
        }
    }

    public static void onResume(Activity a) {
        relaxFileUriPolicy();
        if (Build.VERSION.SDK_INT < 23 || !isMain(a)) return;
        try {
            ArrayList<String> missing = new ArrayList<String>();
            for (String p : WANTED) {
                if (!granted(a, p)) missing.add(p);
            }
            if (missing.isEmpty()) return;
            if (askedThisProcess) {
                Log.i(TAG, "still missing " + missing + " (already asked once this session)");
                return;
            }
            askedThisProcess = true;
            Log.i(TAG, "requesting " + missing);
            a.requestPermissions(missing.toArray(new String[missing.size()]), REQUEST_CODE);
        } catch (Throwable t) {
            Log.w(TAG, "permission request failed", t);
        }
    }

    public static void onRequestPermissionsResult(Activity a, int requestCode, String[] permissions, int[] results) {
        if (requestCode != REQUEST_CODE || Build.VERSION.SDK_INT < 23 || !isMain(a)) return;
        try {
            if (permissions != null && results != null) {
                for (int i = 0; i < permissions.length && i < results.length; i++) {
                    Log.i(TAG, permissions[i] + " -> " + (results[i] == PackageManager.PERMISSION_GRANTED ? "granted" : "denied"));
                }
            }
            if (granted(a, "android.permission.READ_EXTERNAL_STORAGE")) {
                Log.i(TAG, "storage granted, refreshing folder list");
                Toast.makeText(a, "Storage access granted. Refreshing your audiobook folders\u2026", Toast.LENGTH_SHORT).show();
                try {
                    ((MainPlayer) a).updateFolderInfos(false, false);
                } catch (Throwable t) {
                    Log.w(TAG, "folder refresh failed", t);
                    Toast.makeText(a, "Please close and reopen MortPlayer to see your books.", Toast.LENGTH_LONG).show();
                }
            } else {
                Log.i(TAG, "storage denied");
                Toast.makeText(a, "MortPlayer needs storage access to find your audiobooks. "
                        + "You can allow it in Settings > Apps > MortPlayer Audio Books > Permissions.", Toast.LENGTH_LONG).show();
            }
        } catch (Throwable t) {
            Log.w(TAG, "permission result handling failed", t);
        }
    }
}
