//
//  FPBody.m
//  champions
//
//  Created by ikoryakin on 3/12/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "FPBody.h"

#define ANTIALIASED_OUTLINES

@implementation FPBody

@synthesize name;
@synthesize body;
@synthesize shapes;

@synthesize pos, massCenter;
@synthesize mass, angle, inertia;
@synthesize queue, outlineVertexCount, uniqId;
@synthesize isStatic, isFixedRotation, isTouchable, isBreakable, isPinned;
@synthesize blockColor, blockBackColor, outlineColor;
@synthesize userData;
@synthesize outlineVerts;

-(id)init
{
	if(self = [super init])
	{
		self.shapes = [[[DynamicArray alloc] init] autorelease];
		gravity = TRUE;
	}
	return self;
}

-(void)dealloc
{
//	for(b2Shape* shape = body->GetShapeList(); shape; shape = shape->GetNext())
//	{
//		float* texels = (float*)shape->GetUserData();
//		if(texels)
//			free(texels);
//	}
	[self releaseOutlineVerts];
	[sprite release];
	[lightTexture release];
	self.shapes = nil;
	[texture release];
	[super dealloc];
}

-(id)copyWithZone:(NSZone *)zone
{
	FPBody* copy = [[FPBody alloc] init];
	copy.angle = angle;
	copy.body = nil;
	copy.inertia = inertia;
	copy.isFixedRotation = isFixedRotation;
	copy.isStatic = isStatic;
	copy.mass = mass;
	copy.massCenter = massCenter;
	copy.name = [name copy];
	copy.pos = pos;
	copy.queue = queue;
	copy.isTouchable = isTouchable;
	copy.isBreakable = isBreakable;
	copy.shapes = [[[DynamicArray alloc] init] autorelease];
	copy.uniqId = uniqId;
	copy->force = force;
	copy->forceOffset = forceOffset;
	copy->charge = charge;
	copy->isExplodable = isExplodable;
	copy->force = force;
	copy->forceOffset = forceOffset;
	copy->arrowOffset = arrowOffset;
	
	for(int i = 0; i < [shapes count]; i++)
	{
		FPShape* shape = [[shapes objectAtIndex:i] copy];
		[copy.shapes addObject:shape];
		[shape release];
	}
	
	if(outlineVerts && outlineVertexCount > 0)
	{
		[copy allocOutlineVerts:outlineVertexCount];
		for (int i = 0; i < outlineVertexCount; i++)
		{
			copy.outlineVerts[i*2] = outlineVerts[i*2];
			copy.outlineVerts[i*2+1] = outlineVerts[i*2+1];
//			NSLog(@"ov %f %f", outlineVerts[i*2], outlineVerts[i*2+1]);			
		}
	}
	return copy;
}

-(void)update:(TimeType)delta
{
	if(sprite)
		[sprite update:delta];
}

-(void)setSprite:(Image*)spr
{
	[sprite release];
	sprite = [spr retain];
}

