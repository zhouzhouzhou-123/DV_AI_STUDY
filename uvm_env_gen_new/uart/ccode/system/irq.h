#ifndef __IRQ_H__
#define __IRQ_H__

/**
* @enum IRQn_Type
* @brief Interrupt Number definition (CortexM0 Processor Exceptions Numbers)
*/
typedef enum IRQn {
    Reset_IRQn                      = -15,      /* Reset IRQn */
    NMI_IRQn                        = -14,      /* NMI IRQn */
    HardFault_IRQn                  = -13,      /* Hard Fault IRQn */
    MemManage_IRQn                  = -12,      /* MPU Fault IRQn */
    BusFault_IRQn                   = -11,      /* Bus Fault IRQn */
    UsageFault_IRQn                 = -10,      /* Usage Fault IRQn */
    SVC_IRQn                        = -5,       /* SVCall IRQn */
    PendSV_IRQn                     = -2,       /* PendSV IRQn */
    SysTick_IRQn                    = -1,       /* SysTick IRQn */

    /* External interrupts */
    WWDG_IRQn                       = 0,
    PVD_VDDAM_IRQn                  ,
    RTC_TAMPER_CSS_LSE_IRQn         ,
    RTC_WUP_IRQn                    ,
    FLASH_IRQn                      ,
    RCC_IRQn                        ,
    EXTI0_IRQn                      ,
    EXTI1_IRQn                      ,
    EXTI2_IRQn                      ,
    EXTI3_IRQn                      ,
    EXTI4_IRQn                      ,
    DMA1_Channel1_IRQn              = 11,
    DMA1_Channel2_IRQn              ,
    DMA1_Channel3_IRQn              ,
    DMA1_Channel4_IRQn              ,
    DMA1_Channel5_IRQn              ,
    DMA1_Channel6_IRQn              ,
    DMA1_Channel7_IRQn              ,
    ADC1_2_IRQn                     ,
    USB_IRQn                        = 19,
    CAN1_INT0_IRQn                  = 21,
    CAN1_INT1_IRQn                  ,
    EXTI9_5_IRQn                    ,
    TIM1_COM_TIM9_IRQn              ,
    TIM10_IRQn                      ,
    TIM1_TIM11_IRQn                 ,
    TIM1_CC_IRQn                    ,
    TIM2_IRQn                       ,
    TIM3_IRQn                       ,
    TIM4_IRQn                       ,
    I2C1_IRQn                       ,
    I2C2_IRQn                       = 33,
    SPI1_IRQn                       = 35,
    SPI2_IRQn                       ,
    USART1_IRQn                     ,
    USART2_IRQn                     ,
    USART3_IRQn                     ,
    EXTI15_10_IRQn                  ,
    RTC_ALARM_IRQn                  ,
    EXTI18_IRQn                     ,
    TIM8_COM_IRQn                   ,
    TIM8_ALL_IRQn                   = 45,
    TIM8_CC_IRQn                    ,
    ADC3_IRQn                       ,
    LPTIM_IRQn                      = 49,
    TIM5_IRQn                       ,
    SPI3_IRQn                       ,
    UART4_IRQn                      ,
    UART5_IRQn                      ,
    TIM6_IRQn                       ,
    TIM7_IRQn                       ,
    DMA2_CH1_IRQn                   ,
    DMA2_CH2_IRQn                   ,
    DMA2_CH3_IRQn                   ,
    DMA2_CH4_IRQn                   ,
    DMA2_CH5_IRQn                   ,
    COMP1_2_IRQn                    = 64,
    CRS_IRQn                        = 75,
    FPU_IRQn                        = 81,
    SEC_IRQn                        = 85,
    CAN2_INT0_IRQn                  ,
    CAN2_INT1_IRQn                  ,
    I2C3_IRQn                       = 92,
    DMAMUX_OVR_IRQn                 = 94,
    DMA2_CH6_IRQn                   = 97,
    DMA2_CH7_IRQn                   ,
    CORDIC_IRQn                     = 100,
    SDIO_IRQn                       = 102,
    KSIO_IRQn                       ,
    UART6_IRQn                      ,
    UART7_IRQn                      ,
    UART8_IRQn                      ,
    QSPI2_IRQn
} IRQn_Type;

/**
    * @brief CS32E1XX Interrupt Number Definition, according to the selected device
    *        in @ref Library_configuration_section
*/
/*!< CS32E1XX uses 4 Bits for the oity Levels */
#define __NVIC_PRIO_BITS          4

#endif// __IRQ_H__

