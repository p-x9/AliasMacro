//
//  Item.swift
//
//
//  Created by p-x9 on 2024/01/22.
//  
//

import Foundation
import Alias

struct Item {
    @Alias("int_Alias")
    var int = 0

    @Alias("double_Alias")
    var double = 0.0

    @Alias("string_Alias")
    var string = ""

    @Alias("bool_Alias")
    var bool = false

    @Alias("optionalInt_Alias")
    var optionalInt: Int?

    @Alias("optionalDouble_Alias")
    var optionalDouble: Double? = 123.4

    @Alias("optionalString_Alias")
    var optionalString: String?

    @Alias("optionalBool_Alias")
    var optionalBool: Bool? = false

    @Alias("implicitlyUnwrappedString_Alias")
    var implicitlyUnwrappedString: String!

    @Alias("intArray_Alias")
    var intArray = [0]

    @Alias("doubleArray_Alias")
    var doubleArray = [0.0, 1]

    @Alias("stringArray_Alias")
    var stringArray = [""]

    @Alias("boolArray_Alias")
    var boolArray = [nil, false]

    @Alias("optionalIntArray_Alias")
    var optionalIntArray = [0, nil]

    @Alias("optionalDoubleArray_Alias")
    var optionalDoubleArray = [0.0, nil, 1]

    @Alias("optionalStringArray_Alias")
    var optionalStringArray = [nil, ""]

    @Alias("optionalBoolArray_Alias")
    var optionalBoolArray = [false, nil]
}
