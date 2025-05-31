module TextBlock exposing
    ( TextBlockOptions, defaultOptions
    , textBlock, textBlockWith, textBlockWithFormat
    )

{-| Process multiline strings in Elm, removing unwanted indentation and providing flexible formatting options, similar to C# Raw String Literals or Java Text Blocks.

Ideal for generating clean SQL queries, email templates, HTML, or Markdown.


# Types

@docs TextBlockOptions, defaultOptions


# Functions

@docs textBlock, textBlockWith, textBlockWithFormat

-}

import Regex


{-| Configuration options for text block processing.

  - `indent`: Number of indentation characters to add to each line (default: 0).
  - `indentChar`: Character used for indentation (default: space).
  - `newline`: String used for line breaks (default: "\\n").
  - `templateValueStart`: Start delimiter for interpolation placeholders (default: "{{").
  - `templateValueEnd`: End delimiter for interpolation placeholders (default: "}}").

-}
type alias TextBlockOptions =
    { indent : Int
    , indentChar : Char
    , newline : String
    , templateValueStart : String
    , templateValueEnd : String
    }


{-| Default configuration for text block processing.

Use as-is or customize fields, e.g., `{ defaultOptions | indent = 2, indentChar = '.' }`.

-}
defaultOptions : TextBlockOptions
defaultOptions =
    { indent = 0
    , indentChar = ' '
    , newline = "\n"
    , templateValueStart = "{{"
    , templateValueEnd = "}}"
    }


{-| Process a multiline string with default options, removing unwanted leading indentation.

    textBlock
        """
        <div>
            <p>Hello</p>
        </div>
        """
    -- "<div>\n    <p>Hello</p>\n</div>"

Supports backslash (`\`) for newline escaping and pipe (`|`) for preserving trailing spaces.

-}
textBlock : String -> String
textBlock value =
    textBlockWith defaultOptions value


{-| Process a multiline string with custom options.

    textBlockWith { defaultOptions | indent = 2, indentChar = '.' }
        """
        <div>
            <p>Hello</p>
        </div>
        """
    -- "..<div>\n..    <p>Hello</p>\n..</div>"

Supports backslash (`\`) for newline escaping and pipe (`|`) for preserving trailing spaces.

-}
textBlockWith : TextBlockOptions -> String -> String
textBlockWith options value =
    let
        lines : List String
        lines =
            splitLines options value

        indentSize : Int
        indentSize =
            lines
                |> List.map (\line -> Regex.find beginsWithWhitespace line)
                |> List.filterMap List.head
                |> List.map (\match -> String.length match.match)
                |> List.minimum
                |> Maybe.withDefault 0

        blockedLines : List String
        blockedLines =
            lines
                |> List.map (\line -> trimStart line indentSize)
                |> List.map String.trimRight
                |> List.map
                    (\line ->
                        if String.endsWith "|" line then
                            String.dropRight 1 line

                        else
                            line
                    )

        contentLines : List String
        contentLines =
            case List.reverse blockedLines |> List.head of
                Just "" ->
                    List.take (List.length blockedLines - 1) blockedLines

                _ ->
                    blockedLines

        joined : String
        joined =
            case contentLines of
                [] ->
                    ""

                [ single ] ->
                    single

                first :: rest ->
                    List.foldl
                        (\r l ->
                            if String.endsWith "\\" l then
                                String.dropRight 1 l ++ r

                            else
                                let
                                    paddedRight : String
                                    paddedRight =
                                        String.padLeft (String.length r + options.indent) options.indentChar r
                                in
                                l ++ options.newline ++ paddedRight
                        )
                        first
                        rest

        padded : String
        padded =
            String.padLeft (String.length joined + options.indent) options.indentChar joined
    in
    padded


beginsWithWhitespace : Regex.Regex
beginsWithWhitespace =
    Regex.fromString "^([\\s]+)"
        |> Maybe.withDefault Regex.never


{-| Process a multiline string with custom options and replace placeholders with values.

    textBlockWithFormat defaultOptions
        [ ( "name", "World" ) ]
        """
        Hello {{name}}!
        """
    -- "Hello World!"

Placeholders are defined by `templateValueStart` and `templateValueEnd` in `TextBlockOptions`.

-}
textBlockWithFormat : TextBlockOptions -> List ( String, String ) -> String -> String
textBlockWithFormat options replacements template =
    let
        base =
            textBlockWith options template
    in
    List.foldl
        (\( key, value ) str -> String.replace (options.templateValueStart ++ key ++ options.templateValueEnd) value str)
        base
        replacements


splitLines : TextBlockOptions -> String -> List String
splitLines options value =
    let
        newlineLeftStripped : String
        newlineLeftStripped =
            if String.startsWith options.newline value then
                String.dropLeft 1 value

            else
                value
    in
    newlineLeftStripped
        |> String.split options.newline


trimStart : String -> Int -> String
trimStart line trimSize =
    let
        spacePadding : String
        spacePadding =
            String.repeat trimSize " "

        tabPadding : String
        tabPadding =
            String.repeat trimSize "\t"
    in
    if String.startsWith spacePadding line || String.startsWith tabPadding line then
        String.dropLeft trimSize line

    else
        String.trimLeft line
