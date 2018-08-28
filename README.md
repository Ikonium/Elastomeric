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

### Equality (custom types)

A type must implement the `Equatable` protocol to be associated with an `Elastomer`.  Sometimes transmitting a primitive data type is not enough for an application's needs.

```swift
struct FilterVCPresentation: Equatable {
    var indexPath: IndexPath?
    var isPresented: Bool

    static func == (lhs: FilterVCPresentation, rhs: FilterVCPresentation) -> Bool {
        if let lhsIndexUnwrapped = lhs.indexPath {
                if let rhsIndexUnwrapped = rhs.indexPath {
                    if (lhsIndexUnwrapped == rhsIndexUnwrapped) && (lhs.isPresented == rhs.isPresented) {
                        return true
                }
            }
        }

        return false
    }
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

Reading a current value (otherwise known as expressing) is accomplished by calling `.expressValue { }` on any `Elastomer`.  Values are delivered asynchronously.  Values should be optionally cast to the type you are expecting.

```swift
// 1. Recall value from model. Response will be deivered in a trailing closure
Elastomer.someBool.expressValue { (value) in

    //Cast optional Any? as Bool
    guard let bool = value as? Bool else { return }

    //Print result
    print("Boolean derived from value in closure \(bool)")
}

// 2. Recall multiple values from the model at once
[Elastomer.someBool, Elastomer.someString, Elastomer.someInt].expressValues { (dict) in

    //The dictionary contains Elastomer-value associations
    guard let bool = dict[Elastomer.someBool] as? Bool else { return }

    //Print result
    print("Boolean derived from value subscripted from dictionary  \(bool)")
}
```

### Observe values

Any object can register as an observer of any `Elastomer` (or batch of `Elastomer`s). Any time a new value is staged to an `Elastomer`, all observation blocks will be called.

```swift
// 1. Observe any mutations to the Elastomer-associated data
let _ = Elastomer.someBool.registerObserver { (mutation) in

    //The new value can be derived from the mutation
    guard let newBool = mutation.newValue as? Bool else { return }

    //The previous value can be derived from the mutation
    guard let oldBool = mutation.oldValue as? Bool else { return }

    //A timestamp of the change is also delivered by way of the mutation
    let timeOfMutation:TimeInterval = mutation.timestamp

    //Print contents of mutation
    print("old value \(oldBool) was replaced by new value \(newBool), \(abs(CACurrentMediaTime()-timeOfMutation)) seconds ago")
}

// 2. New observers will return UUD receipts that can be captured for later retirement
let stringObserverReceipt = Elastomer.someString.registerObserver { (mutation) in
    print("The string did change")
}

// 3. An observer may be retired with the associated receipt
Elastomer.someString.retireObserver(stringObserverReceipt)

// 4. New observers may be registered in batches
let receipts = [Elastomer.someString, Elastomer.someInt].registerObservers { (mutation) in

switch mutation.elastomer {
    case .someString:   print("The string did change")
    case .someInt:      print("The int did change")
    default:            break
    }
}

// 5. A dictionary of observer receipts may be retired together
receipts.retireAll()
```

### Post

An `Elastomer` can notify all of its observers without having to change its underlying value via a `.stageValue(_:)` call.   This is accomplished with the `.post()` call.

```swift
// Notifies all observer blocks
Elastomer.someBool.post()
```


