#include "NSDictionary.h"

void NSDictionary::dealloc()
{
    while (root)
        removePair(root);
    NSObject::dealloc();
}

void NSDictionary::addPair(KeyValuePair* pair)
{
    pair->prev = 0;
    pair->next = root;
    if (root)
        root->prev = pair;
    else
        tail = pair;
    root = pair;

    size++;
}

void NSDictionary::removePair(KeyValuePair* pair)
{
    if (pair->next)
        pair->next->prev = pair->prev;
    else
        tail = pair->prev;

    if (pair->prev)
        pair->prev->next = pair->next;
    else
        root = pair->next;

    NSREL(pair->key);
    NSREL(pair->value);

    delete pair;

    size--;
}

NSDictionary::KeyValuePair* NSDictionary::findPair(NSObject* key)
{
    KeyValuePair* pair = root;
    while (pair)
    {
        if (pair->key->isEquals(key))
            return pair;

        pair = pair->next;
    }

    return 0;
}

void NSDictionary::removeObjectForKey(IID key)
{
    KeyValuePair* pair = findPair(key);
    if (pair)
        removePair(pair);
}

IID NSDictionary::initWithObjectsforKeyscount(IID* objects, IID* keys, NSUInteger count)
{
	for (int i = 0; i < count; i++)
	{
	    IID key = keys[i];
	    IID obj = objects[i];
	    setObjectforKey(obj, key);
	}

	return this;
}

IID NSDictionary::initWithObjectsforKeys(NSArray* objects, NSArray* keys)
{
    if (!NSObject::init())
        return nil;

    int count = objects->count();
	for (NSUInteger i = 0; i < count; i++)
	{
	    IID key = keys->objectAtIndex(i);
	    IID obj = objects->objectAtIndex(i);
	    setObjectforKey(obj, key);
	}
	return this;
}

IID NSDictionary::initWithDictionary(NSDictionary *dictionary)
{
    if (!NSObject::init())
        return nil;

	NSUInteger count = dictionary->count();
	IID* objects = new IID[count];
	IID* keys = new IID[count];
	dictionary->getObjectsandKeys(objects,keys);

	initWithObjectsforKeyscount(objects, keys, count);

	delete[] objects;
	delete[] keys;

	return this;
}

IID NSDictionary::dictionary()
{
	return NSDictionary::alloc()->init()->autorelease();
}

IID NSDictionary::dictionaryWithObjectsforKeyscount(IID* objects, IID* keys, NSUInteger count)
{
	return NSDictionary::alloc()->initWithObjectsforKeyscount(objects,keys,count)->autorelease();
}

IID NSDictionary::dictionaryWithObjectsforKeys(NSArray* objects, NSArray* keys)
{
	return NSDictionary::alloc()->initWithObjectsforKeys(objects,keys)->autorelease();
}

IID NSDictionary::dictionaryWithDictionary(NSDictionary* other)
{
	return NSDictionary::alloc()->initWithDictionary(other)->autorelease();
}

IID NSDictionary::dictionaryWithObjectforKey(IID object, IID key)
{
	return NSDictionary::alloc()->initWithObjectsforKeyscount(&object, &key, 1)->autorelease();
}

IID NSDictionary::objectForKey(IID key)
{
    KeyValuePair* pair = findPair(key);
    if (pair)
        return pair->value;
    else
        return nil;
}

NSUInteger NSDictionary::count()
{
	return size;
}

void NSDictionary::getObjectsandKeys(IID* objects, IID* keys)
{
    KeyValuePair* pair = root;
    while(pair)
    {
        *objects++ = pair->value;
        *keys++ = pair->key;
        pair = pair->next;
    }
}

BOOL NSDictionary::isEqualToDictionary(NSDictionary *dictionary)
{
    if (count() != dictionary->count())
        return false;

    KeyValuePair* pair = root;
    while (pair)
    {
        NSObject* obj = dictionary->objectForKey(pair->key);
        if (!obj)
            return false;

        if (!obj->isEquals(pair->value))
            return false;

        pair = pair->next;
    }

    return true;
}

NSArray *NSDictionary::allKeys()
{
	NSArray* array = NSArray::alloc();
	array->init()->autorelease();

	KeyValuePair* pair = root;
	while (pair)
	{
	    array->addObject(pair->key);
	    pair = pair->next;
	}

	return array;
}

NSArray *NSDictionary::allKeysForObject(IID object)
{
	NSArray* array = NSArray::alloc();
	array->init()->autorelease();

	KeyValuePair* pair = root;
	while (pair)
	{
	    if (object->isEquals(pair->value))
	        array->addObject(pair->key);
	}

	return array;
}

NSArray *NSDictionary::allValues()
{
	NSArray* array = NSArray::alloc();
	array->init()->autorelease();

    KeyValuePair* pair = root;
    while (pair)
    {
        array->addObject(pair->value);
        pair = pair->next;
    }

	return array;
}

void NSDictionary::setObjectforKey(IID object,IID key)
{
    removeObjectForKey(key);

    KeyValuePair* pair = new KeyValuePair();
    pair->next = 0;
    pair->prev = 0;
    pair->key = NSRET(key);
    pair->value = NSRET(object);

    addPair(pair);
}

void NSDictionary::addEntriesFromDictionary(NSDictionary* dictionary)
{
    KeyValuePair* pair = dictionary->root;
    while (pair)
    {
        setObjectforKey(pair->value, pair->key);
        pair = pair->next;
    }
}

void NSDictionary::setDictionary(NSDictionary* dictionary)
{
    removeAllObjects();
    addEntriesFromDictionary(dictionary);
}

void NSDictionary::removeAllObjects()
{
    while (root)
        removePair(root);
}

void NSDictionary::removeObjectsForKeys(NSArray* keys)
{
    for (NSUInteger i = 0; i < keys->count(); i++)
            removeObjectForKey(keys->objectAtIndex(i));
}