-(void)setTexelsForTexture:(Texture2D*)t
{
	b2Vec2 min_offset = b2Vec2_zero;
	b2Vec2 firstShapeOffset = b2Vec2_zero;
	
	for(b2Shape* shape = body->GetShapeList(); shape; shape = shape->GetNext())
	{
		switch (shape->GetType()) {
			case e_circleShape:
			{
				b2CircleShape* circle = (b2CircleShape*)shape;
				
				b2Vec2 center = b2Mul(body->GetXForm(), circle->GetLocalPosition());
				center *= PTM_RATIO;
				float32 radius = circle->GetRadius() * PTM_RATIO - 2;
				
				b2Vec2 minVect = b2Vec2(center.x - radius, center.y - radius);
				if(firstShapeOffset == b2Vec2_zero)
					firstShapeOffset = minVect;
				
				b2Vec2 offset = minVect - firstShapeOffset;
				min_offset = b2Min(min_offset, offset);
				
				float k_segments = 32;
				int vertexCount=32;
				const float32 k_increment = 2.0f * b2_pi / k_segments;
				float32 theta = 0.0f;
				
				GLfloat	glVertices[vertexCount*2];
				for (int32 i = 0; i < k_segments; i++)
				{
					b2Vec2 v = center + radius * b2Vec2(cosf(theta), sinf(theta));
					glVertices[i*2]=v.x;
					glVertices[i*2+1]=v.y;
					theta += k_increment;
				}
				
				float* texels = (float*)malloc(sizeof(float) * 2 * k_segments);
				[t setTexels:texels FromVertices:glVertices Count:k_segments];
				FPShape* shape = (FPShape*)circle->GetUserData();
				shape->texels = texels;
				
				for(int i = 0; i < k_segments; i++)
				{
					texels[i*2] += offset.x/t.realWidth;
					texels[i*2+1] += offset.y/t.realHeight;
				}
				break;
			}
			case e_polygonShape:
			{
				b2PolygonShape* poly = (b2PolygonShape*)shape;
				int32 vertexCount = poly->GetVertexCount();
				const b2Vec2* localVertices = poly->GetVertices();
				
				b2Assert(vertexCount <= b2_maxPolygonVertices);
				b2Vec2 vertices[b2_maxPolygonVertices];
				b2Vec2 minVect = b2Mul(body->GetXForm(), localVertices[0]);
				minVect *= PTM_RATIO;
				float glVertices[vertexCount*2];
				for (int i = 0; i < vertexCount; i++)
				{
					vertices[i] = b2Mul(body->GetXForm(), localVertices[i]);
					vertices[i] *= PTM_RATIO;
					glVertices[i*2] = vertices[i].x;
					glVertices[i*2+1] = vertices[i].y;

					minVect = b2Min(minVect, vertices[i]);
				}
				if(firstShapeOffset == b2Vec2_zero)
					firstShapeOffset = minVect;
				
				b2Vec2 offset =  minVect-firstShapeOffset;				
				min_offset = b2Min(min_offset, offset);

				
				float* texels = (float*)malloc(sizeof(float) * 2 * vertexCount);
				[t setTexels:texels FromVertices:glVertices Count:vertexCount];
				
				
				for(int i = 0; i < vertexCount; i++)
				{
					texels[i*2] += offset.x/t.realWidth;
					texels[i*2+1] += offset.y/t.realHeight;
				}
				FPShape* shape = (FPShape*)poly->GetUserData();
				shape->texels = texels;
				
				break;
			}
			default:
				break;
		}
	}
	
	for(b2Shape* shape = body->GetShapeList(); shape; shape = shape->GetNext())
	{
		FPShape* fpshape = (FPShape*)shape->GetUserData();
		float* texels =	(float*)fpshape->texels;
		
		switch (shape->GetType()) {
			case e_circleShape:
			{
				float k_segments = 32;				
				
				for(int i = 0; i < k_segments; i++)
				{
					texels[i*2] -= min_offset.x/t.realWidth;
					texels[i*2+1] -= min_offset.y/t.realHeight;
				}
				break;
			}
			case e_polygonShape:
			{
				b2PolygonShape* poly = (b2PolygonShape*)shape;
				int vertexCount = poly->GetVertexCount();
				for(int i = 0; i < vertexCount; i++)
				{
					texels[i*2] -= min_offset.x/t.realWidth;
					texels[i*2+1] -= min_offset.y/t.realHeight;
				}				
				break;
			}
			default:
				break;
		}
	}
	
}
-(void)setTexture:(Texture2D*)t
{
	[texture release];
	texture = [t retain];
	[self setTexelsForTexture:texture];
}

-(void)setLightTexture:(Texture2D*)t
{
	[lightTexture release];
	lightTexture = [t retain];
//	[self setTexelsForTexture:lightTexture];
}

-(void)calcOutlineWithSize:(float)size verts:(b2Vec2*)vertices vertexCount:(int)vertexCount vertsBuf:(float*)vertsBuf
{
	float vertsBuf2[2*vertexCount];
	
	for(int i = 0; i < 2*vertexCount; i++)
	{
		vertsBuf[i] = vertsBuf2[i] = 0;
	}
	
	for(int cntIndex = 0; cntIndex < vertexCount-1; cntIndex++)
	{	
		Vector v1 = vect(vertices[cntIndex].x,vertices[cntIndex].y);
		Vector v2 = vect(vertices[cntIndex+1].x,vertices[cntIndex+1].y);
		Vector vp =  vectNormalize(vectRperp(vectSub(v2, v1)));
		
		if(cntIndex!=vertexCount-2)
		{
			vertsBuf2[cntIndex*2+2] += vp.x;
			vertsBuf2[cntIndex*2+3] += vp.y;
		} else
		{
			vertsBuf2[vertexCount*2-2] += vp.x;
			vertsBuf2[vertexCount*2-1] += vp.y;
		}
		vertsBuf[cntIndex*2] += vp.x;
		vertsBuf[cntIndex*2+1] += vp.y;
	}
	Vector v1 = vect(vertices[vertexCount-1].x, vertices[vertexCount-1].y);
	Vector v2 = vect(vertices[0].x, vertices[0].y);
	Vector vp = vectSidePerp(v1, v2);
	Vector vp1 =vectAdd(vp, v1);	
	Vector vp2 =vectAdd(vp, v2);	
	
	vertsBuf[vertexCount*2-2]+=vp.x;
	vertsBuf[vertexCount*2-1]+=vp.y;
	vertsBuf2[0]+=vp.x;
	vertsBuf2[1]+=vp.y;
	
	
	for(int i = 0; i<vertexCount; i++)
	{
		Vector n1 = vect(vertsBuf[i*2], vertsBuf[i*2+1]);
		Vector n2 = vect(vertsBuf2[i*2], vertsBuf2[i*2+1]);
		Vector offset = vect(vertices[i].x, vertices[i].y);
		Vector result = vectMult( vectAdd(n1, n2), ( size/(1+vectDot(n1, n2)) ) );
		result = vectAdd(offset, result);
		vertsBuf[i*2] = result.x;
		vertsBuf[i*2+1] = result.y;
	}
}

