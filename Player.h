//
//  Player.h
//  ClassicInvaders
//
//  Created by Todd Steinackle on 3/16/10.
//  Copyright 2010 The No Quarter Arcade. All rights reserved.
//

#import "AbstractEntity.h"

@interface Player : AbstractEntity {

    CGFloat playerInitialXShotPostion_;
    CGFloat playerInitialYShotPostion_;
    CGFloat rightScreenBoundary_;

}

@property (nonatomic, assign) CGFloat playerInitialXShotPostion_;
@property (nonatomic, assign) CGFloat playerInitialYShotPostion_;

- (void)movementWithDelta:(float)aDelta;

@end
