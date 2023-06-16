@attached(peer, names: arbitrary)
public macro Alias(_ name: String) = #externalMacro(module: "AliasPlugin", type: "AliasMacro")
