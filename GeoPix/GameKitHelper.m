//
//  GameKitHelper.m
//  GeoPix
//
//  Created by Brian Halderman on 5/10/14.
//  Copyright (c) 2014 Devoir Software. All rights reserved.
//

#import "GameKitHelper.h"

@implementation GameKitHelper

static GKLocalPlayer* _localPlayer;

+(GKLocalPlayer*) localPlayer {
    return _localPlayer;
}

+ (void) authenticateLocalPlayerWithViewController:(UIViewController*)viewController
{
    _localPlayer = [GKLocalPlayer localPlayer];
    _localPlayer.authenticateHandler = ^(UIViewController *VCAuthenticate, NSError *error){
        if (VCAuthenticate != nil)
        {
            [viewController presentViewController:VCAuthenticate animated:YES completion:nil];
        }
    };
}

@end
