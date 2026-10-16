
/* ------------------- */
/* Stack Configuration */
    .syntax unified
  .cpu cortex-m3
  .fpu softvfp
  .thumb

    .section .stack
    .align 3
#ifdef __STACK_SIZE
    .equ    Stack_Size, __STACK_SIZE
#else
    .equ    Stack_Size, 0x00000400
#endif
    .globl __StackTop
    .globl __StackLimit
__StackLimit:
    .space Stack_Size
    .size __StackLimit, . - __StackLimit
__StackTop:
    .size __StackTop, . - __StackTop

/* ------------------ */
/* Heap Configuration */

    .section .heap
    .align 3
#ifdef __HEAP_SIZE
    .equ    Heap_Size, __HEAP_SIZE
#else
    .equ    Heap_Size,  0x00000000
#endif
    .globl __HeapBase
    .globl __HeapLimit
__HeapBase:
    .if Heap_Size
    .space Heap_Size
    .endif
    .size __HeapBase, . - __HeapBase
__HeapLimit:
    .size __HeapLimit, . - __HeapLimit


/* ----------------------------------------------------- */
/* Vector Table */

// .equ BootRAM, 0xF108F85F

    .section .isr_vector
    .align 2
    .globl __isr_vector
__isr_vector:
    .long __StackTop
    .long Reset_Handler
    .long NMI_Handler
    .long HardFault_Handler
    .long MemManage_Handler
    .long BusFault_Handler
    .long UsageFault_Handler
    .long 0
    .long 0
    .long 0
    .long 0
    .long SVC_Handler
    .long DebugMonitor_Handler
    .long 0
    .long PendSV_Handler
    .long SysTick_Handler

    /* External Interrupts */
    /* External Interrupts : maximum of 70 External Interrupts are possible */
    .word DMA_IRQHandler
    .word CACHE_IRQHandler
    .word RCC_IRQHandler
    .word FMC_IRQHandler
    .word KSIO_IRQHandler
    .word VCI_IRQHandler
    .word PWRSW_IRQHandler
    .word Default_IRQHandler
    .word Default_IRQHandler
    .word Default_IRQHandler
    .word Default_IRQHandler
    .word PECI_IRQHandler
    .word ESPI_SLAVE_IRQHandler
    .word ESPI_ERR_IRQHandler
    .word MAILBOX_IRQHandler
    .word KBC8042_IRQHandler
    .word ACPI0_IRQHandler
    .word ACPI1_IRQHandler
    .word ACPI2_IRQHandler
    .word Default_IRQHandler
    .word Default_IRQHandler
    .word Default_IRQHandler
    .word SPI0_IRQHandler
    .word SPI1_IRQHandler
    .word SPI2_IRQHandler
    .word SPI3_IRQHandler
    .word I2C0_IRQHandler
    .word I2C1_IRQHandler
    .word I2C2_IRQHandler
    .word I2C3_IRQHandler
    .word I2C4_IRQHandler
    .word USART2_IRQHandler
    .word USART3_IRQHandler
    .word FAN_IN0_IRQHandler
    .word FAN_IN1_IRQHandler
    .word FAN_IN2_IRQHandler
    .word FAN_IN3_IRQHandler
    .word PWM0_IRQHandler
    .word PWM1_IRQHandler
    .word PWM2_IRQHandler
    .word PWM3_IRQHandler
    .word PWM4_IRQHandler
    .word PWM5_IRQHandler
    .word ACMP1_IRQHandler
    .word TIM0_IRQHandler
    .word TIM1_IRQHandler
    .word RTC_IRQHandler
    .word IWDG_IRQHandler
    .word WWDG_IRQHandler
    .word PD_IRQHandler
    .word USB0_IRQHandler
    .word USB1_IRQHandler
    .word ADC_IRQHandler
    .word DAC_IRQHandler
    .word TYPEC_IRQHandler
    .word SEC_IRQHandler
    .word OWI0_IRQHandler
    .word OWI1_IRQHandler
    .word OWI2_IRQHandler
    .word OWI3_IRQHandler
    .word GPIOA_IRQHandler
    .word GPIOB_IRQHandler
    .word GPIOC_IRQHandler
    .word GPIOD_IRQHandler
    .word GPIOE_IRQHandler
    .word GPIOF_IRQHandler
    .word GPIOG_IRQHandler
    .word GPIOH_IRQHandler
    .word GPIOI_IRQHandler
    .word GPIOJ_IRQHandler
    .word GPIOK_IRQHandler
    .word GPIOL_IRQHandler
    .word GPIOM_IRQHandler
    .word GPIOO_IRQHandler
    .word GPIOP_IRQHandler
    .word GPIOQ_IRQHandler
    .word GPIOR_IRQHandler
    .word TESTBOX_IRQHandler
    .word Default_IRQHandler
    .word Default_IRQHandler

    .size __isr_vector, . - __isr_vector


/* ----------------------------------------------------- */
/* Reset Handler */
    .text

    .thumb
    .thumb_func

    .align 2

    .globl Reset_Handler

    .type Reset_Handler, %function



