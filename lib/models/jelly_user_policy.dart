import 'dart:convert';

import 'package:awesome_extensions/awesome_extensions.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class AccessSchedule {
  final int id;
  final String userId;
  final String dayOfWeek;
  final double startHour;
  final double endHour;

  const AccessSchedule({
    required this.id,
    required this.userId,
    required this.dayOfWeek,
    required this.startHour,
    required this.endHour,
  });

  AccessSchedule copyWith({
    int? id,
    String? userId,
    String? dayOfWeek,
    double? startHour,
    double? endHour,
  }) {
    return AccessSchedule(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startHour: startHour ?? this.startHour,
      endHour: endHour ?? this.endHour,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'dayOfWeek': dayOfWeek,
      'startHour': startHour,
      'endHour': endHour,
    };
  }

  factory AccessSchedule.fromMap(Map<String, dynamic> map) {
    return AccessSchedule(
      id: map['id'] as int,
      userId: map['userId'] as String,
      dayOfWeek: map['dayOfWeek'] as String,
      startHour: map['startHour'] as double,
      endHour: map['endHour'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory AccessSchedule.fromJson(String source) =>
      AccessSchedule.fromMap(json.decode(source) as Map<String, dynamic>);
}

class UserPolicy {
  final bool isAdministrator;
  final bool isHidden;
  final bool enableCollectionManagement;
  final bool enableSubtitleManagement;
  final bool enableLyricManagement;
  final bool isDisabled;
  final int? maxParentalRating;
  final int? maxParentalSubRating;
  final List<String>? blockedTags;
  final List<String>? allowedTags;
  final bool enableUserPreferenceAccess;
  final List<AccessSchedule>? accessSchedules;
  final List<String>? blockUnratedItems;
  final bool enableRemoteControlOfOtherUsers;
  final bool enableSharedDeviceControl;
  final bool enableRemoteAccess;
  final bool enableLiveTvManagement;
  final bool enableLiveTvAccess;
  final bool enableMediaPlayback;
  final bool enableAudioPlaybackTranscoding;
  final bool enableVideoPlaybackTranscoding;
  final bool enablePlaybackRemuxing;
  final bool forceRemoteSourceTranscoding;
  final bool enableContentDeletion;
  final List<String>? enableContentDeletionFromFolders;
  final bool enableContentDownloading;
  final bool enableSyncTranscoding;
  final bool enableMediaConversion;
  final List<String>? enabledDevices;
  final bool enableAllDevices;
  final List<String>? enabledChannels;
  final bool enableAllChannels;
  final List<String>? enabledFolders;
  final bool enableAllFolders;
  final int invalidLoginAttemptCount;
  final int loginAttemptsBeforeLockout;
  final int maxActiveSessions;
  final bool enablePublicSharing;
  final List<String>? blockedMediaFolders;
  final List<String>? blockedChannels;
  final int remoteClientBitrateLimit;
  final String authenticationProviderId;
  final String passwordResetProviderId;
  final String syncPlayAccess;

  const UserPolicy({
    required this.isAdministrator,
    required this.isHidden,
    required this.enableCollectionManagement,
    required this.enableSubtitleManagement,
    required this.enableLyricManagement,
    required this.isDisabled,
    this.maxParentalRating,
    this.maxParentalSubRating,
    required this.blockedTags,
    required this.allowedTags,
    required this.enableUserPreferenceAccess,
    required this.accessSchedules,
    required this.blockUnratedItems,
    required this.enableRemoteControlOfOtherUsers,
    required this.enableSharedDeviceControl,
    required this.enableRemoteAccess,
    required this.enableLiveTvManagement,
    required this.enableLiveTvAccess,
    required this.enableMediaPlayback,
    required this.enableAudioPlaybackTranscoding,
    required this.enableVideoPlaybackTranscoding,
    required this.enablePlaybackRemuxing,
    required this.forceRemoteSourceTranscoding,
    required this.enableContentDeletion,
    required this.enableContentDeletionFromFolders,
    required this.enableContentDownloading,
    required this.enableSyncTranscoding,
    required this.enableMediaConversion,
    required this.enabledDevices,
    required this.enableAllDevices,
    required this.enabledChannels,
    required this.enableAllChannels,
    required this.enabledFolders,
    required this.enableAllFolders,
    required this.invalidLoginAttemptCount,
    required this.loginAttemptsBeforeLockout,
    required this.maxActiveSessions,
    required this.enablePublicSharing,
    required this.blockedMediaFolders,
    required this.blockedChannels,
    required this.remoteClientBitrateLimit,
    required this.authenticationProviderId,
    required this.passwordResetProviderId,
    required this.syncPlayAccess,
  });

  UserPolicy copyWith({
    bool? isAdministrator,
    bool? isHidden,
    bool? enableCollectionManagement,
    bool? enableSubtitleManagement,
    bool? enableLyricManagement,
    bool? isDisabled,
    int? maxParentalRating,
    int? maxParentalSubRating,
    List<String>? blockedTags,
    List<String>? allowedTags,
    bool? enableUserPreferenceAccess,
    List<AccessSchedule>? accessSchedules,
    List<String>? blockUnratedItems,
    bool? enableRemoteControlOfOtherUsers,
    bool? enableSharedDeviceControl,
    bool? enableRemoteAccess,
    bool? enableLiveTvManagement,
    bool? enableLiveTvAccess,
    bool? enableMediaPlayback,
    bool? enableAudioPlaybackTranscoding,
    bool? enableVideoPlaybackTranscoding,
    bool? enablePlaybackRemuxing,
    bool? forceRemoteSourceTranscoding,
    bool? enableContentDeletion,
    List<String>? enableContentDeletionFromFolders,
    bool? enableContentDownloading,
    bool? enableSyncTranscoding,
    bool? enableMediaConversion,
    List<String>? enabledDevices,
    bool? enableAllDevices,
    List<String>? enabledChannels,
    bool? enableAllChannels,
    List<String>? enabledFolders,
    bool? enableAllFolders,
    int? invalidLoginAttemptCount,
    int? loginAttemptsBeforeLockout,
    int? maxActiveSessions,
    bool? enablePublicSharing,
    List<String>? blockedMediaFolders,
    List<String>? blockedChannels,
    int? remoteClientBitrateLimit,
    String? authenticationProviderId,
    String? passwordResetProviderId,
    String? syncPlayAccess,
  }) {
    return UserPolicy(
      isAdministrator: isAdministrator ?? this.isAdministrator,
      isHidden: isHidden ?? this.isHidden,
      enableCollectionManagement:
          enableCollectionManagement ?? this.enableCollectionManagement,
      enableSubtitleManagement:
          enableSubtitleManagement ?? this.enableSubtitleManagement,
      enableLyricManagement:
          enableLyricManagement ?? this.enableLyricManagement,
      isDisabled: isDisabled ?? this.isDisabled,
      maxParentalRating: maxParentalRating ?? this.maxParentalRating,
      maxParentalSubRating: maxParentalSubRating ?? this.maxParentalSubRating,
      blockedTags: blockedTags ?? this.blockedTags,
      allowedTags: allowedTags ?? this.allowedTags,
      enableUserPreferenceAccess:
          enableUserPreferenceAccess ?? this.enableUserPreferenceAccess,
      accessSchedules: accessSchedules ?? this.accessSchedules,
      blockUnratedItems: blockUnratedItems ?? this.blockUnratedItems,
      enableRemoteControlOfOtherUsers:
          enableRemoteControlOfOtherUsers ??
          this.enableRemoteControlOfOtherUsers,
      enableSharedDeviceControl:
          enableSharedDeviceControl ?? this.enableSharedDeviceControl,
      enableRemoteAccess: enableRemoteAccess ?? this.enableRemoteAccess,
      enableLiveTvManagement:
          enableLiveTvManagement ?? this.enableLiveTvManagement,
      enableLiveTvAccess: enableLiveTvAccess ?? this.enableLiveTvAccess,
      enableMediaPlayback: enableMediaPlayback ?? this.enableMediaPlayback,
      enableAudioPlaybackTranscoding:
          enableAudioPlaybackTranscoding ?? this.enableAudioPlaybackTranscoding,
      enableVideoPlaybackTranscoding:
          enableVideoPlaybackTranscoding ?? this.enableVideoPlaybackTranscoding,
      enablePlaybackRemuxing:
          enablePlaybackRemuxing ?? this.enablePlaybackRemuxing,
      forceRemoteSourceTranscoding:
          forceRemoteSourceTranscoding ?? this.forceRemoteSourceTranscoding,
      enableContentDeletion:
          enableContentDeletion ?? this.enableContentDeletion,
      enableContentDeletionFromFolders:
          enableContentDeletionFromFolders ??
          this.enableContentDeletionFromFolders,
      enableContentDownloading:
          enableContentDownloading ?? this.enableContentDownloading,
      enableSyncTranscoding:
          enableSyncTranscoding ?? this.enableSyncTranscoding,
      enableMediaConversion:
          enableMediaConversion ?? this.enableMediaConversion,
      enabledDevices: enabledDevices ?? this.enabledDevices,
      enableAllDevices: enableAllDevices ?? this.enableAllDevices,
      enabledChannels: enabledChannels ?? this.enabledChannels,
      enableAllChannels: enableAllChannels ?? this.enableAllChannels,
      enabledFolders: enabledFolders ?? this.enabledFolders,
      enableAllFolders: enableAllFolders ?? this.enableAllFolders,
      invalidLoginAttemptCount:
          invalidLoginAttemptCount ?? this.invalidLoginAttemptCount,
      loginAttemptsBeforeLockout:
          loginAttemptsBeforeLockout ?? this.loginAttemptsBeforeLockout,
      maxActiveSessions: maxActiveSessions ?? this.maxActiveSessions,
      enablePublicSharing: enablePublicSharing ?? this.enablePublicSharing,
      blockedMediaFolders: blockedMediaFolders ?? this.blockedMediaFolders,
      blockedChannels: blockedChannels ?? this.blockedChannels,
      remoteClientBitrateLimit:
          remoteClientBitrateLimit ?? this.remoteClientBitrateLimit,
      authenticationProviderId:
          authenticationProviderId ?? this.authenticationProviderId,
      passwordResetProviderId:
          passwordResetProviderId ?? this.passwordResetProviderId,
      syncPlayAccess: syncPlayAccess ?? this.syncPlayAccess,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'isAdministrator': isAdministrator,
      'isHidden': isHidden,
      'enableCollectionManagement': enableCollectionManagement,
      'enableSubtitleManagement': enableSubtitleManagement,
      'enableLyricManagement': enableLyricManagement,
      'isDisabled': isDisabled,
      'maxParentalRating': maxParentalRating,
      'maxParentalSubRating': maxParentalSubRating,
      'blockedTags': blockedTags,
      'allowedTags': allowedTags,
      'enableUserPreferenceAccess': enableUserPreferenceAccess,
      'accessSchedules': accessSchedules?.map((x) => x.toMap()).toList(),
      'blockUnratedItems': blockUnratedItems,
      'enableRemoteControlOfOtherUsers': enableRemoteControlOfOtherUsers,
      'enableSharedDeviceControl': enableSharedDeviceControl,
      'enableRemoteAccess': enableRemoteAccess,
      'enableLiveTvManagement': enableLiveTvManagement,
      'enableLiveTvAccess': enableLiveTvAccess,
      'enableMediaPlayback': enableMediaPlayback,
      'enableAudioPlaybackTranscoding': enableAudioPlaybackTranscoding,
      'enableVideoPlaybackTranscoding': enableVideoPlaybackTranscoding,
      'enablePlaybackRemuxing': enablePlaybackRemuxing,
      'forceRemoteSourceTranscoding': forceRemoteSourceTranscoding,
      'enableContentDeletion': enableContentDeletion,
      'enableContentDeletionFromFolders': enableContentDeletionFromFolders,
      'enableContentDownloading': enableContentDownloading,
      'enableSyncTranscoding': enableSyncTranscoding,
      'enableMediaConversion': enableMediaConversion,
      'enabledDevices': enabledDevices,
      'enableAllDevices': enableAllDevices,
      'enabledChannels': enabledChannels,
      'enableAllChannels': enableAllChannels,
      'enabledFolders': enabledFolders,
      'enableAllFolders': enableAllFolders,
      'invalidLoginAttemptCount': invalidLoginAttemptCount,
      'loginAttemptsBeforeLockout': loginAttemptsBeforeLockout,
      'maxActiveSessions': maxActiveSessions,
      'enablePublicSharing': enablePublicSharing,
      'blockedMediaFolders': blockedMediaFolders,
      'blockedChannels': blockedChannels,
      'remoteClientBitrateLimit': remoteClientBitrateLimit,
      'authenticationProviderId': authenticationProviderId,
      'passwordResetProviderId': passwordResetProviderId,
      'syncPlayAccess': syncPlayAccess,
    }.map((k, v) => MapEntry(k.capitalizeFirst, v));
  }

  factory UserPolicy.fromMap(Map<String, dynamic> map) {
    return UserPolicy(
      isAdministrator: map['isAdministrator'] ?? false,
      isHidden: map['isHidden'] ?? false,
      enableCollectionManagement: map['enableCollectionManagement'] ?? false,
      enableSubtitleManagement: map['enableSubtitleManagement'] ?? false,
      enableLyricManagement: map['enableLyricManagement'] ?? false,
      isDisabled: map['isDisabled'] ?? false,
      maxParentalRating: map['maxParentalRating'] != null
          ? map['maxParentalRating'] as int
          : null,
      maxParentalSubRating: map['maxParentalSubRating'] != null
          ? map['maxParentalSubRating'] as int
          : null,
      blockedTags: map['blockedTags'] != null
          ? List<String>.from((map['blockedTags']))
          : null,
      allowedTags: map['allowedTags'] != null
          ? List<String>.from((map['allowedTags']))
          : null,
      enableUserPreferenceAccess: map['enableUserPreferenceAccess'] ?? false,
      accessSchedules: map['accessSchedules'] != null
          ? List<AccessSchedule>.from(
              (map['accessSchedules']).map<AccessSchedule?>(
                (x) => AccessSchedule.fromMap(x as Map<String, dynamic>),
              ),
            )
          : null,
      blockUnratedItems: map['blockUnratedItems'] != null
          ? List<String>.from((map['blockUnratedItems']))
          : null,
      enableRemoteControlOfOtherUsers:
          map['enableRemoteControlOfOtherUsers'] ?? false,
      enableSharedDeviceControl: map['enableSharedDeviceControl'] ?? false,
      enableRemoteAccess: map['enableRemoteAccess'] ?? false,
      enableLiveTvManagement: map['enableLiveTvManagement'] ?? false,
      enableLiveTvAccess: map['enableLiveTvAccess'] ?? false,
      enableMediaPlayback: map['enableMediaPlayback'] ?? false,
      enableAudioPlaybackTranscoding:
          map['enableAudioPlaybackTranscoding'] ?? false,
      enableVideoPlaybackTranscoding:
          map['enableVideoPlaybackTranscoding'] ?? false,
      enablePlaybackRemuxing: map['enablePlaybackRemuxing'] ?? false,
      forceRemoteSourceTranscoding:
          map['forceRemoteSourceTranscoding'] ?? false,
      enableContentDeletion: map['enableContentDeletion'] ?? false,
      enableContentDeletionFromFolders:
          map['enableContentDeletionFromFolders'] != null
          ? List<String>.from(
              (map['enableContentDeletionFromFolders']),
            )
          : null,
      enableContentDownloading: map['enableContentDownloading'] ?? false,
      enableSyncTranscoding: map['enableSyncTranscoding'] ?? false,
      enableMediaConversion: map['enableMediaConversion'] ?? false,
      enabledDevices: map['enabledDevices'] != null
          ? List<String>.from((map['enabledDevices']))
          : null,
      enableAllDevices: map['enableAllDevices'] ?? false,
      enabledChannels: map['enabledChannels'] != null
          ? List<String>.from((map['enabledChannels']))
          : null,
      enableAllChannels: map['enableAllChannels'] ?? false,
      enabledFolders: map['enabledFolders'] != null
          ? List<String>.from((map['enabledFolders']))
          : null,
      enableAllFolders: map['enableAllFolders'] ?? false,
      invalidLoginAttemptCount: map['invalidLoginAttemptCount'] ?? 0,
      loginAttemptsBeforeLockout: map['loginAttemptsBeforeLockout'] ?? 0,
      maxActiveSessions: map['maxActiveSessions'] ?? 0,
      enablePublicSharing: map['enablePublicSharing'] ?? false,
      blockedMediaFolders: map['blockedMediaFolders'] != null
          ? List<String>.from((map['blockedMediaFolders']))
          : null,
      blockedChannels: map['blockedChannels'] != null
          ? List<String>.from((map['blockedChannels']))
          : null,
      remoteClientBitrateLimit: map['remoteClientBitrateLimit'] ?? 0,
      authenticationProviderId: map['authenticationProviderId'] ?? '',
      passwordResetProviderId: map['passwordResetProviderId'] ?? '',
      syncPlayAccess: map['syncPlayAccess'] ?? 'CreateAndJoinGroups',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserPolicy.fromJson(String source) =>
      UserPolicy.fromMap(json.decode(source) as Map<String, dynamic>);
}
