//
//  PuzzleHelper.h
//  GeoPix
//
//  Created by Brian Halderman on 6/1/14.
//  Copyright (c) 2014 Devoir Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PuzzleHelper : NSObject

+(NSInteger)solvedPuzzlesForLocation:(NSString*)locationId;
+(void)solvedPuzzleForLocation:(NSString*)locationId withNumber:(NSInteger)number time:(NSInteger)seconds moves:(NSInteger)moves;
+(NSInteger)scoreForLocation:(NSString*)locationId withNumber:(NSInteger)number;
+(UIImage*)medalForScore:(NSInteger)score withTarget:(NSInteger)target;

@end
