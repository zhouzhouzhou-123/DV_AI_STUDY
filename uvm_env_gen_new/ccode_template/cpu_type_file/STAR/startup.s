/* File: startup_ARMCM4.S
 * Purpose: startup file for Cortex-M4 devices. Should use with
 *   GCC for ARM Embedded Processors
 * Version: V2.0
 * Date: 16 August 2013
 *
 */
/* Copyright (c) 2011 - 2013 ARM LIMITED

   All rights reserved.
   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are met:
   - Redistributions of source code must retain the above copyright
     notice, this list of conditions and the following disclaimer.
   - Redistributions in binary form must reproduce the above copyright
     notice, this list of conditions and the following disclaimer in the
     documentation and/or other materials provided with the distribution.
   - Neither the name of ARM nor the names of its contributors may be used
     to endorse or promote products derived from this software without
     specific prior written permission.
   *
   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
   ARE DISCLAIMED. IN NO EVENT SHALL COPYRIGHT HOLDERS AND CONTRIBUTORS BE
   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
   POSSIBILITY OF SUCH DAMAGE.
   ---------------------------------------------------------------------------*/


	.syntax	unified
	.arch	armv7e-m

	.section .stack
	.align	3
#ifdef __STACK_SIZE
	.equ	Stack_Size, __STACK_SIZE
#else
	.equ	Stack_Size, 0x00000c00
#endif
	.globl	__StackTop
	.globl	__StackLimit
__StackLimit:
	.space	Stack_Size
	.size	__StackLimit, . - __StackLimit
__StackTop:
	.size	__StackTop, . - __StackTop

	.section .heap
	.align	3
#ifdef __HEAP_SIZE
	.equ	Heap_Size, __HEAP_SIZE
#else
	.equ	Heap_Size, 0x00000000
#endif
	.globl	__HeapBase
	.globl	__HeapLimit
__HeapBase:
	.if	Heap_Size
	.space	Heap_Size
	.endif
	.size	__HeapBase, . - __HeapBase
__HeapLimit:
	.size	__HeapLimit, . - __HeapLimit

	.section .isr_vector
	.align	2
	.globl	__isr_vector
__isr_vector:
	.long	__StackTop              /* Top of Stack */
	.long	Reset_Handler           /* Reset Handler */
	.long	NMI_Handler             /* NMI Handler */
	.long	HardFault_Handler       /* Hard Fault Handler */
	.long	MemManage_Handler       /* MPU Fault Handler */
	.long	BusFault_Handler        /* Bus Fault Handler */
	.long	UsageFault_Handler      /* Usage Fault Handler */
	.long	0                       /* Reserved */
	.long	0                       /* Reserved */
	.long	0                       /* Reserved */
	.long	0                       /* Reserved */
	.long	SVC_Handler             /* SVCall Handler */
	.long	0                       /* Debug Monitor Handler */
	.long	0                       /* Reserved */
	.long	PendSV_Handler          /* PendSV Handler */
	.long	SysTick_Handler         /* SysTick Handler */

	/* External interrupts */
    .long   WWDG_IRQHandler
    .long   PVD_VDDAM_IRQHandler
    .long   RTC_TAMPER_CSS_LSE_IRQHandler
    .long   RTC_WUP_IRQHandler
    .long   FLASH_IRQHandler
    .long   RCC_IRQHandler
    .long   EXTI0_IRQHandler
    .long   EXTI1_IRQHandler
    .long   EXTI2_IRQHandler
    .long   EXTI3_IRQHandler
    .long   EXTI4_IRQHandler
    .long   DMA1_Channel1_IRQHandler
    .long   DMA1_Channel2_IRQHandler
    .long   DMA1_Channel3_IRQHandler
    .long   DMA1_Channel4_IRQHandler
    .long   DMA1_Channel5_IRQHandler
    .long   DMA1_Channel6_IRQHandler
    .long   DMA1_Channel7_IRQHandler
    .long   ADC1_2_IRQHandler
    .long   USB_IRQHandler
    .long   0
    .long   CAN1_INT0_IRQHandler
    .long   CAN1_INT1_IRQHandler
    .long   EXTI9_5_IRQHandler
    .long   TIM1_COM_TIM9_IRQHandler
    .long   TIM10_IRQHandler
    .long   TIM1_TIM11_IRQHandler
    .long   TIM1_CC_IRQHandler
    .long   TIM2_IRQHandler
    .long   TIM3_IRQHandler
    .long   TIM4_IRQHandler
    .long   I2C1_IRQHandler
    .long   0
    .long   I2C2_IRQHandler
    .long   0
    .long   SPI1_IRQHandler
    .long   SPI2_IRQHandler
    .long   USART1_IRQHandler
    .long   USART2_IRQHandler
    .long   USART3_IRQHandler
    .long   EXTI15_10_IRQHandler
    .long   RTC_ALARM_IRQHandler
    .long   EXTI18_IRQHandler
    .long   TIM8_COM_IRQHandler
    .long   0
    .long   TIM8_ALL_IRQHandler
    .long   TIM8_CC_IRQHandler
    .long   ADC3_IRQHandler
    .long   0
    .long   LPTIM_IRQHandler
    .long   TIM5_IRQHandler
    .long   SPI3_IRQHandler
    .long   UART4_IRQHandler
    .long   UART5_IRQHandler
    .long   TIM6_IRQHandler
    .long   TIM7_IRQHandler
    .long   DMA2_CH1_IRQHandler
    .long   DMA2_CH2_IRQHandler
    .long   DMA2_CH3_IRQHandler
    .long   DMA2_CH4_IRQHandler
    .long   DMA2_CH5_IRQHandler
    .long   0
    .long   0
    .long   0
    .long   COMP1_2_IRQHandler
    .long   0
    .long   0
    .long   0
    .long   0
    .long   0
    .long   0
    .long   0
    .long   0
    .long   0
    .long   0
    .long   CRS_IRQHandler
    .long   0
    .long   0
    .long   0
    .long   0
    .long   0
    .long   FPU_IRQHandler
    .long   0
    .long   0
    .long   0
    .long   SEC_IRQHandler
    .long   CAN2_INT0_IRQHandler
    .long   CAN2_INT1_IRQHandler
    .long   0
    .long   0
    .long   0
    .long   0
    .long   I2C3_IRQHandler
    .long   0
    .long   DMAMUX_OVR_IRQHandler
    .long   0
    .long   0
    .long   DMA2_CH6_IRQHandler
    .long   DMA2_CH7_IRQHandler
    .long   0
    .long   CORDIC_IRQHandler
    .long   0
    .long   SDIO_IRQHandler
    .long   KSIO_IRQHandler
    .long   UART6_IRQHandler
    .long   UART7_IRQHandler
    .long   UART8_IRQHandler
    .long   QSPI2_IRQHandler

	.size	__isr_vector, . - __isr_vector

	.text
	.thumb
	.thumb_func
	.align	2
	.globl	Reset_Handler
	.type	Reset_Handler, %function
