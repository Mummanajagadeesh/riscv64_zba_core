ENTRY(_start)

SECTIONS
{
  /* Program starts at address 0x0 */
  . = 0x00000000;

  /* Code section */
  .text : {
    *(.text*)
  }

  /* Read-only data (not really used, but safe) */
  .rodata : {
    *(.rodata*)
  }

  /* Initialized data */
  .data : {
    *(.data*)
  }

  /* Uninitialized data */
  .bss : {
    *(.bss*)
    *(COMMON)
  }

  /* Discard everything else */
  /DISCARD/ : {
    *(.comment*)
    *(.note*)
    *(.eh_frame*)
  }
}
