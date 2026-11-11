# MortPlayer Audio Books – community patch kit (1.0.1 → 1.0.3-community)

Disclaimer- I 100% just gave the original APK to Grok and with a little trial and error Grok did everything really. I plugged in my phone so debug commands could be sent. I told the bot when a bug was fixed or not. I informed it of NEW bugs that showed up when it fixed old ones. That was my contribution to the process. I've loved and used this program on my phone for many years and it has gotten increasingly broken as Android updates. Believe it or not, I was still using it and suffering with the bugs. Got grok bot. Threw this challenge at it as a lark. And it more or less one-shotted about three or four bugs with basically no input from me. I tried to reach out to the original author. No response. He has a paypal and I threw some money into as final thanks. Hope he's okay. Anyway, EVERYTHING after this point is written by Grok. I asked it to make a kit for people, none of the author's code in the kit, lots of comments in the code so people can look through it. Use this at your own risk. I have no idea what Grok did. I have not looked at what it did. I only know it works. And frankly, that's good enough for me. I don't care. Good luck. Have fun.

Oh, one more thing, still me. You'll want to set a few things in the mort player audio books settings to avoid some problems. Preferences > headset > Use as Default Player. Helps when the app isn't on screen. The other thing you want to do is set the battery usage to 'unrestricted'. Okay, that's it. Thanks again to Mirko "Mort" Schenk and if you figure out how to get access to your paypal account there's a little money waiting for you.

MortPlayer Audio Books by Mirko "Mort" Schenk was a much-loved Android audiobook player.
It hasn't been updated since 2012 and no longer works properly on modern phones.
This kit fixes your **own copy** of the original app on your **own computer**.

> **Not affiliated with Mort.** MortPlayer is Mort's closed-source app, and he owns it.
> This kit has **none of his code or files**: no APK, no decompiled code, no images.
> It only has our own changes and our own new code. **You need your own copy of the
> original APK.** We can't provide one, so please don't ask.

## What it fixes

| # | Patch | What you notice |
|---|-------|-----------------|
| 01 | `01-errorreport-crash` | The app no longer closes right after it starts. This fix is by **crazyfury** (XDA). |
| 02 | `02-bluetooth-mediasession` | Play, pause, next and previous on Bluetooth headsets, car kits and the lock screen work again on modern Android. |
| 03 | `03-runtime-permissions` | The app asks for storage access, so it can find your audiobooks again. |
| 04 | `04-exact-alarms` | The alarm clock and snooze go off on time. |
| 05 | `05-settings-crash` | Opening **Configuration** no longer crashes the app. |
| 06 | `06-target-sdk-24` | The app installs on Android 14, 15 and 16. Its version shows as `1.0.3-community`. |

Everything else is Mort's original app, unchanged.

## What you need

1. **Java 11 or newer.** Free download: <https://adoptium.net> (pick "JRE" or "JDK"; on Windows, tick *Add to PATH*).
2. **apktool 2.4.0, this exact version.** Newer apktool versions produce an app that crashes.
   Download `apktool_2.4.0.jar` from
   <https://github.com/iBotPeaches/Apktool/releases/tag/v2.4.0> and put it in the `tools` folder.
   SHA-256: `a0f116e8916d6f21160e1559847bb8b8c32ee71900f321cafeadbe37b87ebcc1`
3. **uber-apk-signer.** Download `uber-apk-signer-1.3.0.jar` from
   <https://github.com/patrickfav/uber-apk-signer/releases/tag/v1.3.0> and put it in the `tools` folder.
   SHA-256: `e1299fd6fcf4da527dd53735b56127e8ea922a321128123b9c32d619bba1d835`
4. **Your own original MortPlayer Audio Books 1.0.1 APK** (`de.stohelit.audiobookplayer`, versionCode 200014).
   The script checks it, and only this exact file works. Its SHA-256 is
   `df150b90177d3fc331b5114d3cb38216d65b6a9f24cd4c64d1ec9bcd4989f14f`.
   If you still have the app installed, an APK-backup app can save a copy from your phone.

## Steps

1. Unzip this kit and put the two `.jar` files in its `tools` folder.
2. Run the patcher:
   - **Windows:** double-click `patch.bat`, then pick your APK. You can also drag the APK onto `patch.bat`.
   - **Linux / macOS:** open a terminal in the kit folder and run `./patch.sh "/path/to/MortPlayer 1.0.1.apk"`.
3. Wait about a minute. The new app is saved as `out/MortPlayer-1.0.3-community-selfsigned.apk`.
   You can ignore apktool warnings like `Cant find 9patch chunk`. They come from the manifest-only build, which the kit throws away.
