# CancellablePromiseKit

CancellablePromiseKit is an extension for [PromiseKit](https://github.com/mxcl/PromiseKit). A Promise is an abstraction of an asynchonous operation that can succeed or fail. A `CancellablePromise`, provided by this library, extends this concept to represent tasks that can be cancelled/aborted.


## Installation

CancellablePromiseKit is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CancellablePromiseKit'
```

To run the unit tests, clone the repo, and run `pod install` from the Example directory first.

## Making cancellable Promises

Creating a `CancellablePromise` is done similarly to creating a `Promise`:

```swift
func startTask() -> CancellablePromise<String> {
    let task = Task(…)
    return CancellablePromise<String> { resolver in
        task.completion = { (value, error) in
            resolver.resolve(value, error)
        }
        let cancel = {
            task.cancel()
            print("Task was cancelled")
        }
        return cancel
    }
}
let runningTask = startTask()
```

This initializer is similar to the one of `Promise`. However, the block has to return a function that cancels the task. In this example, it just calls the `cancel` function of the underlying task.


## Cancelling

A `CancellablePromise` has a `cancel()` function that will abort the underlying task:

```swift
runningTask.cancel()
```

Calling `cancel()` will reject the promise with a `CancellablePromiseError.cancelled`. A `catch` handler in your promise chain will not be called unless you set the policy to `.allErrors`:

```swift
runningTask.catch(policy: .allErrors) { error in
    // Will be called with error being CancellablePromiseError.cancelled
}
runningTask.cancel()
```


## `race` and `when` variants with `autoCancel`

The `race` function of `PromiseKit` allows you to wait until the first task of a list of tasks fulfills. You can use this task's result for further processing. The other tasks, however, continue executing, although their result will be ignored. If you're working with `CancellablePromise`s, there is a special overloaded `race(:, autoCancel:)` function that offers you an additional parameter called `autoCancel`. If you set it to `true`, all other tasks in the list will be cancelled:

```swift
race([cancellablePromise1, cancellablePromise2, cancellablePromise3], autoCancel: true)
```
If `cancellablePromise1` will fulfill, `cancellablePromise2` and `cancellablePromise3` will be cancelled automatically. 

Similarly, there are `when(resolved:, autoCancel:)` and `when(fulfilled:, autoCancel:)` that cancel all other promises if one fails. 

The `race(:, autoCancel:)`, `when(resolved:, autoCancel:)` and `when(fulfilled:, autoCancel:)` return a `CancellablePromise` which itself can be cancelled. Cancelling that promise will cancel the passed promises only if autoCancel is `true`.

The `autoCancel` parameter is `false` by default so that leaving it out will produce the same behaviour as with the regular `PromiseKit`.


## `then`

The overloaded `then` function allows you to chain `CancellablePromise`s which creates another `CancellablePromise`:

```swift
let cancellableChain = cancellablePromise1.then {
    cancellablePromise2
}
cancellableChain.cancel()
```
Cancelling the chain will cancel all included pending promises, i.e. `cancellablePromise1` and `cancellablePromise2` in this example.


## `asPromise` and `asCancellable`

If you want to use a `Promise` and a `CancellablePromise` in one expression (like `when` or `race`), you can convert between them. Every `CancellablePromise` provides `asPromise()`, and every `Promise` provides `asCancellable()`. Calling `cancel()` on the latter will cause a reject, but the underlying promise, that you called `asCancellable()` on, will continue beeing `pending`.


## Other initializers of `CancellablePromise`

`CancellablePromise` is not a subclass of `Promise`, but a wrapper around it. You can create a new instance by passing a promise and a cancel function:

```swift
let existingPromise, existingResolver = Promise<String>.pending()
let cancelFunction = { existingResolver.reject(MyError()) }

let cancellablePromise = CancellablePromise<String>(using: existingPromise, cancel: cancelFunction)
```


In some cases, you're building your cancellable task using other promises. In that case, you can use the initializer that provides you with a `cancelPromise`that will reject on cancellation:

```swift
let cancellablePromise = CancellablePromise<String> { cancelPromise in
    let task1 = Task(…)
    let task2 = Task(…)
    return when(fulfilled: [task1.asVoid(), task2.asVoid(), cancelPromise.asPromise().asVoid()]).then { _ in 
        let values = [task1.value!, task2. value!]
        let task3 = Task(values)
        return when(fulfilled: [task3, cancelPromise.asPromise().asVoid()])
    }
}
```

Calling `cancellablePromise.cancel()` in this example will cause `cancelPromise` to reject, which will cause all `when(fulfilled:)` calls and hereby the whole `cancellablePromise` to reject.


### `when` variants for `cancelPromise`

As shown in the previous example, building a cancellable promise often involves waiting for another promise to finish, while also expecting a cancellation. Building this with `when` requires the promises to be converted to `Promise<Void>`, which makes getting the resolved value cumbersome. For that reason, there is the `when(:, while:)` overload. The example can be rewritten as:

```swift
let cancellablePromise = CancellablePromise<String> { cancelPromise in
    let task1 = Task(…)
    let task2 = Task(…)
    return when(fulfilled: [task1, task2], while: cancelPromise).then { values in 
        let task3 = Task(values)
        return when(task3, while: cancelPromise)
    }
}
```


## TODO

- There should be overloads for `map`, `done`, `get`, `catch` etc. that return a CancellablePromise. At the moment, the implementations of `Thenable` take effect and return a regular `Promise`.
- There should be a `firstly` for `CancellablePromise`.
- There should be an `asCancellable()` on `Guarantee` that returns a `CancellablePromise`. There won't be a ~~CancellableGuarantee~~ because a task that offers to be cancelled cannot also claim to always fulfill.
- There should be an `asVoid()` on `CancellablePromise`.
- `PromiseKit` has many overloads for `race` and `when` that can receive arrays, varadic parameters, etc. `CancellablePromiseKit` could have those, too.
- There could be factory functions like `pending`, `value`, etc., like in `PromiseKit`


## Author

Johannes Dörr, mail@johannesdoerr.de


## License

CancellablePromiseKit is available under the MIT license. See the LICENSE file for more info.