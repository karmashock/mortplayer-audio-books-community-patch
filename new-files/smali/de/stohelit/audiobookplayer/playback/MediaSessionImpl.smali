# SPDX-License-Identifier: MIT
# MortPlayer community patch kit - NEW file written by the community (not part of MortPlayer).
# Real MediaSession for Bluetooth/headset/lock-screen buttons on Android 5+. Used by patch 02.
# Generated from source/de/stohelit/audiobookplayer/playback/MediaSessionImpl.java with javac + d8 + baksmali; edit the Java, not this file.
#
.class final Lde/stohelit/audiobookplayer/playback/MediaSessionImpl;
.super Ljava/lang/Object;
.source "MediaSessionImpl.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lde/stohelit/audiobookplayer/playback/MediaSessionImpl$Callback;
    }
.end annotation


# static fields
.field private static final ACTIONS:J = 0x237L

.field private static final RECEIVER:Ljava/lang/String; = "de.stohelit.audiobookplayer.PlayerBroadcastReceiver"

.field private static final SERVICE:Ljava/lang/String; = "de.stohelit.audiobookplayer.playback.PlaybackService"

.field private static final TAG:Ljava/lang/String; = "MortBT"

.field private static appContext:Landroid/content/Context;

.field private static lastMetadata:Landroid/media/MediaMetadata;

.field private static lastState:I

.field private static session:Landroid/media/session/MediaSession;


# direct methods
.method static constructor <clinit>()V
    .registers 1

    .line 26
    const/4 v0, 0x1

    sput v0, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl;->lastState:I

    return-void
.end method

.method private constructor <init>()V
    .registers 1

    .line 29
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 30
    return-void
.end method

.method static actionForKey(I)Ljava/lang/String;
    .registers 1

    .line 101
    sparse-switch p0, :sswitch_data_1e

    .line 120
    const/4 p0, 0x0

    return-object p0

    .line 108
    :sswitch_5
    const-string p0, "pauseForce"

    return-object p0

    .line 106
    :sswitch_8
    const-string p0, "playForce"

    return-object p0

    .line 118
    :sswitch_b
    const-string p0, "ffwd"

    return-object p0

    .line 116
    :sswitch_e
    const-string p0, "rew"

    return-object p0

    .line 114
    :sswitch_11
    const-string p0, "prev"

    return-object p0

    .line 112
    :sswitch_14
    const-string p0, "next"

    return-object p0

    .line 110
    :sswitch_17
    const-string p0, "stop"

    return-object p0

    .line 104
    :sswitch_1a
    const-string p0, "headset"

    return-object p0

    nop

    :sswitch_data_1e
    .sparse-switch
        0x4f -> :sswitch_1a
        0x55 -> :sswitch_1a
        0x56 -> :sswitch_17
        0x57 -> :sswitch_14
        0x58 -> :sswitch_11
        0x59 -> :sswitch_e
        0x5a -> :sswitch_b
        0x7e -> :sswitch_8
        0x7f -> :sswitch_5
    .end sparse-switch
.end method