Reset_Handler:
/*     Loop to copy data from read only memory to RAM. The ranges
 *      of copy from/to are specified by following symbols evaluated in
 *      linker script.
 *      __etext: End of code section, i.e., begin of data sections to copy from.
 *      __data_start__/__data_end__: RAM address range that data should be
 *      copied to. Both must be aligned to 4 bytes boundary.  */

    ldr r1, =__etext
    ldr r2, =__data_start__
    ldr r3, =__data_end__

    subs r3, r2
    ble .LC1
.LC0:
    subs r3, #4
    ldr r0, [r1, r3]
    str r0, [r2, r3]
    bgt .LC0
.LC1:
    bl SystemInit
    // bl _start
    bl main
    .pool
    .size Reset_Handler, . - Reset_Handler
    .section ".text"
/* --------------------------------------------------------
 *    Macro to define default handlers. Default handler
 *    will be weak symbol and just dead loops. They can be
 *    overwritten by other handlers */

    .macro def_default_handler handler_name
    .align 1
    .thumb_func
    .weak \handler_name
    .type \handler_name, %function
\handler_name :
    b .
    .size \handler_name, . - \handler_name
    .endm



    def_default_handler NMI_Handler
    def_default_handler HardFault_Handler
    def_default_handler MemManage_Handler
    def_default_handler BusFault_Handler
    def_default_handler UsageFault_Handler
    def_default_handler SVC_Handler
    def_default_handler DebugMonitor_Handler
    def_default_handler PendSV_Handler
    def_default_handler SysTick_Handler
    def_default_handler Default_Handler

    def_default_handler DMA_IRQHandler
    def_default_handler CACHE_IRQHandler
    def_default_handler RCC_IRQHandler
    def_default_handler FMC_IRQHandler
    def_default_handler KSIO_IRQHandler
    def_default_handler VCI_IRQHandler
    def_default_handler PWRSW_IRQHandler
    def_default_handler PECI_IRQHandler
    def_default_handler ESPI_SLAVE_IRQHandler
    def_default_handler ESPI_ERR_IRQHandler
    def_default_handler MAILBOX_IRQHandler
    def_default_handler KBC8042_IRQHandler
    def_default_handler ACPI0_IRQHandler
    def_default_handler ACPI1_IRQHandler
    def_default_handler ACPI2_IRQHandler
    def_default_handler SPI0_IRQHandler
    def_default_handler SPI1_IRQHandler
    def_default_handler SPI2_IRQHandler
    def_default_handler SPI3_IRQHandler
    def_default_handler I2C0_IRQHandler
    def_default_handler I2C1_IRQHandler
    def_default_handler I2C2_IRQHandler
    def_default_handler I2C3_IRQHandler
    def_default_handler I2C4_IRQHandler
    def_default_handler USART2_IRQHandler
    def_default_handler USART3_IRQHandler
    def_default_handler FAN_IN0_IRQHandler
    def_default_handler FAN_IN1_IRQHandler
    def_default_handler FAN_IN2_IRQHandler
    def_default_handler FAN_IN3_IRQHandler
    def_default_handler PWM0_IRQHandler
    def_default_handler PWM1_IRQHandler
    def_default_handler PWM2_IRQHandler
    def_default_handler PWM3_IRQHandler
    def_default_handler PWM4_IRQHandler
    def_default_handler PWM5_IRQHandler
    def_default_handler ACMP1_IRQHandler
    def_default_handler TIM0_IRQHandler
    def_default_handler TIM1_IRQHandler
    def_default_handler RTC_IRQHandler
    def_default_handler IWDG_IRQHandler
    def_default_handler WWDG_IRQHandler
    def_default_handler PD_IRQHandler
    def_default_handler USB0_IRQHandler
    def_default_handler USB1_IRQHandler
    def_default_handler ADC_IRQHandler
    def_default_handler DAC_IRQHandler
    def_default_handler TYPEC_IRQHandler
    def_default_handler SEC_IRQHandler
    def_default_handler OWI0_IRQHandler
    def_default_handler OWI1_IRQHandler
    def_default_handler OWI2_IRQHandler
    def_default_handler OWI3_IRQHandler
    def_default_handler GPIOA_IRQHandler
    def_default_handler GPIOB_IRQHandler
    def_default_handler GPIOC_IRQHandler
    def_default_handler GPIOD_IRQHandler
    def_default_handler GPIOE_IRQHandler
    def_default_handler GPIOF_IRQHandler
    def_default_handler GPIOG_IRQHandler
    def_default_handler GPIOH_IRQHandler
    def_default_handler GPIOI_IRQHandler
    def_default_handler GPIOJ_IRQHandler
    def_default_handler GPIOK_IRQHandler
    def_default_handler GPIOL_IRQHandler
    def_default_handler GPIOM_IRQHandler
    def_default_handler GPIOO_IRQHandler
    def_default_handler GPIOP_IRQHandler
    def_default_handler GPIOQ_IRQHandler
    def_default_handler GPIOR_IRQHandler
    def_default_handler TESTBOX_IRQHandler

    def_default_handler Default_IRQHandler

    .weak DEF_IRQHandler

    .set DEF_IRQHandler, Default_Handler

    .end
