#include<unistd.h>
#include<sys/mount.h>
#include<sys/syscall.h>
#include<sys/reboot.h>
#include<fcntl.h>
#include<string.h>


int main(int argc, char** argv) {
        mount("-", "/dev", "devtmpfs", 0, NULL);        


        int pid = fork();
        if(pid == 0) {
                int spid = setsid();
                setpgid(0, spid);
                ioctl(0, TIOCSCTTY, 1);

                close(0);
                int fd = open("/dev/tty0", O_RDWR | O_NONBLOCK, 0);
                dup2(STDIN_FILENO, STDOUT_FILENO);
                dup2(STDIN_FILENO, STDERR_FILENO);

                if(!isatty(0)) {
                        write(0, "stdin not tty\n", 14);
                }

                char* params[] = {"/bin/ion"};
                execl("/bin/ion", "ion", NULL);
        } else {
                write(0, "launched process\n", 17);

                wait(pid);
                reboot(RB_POWER_OFF);
        }


        return 0;
}
