#include<stdarg.h>
#include<string.h>

void write_decimal(int n)
{
	if(n<0)
	{
		write(0, "-", 1);
		n=-n;
	}
	if(n>9)
		write_decimal(n/10);
	char c=n%10+'0';
	write(0, &c, 1);
}

int printf(const char *format, ...) {
	va_list args;
	va_start(args, format);

	char* temp;

	while (*format) {
		if (*format == '%') {
			format++;
			switch (*format) {
				case 'd':
					write_decimal(va_arg(args, int));
					break;
				case 's':
					temp = va_arg(args, char*);
					write(0, temp, strlen(temp));
					break;
				case '%':
					write(0, "%", 1);
					break;
			}
		} else {
			write(0, format, 1);
		}
		format++;
	}
}
