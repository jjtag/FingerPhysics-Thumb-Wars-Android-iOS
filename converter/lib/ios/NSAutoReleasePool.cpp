#include "NSAutoReleasePool.h"

NSAutoReleasePool::Node* NSAutoReleasePool::root = 0;

IID NSAutoReleasePool::addToAutorelease(IID object)
{
    Node* node = new Node();
    node->object = object;
    node->next = root;
    root = node;

    return object;
}

void NSAutoReleasePool::performAutorelease()
{
    Node* node = root;

    while (node)
    {
        Node* next = node->next;
        NSREL(node->object);
        delete node;
        node = next;
    }

    root = 0;
}

void NSAutoReleasePool::clearPool()
{
    Node* node = root;

    while (node)
    {
        Node* next = node->next;
        delete node;
        node = next;
    }

    root = 0;
}
