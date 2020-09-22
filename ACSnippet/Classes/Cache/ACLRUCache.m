//
//  ACLRUCache.m
//  TilesnameTest
//
//  Created by Wenzhi WU on 29/6/2019.
//  Copyright © 2019 Wenzhi WU. All rights reserved.
//

#import "ACLRUCache.h"
#import <pthread.h>
#import <UIKit/UIKit.h>

@interface ACLinkedMapNode : NSObject

/// Previous linked node
@property (nonatomic, weak) ACLinkedMapNode *previous;

/// Next linked node
@property (nonatomic, weak) ACLinkedMapNode *next;

/// Key for indexing
@property (nonatomic, copy) NSString *key;

/// Stored object value
@property (nonatomic, strong) id value;

/// Cost for store the value
@property (nonatomic, assign) NSUInteger cost;

/// Expired time interval since 1970
@property (nonatomic, assign) NSTimeInterval time;

/// Initialize ACLinkedMapNode object with key, value and cost
/// @param key Key for node
/// @param value Node value
/// @param cost Cost of store the value
- (instancetype)initWithKey:(NSString *)key value:(id)value cost:(NSInteger)cost;

@end

@implementation ACLinkedMapNode

- (instancetype)initWithKey:(NSString *)key value:(id)value cost:(NSInteger)cost {
    self = [super init];
    if (self) {
        _key = key;
        _value = value;
        _cost = cost;
    }
    
    return self;
}

@end

@interface ACLinkedMap : NSObject

/// Key-value storage
@property (nonatomic, assign) CFMutableDictionaryRef storage;

/// Total cost of caches
@property (nonatomic, assign) NSUInteger totalCost;

/// Total count of cached objects
@property (nonatomic, assign) NSUInteger totalCount;

/// Linked map head object
@property (nonatomic, strong) ACLinkedMapNode *head;

/// Linked map tail object
@property (nonatomic, strong) ACLinkedMapNode *tail;

/// Release freed object on main thread
@property (nonatomic, assign) BOOL releaseOnMainThread;

/// Release freed object asynchroniusly
@property (nonatomic, assign) BOOL releaseAsynchronously;

/// Inser node to map at head position
/// @param node Node to add
- (void)insertNodeAtHead:(ACLinkedMapNode *)node;

/// Bring node to head position
/// @param node Node to move
- (void)bringNodeToHead:(ACLinkedMapNode *)node;

/// Remove node from map
/// @param node Node to remove
- (void)removeNode:(ACLinkedMapNode *)node;

/// Remove node on tail position
- (ACLinkedMapNode *)removeTailNode;

/// Remove all nodes from map
- (void)removeAll;


@end


/// Assign dispatch queue to release operation
static inline dispatch_queue_t ACLinkedMapGetReleaseQueue() {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
}

@implementation ACLinkedMap

- (instancetype)init {
    self = [super init];
    if (self) {
        _storage = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
           _releaseOnMainThread = NO;
           _releaseAsynchronously = YES;
    }
    
    return self;
}

- (void)dealloc {
    CFRelease(_storage);
}

- (void)insertNodeAtHead:(ACLinkedMapNode *)node {
    CFDictionarySetValue(_storage, (__bridge const void *)(node.key), (__bridge const void *)(node));
    _totalCost += node.cost;
    _totalCount++;
    if (_head) {
        node.next = _head;
        _head.previous = node;
        _head = node;
    } else {
        _head = _tail = node;
    }
}

- (void)bringNodeToHead:(ACLinkedMapNode *)node {
    if (_head == node) return;
    
    if (_tail == node) {
        _tail = node.previous;
        _tail.next = nil;
    } else {
        node.next.previous = node.previous;
        node.previous.next = node.next;
    }
    
    node.next = _head;
    node.previous = nil;
    _head.previous = node;
    _head = node;
}

- (void)removeNode:(ACLinkedMapNode *)node {
    CFDictionaryRemoveValue(_storage, (__bridge const void *)(node.key));
    _totalCost -= node.cost;
    _totalCount--;
    if (node.next) node.next.previous = node.previous;
    if (node.previous) node.previous.next = node.next;
    if (_head == node) _head = node.next;
    if (_tail == node) _tail = node.previous;
}

