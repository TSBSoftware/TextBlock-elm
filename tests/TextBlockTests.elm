module TextBlockTests exposing (..)

import Expect
import Test exposing (..)
import TextBlock exposing (..)


emptyValueTests : Test
emptyValueTests =
    let
        testValue : String
        testValue =
            """
            """
    in
    test "Can read empty multiline string return empty string" <|
        \() ->
            textBlock testValue
                |> Expect.equal ""


simpleValueTests : Test
simpleValueTests =
    let
        testValue : String
        testValue =
            """Hello"""
    in
    test "Can read simple value return unchanged value" <|
        \() ->
            textBlock testValue
                |> Expect.equal "Hello"


simpleValueTwoLineTests : Test
simpleValueTwoLineTests =
    let
        testValue : String
        testValue =
            """
            Hello"""
    in
    test "Can read simple value on two lines and return single value" <|
        \() ->
            textBlock testValue
                |> Expect.equal "Hello"


oneLineValueTests : Test
oneLineValueTests =
    let
        testValue : String
        testValue =
            """
            Hello, World!
            """

        expected : String
        expected =
            "Hello, World!"
    in
    test "One line string gets returned with no padding" <|
        \() ->
            textBlock testValue
                |> Expect.equal expected


twoLineValueTests : Test
twoLineValueTests =
    let
        testValue : String
        testValue =
            """
            Hello, World!
            I am me.
            """

        expected : String
        expected =
            "Hello, World!\nI am me."
    in
    test "Two line string gets returned with no padding" <|
        \() ->
            textBlock testValue
                |> Expect.equal expected


newLineEscapeTests : Test
newLineEscapeTests =
    let
        testValue : String
        testValue =
            "\n"
                ++ "    Hello, World! \\\n"
                ++ "    I am me. \\\n"
                ++ "    Who are you?\n"
                ++ "    "

        expected : String
        expected =
            "Hello, World! I am me. Who are you?"
    in
    test "Newlines omitted when \\ is used at end of line" <|
        \() ->
            textBlock testValue
                |> Expect.equal expected


indentedContentTests : Test
indentedContentTests =
    describe "Indented content"
        [ test "is preserved using spaces" <|
            \() ->
                let
                    testValue : String
                    testValue =
                        """
                        <div>
                            <p>Hello</p>
                        </div>
                        """

                    expected : String
                    expected =
                        "<div>\n    <p>Hello</p>\n</div>"
                in
                textBlock testValue
                    |> Expect.equal expected
        , test "is preserved using tabs" <|
            \() ->
                let
                    testValue : String
                    testValue =
                        """
                        <div>
                        \t<p>Hello</p>
                        </div>
                        """

                    expected : String
                    expected =
                        "<div>\n\t<p>Hello</p>\n</div>"
                in
                textBlock testValue
                    |> Expect.equal expected
        , test "with first line indented preserves indentation" <|
            \() ->
                let
                    testValue : String
                    testValue =
                        """
                            <p>Hello</p>
                        </div>
                        """

                    expected : String
                    expected =
                        "    <p>Hello</p>\n</div>"
                in
                textBlock testValue
                    |> Expect.equal expected
        , test "preserves all indentation when not lined up with quotes" <|
            \() ->
                let
                    testValue : String
                    testValue =
                        """
                                <p>Hello</p>
                            </div>
                        """

                    expected : String
                    expected =
                        "        <p>Hello</p>\n    </div>"
                in
                textBlock testValue
                    |> Expect.equal expected
        ]


trailingSpaceTests : Test
trailingSpaceTests =
    let
        testValue : String
        testValue =
            """
            This text must    |
            be blocked        |
            """

        expected : String
        expected =
            "This text must    \nbe blocked        "
    in
    test "Lines ending in | keep trailing spaces" <|
        \() ->
            textBlock testValue
                |> Expect.equal expected


userDefinedIndentTests : Test
userDefinedIndentTests =
    let
        testValue : String
        testValue =
            """
            A
             B
              C
            """
    in
    describe "User defined indent"
        [ test "Indentation can be controlled with options" <|
            \() ->
                let
                    expected : String
                    expected =
                        "    A\n     B\n      C"

                    options : TextBlockOptions
                    options =
                        { defaultOptions
                            | indent = 4
                        }
                in
                textBlockWith options testValue
                    |> Expect.equal expected
        , test "Indentation can use an alternate character" <|
            \() ->
                let
                    expected : String
                    expected =
                        "++++A\n++++ B\n++++  C"

                    options : TextBlockOptions
                    options =
                        { defaultOptions
                            | indent = 4
                            , indentChar = '+'
                        }
                in
                textBlockWith options testValue
                    |> Expect.equal expected
        ]


mixedFeatureTests : Test
mixedFeatureTests =
    let
        testValue : String
        testValue =
            """
              A
            B  |

            C\\
             D\\
              EF
GH
            """

        expected : String
        expected =
            "+  A\n+B  \n+\n+C D  EF\n+GH"

        options : TextBlockOptions
        options =
            { defaultOptions
                | indent = 1
                , indentChar = '+'
            }
    in
    test "All features mixed produce proper string" <|
        \() ->
            textBlockWith options testValue
                |> Expect.equal expected


embededNewlineTests : Test
embededNewlineTests =
    let
        testValue : String
        testValue =
            """
            Name | Address | City
            Bob Smith | 123 Anytown St
Apt 100 | Vancouver
            Jon Brown | 1000 Golden Place
Suite 5 | Santa Ana
            """

        expected : String
        expected =
            "Name | Address | City\n"
                ++ "Bob Smith | 123 Anytown St\n"
                ++ "Apt 100 | Vancouver\n"
                ++ "Jon Brown | 1000 Golden Place\n"
                ++ "Suite 5 | Santa Ana"
    in
    test "Embedded newline characters create new lines" <|
        \() ->
            textBlock testValue
                |> Expect.equal expected


formatStringTests : Test
formatStringTests =
    let
        testValue =
            """
            Hello {{name}},

            Goodbye
            """

        expected =
            "Hello Chris,\n\nGoodbye"
    in
    test "Can be parsed and replace template values" <|
        \() ->
            textBlockWithFormat defaultOptions [ ( "name", "Chris" ) ] testValue
                |> Expect.equal expected
