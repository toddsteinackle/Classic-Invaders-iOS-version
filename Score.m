//  Score.m

#import "Score.h"

#pragma mark -
#pragma mark Public implementation

@implementation Score

@synthesize score_;
@synthesize name_;
@synthesize wave_;
@synthesize isMostRecentScore_;

- (void)dealloc {
	[super dealloc];
}

- (id) initWithScore:(int)score name:(NSString*)name wave:(int)wave {
	self = [super init];
	if (self != nil) {
		self.score_ = score;
		self.name_ = name;
        self.wave_ = wave;
        self.isMostRecentScore_ = TRUE;
	}
	return self;
}

#pragma mark -
#pragma mark Encoding/Decoding

- (id)initWithCoder:(NSCoder *)aDecoder {
	// Decode the values we need to create a new Score instance
	int score = [aDecoder decodeIntForKey:@"score"];
	NSString *name = [aDecoder decodeObjectForKey:@"name"];
    int wave = [aDecoder decodeIntForKey:@"wave"];

	// Create a new instance of Score
	[self initWithScore:score name:name wave:wave];
    self.isMostRecentScore_ = FALSE;

	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeInt:self.score_ forKey:@"score"];
	[aCoder encodeObject:self.name_ forKey:@"name"];
    [aCoder encodeInt:self.wave_ forKey:@"wave"];
}

@end
