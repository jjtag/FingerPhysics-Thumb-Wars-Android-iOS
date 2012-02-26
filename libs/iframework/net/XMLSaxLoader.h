//
//  XMLLoader.h
//  blockit
//
//  Created by Efim Voinov on 12.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Loader.h"
#import "XMLParser.h"

// XML sax loader/parser class
@interface XMLSaxLoader : Loader <LoaderDelegate>
{
	XMLParser* parser;
	id delegate;	
}

@property (assign) id delegate;

-(void)loaderFinishedWith:(NSMutableData*)data from:(NSString*)url withSuccess:(BOOL)success;

@end
