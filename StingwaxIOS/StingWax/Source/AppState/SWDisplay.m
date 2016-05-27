//
// Display.m
//

#import "SWDisplay.h"

#import "SWHelper.h"


@implementation SWDisplay

#pragma mark - Object lifecycle

- (id)init
{
    self = [super init];
	if (self) {
		
		//iPhone, iPhone5 or iPad!
		[self iPhoneOriPadOriPhone5];
        [SWHelper logPrintRect:[UIScreen mainScreen].bounds withPropertyName:[NSString stringWithFormat:@"Device %@ : ",_padPhoneOrPhone5]];
	}
	
	return self;
}


#pragma mark - Methods

- (void) iPhoneOriPadOriPhone5
{	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        self.appDeviceType	= AppDeviceTypeiPad;
        self.isPad			= YES;
        self.isPhone		= NO;
		[self iPad];
	}
    else {
        if  ([UIScreen mainScreen].bounds.size.height > 480.0f) {
            self.appDeviceType	= AppDeviceTypeiPhone5;
            self.isPad			= NO;
            self.isPhone		= YES;
            [self iPhone5];
        }
        else {
            self.appDeviceType	= AppDeviceTypeiPhone;
            self.isPad			= NO;
            self.isPhone		= YES;
            [self iPhone];
        }
	}
}

- (void)iPhone
{    
	_padOrPhone = @"phone";
    _padPhoneOrPhone5 = @"phone";
}

- (void)iPhone5
{
	_padOrPhone = @"phone";
    _padPhoneOrPhone5 = @"phone5";
}

- (void)iPad
{
	_padOrPhone = @"pad";
    _padPhoneOrPhone5 = @"pad";
}

@end
