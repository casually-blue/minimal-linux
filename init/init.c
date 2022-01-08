#include<unistd.h>
#include<sys/mount.h>
#include<sys/syscall.h>
#include<sys/reboot.h>
#include<sys/wait.h>
#include<fcntl.h>
#include<stdlib.h>

int assign_tty(char* tty) {
        close(0);
        int fd = open(tty, O_RDWR |  O_NONBLOCK, 0);
        dup2(STDIN_FILENO, STDOUT_FILENO);
        dup2(STDIN_FILENO, STDERR_FILENO);

        if(!isatty(0)) {
                write(0, "stdin not tty\n", 14);
        }

        return fd;
}

void setup_gid() {
        int spid = setsid();
        setpgid(0, spid);
        ioctl(0, TIOCSCTTY, 1);
}

int main(int argc, char** argv) {
	mount("/dev/sda2", "/", "ext4", MS_REMOUNT | MS_RELATIME, NULL);
        chdir("/");

        mount("dev", "/dev", "devtmpfs", 0, NULL);
        mount("sysfs", "/sys", "sysfs", 0, NULL);
        mount("procfs", "/proc", "proc", 0, NULL);

        setenv("HOME", "/root", 1);



        int pid;
        if((pid = fork()) == 0) {
                setup_gid();
                assign_tty("/dev/tty0");

                execl("/bin/ion", "ion", NULL);
        } else {
                wait(&pid);

                reboot(RB_POWER_OFF);
        }


        return 0;
}
