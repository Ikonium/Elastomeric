# Elastomeric

`Elastomeric` is a simple asynchronous Reactive mechanism intended to facilitate UI statefulness.  `Elastomeric` is very useful for storing and reading any data type between files without the need for layers of class variables.


## Usage

### Declarations

Your app should declare an `extension` on `Elastomer`

```objective-c
//Elastomer declarations
extension Elastomer {
    static var someBool:Elastomer   { return Elastomer(associatedType: Bool.self, name: "someBool") }
    static var someString:Elastomer { return Elastomer(associatedType: String.self, name: "someString") }
    static var someInt:Elastomer    { return Elastomer(associatedType: Int.self, name: "someInt") }
}
```

### Staging values (write)


### Expressing values (read)


### Observe values
