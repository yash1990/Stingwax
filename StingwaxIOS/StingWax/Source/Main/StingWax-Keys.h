/*
 *  Constant.h
 *  StingWax
 *
 *  Created by Dhawal Dawar on 20/04/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

/**
 * Method name: <#name#>
 * Description: <#description#>
 * Parameters: <#parameters#>
 * Example Usage: <#example usage#>
 */


#import "SWAppDelegate.h"


// Values
#define kValueSiteRoot @"http://www.stingwax.com/" //base url of the server for playing streams
#define kValueReportedSongDelay 30 //number of seconds to delay song reporting to the server

// Logged User Defaults
#define kIsCurrentUserLoggedIn @"IsCurrentUserLoggedIn"
#define kIsUserRemembered @"isRememberedForStingWax"
#define kUserNameValue @"StingWaxUserEmail"
#define kPasswordValue @"StingWaxUserPassword"

#define kTabBarBadgeNumber @"getTabBarBadgeNumber" 
#define kNotificationForBadge @"kNotificationForBadge"

#define kLastLoggedInUser @"LastLoggedInUser"
#define kLastAuthToken  @"LastAuthToken"

//Defaults
#define kValueIsRemembered @"isRemembered"
#define kValueUserName @"email"
#define kValuePassword @"password"

//Notifications
#define NotifyInternetReachabilityAvailable @"NotifyInternetReachabilityAvailable"
#define NotifyInternetReachabilityUnavailable @"NotifyInternetReachabilityUnavailable"


//Load URL
#define kRegistrationURL        @"https://stingwax.com/mobile_registration.php"
#define kMyAccountURL           @"https://stingwax.com/"

// Alerts
#define INTERNET_ON_LAUNCH @"You must have an Internet Connection to use this application. Please connect to internet and try again."
#define INTERNET_UNAVAIL @"Internet connection not available. Please connect to Internet and try again."

#define SUBSCRIPTION_FINISH @"You have reached the maximum amount of hours for your subscription term. You can adjust your subscription online at www.stingwax.com."

#define SUBSCRIPTION_ACTIVATION @"Your Subscription has not activated"

#define SUBSCRIPTION_EXPIRED @"Sorry, your subscription has expired. Please visit www.stingwax.com to upgrade your subscription."



//#define MAX_SONG_CHANGES_REACHED @"You have reached the maximum number of song changes. You must listen to an entire song before being able to change songs again."
#define MAX_SONG_CHANGES_REACHED @"You cannot exceed 6 skips per hour on your current plan. For Unlimited skips, please upgrade to 50 hour or more plans."