4. On your phone, **back up your bookmarks and settings, then uninstall the original MortPlayer.**
   Android won't install the fixed app over the original, because the fixed app is signed with
   your own key, not Mort's.
5. Copy the new APK to your phone and tap it to install. Allow installs from unknown sources if asked.
   Play Protect might warn you about an unknown app. That warning is normal for self-built apps.
6. Open the app and tap **Allow** when it asks for access to your files.

**About your signing key:** the first time you run the script, it creates a private key in the
`my-signing-key` folder (the password is in `password.txt` next to it). **Keep that folder, and
don't share it.** Later builds signed with the same key install as normal updates, so you won't
need to uninstall again.

## How it works

Android apps are zip files that contain compiled code (`classes.dex`), resources and a manifest.
The kit works in these steps:

1. **Checks** that your APK's SHA-256 matches the original 1.0.1, so the patches fit exactly.
2. **Decodes it twice** with apktool 2.4.0:
   - `work/app` (`apktool d -r`) turns the code into *smali*, a readable form of Android
     bytecode, and leaves the resources untouched.
   - `work/manifest` (a full decode) turns the manifest into readable XML.
3. **Applies the patches** in `patches/` with `tools/MortPatch.java`, then copies our new
   classes from `new-files/` into the app.
4. **Builds the manifest project** only to get the new binary `AndroidManifest.xml`, and copies it into `work/app`.
5. **Rebuilds** `work/app`. Mort's resources come out byte-for-byte the same as before.
6. **Signs** the app with a key made on your computer (keytool plus uber-apk-signer: v1, v2 and v3 signatures, zipaligned).

### Why `.mpatch` files instead of normal diffs?

A normal `diff` or `.patch` file includes the lines it removes and several lines around each
change. Here, those lines would be Mort's code, and we have no right to share it. The `.mpatch` format
stores **only our new lines**, plus line numbers and the **SHA-256 of the file they apply to**. If the
file isn't exactly the expected one, `MortPatch` stops before changing anything, so plain line numbers
are safe to use. Each `.mpatch` starts with comments that explain what it fixes and why.
The format is described at the top of `tools/MortPatch.java`.

### Folder map

```
patch.sh / patch.ps1 / patch.bat   the build scripts (same steps; heavily commented)
patches/        our changes to existing files (*.mpatch, applied in name order)
new-files/      our new classes as smali, copied into the app
source/         the Java source of those new classes (read these!), plus a compile stub
tools/          MortPatch.java (patch tool), make_mpatch.py (for contributors); put the 2 jars here
work/ out/ my-signing-key/   created when you run the script
```

## Contributing / extending

Ideas, fixes and translations of this README are welcome. To add a fix:

1. Run the kit once, so `work/app` holds the fully patched project. Copy that folder somewhere as your "before".
2. Edit the copy:
   - **New behaviour?** Write it in Java under `source/`, the way `MediaSessionHelper` does it. Compile it
     against `android.jar` (API 23) with `javac --release 8`, run `d8 --min-api 14`, then run `baksmali`
     to get smali. Keep the hook into Mort's code as small as you can: ideally one `invoke-static` line.
   - **Tiny change?** Edit the smali directly.
3. Make the patch with `python3 tools/make_mpatch.py BEFORE AFTER --project app --file smali/... > patches/07-your-fix.mpatch`.
   - Add a header comment that says what it fixes and why.
   - Add `#` comments inside your added smali lines. They are ignored at build time.
   - If your file was already changed by an earlier patch, use that patched file as BEFORE (see patch 03).
4. Check that only **your** lines are in it. Copied or changed lines of Mort's code should be as few as possible.
5. Rebuild, test on a phone, and use `adb logcat -s MortBT MortPerm MortAlarm` to watch our log tags.

Please **never** share an APK, decompiled code or anything else from the original app.
Share only patches and your own code.

## Credits

- **Mirko "Mort" Schenk** wrote MortPlayer Audio Books. All rights in the app stay with him.
- **crazyfury** (XDA forums, MortPlayer thread, 2020) wrote the `errorReport` crash fix used in patch 01.
- **schnurzelat** (XDA forums, 2022) wrote the patching guide (apktool 2.4.0, then uber-apk-signer) that this kit automates.
- [apktool](https://github.com/iBotPeaches/Apktool) by Connor Tumbleson and contributors (Apache-2.0), and
  [uber-apk-signer](https://github.com/patrickfav/uber-apk-signer) by Patrick Favre-Bulle (Apache-2.0).
  You download both yourself; this kit doesn't include them.

## Disclaimer

Use at your own risk, and only with an APK you are entitled to use. The app is still Mort's, it isn't
supported by him, and it has had no security updates since 2012. So far it has been tried on just one phone
(a Pixel 6). Please share how it works on yours.
