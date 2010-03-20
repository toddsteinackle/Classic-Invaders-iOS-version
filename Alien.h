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
}

- (id)initWithPixelLocation:(CGPoint)aLocation dx:(float)dx dy:(float)dy position:(int)position canFire:(bool)canFire chanceToFire:(int)chanceToFire;
- (void)movement:(float)aDelta;
- (void)doAlienLogic;
- (void)description;

@end
