int main(int argc, char** argv) {
	mount("/dev/sda2", "/", "ext4", 32, 0);
        mount("dev", "/dev", "devtmpfs", 0, 0);
        mount("sysfs", "/sys", "sysfs", 0, 0);
        mount("procfs", "/proc", "proc", 0, 0);

        setenv("HOME", "/root", 1);
	setenv("PATH", "/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin", 1);



        int pid;
        if((pid = fork()) == 0) {
		chdir("/");
		execl("/bin/shell", "/bin/shell", 0);
        } else {
                wait(&pid);

		while(1) {}
                reboot(0x4321FEDC);
        }


        return 0;
}
