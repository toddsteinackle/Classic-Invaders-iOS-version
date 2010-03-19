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

@property (assign, nonatomic) bool hit_;

- (void)movement:(float)aDelta;

@end
