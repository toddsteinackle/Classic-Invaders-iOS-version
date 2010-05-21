//
//  TBXMLParticleAdditions.m
//

#import "TBXMLParticleAdditions.h"


@implementation TBXML (TBXMLParticleAdditions)

- (float)floatValueFromChildElementNamed:(NSString*)aName parentElement:(TBXMLElement*)aParentXMLElement {
	TBXMLElement * xmlElement = [self childElementNamed:aName parentElement:aParentXMLElement];

	if (xmlElement) {
		return [[self valueOfAttributeNamed:@"value" forElement:xmlElement] floatValue];
	}

	return 0.0f;
}

- (BOOL)boolValueFromChildElementNamed:(NSString*)aName parentElement:(TBXMLElement*)aParentXMLElement {
	TBXMLElement * xmlElement = [self childElementNamed:aName parentElement:aParentXMLElement];

	if (xmlElement) {
		return [[self valueOfAttributeNamed:@"value" forElement:xmlElement] boolValue];
	}

	return NO;
}

- (Vector2f)vector2fFromChildElementNamed:(NSString*)aName parentElement:(TBXMLElement*)aParentXMLElement {
	TBXMLElement * xmlElement = [self childElementNamed:aName parentElement:aParentXMLElement];

	if (xmlElement) {
		float x = [[self valueOfAttributeNamed:@"x" forElement:xmlElement] floatValue];
		float y = [[self valueOfAttributeNamed:@"y" forElement:xmlElement] floatValue];
		return Vector2fMake(x, y);
	}

	return Vector2fMake(0, 0);
}

- (Color4f)color4fFromChildElementNamed:(NSString*)aName parentElement:(TBXMLElement*)aParentXMLElement {
	TBXMLElement * xmlElement = [self childElementNamed:aName parentElement:aParentXMLElement];

	if (xmlElement) {
		float red = [[self valueOfAttributeNamed:@"red" forElement:xmlElement] floatValue];
		float green = [[self valueOfAttributeNamed:@"green" forElement:xmlElement] floatValue];
		float blue = [[self valueOfAttributeNamed:@"blue" forElement:xmlElement] floatValue];
		float alpha = [[self valueOfAttributeNamed:@"alpha" forElement:xmlElement] floatValue];
		return Color4fMake(red, green, blue, alpha);
	}

	return Color4fMake(0, 0, 0, 0);
}

@end
