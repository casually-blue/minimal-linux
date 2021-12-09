#include<unistd.h>
#include<sys/mount.h>

int main(void) {
        mount("-", "/dev", "devtmpfs", 0, NULL);        

        char* params[] = {"/bin/ion"};
        execl("/bin/ion", "ion", NULL);

        return 0;
}
