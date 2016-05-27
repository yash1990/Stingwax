//
// Display.h
//

#import <Foundation/Foundation.h>

#import "StingWax-Types.h"

@interface SWDisplay : NSObject

- (void)iPhone;
- (void)iPhone5;
- (void)iPad;

@property (nonatomic, assign) BOOL isPad;
@property (nonatomic, assign) BOOL isPhone;
@property (nonatomic, assign) AppDeviceType appDeviceType;
@property (nonatomic, strong) NSString *padOrPhone;
@property (nonatomic, strong) NSString *padPhoneOrPhone5;

@end
