from pathlib import Path
from os.path import abspath


TOP_LEVEL_CONSTANT = 1


class myClass:
    def bar(self) -> int: ...

    def foo(self): ...


def main() -> int:
    """ """
    variable: int = 123
    dictionary = {
        "key": "string value",
    }
    f_string = f"hello {variable}"
    mult_line_f_string = f"""\
        hello {variable}"
        {dictionary}
    """

    ###########################
    # sql embedded highlight testing
    _embedded_single_line_sql = "SELECT * FROM table WHERE column = {variable}"
    _embedded_single_line_sql = "UPDATE table SET column = {variable}"
    _embedded_multi_line_sql = """\
        SELECT * FROM table
        WHERE column = {variable}
    """
    _embedded_multi_line_sql_with_no_first_line_escape = """
        UPDATE table
        SET a=1
        WHERE column = {variable} -- this is a comment
    """
    _embedded_multi_line_sql_with_no_first_line_escape = """
        SELECT * FROM table
        WHERE column = {variable}
    """
    _embedded_multi_line_sql_with_comment_on_first_line = """\
        -- this is a comment
        SELECT * FROM table
    """
    _embedded_multi_line_sql_with_comment_on_first_line = """\
        -- this is a comment
        UPDATE table
        SET a=1
        WHERE column = {variable} -- this is a comment
    """
    _embedded_multi_line_sql_with_f_string = f"""\
        -- this is a comment
        SELECT * FROM table WHERE val = {variable}
    """
    _non_sql_string = """
        help me SELECT an option
    """
    ###########################

    template_string = "hello {{variable}}"
    mult_line_template_string = """\
        hello {variable}"
        {dictionary}
    """
    abspath("ssdfa")
    # This is a comment

    # TODO: this is a todo comment

    # FIXME: this is a todo comment

    # WARN: this is a todo comment

    # ALT: this is a todo comment tyop

    # ! this is a warning comment
    variable = 1 + "str"
    ## build a deep dictionary
    d = {"a": {"a": {"a": {}}}}
    a = True
    b = None
    if True:
        print(variable)
        if False:
            print(variable)

    print(variable)

    def a():
        print("a")

        def b(): ...

    for i in [1, 2, 3]:
        print(i)

    a = [
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
        """""" """""" """""" """""" """""" """""",
    ]
    """ """
    variable: int = 123
    dictionary = {
        "key": "string value",
    }
    abspath("ssdfa")
    # This is a comment

    # TODO: this is a todo comment

    # FIXME: this is a todo comment

    # WARN: this is a todo comment

    # ALT: this is a todo comment typo

    # ! this is a warning comment
    variable = 1 + "str"

    print(variable)

    for i in [1, 2, 3]:
        print(i)

    a = [
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
        """""" """""" """""" """""" """""" """""",
    ]

    return None


if __name__ == "__main__":
    main()