- (ACLinkedMapNode *)removeTailNode {
    if (!_tail) return nil;
    ACLinkedMapNode *tail = _tail;
    CFDictionaryRemoveValue(_storage, (__bridge const void *)(_tail.key));
    _totalCost -= _tail.cost;
    _totalCount--;
    if (_head == _tail) {
        _head = _tail = nil;
    } else {
        _tail = _tail.previous;
        _tail.next = nil;
    }
    return tail;
}
    
/// Get all keys from nodes
- (NSArray <NSString *>*)nodeKeys {
    CFIndex size = CFDictionaryGetCount(_storage);
    CFTypeRef *keys = (CFTypeRef *)malloc(size * sizeof(CFTypeRef));
    CFDictionaryGetKeysAndValues(_storage, (const void **)keys, NULL);
    
    NSMutableArray *mutable = [NSMutableArray new];
    for (int i = 0; i < size; i++) {
        NSString *key = (__bridge NSString *)keys[i];
        [mutable addObject:key];
    }
    
    return mutable.copy;
}

- (void)removeAll {
    _totalCost = 0;
    _totalCount = 0;
    _head = nil;
    _tail = nil;
    if (CFDictionaryGetCount(_storage) > 0) {
        CFMutableDictionaryRef holder = _storage;
        _storage = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        
        if (_releaseAsynchronously) {
            dispatch_queue_t queue = _releaseOnMainThread ? dispatch_get_main_queue() : ACLinkedMapGetReleaseQueue();
            dispatch_async(queue, ^{
                CFRelease(holder);
            });
        } else if (_releaseOnMainThread && !pthread_main_np()) {
            dispatch_async(dispatch_get_main_queue(), ^{
                CFRelease(holder); // hold and release in specified queue
            });
        } else {
            CFRelease(holder);
        }
    }
}

@end


@interface ACLRUCache ()

/// Lock for thread safe
@property (nonatomic, assign) pthread_mutex_t lock;

/// Dispatch queue for background operation
@property (nonatomic, strong) dispatch_queue_t queue;

/// LRU map for node management
@property (nonatomic, strong) ACLinkedMap *LRU;

/// Time interval for auto-trimming
@property (nonatomic, assign) NSTimeInterval autoTrimInterval;


@end


@implementation ACLRUCache

- (instancetype)init {
    self = [super init];
    if (self) {
        pthread_mutex_init(&_lock, NULL);
        _LRU = [ACLinkedMap new];
        _queue = dispatch_queue_create("com.mrcrow.aicity.lru.cache", DISPATCH_QUEUE_SERIAL);
        _countLimit = NSUIntegerMax;
        _costLimit = NSUIntegerMax;
        _timeLimit = DBL_MAX;
        _autoTrimInterval = 10.0;
        _shouldRemoveAllObjectsOnMemoryWarning = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarningNotification) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];

        [self trimRecursively];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [_LRU removeAll];
    pthread_mutex_destroy(&_lock);
}

/// Selector for receive memory warning notification
- (void)didReceiveMemoryWarningNotification {
    if (self.shouldRemoveAllObjectsOnMemoryWarning) {
        [self removeAllObjects];
    }
}

/// Selector for receiving enter background notification
- (void)didEnterBackgroundNotification {
    if (self.shouldRemoveAllObjectsWhenEnteringBackground) {
        [self removeAllObjects];
    }
}

/// Trim object recursively with time interval
- (void)trimRecursively {
    __weak typeof(self) _self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_autoTrimInterval * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        __strong typeof(_self) self = _self;
        if (!self) return;
        [self trimInBackground];
        [self trimRecursively];
    });
}

/// Trim object in background
- (void)trimInBackground {
    dispatch_async(_queue, ^{
        [self trimToCost:self.costLimit];
        [self trimToCount:self.countLimit];
        [self trimToTime:self.timeLimit];
    });
}

- (NSUInteger)totalCount {
    pthread_mutex_lock(&_lock);
    NSUInteger count = _LRU.totalCount;
    pthread_mutex_unlock(&_lock);
    return count;
}

