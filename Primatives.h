/*
 *  Primitives.h
 *  SLQTSOR
 *
 *  Created by Mike Daley on 06/09/2009.
 *  Copyright 2009 Michael Daley. All rights reserved.
 *
 */

#import <objc/objc.h>
#import "Global.h"

@interface Primatives

@end

void drawPoly( CGPoint *poli, int points, BOOL closePolygon );
void drawBox(CGRect aRect);