#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>

#define STDIO_OUT_REG (*(volatile uint32_t *) 0x40000000)
#define STDIO_IN_REG  (*(volatile uint32_t *) 0x40000004)

static void print(const char *str)
{
	while (*str != '\0') {
		STDIO_OUT_REG = *str++ & 0xFF;
	}
}

int main(void)
{
  print("the world is a moving target ....\r\n");

  while (true)
  {
    /* Sleep forever */
    uint32_t v = STDIO_IN_REG & 0xFFu;

    if (v != 0)
    {
       if (v >= 'a' && v <= 'z')
       {
          v = 'a' + ((v - 'a' + 13) % 26);
       }
       else if (v >= 'A' && v <= 'Z')
       {
          v = 'A' - ((v - 'A' + 13) % 26);
       }

       STDIO_OUT_REG = v;
    }
  }
  return 0;
}
