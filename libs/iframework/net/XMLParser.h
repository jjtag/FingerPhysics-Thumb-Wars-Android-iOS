//
//  XMLParser.h
//  rogatka
//
//  Created by Efim Voinov on 31.07.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

// xml sax parser wrapper
@interface XMLParser : NSObject 
{
	NSXMLParser* nsparser;
	id delegate;	
}

-(void)parseData:(NSData*)data;

@property (assign) id delegate;
@property (readonly) NSXMLParser* nsparser;

@end