- (NSUInteger)totalCost {
    pthread_mutex_lock(&_lock);
    NSUInteger totalCost = _LRU.totalCost;
    pthread_mutex_unlock(&_lock);
    return totalCost;
}

- (void)setCountLimit:(NSUInteger)countLimit {
    if (_countLimit == countLimit) return;
    _countLimit = countLimit;
    [self trimToCount:countLimit];
}

- (void)setCostLimit:(NSUInteger)costLimit {
    if (_costLimit == costLimit) return;
    _costLimit = costLimit;
    [self trimToCost:costLimit];
}

- (void)setTimeLimit:(NSTimeInterval)timeLimit {
    if (_timeLimit == timeLimit) return;
    _timeLimit = timeLimit;
    [self trimToTime:timeLimit];
}

- (BOOL)containsObjectForKey:(NSString *)key {
    if (!key) return NO;
    pthread_mutex_lock(&_lock);
    BOOL contains = CFDictionaryContainsKey(_LRU.storage, (__bridge const void *)(key));
    pthread_mutex_unlock(&_lock);
    return contains;
}

- (id)objectForKey:(NSString *)key {
    if (!key) return nil;
    pthread_mutex_lock(&_lock);
    ACLinkedMapNode *node = CFDictionaryGetValue(_LRU.storage, (__bridge const void *)(key));
    if (node) {
        node.time = CACurrentMediaTime();
        [_LRU bringNodeToHead:node];
    }
    pthread_mutex_unlock(&_lock);
    return node ? node.value : nil;
}

- (void)removeObjectForKey:(NSString *)key {
    if (!key) return;
    pthread_mutex_lock(&_lock);
    ACLinkedMapNode *node = CFDictionaryGetValue(_LRU.storage, (__bridge const void *)(key));
    if (node) {
        [_LRU removeNode:node];
        if (_LRU.releaseAsynchronously) {
            dispatch_queue_t queue = _LRU.releaseOnMainThread ? dispatch_get_main_queue() : ACLinkedMapGetReleaseQueue();
            dispatch_async(queue, ^{
                [node class]; //hold and release in queue
            });
        } else if (_LRU.releaseOnMainThread && !pthread_main_np()) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [node class]; //hold and release in queue
            });
        }
    }
    pthread_mutex_unlock(&_lock);
}

- (void)setObject:(id)object forKey:(NSString *)key {
    [self setObject:object forKey:key cost:0];
}

- (void)setObject:(id)object forKey:(NSString *)key cost:(NSUInteger)cost {
    if (!key) return;
    
    pthread_mutex_lock(&_lock);
    ACLinkedMapNode *node = CFDictionaryGetValue(_LRU.storage, (__bridge const void *)(key));
    NSTimeInterval now = CACurrentMediaTime();
    if (node) {
        _LRU.totalCost -= node.cost;
        _LRU.totalCost += cost;
        node.cost = cost;
        node.time = now;
        node.value = object;
        [_LRU bringNodeToHead:node];
    } else {
        node = [[ACLinkedMapNode alloc] initWithKey:key value:object cost:cost];
        node.time = now;
        [_LRU insertNodeAtHead:node];
    }
    
    if (_LRU.totalCost > _costLimit) {
        dispatch_async(_queue, ^{
            [self trimToCost:self.costLimit];
        });
    }
    
    if (_LRU.totalCount > _countLimit) {
        ACLinkedMapNode *node = [_LRU removeTailNode];
        [self didTrimKeys:@[node.key]];
        if (_LRU.releaseAsynchronously) {
            dispatch_queue_t queue = _LRU.releaseOnMainThread ? dispatch_get_main_queue() : ACLinkedMapGetReleaseQueue();
            dispatch_async(queue, ^{
                [node class]; //hold and release in queue
            });
        } else if (_LRU.releaseOnMainThread && !pthread_main_np()) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [node class]; //hold and release in queue
            });
        }
    }
    pthread_mutex_unlock(&_lock);
}

- (void)removeAllObjects {
    NSArray <NSString *>*keys = [_LRU nodeKeys];
    [_LRU removeAll];
    [self didTrimKeys:keys];
}

- (NSArray <NSString *>*)objectKeys {
    return [_LRU nodeKeys];
}

