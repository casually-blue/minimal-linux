#include<unistd.h>
#include<sys/mount.h>

int main(void) {
        mount("-", "/dev", "devtmpfs", 0, NULL);        
        write(1, "Hello World!\n", 13);

        while(1) {

        }
        return 0;
}