-(void)drawOutline
{
	if(outlineVertexCount > 0)
	{
		float offX = body->GetPosition().x * PTM_RATIO;
		float offY = body->GetPosition().y * PTM_RATIO;
		
		glPushMatrix();
		glTranslatef(offX, offY, 0);
		glRotatef(RADIANS_TO_DEGREES(body->GetAngle()), 0, 0, 1);
		
#ifdef ANTIALIASED_OUTLINES		
		glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
		
		for (int c = 0; c < outlineVertexCount * 2 - 2; c += 2)
		{
			drawAntialiasedLine(outlineVerts[c], outlineVerts[c+1], outlineVerts[c+2], outlineVerts[c+3], 
								1.0, outlineColor);
		}

		drawAntialiasedLine(outlineVerts[outlineVertexCount * 2 - 2], outlineVerts[outlineVertexCount * 2 - 1], outlineVerts[0], outlineVerts[1], 
							1.0, outlineColor);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);		
#else		
		drawPolygon(outlineVerts, outlineVertexCount, outlineColor);
#endif		
		glPopMatrix();
	}
}

-(void)drawShapesShadow
{
	RGBAColor shadowRGBA = MakeRGBA(0, 0, 0, 0.2);
	for(b2Shape* shape = body->GetShapeList(); shape; shape = shape->GetNext())
	{		
		switch (shape->GetType()) {
			case e_circleShape:
			{
				b2CircleShape* circle = (b2CircleShape*)shape;
				
				b2Vec2 center = b2Mul(body->GetXForm(), circle->GetLocalPosition());
				center *= PTM_RATIO;
				float32 radius = circle->GetRadius() * PTM_RATIO;
				
				//Draw circle outline				
				float k_segments = 64;
				
				drawSolidCircle(center.x, center.y, radius, k_segments, transparentRGBA, shadowRGBA);
				break;
			}
			case e_polygonShape:
			{
				b2PolygonShape* poly = (b2PolygonShape*)shape;
				int32 vertexCount = poly->GetVertexCount();
				const b2Vec2* localVertices = poly->GetVertices();
				b2Assert(vertexCount <= b2_maxPolygonVertices);
				b2Vec2 vertices[b2_maxPolygonVertices];
				
				GLfloat	glVertices[vertexCount*2];
				for (int32 i = 0; i < vertexCount; i++)
				{
					vertices[i] = b2Mul(body->GetXForm(), localVertices[i]);
					vertices[i] *= PTM_RATIO;					
					glVertices[i*2] = vertices[i].x;
					glVertices[i*2+1] = vertices[i].y;

				}				
				drawSolidPolygon(glVertices, vertexCount, transparentRGBA, shadowRGBA);
				break;
			}
			default:
				break;
		}
	}	
}


-(void)drawSolidBodyShape
{
	for(b2Shape* shape = body->GetShapeList(); shape; shape = shape->GetNext())
	{
		switch (shape->GetType()) {
			case e_circleShape:
			{
				b2CircleShape* circle = (b2CircleShape*)shape;
				
				b2Vec2 center = b2Mul(body->GetXForm(), circle->GetLocalPosition());
				center *= PTM_RATIO;
				float32 radius = circle->GetRadius() * PTM_RATIO;
				
				//Draw circle outline				
				int k_segments = 32;

				drawSolidCircle(center.x, center.y, radius - 1.0, k_segments, outlineColor, outlineColor);
				break;
			}
			case e_polygonShape:
			{
				b2PolygonShape* poly = (b2PolygonShape*)shape;
				int vertexCount = poly->GetVertexCount();
				const b2Vec2* localVertices = poly->GetVertices();
				b2Assert(vertexCount <= b2_maxPolygonVertices);
				b2Vec2 vertices[b2_maxPolygonVertices];

				float glVertices[vertexCount*2];
				
				for (int i = 0; i < vertexCount; i++)
				{
					vertices[i] = b2Mul(body->GetXForm(), localVertices[i]);
					vertices[i] *= PTM_RATIO;			
					glVertices[i*2] = vertices[i].x;
					glVertices[i*2+1] = vertices[i].y;
				}
				
				drawSolidPolygonWOBorder(glVertices, vertexCount, blockBackColor);
				break;
			}
			default:
				break;
		}
	}	
}

