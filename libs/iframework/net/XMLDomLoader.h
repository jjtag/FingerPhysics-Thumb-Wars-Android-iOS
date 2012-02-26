//
//  XMLDomLoader.h
//  template
//
//  Created by Efim Voinov on 20.10.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Loader.h"
#import "XMLDocument.h"

@protocol XMLDomLoaderDelegate
-(void)xmlLoaderFinishedWith:(XMLNode*)rootNode from:(NSString*)url withSuccess:(BOOL)success;
@end

// XML dom loader/parser class
@interface XMLDomLoader : Loader <LoaderDelegate>
{
	XMLDocument* parser;
	id<XMLDomLoaderDelegate> delegate;	
}

@property (assign) id<XMLDomLoaderDelegate> delegate;

-(void)loaderFinishedWith:(NSMutableData*)data from:(NSString*)url withSuccess:(BOOL)success;

@end
