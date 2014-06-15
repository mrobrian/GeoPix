//
//  EnergyHelper.h
//  GeoPix
//
//  Created by Brian Halderman on 6/8/14.
//  Copyright (c) 2014 Devoir Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EnergyHelper : NSObject

+(BOOL)useEnergy:(NSInteger)amount;
+(BOOL)hasEnergy;
+(NSTimeInterval)nextEnergy;
+(NSInteger)currentEnergy;

@end
