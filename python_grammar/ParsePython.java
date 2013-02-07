import antlr.*;

public class ParsePython
{
    public static void main(String[] args) throws Exception
    {
        PythonLexer lexer = new PythonLexer(System.in);
        PythonParser parser = new PythonParser(lexer);
        parser.expr();
    }
}
