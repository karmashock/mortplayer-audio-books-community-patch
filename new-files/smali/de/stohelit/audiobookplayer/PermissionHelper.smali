# SPDX-License-Identifier: MIT
# MortPlayer community patch kit - NEW file written by the community (not part of MortPlayer).
# Asks for storage/phone permissions at run time (needed since targetSdk 23). Used by patch 03.
# Generated from source/de/stohelit/audiobookplayer/PermissionHelper.java with javac + d8 + baksmali; edit the Java, not this file.
#
.class public final Lde/stohelit/audiobookplayer/PermissionHelper;
.super Ljava/lang/Object;
.source "PermissionHelper.java"


# static fields
.field private static final MAIN:Ljava/lang/String; = "de.stohelit.audiobookplayer.MainPlayer"

.field public static final REQUEST_CODE:I = 0x4d50

.field private static final TAG:Ljava/lang/String; = "MortPerm"

.field private static final WANTED:[Ljava/lang/String;

.field private static askedThisProcess:Z

.field private static vmPolicyRelaxed:Z


# direct methods
.method static constructor <clinit>()V
    .registers 4

    .line 24
    const/4 v0, 0x3

    new-array v0, v0, [Ljava/lang/String;

    const-string v1, "android.permission.READ_EXTERNAL_STORAGE"

    const/4 v2, 0x0

    aput-object v1, v0, v2

    const/4 v1, 0x1

    const-string v3, "android.permission.WRITE_EXTERNAL_STORAGE"

    aput-object v3, v0, v1

    const/4 v1, 0x2

    const-string v3, "android.permission.READ_PHONE_STATE"

    aput-object v3, v0, v1

    sput-object v0, Lde/stohelit/audiobookplayer/PermissionHelper;->WANTED:[Ljava/lang/String;

    .line 30
    sput-boolean v2, Lde/stohelit/audiobookplayer/PermissionHelper;->askedThisProcess:Z

    .line 42
    sput-boolean v2, Lde/stohelit/audiobookplayer/PermissionHelper;->vmPolicyRelaxed:Z

    return-void
.end method

.method private constructor <init>()V
    .registers 1

    .line 32
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method private static granted(Landroid/app/Activity;Ljava/lang/String;)Z
    .registers 2

    .line 39
    invoke-virtual {p0, p1}, Landroid/app/Activity;->checkSelfPermission(Ljava/lang/String;)I

    move-result p0

    if-nez p0, :cond_8

    const/4 p0, 0x1

    goto :goto_9

    :cond_8
    const/4 p0, 0x0

    :goto_9
    return p0
.end method

.method private static isMain(Landroid/app/Activity;)Z
    .registers 2

    .line 35
    if-eqz p0, :cond_14

    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/Class;->getName()Ljava/lang/String;

    move-result-object p0

    const-string v0, "de.stohelit.audiobookplayer.MainPlayer"

    invoke-virtual {v0, p0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p0

    if-eqz p0, :cond_14

    const/4 p0, 0x1

    goto :goto_15

    :cond_14
    const/4 p0, 0x0

    :goto_15
    return p0
.end method

.method public static onRequestPermissionsResult(Landroid/app/Activity;I[Ljava/lang/String;[I)V
    .registers 8

    .line 81
    const/16 v0, 0x4d50

    if-ne p1, v0, :cond_8c

    sget p1, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v0, 0x17

    if-lt p1, v0, :cond_8c

    invoke-static {p0}, Lde/stohelit/audiobookplayer/PermissionHelper;->isMain(Landroid/app/Activity;)Z

    move-result p1

    if-nez p1, :cond_12

    goto/16 :goto_8c

    .line 83
    :cond_12
    const/4 p1, 0x0

    const-string v0, "MortPerm"

    if-eqz p2, :cond_48

    if-eqz p3, :cond_48

    .line 84
    const/4 v1, 0x0

    :goto_1a
    :try_start_1a
    array-length v2, p2

    if-ge v1, v2, :cond_48

    array-length v2, p3

    if-ge v1, v2, :cond_48

    .line 85
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    aget-object v3, p2, v1

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, " -> "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    aget v3, p3, v1

    if-nez v3, :cond_38

    const-string v3, "granted"

    goto :goto_3a

    :cond_38
    const-string v3, "denied"

    :goto_3a
    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v0, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 84
    add-int/lit8 v1, v1, 0x1

    goto :goto_1a

    .line 88
    :cond_48
    const-string p2, "android.permission.READ_EXTERNAL_STORAGE"

    invoke-static {p0, p2}, Lde/stohelit/audiobookplayer/PermissionHelper;->granted(Landroid/app/Activity;Ljava/lang/String;)Z

    move-result p2

    const/4 p3, 0x1

    if-eqz p2, :cond_76

    .line 89
    const-string p2, "storage granted, refreshing folder list"

    invoke-static {v0, p2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 90
    const-string p2, "Storage access granted. Refreshing your audiobook folders\u2026"

    invoke-static {p0, p2, p1}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object p2

    invoke-virtual {p2}, Landroid/widget/Toast;->show()V
    :try_end_5f
    .catchall {:try_start_1a .. :try_end_5f} :catchall_85

    .line 92
    :try_start_5f
    move-object p2, p0

    check-cast p2, Lde/stohelit/audiobookplayer/MainPlayer;

    invoke-virtual {p2, p1, p1}, Lde/stohelit/audiobookplayer/MainPlayer;->updateFolderInfos(ZZ)V
    :try_end_65
    .catchall {:try_start_5f .. :try_end_65} :catchall_66

    .line 96
    :goto_65
    goto :goto_84

    .line 93
    :catchall_66
    move-exception p1

    .line 94
    :try_start_67
    const-string p2, "folder refresh failed"

    invoke-static {v0, p2, p1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 95
    const-string p1, "Please close and reopen MortPlayer to see your books."

    invoke-static {p0, p1, p3}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object p0

    invoke-virtual {p0}, Landroid/widget/Toast;->show()V

    goto :goto_65

    .line 98
    :cond_76
    const-string p1, "storage denied"

    invoke-static {v0, p1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 99
    const-string p1, "MortPlayer needs storage access to find your audiobooks. You can allow it in Settings > Apps > MortPlayer Audio Books > Permissions."

    invoke-static {p0, p1, p3}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object p0

    .line 100
    invoke-virtual {p0}, Landroid/widget/Toast;->show()V
    :try_end_84
    .catchall {:try_start_67 .. :try_end_84} :catchall_85

    .line 104
    :goto_84
    goto :goto_8b

    .line 102
    :catchall_85
    move-exception p0

    .line 103
    const-string p1, "permission result handling failed"

    invoke-static {v0, p1, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 105
    :goto_8b
    return-void

    .line 81
    :cond_8c
    :goto_8c
    return-void
.end method

.method public static onResume(Landroid/app/Activity;)V
    .registers 8

    .line 60
    const-string v0, "MortPerm"

    invoke-static {}, Lde/stohelit/audiobookplayer/PermissionHelper;->relaxFileUriPolicy()V

    .line 61
    sget v1, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v2, 0x17

    if-lt v1, v2, :cond_85

    invoke-static {p0}, Lde/stohelit/audiobookplayer/PermissionHelper;->isMain(Landroid/app/Activity;)Z

    move-result v1

    if-nez v1, :cond_12

    goto :goto_85

    .line 63
    :cond_12
    :try_start_12
    new-instance v1, Ljava/util/ArrayList;

    invoke-direct {v1}, Ljava/util/ArrayList;-><init>()V

    .line 64
    sget-object v2, Lde/stohelit/audiobookplayer/PermissionHelper;->WANTED:[Ljava/lang/String;

    array-length v3, v2

    const/4 v4, 0x0

    :goto_1b
    if-ge v4, v3, :cond_2b

    aget-object v5, v2, v4

    .line 65
    invoke-static {p0, v5}, Lde/stohelit/audiobookplayer/PermissionHelper;->granted(Landroid/app/Activity;Ljava/lang/String;)Z

    move-result v6

    if-nez v6, :cond_28

    invoke-virtual {v1, v5}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 64
    :cond_28
    add-int/lit8 v4, v4, 0x1

    goto :goto_1b

    .line 67
    :cond_2b
    invoke-virtual {v1}, Ljava/util/ArrayList;->isEmpty()Z

    move-result v2

    if-eqz v2, :cond_32

    return-void

    .line 68
    :cond_32
    sget-boolean v2, Lde/stohelit/audiobookplayer/PermissionHelper;->askedThisProcess:Z

    if-eqz v2, :cond_53

    .line 69
    new-instance p0, Ljava/lang/StringBuilder;

    invoke-direct {p0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "still missing "

    invoke-virtual {p0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object p0

    const-string v1, " (already asked once this session)"

    invoke-virtual {p0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-static {v0, p0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 70
    return-void

    .line 72
    :cond_53
    const/4 v2, 0x1

    sput-boolean v2, Lde/stohelit/audiobookplayer/PermissionHelper;->askedThisProcess:Z

    .line 73
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "requesting "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v0, v2}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 74
    invoke-virtual {v1}, Ljava/util/ArrayList;->size()I

    move-result v2

    new-array v2, v2, [Ljava/lang/String;

    invoke-virtual {v1, v2}, Ljava/util/ArrayList;->toArray([Ljava/lang/Object;)[Ljava/lang/Object;

    move-result-object v1

    check-cast v1, [Ljava/lang/String;

    const/16 v2, 0x4d50

    invoke-virtual {p0, v1, v2}, Landroid/app/Activity;->requestPermissions([Ljava/lang/String;I)V
    :try_end_7d
    .catchall {:try_start_12 .. :try_end_7d} :catchall_7e

    .line 77
    goto :goto_84

    .line 75
    :catchall_7e
    move-exception p0

    .line 76
    const-string v1, "permission request failed"

    invoke-static {v0, v1, p0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 78
    :goto_84
    return-void

    .line 61
    :cond_85
    :goto_85
    return-void
.end method

.method private static relaxFileUriPolicy()V
    .registers 3

    .line 49
    const-string v0, "MortPerm"

    sget-boolean v1, Lde/stohelit/audiobookplayer/PermissionHelper;->vmPolicyRelaxed:Z

    if-nez v1, :cond_29

    sget v1, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v2, 0x18

    if-ge v1, v2, :cond_d

    goto :goto_29

    .line 50
    :cond_d
    const/4 v1, 0x1

    sput-boolean v1, Lde/stohelit/audiobookplayer/PermissionHelper;->vmPolicyRelaxed:Z

    .line 52
    :try_start_10
    new-instance v1, Landroid/os/StrictMode$VmPolicy$Builder;

    invoke-direct {v1}, Landroid/os/StrictMode$VmPolicy$Builder;-><init>()V

    invoke-virtual {v1}, Landroid/os/StrictMode$VmPolicy$Builder;->build()Landroid/os/StrictMode$VmPolicy;

    move-result-object v1

    invoke-static {v1}, Landroid/os/StrictMode;->setVmPolicy(Landroid/os/StrictMode$VmPolicy;)V

    .line 53
    const-string v1, "file:// URI exposure check disabled (legacy SendMp3Mail)"

    invoke-static {v0, v1}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_21
    .catchall {:try_start_10 .. :try_end_21} :catchall_22

    .line 56
    goto :goto_28

    .line 54
    :catchall_22
    move-exception v1

    .line 55
    const-string v2, "could not relax VmPolicy"

    invoke-static {v0, v2, v1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 57
    :goto_28
    return-void

    .line 49
    :cond_29
    :goto_29
    return-void
.end method
