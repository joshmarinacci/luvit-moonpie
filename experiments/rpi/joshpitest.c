#include <stdio.h>
#include "joshpi.h"


int main(void)
{
    puts("this is a test");
    foo();
    PWindow *window = createDefaultWindow();
    printf("got a pwindow with size %d x %d\n",window->screen_width, window->screen_height);
    printf("doing more\n");
    
//    int i = 0;
    while(1) {
        int x, y;
        int key, state;
        int buttons = get_mouse(window->screen_width, window->screen_height, &x, &y);
        //printf("mouse = %d %d x %d\n", buttons,x,y);
        int keyboard = get_keyboard(&key,&state);
        printf("key = %d\n",key);
    }
    return 0;
}
