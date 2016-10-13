/* cocos2d for iPhone
 *
 * http://code.google.com/p/cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "TextureMgr.h"
#import "Sprite.h"
#import "ccMacros.h"
#import "Support/CGPointExtension.h"

#pragma mark Sprite

@interface Sprite (Private)
// lazy allocation
-(void) initAnimationDictionary;
@end

@implementation Sprite

@synthesize autoCenterFrames = _autoCenterFrames;

#pragma mark Sprite - image file
+ (id) spriteWithFile:(NSString*) filename
{
	return [[[self alloc] initWithFile:filename] autorelease];
}

- (id) initWithFile:(NSString*) filename
{
	self = [super init];
	if( self ) {
		// texture is retained
		self.texture = [[TextureMgr sharedTextureMgr] addImage: filename];
		
		CGSize s = self.texture.contentSize;
		transformAnchor = ccp(s.width/2, s.height/2);
		_autoCenterFrames = NO;
		
		// lazy alloc
		animations = nil;
	}
	
	return self;
}

#pragma mark Sprite - PVRTC RAW

+ (id) spriteWithPVRTCFile: (NSString*) fileimage bpp:(int)bpp hasAlpha:(BOOL)alpha width:(int)w
{
	return [[[self alloc] initWithPVRTCFile:fileimage bpp:bpp hasAlpha:alpha width:w] autorelease];
}

- (id) initWithPVRTCFile: (NSString*) fileimage bpp:(int)bpp hasAlpha:(BOOL)alpha width:(int)w
{
	if((self=[super init])) {
		// texture is retained
		self.texture = [[TextureMgr sharedTextureMgr] addPVRTCImage:fileimage bpp:bpp hasAlpha:alpha width:w];
		
		CGSize s = self.texture.contentSize;
		transformAnchor = ccp(s.width/2, s.height/2);
		_autoCenterFrames = NO;

		// lazy alloc
		animations = nil;
	}
	
	return self;
}

#pragma mark Sprite - CGImageRef

+ (id) spriteWithCGImage: (CGImageRef) image
{
	return [[[self alloc] initWithCGImage:image] autorelease];
}

- (id) initWithCGImage: (CGImageRef) image
{
	self = [super init];
	if( self ) {
		// texture is retained
		self.texture = [[TextureMgr sharedTextureMgr] addCGImage: image];
		
		CGSize s = self.texture.contentSize;
		transformAnchor = ccp(s.width/2, s.height/2);
		_autoCenterFrames = NO;

		// lazy alloc
		animations = nil;
	}
	
	return self;
}

#pragma mark Sprite - Texture2D

+ (id)  spriteWithTexture:(Texture2D*) tex
{
	return [[[self alloc] initWithTexture:tex] autorelease];
}

- (id) initWithTexture:(Texture2D*) tex
{
	if( (self = [super init]) ) {
		// texture is retained
		self.texture = tex;
		
		CGSize s = self.texture.contentSize;
		transformAnchor = ccp(s.width/2, s.height/2);
		_autoCenterFrames = NO;
		
		// lazy alloc
		animations = nil;
	}
	return self;
}	

#pragma mark Sprite - TextureNode override

-(void) setTexture: (Texture2D *) aTexture
{
	super.texture = aTexture;
}

#pragma mark Sprite

-(void) dealloc
{
	[animations release];
	[super dealloc];
}

-(void) initAnimationDictionary
{
	animations = [[NSMutableDictionary dictionaryWithCapacity:2] retain];
}

//
// CocosNodeFrames protocol
//
-(void) setDisplayFrame:(id)frame
{
	self.texture = frame;
	
	if( _autoCenterFrames ) {
		CGSize s = self.texture.contentSize;
		self.transformAnchor = ccp(s.width/2, s.height/2);
	}
}

-(void) setDisplayFrame: (NSString*) animationName index:(int) frameIndex
{
	if( ! animations )
		[self initAnimationDictionary];
	
	Animation *a = [animations objectForKey: animationName];
	Texture2D *frame = [[a frames] objectAtIndex:frameIndex];
	self.texture = frame;
	
	if( _autoCenterFrames ) {
		CGSize s = self.texture.contentSize;
		self.transformAnchor = ccp(s.width/2, s.height/2);
	}	
}

-(BOOL) isFrameDisplayed:(id)frame
{
	return texture == frame;
}
-(id) displayFrame
{
	return texture;
}
-(void) addAnimation: (id<CocosAnimation>) anim
{
	// lazy alloc
	if( ! animations )
		[self initAnimationDictionary];
	
	[animations setObject:anim forKey:[anim name]];
}
-(id<CocosAnimation>)animationByName: (NSString*) animationName
{
	NSAssert( animationName != nil, @"animationName parameter must be non nil");
    return [animations objectForKey:animationName];
}
@end

#pragma mark -
#pragma mark Animation

@implementation Animation
@synthesize name, delay, frames;

+(id) animationWithName:(NSString*)n delay:(float)d
{
	return [[[self alloc] initWithName:n delay:d] autorelease];
}

-(id) initWithName: (NSString*) n delay:(float)d
{
	return [self initWithName:n delay:d firstImage:nil vaList:nil];
}

-(void) dealloc
{
	CCLOG( @"deallocing %@",self);
	[name release];
	[frames release];
	[super dealloc];
}

#pragma mark Animation - image files

+(id) animationWithName: (NSString*) name delay:(float)delay images:image1,...
{
	va_list args;
	va_start(args,image1);
	
	id s = [[[self alloc] initWithName:name delay:delay firstImage:image1 vaList:args] autorelease];
	
	va_end(args);
	return s;
}

-(id) initWithName: (NSString*) n delay:(float)d firstImage:(NSString*)image vaList: (va_list) args
{
	if( ! (self=[super init]) )
		return nil;
	
	name = [n retain];
	frames = [[NSMutableArray array] retain];
	delay = d;

	if( image ) {
		Texture2D *tex = [[TextureMgr sharedTextureMgr] addImage: image];
		[frames addObject:tex];

		NSString *filename = va_arg(args, NSString*);
		while(filename) {
			tex = [[TextureMgr sharedTextureMgr] addImage: filename];
			[frames addObject:tex];
		
			filename = va_arg(args, NSString*);
		}	
	}
	return self;
}

-(void) addFrame: (NSString*) filename
{
	return [self addFrameWithFilename:filename];
}
-(void) addFrameWithFilename: (NSString*) filename
{
	Texture2D *tex = [[TextureMgr sharedTextureMgr] addImage: filename];
	[frames addObject:tex];
}

#pragma mark Animation - Texture2D

+(id) animationWithName: (NSString*) name delay:(float)delay textures:tex1,...
{
	va_list args;
	va_start(args,tex1);
	
	id s = [[[self alloc] initWithName:name delay:delay firstTexture:tex1 vaList:args] autorelease];
	
	va_end(args);
	return s;
}

-(id) initWithName:(NSString*)n delay:(float)d firstTexture:(Texture2D*)tex vaList:(va_list)args
{
	self = [super init];
	if( self ) {
		name = [n retain];
		frames = [[NSMutableArray array] retain];
		delay = d;
		
		if( tex ) {
			[frames addObject:tex];
			
			Texture2D *newTex = va_arg(args, Texture2D*);
			while(newTex) {
				[frames addObject:newTex];
				
				newTex = va_arg(args, Texture2D*);
			}	
		}
	}
	return self;
}

-(void) addFrameWithTexture: (Texture2D*) tex
{
	[frames addObject:tex];
}

@end

