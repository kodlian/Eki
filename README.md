
# Eki #

[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat
            )](http://mit-license.org)
[![Platform](http://img.shields.io/badge/platform-iOS%20%26%20OSX-lightgrey.svg?style=flat
             )](https://developer.apple.com/resources/)
[![Language](http://img.shields.io/badge/language-swift-orange.svg?style=flat
             )](https://developer.apple.com/swift)
[![Issues](https://img.shields.io/github/issues/kodlian/Eki.svg?style=flat
                        )](https://github.com/kodlian/Eki/issues)
[![Cocoapod](http://img.shields.io/cocoapods/v/Eki.svg?style=flat)](http://cocoadocs.org/docsets/Eki/)

<p align="center">
<img src="logo.png" alt="logo"/>
<br/><br/>
Eki is a framework to manage easily concurrency in your apps that wraps the powerful API Grand Central Dispatch.
</p>

## Requirements
 - iOS 8.0+ / Mac OS X 10.10+
 - Xcode 6.3

## Queue
Internally GCD manages a pool of threads which process dispatch queues and invoke blocks submitted to them.

### Main and Global queues

 - `Main`
 - `UserInteractive`
 - `UserInitiated`
 - `Default`
 - `Utility`
 - `Background`

The queues are ordered in descending priority order.

You access them like so:

```swift
Queue.Background
```

### Dispatch
You dispatch a block on queue asynchronously by using `async` or synchronously by using `sync`:

```swift
// Asynchronously
Queue.Utility.async {
	...
}
// Or asynchronously using the operator shortcut
Queue.Utility <<< {
	...
}

// Synchronously
Queue.Utility.sync { // Eki will prevent deadlock if you submit a sync on the current queue
	...
}
```

You can send multiple blocks to a queue:
```swift
Queue.Utility <<< {
	// Block 1
} <<< {
	// Block 2
}
// Or by submitting an array of blocks:
let blocks = [{
	// Block 1
}, {
	// Block 2
}]
Queue.Utility.async(blocks)
```


### Custom Queue

Create your own queue (serial or concurrent):

```swift
let queue = Queue(name:"QueueName", kind:.Concurrent)
queue.async{
	...
}
```

### Dispatch barrier
Dispatch a block asynchronously with barrier:

```swift
let queue:Queue = Queue(name:"QueueName", type:.Concurrent)
...
queue |<| { // Or barrierAsync { }
	// This block will be executed on the queue only after all previous submitted blocks have been executed
} <<< {
	// This block will be executed only after the previous barrier block have completed
}
```
### Schedule

```swift
Queue.Background.after(2) {
    // Do some stuff on Background after 2 seconds
}
```

### Iterate on a Queue

```swift
Queue.Background.iterate(4) { i in
    // Do some stuff on Background 4 times
}
```

### Current Queue

```swift
Queue.current // Get current queue
Queue.Background.isCurrent // Check if background is current queue
```
Take notice that will work only on **Custom Queues** created with the designed initializer `Queue(name:String, kind:Queue.Custom.Kind)`, the **Main queue** and **Global queues**.

## Task
A task represents a block to be dispatched on a queue.

```swift
let t = Task(queue:.Utility) {
	...
}
// Or
let t = Queue.Utility + {
	...
}

t.async() // Dispatch asynchronously

group.async(t) // Dispatch on a group

let tasks:[Task] = ...
g.async(tasks) // Tasks dispatched on a group.
```
A task can be chained with a `block` or an another `Task`

```swift
t.chain {
	// Executed after t on same queue
}.chain(Task(queue:.Main) {
	// Executed after previous block on the main queue
})
t.async()

// Or chain directly after async and use the operator shortcut
t.async() <> {  
	// Executed after t on same queue
} <> Queue.Main + {
	// Executed after previous block on the main queue
}
```

## Group
A group allows to associate multiple blocks to be dispatched asynchronously.

```swift
let g = Group(queue:.Utility) // By default the group queue is Background

g.async {
	// Block dispatched on the group's queue.
} <<< {
	// Block dispatched on the group's queue using the operator.
} <<< Task(queue:.Main) {
	// Block dispatched on the Main queue (see Task).
}

let blocks:[()-> Void] = ...
g.async(blocks) // Blocks dispatched on the group's queue.
```
There is two ways to track group's blocks execution:
```swift
g.notify {
	// Block executed on the group queue when blocks previously dispatched on the group have been executed.
}
g.notify(Queue.Main + {
	// Block executed on the Main queue when blocks previously dispatched on the group have been executed.
})

g.wait() // Wait on the current process the group's blocks execution.
```

## Once
Execute a block once and only once.

```swift
let token = OnceToken() // Store it somewhere
...
once(token) {
	// Executed only one time
}
```


## Semaphore
There is three kinds of semaphore:

|	Kind 				    	    	  	    | Initial Resource(s)     |
| :------------------------------ | :--------------------- |
| Binary  												| 		1      |
| Barrier     									  | 		0      |
| Counting(resource:UInt16)       | 		custom      |

Initialize a semaphore:

```swift
let sem = Semaphore(.Binary)
```

You can increment/decrement a resource on the semaphore by using `wait/signal` methods:

```swift
sem.wait()
// Do some stuff when a resource is available
sem.signal()
```
Or by using the `perform` convenient method with a closure:

```swift
sem.perform {
	// Do some stuff when a resource is available
}
```

### Mutex
A **mutex** is essentially the same thing as a **binary semaphore** except that only the block that locked the resource is supposed to unlock it.

```swift
let m = Mutex()
...
m.perform {
	// Do some stuff when a mutext is available
}
```

### LockedObject
`LockedObject` is convenient class to lock access to an object with an internal **mutext**.

```swift
let myobj = MyObject()
let l = LockedObject(myobj)
...
l.access { obj in
	// Only one process at a time will access the locked object
}

```
## Use with [cocoapods](http://cocoapods.org/)

Add `pod 'Eki'` to your `Podfile` and run `pod install`.