Reset_Handler:
/*  Firstly it copies data from read only memory to RAM. There are two schemes
 *  to copy. One can copy more than one sections. Another can only copy
 *  one section.  The former scheme needs more instructions and read-only
 *  data to implement than the latter.
 *  Macro __STARTUP_COPY_MULTIPLE is used to choose between two schemes.  */

/*  Single section scheme.
 *
 *  The ranges of copy from/to are specified by following symbols
 *    __etext: LMA of start of the section to copy from. Usually end of text
 *    __data_start__: VMA of start of the section to copy to
 *    __data_end__: VMA of end of the section to copy to
 *
 *  All addresses must be aligned to 4 bytes boundary.
 */
    mov     r0,     #0
    mov     r1,     #0
    mov     r2,     #0
    mov     r3,     #0
    mov     r4,     #0
    mov     r5,     #0
    mov     r6,     #0
    mov     r7,     #0
    mov     r8,     #0
    mov     r9,     #0
    mov     r10,    #0
    mov     r11,    #0
    mov     r12,    #0
    mov     r14,    #0

	ldr	r1, =__etext
	ldr	r2, =__data_start__
	ldr	r3, =__data_end__

.L_loop1:
	cmp	r2, r3
	ittt	lt
	ldrlt	r0, [r1], #4
	strlt	r0, [r2], #4
	blt	.L_loop1

/*  This part of work usually is done in C library startup code. Otherwise,
 *  define this macro to enable it in this startup.
 *
 *  There are two schemes too. One can clear multiple BSS sections. Another
 *  can only clear one section. The former is more size expensive than the
 *  latter.
 *
 *  Define macro __STARTUP_CLEAR_BSS_MULTIPLE to choose the former.
 *  Otherwise efine macro __STARTUP_CLEAR_BSS to choose the later.
 */
/*  Single BSS section scheme.
 *
 *  The BSS section is specified by following symbols
 *    __bss_start__: start of the BSS section.
 *    __bss_end__: end of the BSS section.
 *
 *  Both addresses must be aligned to 4 bytes boundary.
 */
	ldr	r1, =__bss_start__
	ldr	r2, =__bss_end__

	movs	r0, 0
.L_loop3:
	cmp	r1, r2
	itt	lt
	strlt	r0, [r1], #4
	blt	.L_loop3

#ifndef __NO_SYSTEM_INIT
	bl	SystemInit
#endif

	bl	_start

	.pool
	.size	Reset_Handler, . - Reset_Handler

	.align	1
	.thumb_func
	.weak	Default_Handler
	.type	Default_Handler, %function
Default_Handler:
	b	.
	.size	Default_Handler, . - Default_Handler

