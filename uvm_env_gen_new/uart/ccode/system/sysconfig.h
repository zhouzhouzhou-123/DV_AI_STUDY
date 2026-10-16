#ifndef __SYSCONFIG_H__
#define __SYSCONFIG_H__

//#/* ########################### System Configuration ######################### */
//#/**
//#  * @brief This is the HAL system configuration section
//#  */     
//##define  VDD_VALUE                    3300U  /*!< Value of VDD in mv */           
//##define  TICK_INT_PRIORITY            ((uint32_t)(1U<<__NVIC_PRIO_BITS) - 1U) /*!< tick interrupt priority (lowest by default)             */
//#                                                                              /*  Warning: Must be set to higher priority for HAL_Delay()  */
//#                                                                              /*  and HAL_GetTick() usage under interrupt context          */
//##define  USE_RTOS                     0U
//##define  PREFETCH_ENABLE              1U
//##define  INSTRUCTION_CACHE_ENABLE     0U
//##define  DATA_CACHE_ENABLE            0U
//##define  USE_SPI_CRC                  1U

/*
 * ==========================================================================
 * ----------- Processor and Core Peripheral Section ------------------------
 * ==========================================================================
 */

/* Configuration of the Star Processor and Core Peripherals */
#define __MPU_PRESENT           1       /*!< exectb_mcu can support an MPU                       */
#define __SAU_PRESENT           1       /*!< exectb_mcu can support an SAU                       */
#define __VTOR_PRESENT          1       /*!< exectb_mcu can support the VTOR                     */
#define __Vendor_SysTickConfig  0       /*!< Set to 1 if different SysTick Config is used        */
#define __ICACHE_PRESENT        1       /*!< Set to 1 if I-Cache is present                      */
#define __DCACHE_PRESENT        1       /*!< Set to 1 if D-Cache is present                      */
#define __FPU_PRESENT           1       /*!< Set to 1 if FPU is present                          */

#undef __CHECK_DEVICE_DEFINES//check Macro

#endif
