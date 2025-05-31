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
            computeIndentSize lines

        contentLines : List String
        contentLines =
            computeContentLines lines indentSize

        joined : String
        joined =
            joinLines options contentLines

        padded : String
        padded =
            String.repeat options.indent (String.fromChar options.indentChar) ++ joined ++ ""
    in
    padded


joinLines : TextBlockOptions -> List String -> String
joinLines options contentLines =
    case contentLines of
        [] ->
            ""

        [ single ] ->
            single

        "" :: line :: [] ->
            line

        "" :: line :: rest ->
            joinLinesHelp options line rest

        line :: rest ->
            joinLinesHelp options line rest


joinLinesHelp : TextBlockOptions -> String -> List String -> String
joinLinesHelp options startAcc lines =
    List.foldl
        (\line acc ->
            if String.endsWith "\\" line then
                String.dropRight 1 line ++ acc ++ ""

            else
                let
                    paddedRight : String
                    paddedRight =
                        String.padLeft (String.length acc + options.indent) options.indentChar acc
                in
                line ++ options.newline ++ paddedRight ++ ""
        )
        startAcc
        lines


computeIndentSize : List String -> Int
computeIndentSize lines =
    case lines of
        line :: restOfLines ->
            case Regex.find beginsWithWhitespace line of
                { match } :: _ ->
                    computeIndentSizeWithMinimum (String.length match) restOfLines

                _ ->
                    computeIndentSize restOfLines

        [] ->
            0


computeIndentSizeWithMinimum : Int -> List String -> Int
computeIndentSizeWithMinimum minimum lines =
    case lines of
        line :: restOfLines ->
            case Regex.find beginsWithWhitespace line of
                { match } :: _ ->
                    computeIndentSizeWithMinimum
                        (min (String.length match) minimum)
                        restOfLines

                _ ->
                    computeIndentSizeWithMinimum minimum restOfLines

        [] ->
            minimum


computeContentLines : List String -> Int -> List String
computeContentLines lines indentSize =
    List.foldl
        (\line acc -> trimLine line indentSize :: acc)
        []
        lines


trimLine : String -> Int -> String
trimLine line indentSize =
    let
        newLine : String
        newLine =
            trimStart line indentSize
                |> String.trimRight
    in
    if String.endsWith "|" newLine then
        String.dropRight 1 newLine

    else
        newLine


beginsWithWhitespace : Regex.Regex
beginsWithWhitespace =
    Regex.fromString "^(\\s+)"
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
        (\( key, value ) str -> String.replace (options.templateValueStart ++ key ++ options.templateValueEnd ++ "") value str)
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
    if
        String.startsWith (String.repeat trimSize " ") line
            || String.startsWith (String.repeat trimSize "\t") line
    then
        String.dropLeft trimSize line

    else
        String.trimLeft line
