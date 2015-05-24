# Eki
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat
            )](http://mit-license.org)
[![Platform](http://img.shields.io/badge/platform-iOS%20%26%20OSX-lightgrey.svg?style=flat
             )](https://developer.apple.com/resources/)
[![Language](http://img.shields.io/badge/language-swift-orange.svg?style=flat
             )](https://developer.apple.com/swift)
             
[<img align="left" src="logo.png" hspace="20">](#logo)

Eki is a framework to manage easily concurrency in your apps that wraps the powerful API Grand Central Dispatch.



## Requirements
 - iOS 8.0+ / Mac OS X 10.10+
 - Xcode 6.3

## Queue
Internally GCD manages a pool of threads which process dispatch queues and invoke blocks submitted to them.

### Global queues

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

###Dispatch
You dispatch a block on queue asynchronously by using `async`:

```swift
Queue.Utility.async {
	...
}
```
Or by using the operator shortcut:

```swift
Queue.Utility <<< {
	...
}
```
You can send multiple blocks to a queue by using chaining:

```swift
Queue.Utility <<< {
	// Block 1
} <<< {
	// Block 2
}
```
Or by submitting an array of blocks:

```swift
let blocks = [{
	// Block 1
}, {
	// Block 2
}]
Queue.Utility.async(blocks)
```


### Custom Queue

You can also create your own queue (serial or concurrent):

```swift
let queue = Queue("QueueName", type:.Concurrent)
queue.async{
	...
}
```
### Dispatch barrier
Dispatch a block asynchronously with barrier:

```swift
let queue:Queue = Queue("QueueName", type:.Concurrent)
...
queue |<| { // Or barrierAsync { }
	// This block will be executed on the queue only after all previous submitted blocks have been executed
} <<< {
	// This block will be executed only after the previous barrier block have completed
}
```

### Iterate on a Queue

```swift
Queue.Background.iterate(4) { i in
    // Do some stuff 4 times
}
```

## Group
A group allows to associate multiple blocks to be dispatched asynchronously.

```swift
let g = Group(queue:.Utility)

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
	// Block executed when blocks previously dispatched on the group have been executed.
}

g.wait() // Wait on the current process the group's blocks execution.
```

## Task
A task represents a block to be dispatched on a queue.

```swift
let task = Task(queue:.Utility) {
	...
}
// Or
let task = Queue.Utility + {
	...
}

task.async() // Dispatch asynchronously

group.async(task) // Dispatch on a group

let tasks:[Task] = ...
g.async(tasks) // Tasks dispatched on a group.
```
A task can be chained with a `block` or an another `Task`

```swift
task.chain { // Or use .chain()
	// Do some stuff after task's block execution on same queue
}.chain(Task(queue:.Main) {
	// Do some stuff after previous block execution on the main queue
})
task.async()

// Or
task.async() <> {
	// Do some stuff after task's block execution on same queue
} <> Queue.Main + {
	// Do some stuff after previous block execution on the main queue
}
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

 - `Binary` resource initialized to 1
 - `Barrier` resource initialized to 0
 - `Counting(resource:UInt16)` ressource initialized to the given parameter

Initialize a semaphore:

```swift
let sem = Sempahore(type:.Binary)
```

You can increment/decrement a resource on the semaphore by using `wait/signal` methods:

```swift
sem.wait()
// Do some stuff when a ressource is available
sem.signal()
```
Or by using the `perform` convenient method with a closure:

```swift
sem.perform {
	// Do some stuff when a ressource is available
}
```

### Mutex
A **mutex** is essentially the same thing as a **binary semaphore** exept that only the block that locked the ressource is supposed to unlock it.

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

Add `pod 'Eki', :git => 'https://github.com/kodlian/Eki.git'` to your `Podfile` and run `pod install`.