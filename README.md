# LuaDefender

LuaDefender is a Lua code obfuscator designed to make your Lua code harder to read and reverse-engineer. It uses a variety of techniques to obfuscate your code, including identifier renaming, dead code injection, control flow obfuscation, arithmetic obfuscation, and boolean obfuscation.

## Features

- **Identifier Renaming**: All variable and function names are replaced with randomly generated names.
- **Dead Code Injection**: Randomly generated code that does not affect the program's behavior is inserted.
- **Control Flow Obfuscation**: Unnecessary conditional statements and loops are added to the code.
- **Arithmetic Obfuscation**: Arithmetic operations are replaced with equivalent, but more complex expressions.
- **Boolean Obfuscation**: 'true' and 'false' values are replaced with dynamically generated expressions that evaluate to 'true' or 'false'.
- **Code Minification**: Removes comments and unnecessary white spaces, and reduces the code to a single line.

## Usage

1. Place your Lua script in the same directory as the LuaDefender script and name it `script.lua`.
2. Run the LuaDefender script. This will generate an obfuscated version of your script named `obfs.lua`.

## Limitations

- The obfuscator does not currently support the obfuscation of `goto` statements.
- The obfuscator may not work correctly with complex Lua scripts that use advanced features of the language.

## Disclaimer

This tool is intended for educational purposes and to increase the difficulty of reverse-engineering Lua scripts. It does not provide absolute security or protection for your code. Skilled attackers may still be able to reverse-engineer the obfuscated code.

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the Apache License 2.0