.method private static applyState(I)V
    .registers 6

    .line 83
    const/4 v0, 0x3

    packed-switch p0, :pswitch_data_48

    .line 86
    const/4 p0, 0x1

    goto :goto_9

    .line 85
    :pswitch_6
    const/4 p0, 0x2

    goto :goto_9

    .line 84
    :pswitch_8
    const/4 p0, 0x3

    .line 88
    :goto_9
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "PlaybackState set: "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, " (3=PLAYING 2=PAUSED 1=STOPPED)"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    const-string v2, "MortBT"

    invoke-static {v2, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 89
    sget-object v1, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl;->session:Landroid/media/session/MediaSession;

    new-instance v2, Landroid/media/session/PlaybackState$Builder;

    invoke-direct {v2}, Landroid/media/session/PlaybackState$Builder;-><init>()V

    .line 90
    const-wide/16 v3, 0x237

    invoke-virtual {v2, v3, v4}, Landroid/media/session/PlaybackState$Builder;->setActions(J)Landroid/media/session/PlaybackState$Builder;

    move-result-object v2

    .line 91
    if-ne p0, v0, :cond_39

    const/high16 v0, 0x3f800000    # 1.0f

    goto :goto_3a

    :cond_39
    const/4 v0, 0x0

    :goto_3a
    const-wide/16 v3, -0x1

    invoke-virtual {v2, p0, v3, v4, v0}, Landroid/media/session/PlaybackState$Builder;->setState(IJF)Landroid/media/session/PlaybackState$Builder;

    move-result-object p0

    .line 92
    invoke-virtual {p0}, Landroid/media/session/PlaybackState$Builder;->build()Landroid/media/session/PlaybackState;

    move-result-object p0

    .line 89
    invoke-virtual {v1, p0}, Landroid/media/session/MediaSession;->setPlaybackState(Landroid/media/session/PlaybackState;)V

    .line 93
    return-void

    :pswitch_data_48
    .packed-switch 0x2
        :pswitch_8
        :pswitch_6
    .end packed-switch
.end method

.method static declared-synchronized close()V
    .registers 3

    const-class v0, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl;

    monitor-enter v0

    .line 58
    :try_start_3
    sget-object v1, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl;->session:Landroid/media/session/MediaSession;
    :try_end_5
    .catchall {:try_start_3 .. :try_end_5} :catchall_1e

    if-nez v1, :cond_9

    monitor-exit v0

    return-void

    .line 59
    :cond_9
    const/4 v2, 0x0

    :try_start_a
    invoke-virtual {v1, v2}, Landroid/media/session/MediaSession;->setActive(Z)V

    .line 60
    sget-object v1, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl;->session:Landroid/media/session/MediaSession;

    invoke-virtual {v1}, Landroid/media/session/MediaSession;->release()V

    .line 61
    const/4 v1, 0x0

    sput-object v1, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl;->session:Landroid/media/session/MediaSession;

    .line 62
    const-string v1, "MortBT"

    const-string v2, "MediaSession released"

    invoke-static {v1, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_1c
    .catchall {:try_start_a .. :try_end_1c} :catchall_1e

    .line 63
    monitor-exit v0

    return-void

    .line 57
    :catchall_1e
    move-exception v1

    monitor-exit v0

    throw v1
.end method

.method static declared-synchronized isOpen()Z
    .registers 2

    const-class v0, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl;

    monitor-enter v0

    .line 33
    :try_start_3
    sget-object v1, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl;->session:Landroid/media/session/MediaSession;
    :try_end_5
    .catchall {:try_start_3 .. :try_end_5} :catchall_c

    if-eqz v1, :cond_9

    const/4 v1, 0x1

    goto :goto_a

    :cond_9
    const/4 v1, 0x0

    :goto_a
    monitor-exit v0

    return v1

    .line 33
    :catchall_c
    move-exception v1

    monitor-exit v0

    throw v1
.end method

.method static declared-synchronized open(Landroid/content/Context;)V
    .registers 7

    const-class v0, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl;

    monitor-enter v0

    .line 37
    :try_start_3
    sget-object v1, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl;->session:Landroid/media/session/MediaSession;
    :try_end_5
    .catchall {:try_start_3 .. :try_end_5} :catchall_b3

    if-eqz v1, :cond_9

    monitor-exit v0

    return-void

    .line 38
    :cond_9
    :try_start_9
    const-string v1, "MortBT"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "creating MediaSession (SDK "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    sget v3, Landroid/os/Build$VERSION;->SDK_INT:I

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, ")"

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v1, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 39
    invoke-virtual {p0}, Landroid/content/Context;->getApplicationContext()Landroid/content/Context;

    move-result-object p0

    sput-object p0, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl;->appContext:Landroid/content/Context;

    .line 40
    new-instance p0, Landroid/media/session/MediaSession;

    sget-object v1, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl;->appContext:Landroid/content/Context;

    const-string v2, "MortPlayerAudioBooks"

    invoke-direct {p0, v1, v2}, Landroid/media/session/MediaSession;-><init>(Landroid/content/Context;Ljava/lang/String;)V

    .line 41
    const/4 v1, 0x3

    invoke-virtual {p0, v1}, Landroid/media/session/MediaSession;->setFlags(I)V

    .line 42
    new-instance v1, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl$Callback;

    invoke-direct {v1}, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl$Callback;-><init>()V

    new-instance v2, Landroid/os/Handler;

    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;

    move-result-object v3

    invoke-direct {v2, v3}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V

    invoke-virtual {p0, v1, v2}, Landroid/media/session/MediaSession;->setCallback(Landroid/media/session/MediaSession$Callback;Landroid/os/Handler;)V
    :try_end_4d
    .catchall {:try_start_9 .. :try_end_4d} :catchall_b3

    .line 44
    const/4 v1, 0x1

    :try_start_4e
    new-instance v2, Landroid/content/Intent;

    const-string v3, "android.intent.action.MEDIA_BUTTON"

    invoke-direct {v2, v3}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    .line 45
    new-instance v3, Landroid/content/ComponentName;

    sget-object v4, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl;->appContext:Landroid/content/Context;

    invoke-virtual {v4}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object v4

    const-string v5, "de.stohelit.audiobookplayer.PlayerBroadcastReceiver"

    invoke-direct {v3, v4, v5}, Landroid/content/ComponentName;-><init>(Ljava/lang/String;Ljava/lang/String;)V

    invoke-virtual {v2, v3}, Landroid/content/Intent;->setComponent(Landroid/content/ComponentName;)Landroid/content/Intent;

    .line 46
    sget-object v3, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl;->appContext:Landroid/content/Context;

    const/4 v4, 0x0

    invoke-static {v3, v1, v2, v4}, Landroid/app/PendingIntent;->getBroadcast(Landroid/content/Context;ILandroid/content/Intent;I)Landroid/app/PendingIntent;

    move-result-object v2

    invoke-virtual {p0, v2}, Landroid/media/session/MediaSession;->setMediaButtonReceiver(Landroid/app/PendingIntent;)V
    :try_end_6f
    .catchall {:try_start_4e .. :try_end_6f} :catchall_70

    .line 49
    goto :goto_78

    .line 47
    :catchall_70
    move-exception v2

    .line 48
    :try_start_71
    const-string v3, "MortBT"

    const-string v4, "setMediaButtonReceiver failed"

    invoke-static {v3, v4, v2}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 50
    :goto_78
    sput-object p0, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl;->session:Landroid/media/session/MediaSession;

    .line 51
    sget v2, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl;->lastState:I

    invoke-static {v2}, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl;->applyState(I)V

    .line 52
    sget-object v2, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl;->lastMetadata:Landroid/media/MediaMetadata;

    if-eqz v2, :cond_86

    invoke-virtual {p0, v2}, Landroid/media/session/MediaSession;->setMetadata(Landroid/media/MediaMetadata;)V

    .line 53
    :cond_86
    invoke-virtual {p0, v1}, Landroid/media/session/MediaSession;->setActive(Z)V

    .line 54
    const-string v1, "MortBT"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "MediaSession created and active="

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {p0}, Landroid/media/session/MediaSession;->isActive()Z

    move-result p0

    invoke-virtual {v2, p0}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    move-result-object p0

    const-string v2, ", state="

    invoke-virtual {p0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    sget v2, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl;->lastState:I

    invoke-virtual {p0, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-static {v1, p0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_b1
    .catchall {:try_start_71 .. :try_end_b1} :catchall_b3

    .line 55
    monitor-exit v0

    return-void

    .line 36
    :catchall_b3
    move-exception p0

    monitor-exit v0

    throw p0
.end method

.method static sendButton(Ljava/lang/String;)V
    .registers 5

    .line 126
    sget-object v0, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl;->appContext:Landroid/content/Context;

    if-nez v0, :cond_5

    return-void

    .line 127
    :cond_5
    new-instance v0, Landroid/content/Intent;

    invoke-direct {v0}, Landroid/content/Intent;-><init>()V

    .line 128
    new-instance v1, Landroid/content/ComponentName;

    sget-object v2, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl;->appContext:Landroid/content/Context;

    invoke-virtual {v2}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object v2

    const-string v3, "de.stohelit.audiobookplayer.playback.PlaybackService"

    invoke-direct {v1, v2, v3}, Landroid/content/ComponentName;-><init>(Ljava/lang/String;Ljava/lang/String;)V

    invoke-virtual {v0, v1}, Landroid/content/Intent;->setComponent(Landroid/content/ComponentName;)Landroid/content/Intent;

    .line 129
    const-string v1, "button"

    invoke-virtual {v0, v1, p0}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 130
    const-string v1, "longPress"

    const/4 v2, 0x0

    invoke-virtual {v0, v1, v2}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Z)Landroid/content/Intent;

    .line 131
    sget-object v1, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl;->appContext:Landroid/content/Context;

    invoke-virtual {v1, v0}, Landroid/content/Context;->startService(Landroid/content/Intent;)Landroid/content/ComponentName;

    move-result-object v0

    .line 132
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "command sent to PlaybackService: button="

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    const-string v1, " -> "

    invoke-virtual {p0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    const-string v0, "MortBT"

    invoke-static {v0, p0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 133
    return-void
.end method

.method static declared-synchronized setMetadata(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;J)V
    .registers 8

    const-class v0, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl;

    monitor-enter v0

    .line 72
    :try_start_3
    new-instance v1, Landroid/media/MediaMetadata$Builder;

    invoke-direct {v1}, Landroid/media/MediaMetadata$Builder;-><init>()V

    .line 73
    if-eqz p0, :cond_f

    const-string v2, "android.media.metadata.ARTIST"

    invoke-virtual {v1, v2, p0}, Landroid/media/MediaMetadata$Builder;->putString(Ljava/lang/String;Ljava/lang/String;)Landroid/media/MediaMetadata$Builder;

    .line 74
    :cond_f
    if-eqz p1, :cond_16

    const-string p0, "android.media.metadata.ALBUM"

    invoke-virtual {v1, p0, p1}, Landroid/media/MediaMetadata$Builder;->putString(Ljava/lang/String;Ljava/lang/String;)Landroid/media/MediaMetadata$Builder;

    .line 75
    :cond_16
    if-eqz p2, :cond_1d

    const-string p0, "android.media.metadata.TITLE"

    invoke-virtual {v1, p0, p2}, Landroid/media/MediaMetadata$Builder;->putString(Ljava/lang/String;Ljava/lang/String;)Landroid/media/MediaMetadata$Builder;

    .line 76
    :cond_1d
    const-wide/16 p0, 0x0

    cmp-long p2, p3, p0

    if-lez p2, :cond_28

    const-string p0, "android.media.metadata.DURATION"

    invoke-virtual {v1, p0, p3, p4}, Landroid/media/MediaMetadata$Builder;->putLong(Ljava/lang/String;J)Landroid/media/MediaMetadata$Builder;

    .line 77
    :cond_28
    invoke-virtual {v1}, Landroid/media/MediaMetadata$Builder;->build()Landroid/media/MediaMetadata;

    move-result-object p0

    sput-object p0, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl;->lastMetadata:Landroid/media/MediaMetadata;

    .line 78
    sget-object p1, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl;->session:Landroid/media/session/MediaSession;

    if-eqz p1, :cond_35

    invoke-virtual {p1, p0}, Landroid/media/session/MediaSession;->setMetadata(Landroid/media/MediaMetadata;)V
    :try_end_35
    .catchall {:try_start_3 .. :try_end_35} :catchall_37

    .line 79
    :cond_35
    monitor-exit v0

    return-void

    .line 71
    :catchall_37
    move-exception p0

    monitor-exit v0

    throw p0
.end method

.method static declared-synchronized setPlaybackState(I)V
    .registers 5

    const-class v0, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl;

    monitor-enter v0

    .line 66
    :try_start_3
    sget v1, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl;->lastState:I

    if-ne p0, v1, :cond_b

    sget-object v1, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl;->session:Landroid/media/session/MediaSession;

    if-nez v1, :cond_30

    :cond_b
    const-string v1, "MortBT"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "app state "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, p0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    sget-object v3, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl;->session:Landroid/media/session/MediaSession;

    if-nez v3, :cond_23

    const-string v3, " (no session yet)"

    goto :goto_25

    :cond_23
    const-string v3, ""

    :goto_25
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v1, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 67
    :cond_30
    sput p0, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl;->lastState:I

    .line 68
    sget-object v1, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl;->session:Landroid/media/session/MediaSession;

    if-eqz v1, :cond_39

    invoke-static {p0}, Lde/stohelit/audiobookplayer/playback/MediaSessionImpl;->applyState(I)V
    :try_end_39
    .catchall {:try_start_3 .. :try_end_39} :catchall_3b

    .line 69
    :cond_39
    monitor-exit v0

    return-void

    .line 65
    :catchall_3b
    move-exception p0

    monitor-exit v0

    throw p0
.end method