/*    Macro to define default handlers. Default handler
 *    will be weak symbol and just dead loops. They can be
 *    overwritten by other handlers */
	.macro	def_irq_handler	handler_name
	.weak	\handler_name
	.set	\handler_name, Default_Handler
	.endm

	def_irq_handler	NMI_Handler
	def_irq_handler	HardFault_Handler
	def_irq_handler	MemManage_Handler
	def_irq_handler	BusFault_Handler
	def_irq_handler	UsageFault_Handler
	def_irq_handler	SVC_Handler
	def_irq_handler	PendSV_Handler
	def_irq_handler	SysTick_Handler

    def_irq_handler   WWDG_IRQHandler
    def_irq_handler   PVD_VDDAM_IRQHandler
    def_irq_handler   RTC_TAMPER_CSS_LSE_IRQHandler
    def_irq_handler   RTC_WUP_IRQHandler
    def_irq_handler   FLASH_IRQHandler
    def_irq_handler   RCC_IRQHandler
    def_irq_handler   EXTI0_IRQHandler
    def_irq_handler   EXTI1_IRQHandler
    def_irq_handler   EXTI2_IRQHandler
    def_irq_handler   EXTI3_IRQHandler
    def_irq_handler   EXTI4_IRQHandler
    def_irq_handler   DMA1_Channel1_IRQHandler
    def_irq_handler   DMA1_Channel2_IRQHandler
    def_irq_handler   DMA1_Channel3_IRQHandler
    def_irq_handler   DMA1_Channel4_IRQHandler
    def_irq_handler   DMA1_Channel5_IRQHandler
    def_irq_handler   DMA1_Channel6_IRQHandler
    def_irq_handler   DMA1_Channel7_IRQHandler
    def_irq_handler   ADC1_2_IRQHandler
    def_irq_handler   USB_IRQHandler
    def_irq_handler   CAN1_INT0_IRQHandler
    def_irq_handler   CAN1_INT1_IRQHandler
    def_irq_handler   EXTI9_5_IRQHandler
    def_irq_handler   TIM1_COM_TIM9_IRQHandler
    def_irq_handler   TIM10_IRQHandler
    def_irq_handler   TIM1_TIM11_IRQHandler
    def_irq_handler   TIM1_CC_IRQHandler
    def_irq_handler   TIM2_IRQHandler
    def_irq_handler   TIM3_IRQHandler
    def_irq_handler   TIM4_IRQHandler
    def_irq_handler   I2C1_IRQHandler
    def_irq_handler   I2C2_IRQHandler
    def_irq_handler   SPI1_IRQHandler
    def_irq_handler   SPI2_IRQHandler
    def_irq_handler   USART1_IRQHandler
    def_irq_handler   USART2_IRQHandler
    def_irq_handler   USART3_IRQHandler
    def_irq_handler   EXTI15_10_IRQHandler
    def_irq_handler   RTC_ALARM_IRQHandler
    def_irq_handler   EXTI18_IRQHandler
    def_irq_handler   TIM8_COM_IRQHandler
    def_irq_handler   TIM8_ALL_IRQHandler
    def_irq_handler   TIM8_CC_IRQHandler
    def_irq_handler   ADC3_IRQHandler
    def_irq_handler   LPTIM_IRQHandler
    def_irq_handler   TIM5_IRQHandler
    def_irq_handler   SPI3_IRQHandler
    def_irq_handler   UART4_IRQHandler
    def_irq_handler   UART5_IRQHandler
    def_irq_handler   TIM6_IRQHandler
    def_irq_handler   TIM7_IRQHandler
    def_irq_handler   DMA2_CH1_IRQHandler
    def_irq_handler   DMA2_CH2_IRQHandler
    def_irq_handler   DMA2_CH3_IRQHandler
    def_irq_handler   DMA2_CH4_IRQHandler
    def_irq_handler   DMA2_CH5_IRQHandler
    def_irq_handler   COMP1_2_IRQHandler
    def_irq_handler   CRS_IRQHandler
    def_irq_handler   FPU_IRQHandler
    def_irq_handler   SEC_IRQHandler
    def_irq_handler   CAN2_INT0_IRQHandler
    def_irq_handler   CAN2_INT1_IRQHandler
    def_irq_handler   I2C3_IRQHandler
    def_irq_handler   DMAMUX_OVR_IRQHandler
    def_irq_handler   DMA2_CH6_IRQHandler
    def_irq_handler   DMA2_CH7_IRQHandler
    def_irq_handler   CORDIC_IRQHandler
    def_irq_handler   SDIO_IRQHandler
    def_irq_handler   KSIO_IRQHandler
    def_irq_handler   UART6_IRQHandler
    def_irq_handler   UART7_IRQHandler
    def_irq_handler   UART8_IRQHandler
    def_irq_handler   QSPI2_IRQHandler

	.end
