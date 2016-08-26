//
//  HTJSONAdapter.h
//
//  Created by Pat Ren on 12-1-11.
//

// JSON序列化和反序列化接口

#import <Foundation/Foundation.h>

@interface NSString (JSONAdapter)
- (id)jsonValue;
@end

@interface NSData (JSONAdapter)
- (id)jsonValue;
@end

@interface NSDictionary (JSONAdapter)
- (NSString *)jsonString;
@end

@interface NSArray (JSONAdapter)
- (NSString *)jsonString;
@end
