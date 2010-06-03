//
//  Alien.h
//  ClassicInvaders
//
//  Created by Todd Steinackle on 3/14/10.
//  Copyright 2010 Todd Steinackle. All rights reserved.
//

#import "AbstractEntity.h"


@interface Alien : AbstractEntity {
    int position_, fireChance_; // used by Aliens to determine if and when to fire
    int points_;
    bool canFire_;
    CGFloat alienInitialXShotPostion_;
    CGFloat alienInitialYShotPostion_;
    CGFloat alienDropDown_;
}

@property (nonatomic, assign) int position_;
@property (nonatomic, assign) bool canFire_;
@property (nonatomic, assign) int fireChance_;
@property (nonatomic, assign) CGFloat alienInitialXShotPostion_;
@property (nonatomic, assign) CGFloat alienInitialYShotPostion_;

- (id)initWithPixelLocation:(CGPoint)aLocation
                         dx:(float)dx
                         dy:(float)dy
                   position:(int)position
                    canFire:(bool)canFire
               chanceToFire:(int)chanceToFire;

- (void)movementWithDelta:(float)aDelta;
- (void)doAlienLogic;
- (void)description;

@end
