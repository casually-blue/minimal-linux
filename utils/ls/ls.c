#include<sys/types.h>
#include<sys/stat.h>
#include<unistd.h>
#include<string.h>
#include<dirent.h>

void ls(char *path)
{
	struct stat st;
	if(stat(path, &st) == -1)
	{
		return;
	}

	if(S_ISDIR(st.st_mode))
	{
		DIR *dir = opendir(path);
		if(dir == NULL)
		{
			return;
		}

		struct dirent *d;
		while((d = readdir(dir)) != NULL)
		{
			write(0, d->d_name, strlen(d->d_name));
			write(0, "\n", 1);
		}
		closedir(dir);
	}
	else
	{
		write(0, path, strlen(path));
		write(0, "\n", 1);
	}

}

int main(int argc, char *argv[])
{
	ls("/");
	return 0;
}
