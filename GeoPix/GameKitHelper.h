//
//  GameKitHelper.h
//  GeoPix
//
//  Created by Brian Halderman on 5/10/14.
//  Copyright (c) 2014 Devoir Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@interface GameKitHelper : NSObject

+(GKLocalPlayer*) localPlayer;
+ (void) authenticateLocalPlayerWithViewController:(UIViewController*)viewController;

@end
