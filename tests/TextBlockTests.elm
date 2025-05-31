module TextBlockTests exposing (..)

import Expect
import Test exposing (..)
import TextBlock exposing (..)


emptyValueTests : Test
emptyValueTests =
    test "Can read empty multiline string return empty string" <|
        \() ->
            let
                testValue : String
                testValue =
                    """
            """
            in
            textBlock testValue
                |> Expect.equal ""


simpleValueTests : Test
simpleValueTests =
    test "Can read simple value return unchanged value" <|
        \() ->
            let
                testValue : String
                testValue =
                    """Hello"""
            in
            textBlock testValue
                |> Expect.equal "Hello"


simpleValueTwoLineTests : Test
simpleValueTwoLineTests =
    test "Can read simple value on two lines and return single value" <|
        \() ->
            let
                testValue : String
                testValue =
                    """
                    Hello"""
            in
            textBlock testValue
                |> Expect.equal "Hello"


oneLineValueTests : Test
oneLineValueTests =
    test "One line string gets returned with no padding" <|
        \() ->
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
            textBlock testValue
                |> Expect.equal expected


twoLineValueTests : Test
twoLineValueTests =
    test "Two line string gets returned with no padding" <|
        \() ->
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
            textBlock testValue
                |> Expect.equal expected


newLineEscapeTests : Test
newLineEscapeTests =
    test "Newlines omitted when \\ is used at end of line" <|
        \() ->
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
    test "Lines ending in | keep trailing spaces" <|
        \() ->
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
    test "Embedded newline characters create new lines" <|
        \() ->
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
            textBlock testValue
                |> Expect.equal expected


formatStringTests : Test
formatStringTests =
    test "Can be parsed and replace template values" <|
        \() ->
            let
                testValue : String
                testValue =
                    """
                    Hello {{name}},

                    Goodbye
                    """

                expected =
                    "Hello Chris,\n\nGoodbye"
            in
            textBlockWithFormat defaultOptions [ ( "name", "Chris" ) ] testValue
                |> Expect.equal expected
