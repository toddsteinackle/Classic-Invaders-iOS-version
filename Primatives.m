//
//  Primatives.m
//

#import "Primatives.h"

@implementation Primatives

void drawBox(CGRect aRect) {

	GLfloat vertices[8];
	vertices[0] = aRect.origin.x;
	vertices[1] = aRect.origin.y;
	vertices[2] = aRect.origin.x + aRect.size.width;
	vertices[3] = aRect.origin.y;
	vertices[4] = aRect.origin.x + aRect.size.width;
	vertices[5] = aRect.origin.y + aRect.size.height;
	vertices[6] = aRect.origin.x;
	vertices[7] = aRect.origin.y + aRect.size.height;

	glDisableClientState(GL_COLOR_ARRAY);
	glDisable(GL_TEXTURE_2D);
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glDrawArrays(GL_LINE_LOOP, 0, 4);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnable(GL_TEXTURE_2D);

}

@end