/// Notify delegate with trimmed keys
/// @param keys Trimmed keys
- (void)didTrimKeys:(NSArray <NSString *>*)keys {
    if ([keys count] && self.delegate && [self.delegate respondsToSelector:@selector(lruCache:didTrimObjectsForKeys:)]) {
        if (!pthread_main_np()) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate lruCache:self didTrimObjectsForKeys:keys];
            });
        } else {
            [self.delegate lruCache:self didTrimObjectsForKeys:keys];
        }
    }
}

/// Trim object to cache cost
/// @param costLimit Destination cost
- (void)trimToCost:(NSUInteger)costLimit {
    BOOL finish = NO;
    pthread_mutex_lock(&_lock);
    if (costLimit == 0) {
        [self removeAllObjects];
        finish = YES;
    } else if (_LRU.totalCost <= costLimit) {
        finish = YES;
    }
    pthread_mutex_unlock(&_lock);
    if (finish) return;
    
    NSMutableArray *holder = [NSMutableArray new];
    while (!finish) {
        if (pthread_mutex_trylock(&_lock) == 0) {
            if (_LRU.totalCost > costLimit) {
                ACLinkedMapNode *node = [_LRU removeTailNode];
                [self didTrimKeys:@[node.key]];
                if (node) [holder addObject:node];
            } else {
                finish = YES;
            }
            pthread_mutex_unlock(&_lock);
        } else {
            usleep(10 * 1000); //10 ms
        }
    }
    
    if (holder.count) {
        dispatch_queue_t queue = _LRU.releaseOnMainThread ? dispatch_get_main_queue() : ACLinkedMapGetReleaseQueue();
        dispatch_async(queue, ^{
            [holder count];
        });
    }
}

/// Trim object to count
/// @param countLimit Destination object count
- (void)trimToCount:(NSUInteger)countLimit {
    BOOL finish = NO;
    pthread_mutex_lock(&_lock);
    if (countLimit == 0) {
        [self removeAllObjects];
        finish = YES;
    } else if (_LRU.totalCount <= countLimit) {
        finish = YES;
    }
    pthread_mutex_unlock(&_lock);
    if (finish) return;
    
    NSMutableArray *holder = [NSMutableArray new];
    while (!finish) {
        if (pthread_mutex_trylock(&_lock) == 0) {
            if (_LRU.totalCount > countLimit) {
                ACLinkedMapNode *node = [_LRU removeTailNode];
                [self didTrimKeys:@[node.key]];
                if (node) [holder addObject:node];
            } else {
                finish = YES;
            }
            pthread_mutex_unlock(&_lock);
        } else {
            usleep(10 * 1000); //10 ms
        }
    }
    
    if (holder.count) {
        dispatch_queue_t queue = _LRU.releaseOnMainThread ? dispatch_get_main_queue() : ACLinkedMapGetReleaseQueue();
        dispatch_async(queue, ^{
            [holder count];
        });
    }
}

/// Trim object to date with time interval since 1970
/// @param time Destination date interval
- (void)trimToTime:(NSTimeInterval)time {
    BOOL finish = NO;
    NSTimeInterval now = CACurrentMediaTime();
    pthread_mutex_lock(&_lock);
    if (time <= 0) {
        [self removeAllObjects];
        finish = YES;
    } else if (!_LRU.tail || (now - _LRU.tail.time) <= time) {
        finish = YES;
    }
    pthread_mutex_unlock(&_lock);
    if (finish) return;
    
    NSMutableArray *holder = [NSMutableArray new];
    while (!finish) {
        if (pthread_mutex_trylock(&_lock) == 0) {
            if (_LRU.tail && (now - _LRU.tail.time) > time) {
                ACLinkedMapNode *node = [_LRU removeTailNode];
                [self didTrimKeys:@[node.key]];
                if (node) [holder addObject:node];
            } else {
                finish = YES;
            }
            pthread_mutex_unlock(&_lock);
        } else {
            usleep(10 * 1000); //10 ms
        }
    }
    
    if (holder.count) {
        dispatch_queue_t queue = _LRU.releaseOnMainThread ? dispatch_get_main_queue() : ACLinkedMapGetReleaseQueue();
        dispatch_async(queue, ^{
            [holder count];
        });
    }
}

@end
