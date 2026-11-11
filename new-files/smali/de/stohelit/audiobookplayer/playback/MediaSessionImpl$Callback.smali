# SPDX-License-Identifier: MIT
# MortPlayer community patch kit - NEW file written by the community (not part of MortPlayer).
# Real MediaSession for Bluetooth/headset/lock-screen buttons on Android 5+. Used by patch 02.
# Generated from source/de/stohelit/audiobookplayer/playback/MediaSessionImpl.java with javac + d8 + baksmali; edit the Java, not this file.
#
.class final Lde/stohelit/audiobookplayer/playback/MediaSessionImpl$Callback;
.super Landroid/media/session/MediaSession$Callback;
.source "MediaSessionImpl.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lde/stohelit/audiobookplayer/playback/MediaSessionImpl;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x18
    name = "Callback"
.end annotation


# direct methods
.method constructor <init>()V
    .registers 1

    .line 135
    invoke-direct {p0}, Landroid/media/session/MediaSession$Callback;-><init>()V

    return-void
.end method

.method private safe(Ljava/lang/String;)V
    .registers 5

    .line 161
    const-string v0, "MortBT"

    :try_start_2
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "handling "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 162
    invoke-static {p1}, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl;->sendButton(Ljava/lang/String;)V
    :try_end_1b
    .catchall {:try_start_2 .. :try_end_1b} :catchall_1c

    .line 165
    goto :goto_22

    .line 163
    :catchall_1c
    move-exception p1

    .line 164
    const-string v1, "sendButton failed"

    invoke-static {v0, v1, p1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 166
    :goto_22
    return-void
.end method


# virtual methods
.method public onMediaButtonEvent(Landroid/content/Intent;)Z
    .registers 7

    .line 139
    const-string v0, "MortBT"

    const/4 v1, 0x1

    :try_start_3
    const-string v2, "android.intent.extra.KEY_EVENT"

    invoke-virtual {p1, v2}, Landroid/content/Intent;->getParcelableExtra(Ljava/lang/String;)Landroid/os/Parcelable;

    move-result-object v2

    check-cast v2, Landroid/view/KeyEvent;

    .line 140
    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "callback received key "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-static {v0, v3}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 141
    if-nez v2, :cond_28

    invoke-super {p0, p1}, Landroid/media/session/MediaSession$Callback;->onMediaButtonEvent(Landroid/content/Intent;)Z

    move-result p1

    return p1

    .line 142
    :cond_28
    invoke-virtual {v2}, Landroid/view/KeyEvent;->getKeyCode()I

    move-result v3

    invoke-static {v3}, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl;->actionForKey(I)Ljava/lang/String;

    move-result-object v3

    .line 143
    if-nez v3, :cond_57

    .line 144
    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "unhandled keyCode "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v2}, Landroid/view/KeyEvent;->getKeyCode()I

    move-result v2

    invoke-virtual {v3, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, ", passing to default handling"

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v0, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 145
    invoke-super {p0, p1}, Landroid/media/session/MediaSession$Callback;->onMediaButtonEvent(Landroid/content/Intent;)Z

    move-result p1

    return p1

    .line 147
    :cond_57
    invoke-virtual {v2}, Landroid/view/KeyEvent;->getAction()I

    move-result p1

    if-ne p1, v1, :cond_61

    .line 148
    invoke-direct {p0, v3}, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl$Callback;->safe(Ljava/lang/String;)V

    goto :goto_7d

    .line 150
    :cond_61
    new-instance p1, Ljava/lang/StringBuilder;

    invoke-direct {p1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "key down/repeat for "

    invoke-virtual {p1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    const-string v2, ", acting on key up"

    invoke-virtual {p1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {v0, p1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_7d
    .catchall {:try_start_3 .. :try_end_7d} :catchall_7e

    .line 152
    :goto_7d
    return v1

    .line 153
    :catchall_7e
    move-exception p1

    .line 154
    const-string v2, "onMediaButtonEvent failed"

    invoke-static {v0, v2, p1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 155
    return v1
.end method

.method public onPause()V
    .registers 2

    .line 169
    const-string v0, "pauseForce"

    invoke-direct {p0, v0}, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl$Callback;->safe(Ljava/lang/String;)V

    return-void
.end method

.method public onPlay()V
    .registers 2

    .line 168
    const-string v0, "playForce"

    invoke-direct {p0, v0}, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl$Callback;->safe(Ljava/lang/String;)V

    return-void
.end method

.method public onSkipToNext()V
    .registers 2

    .line 170
    const-string v0, "next"

    invoke-direct {p0, v0}, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl$Callback;->safe(Ljava/lang/String;)V

    return-void
.end method

.method public onSkipToPrevious()V
    .registers 2

    .line 171
    const-string v0, "prev"

    invoke-direct {p0, v0}, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl$Callback;->safe(Ljava/lang/String;)V

    return-void
.end method

.method public onStop()V
    .registers 2

    .line 172
    const-string v0, "stop"

    invoke-direct {p0, v0}, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl$Callback;->safe(Ljava/lang/String;)V

    return-void
.end method
