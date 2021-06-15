.globl _start
.section .text.init;
_start:
    ## Initialize global pointer
    .option push
    .option norelax
    1:auipc gp, %pcrel_hi(__global_pointer$)
      addi  gp, gp, %pcrel_lo(1b)
    .option pop
    /* reset vector */
    j reset_vector
.section .text;
reset_vector:
    li      x1, 0
    li      x4, 0
    li      x5, 0
    li      x6, 0
    li      x7, 0
    li      x8, 0
    li      x9, 0
    li      x10, 0
    li      x11, 0
    li      x12, 0
    li      x13, 0
    li      x14, 0
    li      x15, 0
    li      x16, 0
    li      x17, 0
    li      x18, 0
    li      x19, 0
    li      x20, 0
    li      x10, 0
    li      x21, 0
    li      x22, 0
    li      x23, 0
    li      x24, 0
    li      x25, 0
    li      x26, 0
    li      x27, 0
    li      x28, 0
    li      x29, 0
    li      x30, 0
    li      x31, 0
    ## get system info
    la      sp, tcdm_end_address_reg # load stack top from peripheral register
    lw      sp, 0(sp)
    ## get hart id and number of cores in the cluster
    csrr    a0, mhartid
    la      a1, nr_cores_address_reg # get the number of cores per cluster
    lw      a1, 0(a1)
    # check if the core has the F-extension
    csrr    t0, misa
    andi    t0, t0, (1 << 5)
    beqz    t0, data_init
    ## clear FP registers
    # fmv.w.x f0, x0
    # fmv.w.x f1, x0
    # fmv.w.x f4, x0
    # fmv.w.x f5, x0
    # fmv.w.x f6, x0
    # fmv.w.x f7, x0
    # fmv.w.x f8, x0
    # fmv.w.x f9, x0
    # fmv.w.x f10, x0
    # fmv.w.x f11, x0
    # fmv.w.x f12, x0
    # fmv.w.x f13, x0
    # fmv.w.x f14, x0
    # fmv.w.x f15, x0
    # fmv.w.x f16, x0
    # fmv.w.x f17, x0
    # fmv.w.x f18, x0
    # fmv.w.x f19, x0
    # fmv.w.x f20, x0
    # fmv.w.x f10, x0
    # fmv.w.x f21, x0
    # fmv.w.x f22, x0
    # fmv.w.x f23, x0
    # fmv.w.x f24, x0
    # fmv.w.x f25, x0
    # fmv.w.x f26, x0
    # fmv.w.x f27, x0
    # fmv.w.x f28, x0
    # fmv.w.x f29, x0
    # fmv.w.x f30, x0
    # fmv.w.x f31, x0

    ## Init data
data_init:
    # skip data init, banshee has done that for us already..
#if defined(BANSHEE)
    j stack_init
#endif
    # only core0 should do data init
    addi x26, x0, 0
    bne a0, x26, stack_init

    ## Clear BSS
#ifndef SIMULATION
    la x26, _sbss
    la x27, _ebss

    bge x26, x27, zero_loop_end

    zero_loop:
        sw x0, 0(x26)
        addi x26, x26, 4
        ble x26, x27, zero_loop
    zero_loop_end:
#endif

    ## Copy data init
    la      t0, _sdata
    la      t1, _edata
    la      t2, _sidata
    j   loop_copy_data_init

    copy_data_init:
        lw  x29, 0(t2)
        sw  x29, 0(t0)
        
        addi    t0, t0, 4
        addi    t2, t2, 4

    loop_copy_data_init:
        bltu t0, t1, copy_data_init

stack_init:
    la      t0, cluster_base_hart_id_reg
    lw      a2, 0(t0)
    sub     t0, a0, a2
    la      t1, StackShift # set some stack-space aside for each hart
    sll     t0, t0, t1 
    sub     sp, sp, t0

# word-wise pattern fill of stack to verify stack usage
# takes ~5us at 80MHz
#ifndef SIMULATION
# StackFill:
#     # t0 holds pointer to stack
#     add     t0, x0, sp
#     # load 0x54545454 to t1 as fill pattern
#     lui     t1, 0x54545
#     addi    t1, t1, 0x454
#     # t3 contains number of bytes in stack
#     la      t2, StackShift # set some stack-space aside for each hart
#     addi    t3, x0, 1
#     sll     t3, t3, t2
# StackFillLoop:
#     # store pattern word at current pointer
#     sw      t1, 0(t0)
#     # decrement pointer in word increments
#     addi    t0, t0, -4
#     # decrement counter
#     addi    t3, t3, -4
#     # branch if not done
#     bne     t3, x0, StackFillLoop
#endif

rdy:
    # ## Put all cores to sleep so that they can be started if necessary
    # wfi
run:
    # call    __libc_init_array
    call    main
eoc:
    la t0, eoc_address
    sw a0, 0(t0)
    # write exit code and done bit
    csrr      t0, mhartid
    bnez      t0, done # only write exit code for core 0
    la        t1, tohost
    slli      a0, a0, 1
    ori       a0, a0, 1
    sw        a0, 0(t1)
    # write exit code for banshee
    li        t0, 0x40000020
    sw        a0, 0(t0)
    # goto done
    jal x0, done
fail:
    la t0, eoc_address
    sw a0, 0(t0)
    jal x0, done
done:
    wfi
    j done

# .section ".eoc_address","aw",@progbits
# .align 6
# .globl eoc_address
# eoc_address: .dword 0

.section .text
.section .data
