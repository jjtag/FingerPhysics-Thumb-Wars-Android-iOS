//
//  List.m
//  rogatka
//
//  Created by Efim Voinov on 26.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "List.h"

ListNode* listAdd(ListNode** p, id obj) 
{
	ListNode* n = malloc(sizeof(ListNode));
	if (!n)
	{
		return nil;
	}
	
	n->next = *p;
	*p = n;
	n->obj = obj;
	[n->obj retain];
	return *p;
}

void listRemove(ListNode** p)
{
	if (*p != nil)
	{
		ListNode* n = *p;
		*p = (*p)->next;
		[n->obj release];
		free(n);
	}
}

ListNode** listSearch(ListNode** n, id obj)
{
	while (*n != nil)
	{
		if ((*n)->obj == obj)
		{
			return n;
		}
		n = &(*n)->next;
	}
	return nil;
}