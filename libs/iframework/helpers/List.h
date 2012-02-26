//
//  List.h
//  rogatka
//
//  Created by Efim Voinov on 26.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

// lightweight c single-linked list
typedef struct ListNode
{
	id obj;
	struct ListNode* next;
} ListNode;

ListNode* listAdd(ListNode** p, id obj);
void listRemove(ListNode** p);
ListNode** listSearch(ListNode** n, id obj);
