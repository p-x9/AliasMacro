# AliasMacro
Swift Macro for defining aliases for types, functions, or variables.

<!-- # Badges -->

[![Github issues](https://img.shields.io/github/issues/p-x9/AliasMacro)](https://github.com/p-x9/AliasMacro/issues)
[![Github forks](https://img.shields.io/github/forks/p-x9/AliasMacro)](https://github.com/p-x9/AliasMacro/network/members)
[![Github stars](https://img.shields.io/github/stars/p-x9/AliasMacro)](https://github.com/p-x9/AliasMacro/stargazers)
[![Github top language](https://img.shields.io/github/languages/top/p-x9/AliasMacro)](https://github.com/p-x9/AliasMacro/)

## Usage
A macro that can be attached to a type, function or variable.

### Class/Struct/Enum/Actor
For example, the `ViewController` can also be referenced as a `VC` by writing the following.
(If this macro is used for type, it is defined internally simply using `typealias`.)
```swift
@Alias("VC")
class ViewContoroller: UIViewController {
    /* --- */
}
```

### Variable
You can define an alias for a variable as follows
```swift
class SomeClass {
    @Alias("title")
    var text: String
}
```

### Function/Method
You can define an alias for a function as follows.
In this way, you can call both `hello("aaa", Date())` and `こんにちは("aaa", Date())`.
```swift
class SomeClass {
    @Alias("こんにちは")
    func hello(_ text: String, at date: Date) {
        /* --- */
    }
}
```

### Multiple Aliases
Multiple aliases can be defined by adding multiple macros as follows
```swift
@Alias("hello")
@Alias("こんにちは")
var text: String = "Hello"
```

### Specify Access Modifier of Alias
You can specify an alias access modifier as follows.
```swift
@Alias("hello", access: .public)
private var text: String = "Hello"
```

If set "inherit", it will inherit from the original definition.
```swift
@Alias("hello", access: .inherit)
private var text: String = "Hello"
```
## License
AliasMacro is released under the MIT License. See [LICENSE](./LICENSE)
