#include <stdio.h> // Preprocessor directive for input/output
#include <math.h>  // Another one to test multiple includes

// This is a single-line comment

/*
  This is a multi-line comment
  Spanning multiple lines
*/

int add(int a, int b)
{
    return a + b;
}

float subtract(float x, float y)
{
    return x - y;
}

char getChar()
{
    char ch = 'Z';
    return ch;
}

int main()
{
    int num = 100;
    float pi = +3.14159;
    char letter = 'A';
    char message[] = "Hello, Lexer!";

    // Calling functions
    int result = add(10, 20);
    float diff = subtract(5.5, 2.2);
    char c = getChar();

    // Arithmetic
    int expr = num + 5 * (3 - 1) / 2 % 4;
    $

        return 0;
}
