OUTPUT_ARCH( "riscv" )
ENTRY(_start)

/**
 * Heap size for dynamic memory allocation
 */
_Heap_Size = 0x10000;

/**
 * Stack size PER-CORE
 */
StackShift = 12;
StackSize = 1 << 12;


/* Specify the memory areas */
MEMORY
{
  /* L1 TCDM memory */
  L1 (xrw)         : ORIGIN = 0x00100000, LENGTH = 2048K
  /*Block memory for program*/
  BRAM (xrw)       : ORIGIN = 0x80000000, LENGTH = 512K
  /* Simultaion, tohost stuff */
  HOSTCOM(rw)      : ORIGIN = 0x00000000, LENGTH = 1K
}


/* Define output sections */
SECTIONS
{
  /* The program code and other data goes into BRAM */
  .text :
  {
    . = ALIGN(4);
    *(.text.init)
    *(.text.startup)
    *(.text)
    *(.text*)
    *(.text)

    . = ALIGN(4);
    _etext = .;        /* define a global symbols at end of code */
  } >BRAM
  
  /* Constant data goes into BRAM */
  .rodata :
  {
    . = ALIGN(4);
    *(.rodata)         /* .rodata sections (constants, strings, etc.) */
    *(.rodata*)        /* .rodata* sections (constants, strings, etc.) */
    . = ALIGN(4);
  } >BRAM
  
  /* used by the startup to initialize data */
  _sidata = LOADADDR(.data);
  
  /* Initialized data sections goes into L1, load LMA copy after code */
  .data : 
  {
    . = ALIGN(8);
    __global_pointer$ = . + (4K / 2);
    _sdata = .;        /* create a global symbol at data start */
    *(.data .data.*)   /* .data sections */
    *(.sdata)           /* .sdata sections */
    *(.data*)          /* .data* sections */

    . = ALIGN(4);
    _edata = .;        /* define a global symbol at data end */
  } >L1 AT> BRAM

  /* Uninitialized data section */
  . = ALIGN(4);
  .bss :
  {
    /* This is used by the startup in order to initialize the .bss secion */
    _sbss = .;         /* define a global symbol at bss start */
    __bss_start__ = _sbss;
    *(.sbss .sbss*) /* sbss is for small bss for quicker addressing */
    *(.sbss2 .sbss2.* .gnu.linkonce.sb2.*)
    *(.bss .bss*)

    . = ALIGN(4);
    _ebss = .;         /* define a global symbol at bss end */
    __bss_end__ = _ebss;
  } >L1

  /* heap section, used to check that there is enough RAM left */
  ._user_heap (NOLOAD) :
  {
    . = ALIGN(4);
    PROVIDE ( _sheap = . );
    . = . + _Heap_Size;
    PROVIDE ( _eheap = . );
    . = ALIGN(4);
  } >L1


  /*---------------------*/
  /* Host communitation  */
  /*---------------------*/

  .tohost (NOLOAD) :
  {
    /* vsim somehow fails to finish if toost is at 0x00*/
    . = . + 0x40;
    /* syscalls from snitch to SoC. each is a uint64_t */
    tohost    = ALIGN(4);
    /* make room for 8 tohosts for each core one. 8*64bit */
    . = . + 0x50;
    fromhost  = ALIGN(4);
    . = . + 0x50;

    /* l3 start and size. Host writes to these */
    __l3_base = ALIGN(4);
    . = . + 0x10;
    __l3_size = ALIGN(4);
    . = . + 0x10;
  } > HOSTCOM

}

/*------------------*/
/* Constant symbols */
/*------------------*/

/*Cluster peripheral*/  
tcdm_start_address_reg = 0x40000000;
tcdm_end_address_reg = 0x40000008;
nr_cores_address_reg = 0x40000010;
fetch_enable_reg = 0x40000018;
scratch_reg = 0x40000020;
wake_up_reg = 0x40000028;
cycle_count_reg = 0x40000030;
barrier_reg = 0x40000038;
cluster_base_hart_id_reg = 0x40000040;

/*SSR Config*/
ssr_config_reg = 0x204800;

/*for RTL simulation*/
eoc_address = 0xD0000000;
fake_uart = 0xC0000000;
