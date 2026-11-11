# SPDX-License-Identifier: MIT
# MortPlayer community patch kit - NEW file written by the community (not part of MortPlayer).
# Real MediaSession for Bluetooth/headset/lock-screen buttons on Android 5+. Used by patch 02.
# Generated from source/de/stohelit/audiobookplayer/playback/MediaSessionHelper.java with javac + d8 + baksmali; edit the Java, not this file.
#
.class public final Lde/stohelit/audiobookplayer/playback/MediaSessionHelper;
.super Ljava/lang/Object;
.source "MediaSessionHelper.java"


# static fields
.field static final TAG:Ljava/lang/String; = "MortBT"


# direct methods
.method private constructor <init>()V
    .registers 1

    .line 14
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 15
    return-void
.end method

.method public static close()V
    .registers 3

    .line 50
    invoke-static {}, Lde/stohelit/audiobookplayer/playback/MediaSessionHelper;->supported()Z

    move-result v0

    if-nez v0, :cond_7

    return-void

    .line 52
    :cond_7
    :try_start_7
    invoke-static {}, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl;->close()V
    :try_end_a
    .catchall {:try_start_7 .. :try_end_a} :catchall_b

    .line 55
    goto :goto_13

    .line 53
    :catchall_b
    move-exception v0

    .line 54
    const-string v1, "MortBT"

    const-string v2, "close failed"

    invoke-static {v1, v2, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 56
    :goto_13
    return-void
.end method

.method public static open(Landroid/content/Context;)V
    .registers 3

    .line 22
    invoke-static {}, Lde/stohelit/audiobookplayer/playback/MediaSessionHelper;->supported()Z

    move-result v0

    if-nez v0, :cond_7

    return-void

    .line 24
    :cond_7
    :try_start_7
    invoke-static {p0}, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl;->open(Landroid/content/Context;)V
    :try_end_a
    .catchall {:try_start_7 .. :try_end_a} :catchall_b

    .line 27
    goto :goto_13

    .line 25
    :catchall_b
    move-exception p0

    .line 26
    const-string v0, "MortBT"

    const-string v1, "open failed"

    invoke-static {v0, v1, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 28
    :goto_13
    return-void
.end method

.method public static setMetadata(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;IIJ)V
    .registers 7

    .line 70
    invoke-static {}, Lde/stohelit/audiobookplayer/playback/MediaSessionHelper;->supported()Z

    move-result p3

    if-nez p3, :cond_7

    return-void

    .line 72
    :cond_7
    :try_start_7
    invoke-static {p0, p1, p2, p5, p6}, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl;->setMetadata(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;J)V
    :try_end_a
    .catchall {:try_start_7 .. :try_end_a} :catchall_b

    .line 75
    goto :goto_13

    .line 73
    :catchall_b
    move-exception p0

    .line 74
    const-string p1, "MortBT"

    const-string p2, "setMetadata failed"

    invoke-static {p1, p2, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 76
    :goto_13
    return-void
.end method

.method public static setPlaybackState(I)V
    .registers 3

    .line 60
    invoke-static {}, Lde/stohelit/audiobookplayer/playback/MediaSessionHelper;->supported()Z

    move-result v0

    if-nez v0, :cond_7

    return-void

    .line 62
    :cond_7
    :try_start_7
    invoke-static {p0}, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl;->setPlaybackState(I)V
    :try_end_a
    .catchall {:try_start_7 .. :try_end_a} :catchall_b

    .line 65
    goto :goto_13

    .line 63
    :catchall_b
    move-exception p0

    .line 64
    const-string v0, "MortBT"

    const-string v1, "setPlaybackState failed"

    invoke-static {v0, v1, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 66
    :goto_13
    return-void
.end method

.method private static supported()Z
    .registers 2

    .line 18
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x15

    if-lt v0, v1, :cond_8

    const/4 v0, 0x1

    goto :goto_9

    :cond_8
    const/4 v0, 0x0

    :goto_9
    return v0
.end method

.method public static takeOver(Landroid/content/Context;)Z
    .registers 5

    .line 37
    const-string v0, "MortBT"

    invoke-static {}, Lde/stohelit/audiobookplayer/playback/MediaSessionHelper;->supported()Z

    move-result v1

    const/4 v2, 0x0

    if-nez v1, :cond_a

    return v2

    .line 39
    :cond_a
    :try_start_a
    invoke-static {p0}, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl;->open(Landroid/content/Context;)V

    .line 40
    invoke-static {}, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl;->isOpen()Z

    move-result p0

    .line 41
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "takeOver: "

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    if-eqz p0, :cond_21

    const-string v3, "MediaSession active, legacy RemoteControlClient skipped"

    goto :goto_23

    :cond_21
    const-string v3, "session not open, falling back to legacy path"

    :goto_23
    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_2e
    .catchall {:try_start_a .. :try_end_2e} :catchall_2f

    .line 42
    return p0

    .line 43
    :catchall_2f
    move-exception p0

    .line 44
    const-string v1, "takeOver failed, falling back to legacy path"

    invoke-static {v0, v1, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 45
    return v2
.end method
