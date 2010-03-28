//
//  Shot.h
//  ClassicInvaders
//
//  Created by Todd Steinackle on 3/17/10.
//  Copyright 2010 The No Quarter Arcade. All rights reserved.
//

#import "AbstractEntity.h"

@interface Shot : AbstractEntity {
    bool hit_;
}

@property (nonatomic, assign) bool hit_;

- (void)movementWithDelta:(float)aDelta;

@end
