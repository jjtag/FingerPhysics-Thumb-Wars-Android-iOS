#ifndef LIST_H_
#define LIST_H_

#include "NSObject.h"

class node;

class List
{
public:
    class Iterator
    {
    public:
        Iterator();
        void operator++(int dummy);
        void operator+=(int dummy);
        void operator-=(int dummy);
        void operator--(int dummy);
        bool operator!=(Iterator b) const;
    private:
        node *position;
        node *last;
        NSUInteger posIndex;
        NSUInteger size;
        friend class List;
    };
    List();
    ~List();
    void push_back(IID inf);
    void push_front(IID inf);
    void pop_front();
    void pop_back();
    IID &operator[](NSUInteger index);
    void insert(Iterator pos, IID inf);
    IID getObj(Iterator pos);
    void erase(Iterator pos);
    void erase(NSUInteger posIndex);
    void reverse();

    void concatenate(List const &X);
    void print() const;
    void clear();
    Iterator begin();
    Iterator end();
    int size();
    friend class List::Iterator;
private:
    void swap(IID obj1, IID obj2);
    void del();
    node *first;
    node *last;
};

class node
{
public:
    node(IID inf);
private:
    NSObject *data;
    node *next;
    node *previous;
    friend class List;
    friend class List::Iterator;
};

#endif /* LIST_H_ */
