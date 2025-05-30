# TextBlock

Format multiline strings in Elm, inspired by C# Raw String Literals and Java Text Blocks.

This library simplifies working with multiline strings in Elm, removing unwanted indentation and providing flexible formatting options. It’s ideal for generating clean SQL queries, email templates, HTML, Markdown, or other structured text.


## Who Is It For?

Elm developers who need to format multiline strings without the extra indentation that Elm’s triple-quoted strings (`"""`) preserve by default.


## Features

- **Automatic Indentation Stripping**: Removes unwanted leading whitespace (spaces or tabs) from each line, based on the minimum indentation, for clean output.
- **Newline Escaping**: Supports backslash (`\`) at the end of a line to suppress newlines, merging lines in the output.
- **Trailing Space Preservation**: Preserves trailing spaces using a pipe (`|`) marker, perfect for templates requiring precise spacing.
- **Custom Indentation**: Adds user-defined indentation with a specified character (default is a space) and count for flexible formatting.
- **String Interpolation**: Supports placeholder replacement (e.g., `{{key}}`) for dynamic templates, ideal for email or HTML generation.
- **Configurable Newlines**: Allows custom newline characters (default is `\n`) for compatibility with different platforms or formats.

## Installation

Add the package to your Elm project using:

```bash
elm install TSBSoftware/textblock
```

## Getting Started

Use the `textBlock` function to process a multiline string with default settings:

```elm
import TextBlock

myText =
    textBlock
        """
        <div>
            <p>Hello</p>
        </div>
        """
-- Output: "<div>\n    <p>Hello</p>\n</div>"
```

Without `textBlock`, Elm preserves leading indentation:

```elm
"""
    <div>
        <p>Hello</p>
    </div>
"""
-- Output: "\n    <div>\n        <p>Hello</p>\n    </div>\n"
```


## Examples

### Custom Indentation

Apply additional indentation with a custom character:

```elm
import TextBlock

someHtml =
    TextBlock.textBlockWith { defaultOptions | indent = 4, indentChar = '.' }
        """
        <div>
            <p>Hello</p>
        </div>
        """
-- Output: "....<div>\n....    <p>Hello</p>\n....</div>"
```


### String Interpolation

Replace placeholders in a template:

```elm
import TextBlock

greeting =
    TextBlock.textBlockWithFormat defaultOptions
        [ ( "name", "World" ) ]
        """
        Hello {{name}}!
        """
-- Output: "Hello World!"
```


### Escaping Newlines

Merge lines using a backslash:

```elm
import TextBlock

text =
    textBlock
        """
        Hello \
        World!
        """
-- Output: "Hello World!"
```


### Preserving Trailing Spaces

Keep trailing spaces with a pipe (|):

```elm
import TextBlock

blocked =
    textBlock
        """
        Blocked   |
        Text      |
        """
-- Output: "Blocked   \nText      " (trailing spaces preserved)
```


## Notes

- **One-Shot Usage**: `textBlock` is designed for single application. Applying it multiple times (e.g., `textBlock (textBlock value)`) may alter indentation unexpectedly and is not recommended.
- **Newline Handling**: The default newline is `\n`. Customize it via TextBlockOptions if needed (e.g., `\r\n` for Windows compatibility).


## License

- **License**: MIT (see LICENSE for details)
