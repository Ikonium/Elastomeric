# Elastomeric

`Elastomeric` is a simple asynchronous Reactive mechanism intended to facilitate UI statefulness.  `Elastomeric` is very useful for storing and reading any data type between files without the need for layers of class variables.


## Usage

### Declarations

Your app should declare an `extension` on `Elastomer` that contain static variables for 

```swift
//Elastomer declarations
extension Elastomer {
    static var someBool:Elastomer   { return Elastomer(associatedType: Bool.self, name: "someBool") }
    static var someString:Elastomer { return Elastomer(associatedType: String.self, name: "someString") }
    static var someInt:Elastomer    { return Elastomer(associatedType: Int.self, name: "someInt") }
}
```

### Staging values (write)

Writing new values (otherwise known as staging) is accomplished by calling `.stageValue(_:)` on any `Elastomer`.   When a new value is staged, all of the obervers registered to listen for new values on the particular `Elastomer` will be notified.

```swift
// 1. Add or change a value on a per-value basis
Elastomer.someBool.stageValue(true)
Elastomer.someString.stageValue("hello!")
Elastomer.someInt.stageValue(Int(27))

// 2. All Attempts to stage a value of an unassociated type will be ignored.
Elastomer.someInt.stageValue(Float(27))

// 3. A value may be staged after an arbitrary delay
Elastomer.someBool.stageValue(false, afterDelay: TimeInterval(12))

// 4. Redundant entries are ignored by default, but that may be overridden
Elastomer.someBool.stageValue(false, discardingRedundancy: false)

// 5. Values may be staged in a batch operation
[Elastomer.someBool:true, Elastomer.someInt:Int(72), Elastomer.someString:"goodbye!"].stage()
```

### Expressing values (read)


### Observe values


### Equality