-(void)drawTexture
{
	for(b2Shape* shape = body->GetShapeList(); shape; shape = shape->GetNext())
	{
		switch (shape->GetType()) {
			case e_circleShape:
			{
				b2CircleShape* circle = (b2CircleShape*)shape;
				
				b2Vec2 center = b2Mul(body->GetXForm(), circle->GetLocalPosition());
				center *= PTM_RATIO;
				float32 radius = circle->GetRadius() * PTM_RATIO;
			
				//Draw circle outline
				int k_segments = 32;
				FPShape* fpshape = (FPShape*)circle->GetUserData();
				float* texels = fpshape->texels;

				glPushMatrix();
				glTranslatef(center.x, center.y, 0);
				glRotatef(RADIANS_TO_DEGREES(body->GetAngle()), 0, 0, 1);
				glTranslatef(-center.x, -center.y, 0);
				drawTexturedCircle(center.x, center.y, radius, texels, k_segments, texture);
				glPopMatrix();

#ifdef ANTIALIASED_OUTLINES
				float glVertices[k_segments * 2];
				calcCircle(center.x, center.y, radius, k_segments, (float*)&glVertices);
				glDisable(GL_TEXTURE_2D);
				glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
				
				for (int c = 0; c < k_segments * 2 - 2; c += 2)
				{
					drawAntialiasedLine(glVertices[c], glVertices[c+1], glVertices[c+2], glVertices[c+3], 
										1.0, outlineColor);
				}
				
				drawAntialiasedLine(glVertices[k_segments * 2 - 2], glVertices[k_segments * 2 - 1], glVertices[0], glVertices[1], 
									1.0, outlineColor);								
				glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);						
#endif
				break;
			}
			case e_polygonShape:
			{
				b2PolygonShape* poly = (b2PolygonShape*)shape;
				int32 vertexCount = poly->GetVertexCount();
				const b2Vec2* localVertices = poly->GetVertices();
				b2Assert(vertexCount <= b2_maxPolygonVertices);
				b2Vec2 vertices[b2_maxPolygonVertices];
				GLfloat	glVertices[vertexCount*2];
				
				for (int i = 0; i < vertexCount; i++)
				{
					vertices[i] = b2Mul(body->GetXForm(), localVertices[i]);
					vertices[i] *= PTM_RATIO;
					glVertices[i*2] = vertices[i].x;
					glVertices[i*2+1] = vertices[i].y;

				}
				FPShape* fpshape = (FPShape*)poly->GetUserData();
				float* texels = (float*)fpshape->texels;
	
				if(texels)
				{
					[texture drawPolygon:glVertices Texels:texels Count:vertexCount Mode:GL_TRIANGLE_FAN];
				}
//				glDisable(GL_TEXTURE_2D);
//				b2AABB aabb;
//				shape->ComputeAABB(&aabb, body->GetXForm());
//				aabb.lowerBound.x *= PTM_RATIO;
//				aabb.lowerBound.y *= PTM_RATIO;
//				aabb.upperBound.x *= PTM_RATIO;
//				aabb.upperBound.y *= PTM_RATIO;
//				drawSegment(aabb.lowerBound.x, aabb.lowerBound.y, aabb.upperBound.x, aabb.lowerBound.y, redRGBA);
//				drawSegment(aabb.upperBound.x, aabb.lowerBound.y, aabb.upperBound.x, aabb.upperBound.y, blueRGBA);
//				drawSegment(aabb.upperBound.x, aabb.upperBound.y, aabb.lowerBound.x, aabb.upperBound.y, greenRGBA);
//				drawSegment(aabb.lowerBound.x, aabb.upperBound.y, aabb.lowerBound.x, aabb.lowerBound.y, blackRGBA);
//				drawPoint(body->GetWorldPoint(b2Vec2_zero).x * PTM_RATIO, body->GetWorldPoint(b2Vec2_zero).y * PTM_RATIO, 4, redRGBA);
//				glEnable(GL_TEXTURE_2D);
				break;
			}
			default:
				break;
		}
	}
}

