#include<stdio.h>


int add(int a, int b);

int main()
{
    int a = 10;
    int b = 20;
    int c = a + 5;
    if(a > b) {
        c = c + a;
        if(a > b) {
            c = c + a;
        }
        else {
            c = c + b;
        }
    }
    else if(a < b) {
        c = c + b;
    }
    else {
        c = c + b;
    }
    switch(a>b) {
        case 0:
            c = c + a;
            break;
        case 1:
            c = c + b;
        default:
            c = c + a;
    }
    for(a = 0; a < b; a++) {
        c = c + a;
    }

    while(a < b) {
        a++;
    }

    return c;
}

int add(int a, int b) {
    return a + b;
}
