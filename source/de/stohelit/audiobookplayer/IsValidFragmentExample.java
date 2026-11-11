// SPDX-License-Identifier: MIT
// Part of the MortPlayer community patch kit (patch 05). Documentation only: this method was
// compiled (javac + d8 + baksmali) and the resulting smali is what patch 05 inserts into
// MainPreferences and HelpPreferences. It is shown here as a stand-alone class for reading.
package de.stohelit.audiobookplayer;

class IsValidFragmentExample extends android.preference.PreferenceActivity {
    /**
     * Android calls this before showing a settings "header" fragment. Apps targeting SDK 19+
     * must override it, otherwise Android throws (the default only allows it for old targets).
     * We allow only MortPlayer's own fragment classes, which is the point of the check:
     * another app must not be able to make this screen load an arbitrary fragment.
     */
    @Override
    protected boolean isValidFragment(String fragmentName) {
        return fragmentName != null && fragmentName.startsWith("de.stohelit.audiobookplayer.");
    }
}