-(void)drawBodyOutlines
{
	glDisable(GL_TEXTURE_2D);
	glColor4f(1, 1, 1, 1);
	[self drawOutline];
	glEnable(GL_BLEND);
}

-(void)drawHighlight
{
//	for(b2Shape* shape = body->GetShapeList(); shape; shape = shape->GetNext())
//	{
//		switch (shape->GetType()) {
//			case e_circleShape:
//			{
//				break;
//			}
//			case e_polygonShape:
//			{
//				b2PolygonShape* poly = (b2PolygonShape*)shape;
//				int32 vertexCount = poly->GetVertexCount();
//				const b2Vec2* localVertices = poly->GetVertices();
//				b2Assert(vertexCount <= b2_maxPolygonVertices);
//				b2Vec2 vertices[b2_maxPolygonVertices];
//				
//				for (int32 i = 0; i < vertexCount; ++i)
//				{
//					vertices[i] = b2Mul(body->GetXForm(), localVertices[i]);
//					vertices[i] *= PTM_RATIO;					
//				}
//				
//				GLfloat	glVertices[vertexCount*2];
//				for(int32 i = 0; i < vertexCount; i++)
//				{
//					glVertices[i*2] = vertices[i].x;
//					glVertices[i*2+1] = vertices[i].y;
//				}				
//				
//				float* texels = (float*)poly->GetUserData();
//				
//				if(texels)
//				{
//					[texture drawPolygon:glVertices Texels:texels Count:vertexCount Mode:GL_TRIANGLE_FAN];
//				}
//				
//				break;
//			}
//			default:
//				break;
//		}
//	}	
}

-(void)draw
{
	glColor4f(1, 1, 1, 1);
	
	if(!sprite)
	{

//		glShadeModel(GL_SMOOTH);
		glDisable(GL_TEXTURE_2D);
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		
//		glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
//		glEnable(GL_LINE_SMOOTH);
		[self drawSolidBodyShape];
//		glDisable(GL_LINE_SMOOTH);
		glEnable(GL_TEXTURE_2D);
		glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);		
		glColor4f(blockColor.r, blockColor.g, blockColor.b, blockColor.a);
//		if(isStatic || (isTouchable && !isBreakable))
			[self drawTexture];
		
//		[self drawHighlight];
		
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		[self drawBodyOutlines];	
//		glDisable(GL_LINE_SMOOTH);
		
		glColor4f(1, 1, 1, 1);
		glDisable(GL_BLEND);
//		glShadeModel(GL_FLAT);
		
	}
	else
	{
		glEnable(GL_TEXTURE_2D);
		glEnable(GL_BLEND);
		glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
		
		sprite->rotation = RADIANS_TO_DEGREES(body->GetAngle());
		b2Vec2 p = body->GetPosition();
		p *= PTM_RATIO;
		sprite->x = p.x;
		sprite->y = p.y;
		[sprite draw];
		glDisable(GL_TEXTURE_2D);
		glDisable(GL_BLEND);
	}

	if(arrowTexture)
	{
		b2Vec2 worldsGravity = body->GetWorld()->GetGravity();
		glEnable(GL_TEXTURE_2D);
		glEnable(GL_BLEND);
		glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);		
		b2Vec2 arrow = body->GetWorldCenter() + b2Vec2(arrowOffset.x, arrowOffset.y);
		arrow *= PTM_RATIO;
		float rot = RADIANS_TO_DEGREES(atan2(force.x + worldsGravity.x, -force.y - worldsGravity.y))+90;
		glPushMatrix();
		Vector center = vect(arrow.x, arrow.y);
		glTranslatef(center.x, center.y, 0);
		glRotatef(rot, 0, 0, 1);
		glTranslatef(-center.x, -center.y, 0);		
		drawImage(arrowTexture, center.x - arrowTexture.realHeight/2, center.y - arrowTexture.realWidth/2);
		glPopMatrix();
		glDisable(GL_TEXTURE_2D);
		glDisable(GL_BLEND);
	}
}

-(void)allocOutlineVerts:(int)vertexCount
{
	ASSERT(outlineVertexCount == 0);
	outlineVertexCount = vertexCount;
	if(outlineVertexCount > 0)
	{
		outlineVerts = (float*)malloc(sizeof(float)*outlineVertexCount*2);
	}
}

-(void)releaseOutlineVerts
{
	if(outlineVertexCount > 0)
	{
		free(outlineVerts);
		outlineVerts = nil;
		outlineVertexCount = 0;
	}
}

@end
