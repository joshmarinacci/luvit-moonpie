#include <stdio.h>
#include "joshpi.h"


int main(void)
{
    puts("this is a test");
    foo();
    PWindow *window = createDefaultWindow();
    printf("got a pwindow with size %d x %d\n",window->screen_width, window->screen_height);
    return 0;
}
