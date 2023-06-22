import AliasCore

@attached(peer, names: arbitrary)
public macro Alias(_ name: String, access: AccessControl = .inherit) = #externalMacro(module: "AliasPlugin", type: "AliasMacro")
