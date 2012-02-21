#ifndef __NSDictionary_h__
#define __NSDictionary_h__

#include "List.h"
#include "NSObject.h"
#include "NSArray.h"

class NSDictionary : public NSObject
{
public:
    struct KeyValuePair
    {
        NSObject* key;
        NSObject* value;

        KeyValuePair* next;
        KeyValuePair* prev;
    };

    KeyValuePair* root;
    KeyValuePair* tail;
    int size;

    void addPair(KeyValuePair* pair);
    void removePair(KeyValuePair* pair);
    KeyValuePair* findPair(NSObject* key);

public:
    NSOBJ(NSDictionary);
	virtual void dealloc();

    virtual IID initWithObjectsforKeyscount(IID *objects, IID *keys,NSUInteger count);
    virtual IID initWithObjectsforKeys(NSArray *objects,NSArray *keys);
    virtual IID initWithDictionary(NSDictionary *dictionary);
    //virtual IID initWithDictionaryforKeys(NSDictionary *dictionary, bool copyItems);
//    virtual IID initWithObjectsAndKeys(IID object,...);
    //virtual IID initWithContentsOfFile(NSString *path);
    //virtual IID initWithContentsOfURL(NSURL *url);

    static IID dictionary();
    static IID dictionaryWithObjectsforKeyscount(IID *objects,IID *keys,NSUInteger count);
    static IID dictionaryWithObjectsforKeys(NSArray *objects, NSArray *keys);
    static IID dictionaryWithDictionary(NSDictionary *other);
//    static IID dictionaryWithObjectsAndKeys(IID first,...);
    static IID dictionaryWithObjectforKey(IID object, IID key);
    //static IID dictionaryWithContentsOfFile:(NSString *)path;
    //static IID dictionaryWithContentsOfURL:(NSURL *)url;

    virtual IID objectForKey(IID key);
    virtual NSUInteger count();
   // virtual NSEnumerator *keyEnumerator;
   // virtual NSEnumerator *objectEnumerator;

    virtual void getObjectsandKeys(IID* objects, IID* keys);

    virtual bool isEqualToDictionary(NSDictionary* dictionary);

    virtual NSArray* allKeys();
    virtual NSArray* allKeysForObject(IID object);
    //virtual NSArray *keysSortedByValueUsingSelector(SEL selector);

    virtual NSArray* allValues();
    //virtual NSArray *objectsForKeysnotFoundMarker(NSArray *keys,IID marker);

    //virtual bool writeToFileatomically(NSString *path, bool atomically);
    //virtual bool writeToURLatomically(NSURL *url, boolatomically);

    //virtual NSString *description;
    //virtual NSString *descriptionInStringsFileFormat;
    //virtual NSString *descriptionWithLocale:locale;
    //virtual NSString *descriptionWithLocale:locale indent:(NSUInteger)indent;



public:
    // From NSMutableDictionary

    virtual IID initWithCapacity(NSUInteger capacity) { return init(); }
    static IID dictionaryWithCapacity(NSUInteger capacity) { return NSDictionary::alloc()->init()->autorelease(); }

    virtual void setObjectforKey(IID object, IID key);
    virtual void addEntriesFromDictionary(NSDictionary *dictionary);
    virtual void setDictionary(NSDictionary *dictionary);

    virtual void removeObjectForKey(IID key);
    virtual void removeAllObjects();
    virtual void removeObjectsForKeys(NSArray *keys);

};

#endif /* NSDICTIONARY_H_ */
