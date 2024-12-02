import Parsing

let input = """
<copy input here>
"""

struct MainParser: Parser {
    var body: some Parser<Substring, String> {
        Rest().map(String.init)
    }
}

print(try MainParser().parse(input))
