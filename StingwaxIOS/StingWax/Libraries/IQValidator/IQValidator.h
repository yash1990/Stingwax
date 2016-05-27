//
//  Validator.h
//  IQLoginNRegister
//
//  Created by Jyotsna on 22/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	IQEmailIDPatternDefault=0,
	IQEmailIDPatternStrict,
} IQEmailIDPattern;

typedef enum{
	IQPasswordPatternDefault=0,  /*  password must cantain at least 6 characters and at most 15 characters. */
	IQPasswordPattern1UppChar,   /*  Password must contain at least one Upper case character. */
	IQPasswordPatternStrict,     /*  Password must contain one upper case letter and a digit. */
} IQPasswordPattern;

@interface IQValidator : NSObject {
	
}

//+ (BOOL) validateEmail:(IQEmailIDPattern) pattern emailID:(NSString *) emailID;     /*  validate Emailid */
+ (BOOL) validatePassword:(IQPasswordPattern) pattern password:(NSString *) password; /*  validatepassword  */
+ (BOOL) validateEmail:(NSString *) emailID;										  /*  validate Emailid with default pattern  */
+ (BOOL) validatePassword:(NSString *) password;									  /*  validate password with default pattern  */

+ (BOOL) validateUsername:(NSString *) username;									  /*  validate username  */
+ (BOOL) validateURL:(NSString *) urlString;										  /*  validate url formate, starts from http */	
+ (BOOL) isDigit:(NSString *) string ofLength:(NSInteger ) length;					  /*  check given string is digit and of the length  */
+ (BOOL) isDigit:(NSString *) string;												  /*  check given string is digit of any length	*/
+ (BOOL) isDouble:(NSString *) string;
+ (BOOL) validateTemperature:(NSString *) string;
+ (BOOL) isString:(NSString *) string;												  /*  check given string is having only alphabets	*/
+ (BOOL) isString:(NSString *) string ofLength:(NSInteger ) length;				      /*  check given string is having only alphabets and of len length  */

//********* US formates *********//
//*******************************//
+ (BOOL) validateState:(NSString *) state;											/*  validate all states of US */
+ (BOOL) validateZipCode:(NSString *) zipCode;										/*	validate us formates of zipcode  */ 
+ (BOOL) validatePhonenumber:(NSString *) phoneNumber;								/*  all phone number formates of US */
@end
