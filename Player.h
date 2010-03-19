//
//  Player.h
//  ClassicInvaders
//
//  Created by Todd Steinackle on 3/16/10.
//  Copyright 2010 The No Quarter Arcade. All rights reserved.
//

#import "AbstractEntity.h"


@interface Player : AbstractEntity {

    int playerInitialXShotPostion_;
    int playerInitialYShotPostion_;

}

@property (nonatomic, assign) int playerInitialXShotPostion_;
@property (nonatomic, assign) int playerInitialYShotPostion_;

- (void)movement:(float)aDelta;

@end
