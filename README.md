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

/* ↓↓↓↓↓ */

print(ViewContoroller.self) // => "ViewController"
print(VC.self) // => "ViewController"
```

### Variable
You can define an alias for a variable as follows
```swift
class SomeClass {
    @Alias("title")
    var text: String = "hello"
}

/* ↓↓↓↓↓ */

let someClass = SomeClass()

print(text) // => "hello"
print(title) // => "hello"
```

### Function/Method
You can define an alias for a function as follows.
In this way, you can call both `hello("aaa", at: Date())` and `こんにちは("aaa", at: Date())`.
```swift
class SomeClass {
    @Alias("こんにちは")
    func hello(_ text: String, at date: Date) {
        /* --- */
        print(text)
    }
}

/* ↓↓↓↓↓ */

let someClass = SomeClass()

someClass.hello("aaa", at: Date()) // => "aaa"
someClass.こんにちは("aaa", at: Date()) // => "aaa"
```

#### Customize Argument Label
Argument labels can also be customized by separating them with ":".

```swift
class SomeClass {
    @Alias("こんにちは:いつ")
    func hello(_ text: String, at date: Date) {
        /* --- */
        print(text)
    }

    @Alias("こんにちは2:_") // Omit argument labels
    func hello2(_ text: String, at date: Date) {
        /* --- */
        print(text)
    }

    @Alias("こんにちは3::宛") // The first argument label is inherited. The second is customized
    func hello3(_ text: String, at date: Date, to: String) {
        /* --- */
        print(text)
    }
}

/* ↓↓↓↓↓ */

let someClass = SomeClass()

someClass.hello("aaa", at: Date()) // => "aaa"
someClass.こんにちは("aaa", いつ: Date()) // => "aaa"

someClass.hello2("aaa", at: Date()) // => "aaa"
someClass.こんにちは2("aaa", Date()) // => "aaa"

someClass.hello3("aaa", at: Date(), to: "you") // => "aaa"
someClass.こんにちは3("aaa", at: Date(), 宛: "あなた") // => "aaa"
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
