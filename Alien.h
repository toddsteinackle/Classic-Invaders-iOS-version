//
//  Alien.h
//  ClassicInvaders
//
//  Created by Todd Steinackle on 3/14/10.
//  Copyright 2010 Todd Steinackle. All rights reserved.
//

#import "AbstractEntity.h"


@interface Alien : AbstractEntity {
    int position, fire_chance; // used by Aliens to determine if and when to fire
    int points;
}

- (id)initWithLocation:(CGPoint)aLocation dx:(float)hspeed dy:(float)vspeed position:(int)pos fire_chance:(int)chance;

@end
