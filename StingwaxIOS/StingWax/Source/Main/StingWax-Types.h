//
//  StingWax-Types.h
//  StingWax
//
//  Created by Mark Perkins on 6/18/13.
//
//

typedef enum AppDeviceType {
    AppDeviceTypeUnknown = 0,
    AppDeviceTypeiPhone = 1,
    AppDeviceTypeiPad = 2,
    AppDeviceTypeiPhone5 = 3,
} AppDeviceType;


typedef enum AppAlertType {
    AppAlertTypeUnknown = 0,
    AppAlertTypeInternetUnavailable = 1,
    AppAlertTypeSubscriptionFinished = 2,
    AppAlertTypeInternetRequired = 3,
    AppAlertTypeMaxSongChangesReached = 4,
} AppAlertType;

typedef enum PlayerStatus {
    PlayerStatusUnknown = 0,
    PlayerStatusPlayListLoading,
    PlayerStatusPlayListLoaded,
    PlayerStatusWaiting,
    PlayerStatusPlaying,
    PlayerStatusStopped,
    PlayerStatusPaused,
    PlayerStatusNetworkError,
    PlayerStatusError,
} PlayerStatus;

typedef enum PlayerRequest {
    PlayerRequestUnknown = 0,
    PlayerRequestPlay,
    PlayerRequestPause,
    PlayerRequestNext,
    PlayerRequestPrevious,
} PlayerRequest;
