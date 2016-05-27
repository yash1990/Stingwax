
#import <Foundation/Foundation.h>

static inline BOOL isNull(id object)
{
    BOOL isNull = NO;
    if (object == nil || object == [NSNull null])
    {
        isNull = YES;
    }
    return isNull;
}

static inline BOOL isEmpty(id object)
{
    BOOL isEmpty = NO;
    if (isNull(object) == YES
        || ([object respondsToSelector: @selector(length)] && [object length] == 0)
        || ([object respondsToSelector: @selector(count)] && [object count] == 0))
    {
        isEmpty = YES;
    }
    
    return isEmpty;
}

@interface NSObject (NSObject_Expanded)

- (void)performBlock:(dispatch_block_t)block afterDelay:(NSTimeInterval)delay;
- (void)performBlockOnMainThread:(dispatch_block_t)block;
- (void)performBlockInBackground:(dispatch_block_t)block;

- (BOOL)isEmpty;

@end
