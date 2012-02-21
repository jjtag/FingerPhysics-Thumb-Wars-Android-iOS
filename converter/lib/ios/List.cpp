#include <jni.h>
#include "List.h"



List::List()
{
	first=nil;
	last=nil;
}


List::~List()
{
	del();
}


void List::del()
{
	node *p;
	while(first)
	{
		p=first;
		first=first->next;
		delete p;
	}
	last=nil;
}


void List::clear()
{
	del();
}


void List::push_back(IID inf)
{
	node *p=new node(inf);
	if(last==nil)
	{
		first=p;
		last=p;
	}
	else
	{
		p->previous=last;
		last->next=p;
		last=p;
	}
}


void List::push_front(IID inf)
{
	node *p=new node(inf);
	if(first==nil)
	{
		first=p;
		last=p;
	}
	else
	{
		p->next=first;
		first->previous=p;
		first=p;
	}
}


void List::pop_front()
{
	node *p=first;
	if(first->next!=nil)
		first=first->next;
	else
		first=last=nil;
	delete p;
}


void List::pop_back()
{
	node *p=last;
	if(last->previous!=nil)
		last=last->previous;
	else
		first=last=nil;
	delete p;
}


void List::insert(Iterator pos, IID inf)
{
	if(pos.position==nil)
	{
		push_back(inf);
		return;
	}
	node *p=new node(inf);
	node *after=pos.position;
	node *before=after->previous;
	p->previous=before;
	p->next=after;
	if(before==nil)
		first=p;
	else
		before->next=p;
}


void List::erase(Iterator pos)
{
	ASSERT(pos.position!=nil);
	if(pos.position==nil)
		return;
	node *remove=pos.position;
	node *after=remove->next;
	node *before=remove->previous;
	if(remove==first)
		first=after;
	else
		before->next=after;
	if(remove==last)
		last=before;
	else
		after->previous=before;
	pos.position=after;
	delete remove;
}
void List::erase(NSUInteger posIndex)
{
	ASSERT(posIndex<size());
	if(posIndex>=size())
		return;
	node *pos = first;
	for(NSUInteger i = 0; i<posIndex; i++)
		pos=pos->next;
	node *remove=pos;
	node *after=remove->next;
	node *before=remove->previous;
	if(remove==first)
		first=after;
	else
		before->next=after;
	if(remove==last)
		last=before;
	else
		after->previous=before;
	pos=after;
	delete remove;
}
IID &List::operator[] (NSUInteger index)
{
	node *pos=first;
	ASSERT(index<=size());
	for(NSUInteger i = 0; i<index; i++)
		pos=pos->next;
	return pos->data;
}

void List::reverse()
{
	node *start=first;
	node *end=last;
	for(int i=0; i<size()/2; i++)
	{
		swap(start->data,end->data);
		start=start->next;
		end=end->previous;
	}
}


int List::size()
{
	int counter=0;
	node *pos=first;
	while(pos!=nil)
	{
		counter++;
		pos=pos->next;
	}
	return counter;
}



void List::swap(IID obj1, IID obj2)
{
	IID tmp = obj1;
	obj1 = obj2;
	obj2 = tmp;

}



void List::concatenate(List const &X)
{
	node *p=X.first;
	while(p)
	{
		push_back(p->data);
		p=p->next;
	}
}


IID List::getObj(Iterator pos)
{
	ASSERT(pos.position!=nil);
	return pos.position->data;
}

node::node(IID inf)
{
	data=inf;
	next=nil;
	previous=nil;
}



List::Iterator List::begin()
{
	Iterator iter;
	iter.position=first;
	iter.last=last;
	iter.size=size();
	iter.posIndex = 0;
	return iter;
}


List::Iterator List::end()
{
	Iterator iter;
	iter.position=nil;
	iter.last=last;
	iter.size=size();
	iter.posIndex = iter.size;
	return iter;
}

// class Iterator


List::Iterator::Iterator()
{
	posIndex = 0;
	position=nil;
	last=nil;
}

void List::Iterator::operator+=(int dummy)
{
	ASSERT((dummy+posIndex) <size());
	for(NSUInteger i = 0; i<dummy; i++)
		position=position->next;
	posIndex += dummy;
}
void List::Iterator::operator-=(int dummy)
{
	ASSERT((posIndex - dummy) >=0);
	for(NSUInteger i = 0; i<dummy; i++)
		position=position->previous;
	posIndex -= dummy;
}



void List::Iterator::operator ++(int dummy)
{
	position=position->next;
	posIndex++;
	ASSERT(position!=nil);
}


void List::Iterator::operator --(int dummy)
{

	if(position==nil)
	{
		position=last;
		posIndex = size;
	}
	else
	{
		position=position->previous;
		posIndex--;
	}
	ASSERT(position!=nil);
}


bool List::Iterator::operator !=(Iterator b) const
{
	return position!=b.position;
}

