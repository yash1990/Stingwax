//
//  Validator.m
//  IQLoginNRegister
//
//  Created by Jyotsna on 22/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "IQValidator.h"
@implementation IQValidator

/*
+ (BOOL) validateEmail:(IQEmailIDPattern) pattern emailID:(NSString *) emailID
{
	NSString *filterString;
	if(pattern==IQEmailIDPatternDefault) 
		filterString=@".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
	else 
		filterString=@"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
	
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", filterString];  
	return [emailTest evaluateWithObject:emailID]; 
}*/

+ (BOOL) validateEmail:(NSString *)emailID{
	
	NSString *newString = [emailID stringByReplacingOccurrencesOfString:@" " withString:@""];
	
	if([newString length] == [emailID length]){
		NSString *filterString;
		filterString=@"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
		NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", filterString];  
		return [emailTest evaluateWithObject:emailID]; 
	}
	return NO;
}

+ (BOOL) validatePassword:(IQPasswordPattern) pattern password:(NSString *)password{
	NSString *passwordRegEx;
	
	NSString *newString = [password stringByReplacingOccurrencesOfString:@" " withString:@""];
	
	if([newString length] == [password length]){
		
		if(pattern == IQPasswordPatternDefault){
			passwordRegEx = @"\\w*(\\w*[a-zA-Z0-9]){6,15}\\w*"; 
		}
		else if(pattern == IQPasswordPattern1UppChar){
			passwordRegEx = @"^(?=\\w*[a-zA-Z0-9])(?=\\w*[A-Z]).{6,15}$";
		}
		else if(pattern == IQPasswordPatternStrict){
			passwordRegEx = @"^(?=\\w*\\d)(?=\\w*[a-z])(?=\\w*[A-Z]).{6,15}$";
		}
		
		NSPredicate *passwordtest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", passwordRegEx];  
		return [passwordtest evaluateWithObject: password]; 
	}
	return NO;
}

+ (BOOL) validatePassword:(NSString *)password{
	
	NSString *passwordRegEx =@"[A-Za-z.0-9_-]{4,20}"; // @"\\w*(\\w*[a-zA-Z0-9].-_){4,20}\\w*"; //contain between 6 and 20 non-whitespace characters 
	NSPredicate *passwordtest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", passwordRegEx];  
	return [passwordtest evaluateWithObject: password]; 
}

+ (BOOL) validateState:(NSString *) state{
	
	NSArray * states = @[@"AL",	@"AK", 	@"AZ",	@"AR",	@"CA",	@"CT",	@"DE",	@"FL",	@"GA",	@"HI",	@"ID",	@"IL",	@"IN",	@"IA",	@"KS",	@"KY",	@"LA", @"ME",	@"MD",	@"MA",	@"MI",	@"MN",	@"MS",	@"MO",	@"MT",	@"NE",	@"NV",	@"NH",	@"NJ",	@"NM",	@"NY",	@"NC",	@"ND",	@"OH", @"OK",	@"OR",	@"PA",	@"RI",	@"SC",	@"SD",	@"TN",	@"TX",	@"UT",	@"VT",	@"VA",	@"WA",	@"WV",	@"WI",	@"WY",	@"DC",	@"AS", @"GU",	@"MP",	@"PR",	@"VI",	@"UM",	@"AE",	@"AA",	@"AP",	@"CO", @""];
	
	if([state length] < 2)
		return NO;
	int i = 0;
	for (i = 0; i < (NSInteger)[states count]; i++) {
		if ([state isEqualToString:states[i]]) {
			return YES;
        }
	}
	return NO;
}

+ (BOOL) validateZipCode:(NSString *) zipCode{
	
	NSString *zipRegEx = @"\\d{5}([\\-]\\d{4})?";
	NSPredicate *zipCodeValidator = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", zipRegEx];  
	return [zipCodeValidator evaluateWithObject: zipCode]; 
}

+ (BOOL) validatePhonenumber:(NSString *) phoneNumber{
	NSString *isDigitRegEx = @"^[0-9\\-]{1,}$";
	NSPredicate *digitValidator = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", isDigitRegEx];
	if([digitValidator evaluateWithObject:phoneNumber]){
		int count=0;
		for (int i = 0; i < (NSInteger)[phoneNumber length]; i++) {
			if ([phoneNumber characterAtIndex:i]=='-') {
				count++;
            }
		}
		if([phoneNumber length]-count>12)
			return NO;
		else
			return YES;
	}
	return NO;
}
+ (BOOL) validateUsername:(NSString *) username{

	NSString *usernameRegEx = @"[A-Za-z.0-9_-]{4,20}";
	NSPredicate *usernameValidator = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", usernameRegEx];
	return [usernameValidator evaluateWithObject:username];
}

+ (BOOL) validateURL:(NSString *) urlString{
	
	NSString *urlRegEx = @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
	
	NSPredicate *urlValidator = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
	return [urlValidator evaluateWithObject:urlString];
}

+ (BOOL) isDigit:(NSString *) string ofLength: (NSInteger)length{
	
	NSString *isDigitRegEx = [NSString stringWithFormat:@"[0-9]{%ld}",(long)length];
	NSPredicate *digitValidator = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", isDigitRegEx];
	return [digitValidator evaluateWithObject:string];
}

+ (BOOL) isDigit:(NSString *) string{
	
	NSString *isDigitRegEx = @"[0-9]{1,}";
	NSPredicate *digitValidator = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", isDigitRegEx];
	return [digitValidator evaluateWithObject:string];
}

+ (BOOL) isDouble:(NSString *) string{
	NSString *isDoubleRegEx = @"(?!^0*$)(?!^0*\\.0*$)^\\d{1,5}(\\.\\d{1,2})?$";
	NSPredicate *doubleValidator = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", isDoubleRegEx];
	return [doubleValidator evaluateWithObject:string];
}

+ (BOOL) validateTemperature:(NSString *) string{
	NSString *isDoubleRegEx = @"^-?\\d{1,5}(\\.\\d{1,2})?$";
	NSPredicate *doubleValidator = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", isDoubleRegEx];
	return [doubleValidator evaluateWithObject:string];
}

+ (BOOL) isString:(NSString *) string{
	
	NSString *isStringRegEx = @"[a-zA-Z\\s]{1,}";
	NSPredicate *stringValidator = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", isStringRegEx];
	return [stringValidator evaluateWithObject:string];
}

+ (BOOL) isString:(NSString *)string ofLength:(NSInteger) length{
	
	NSString *isStringRegEx = [NSString stringWithFormat:@"[a-zA-Z\\s]{1,%ld}",(long)length];
	NSPredicate *stringValidator = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", isStringRegEx];
	return [stringValidator evaluateWithObject:string];
}

@end
