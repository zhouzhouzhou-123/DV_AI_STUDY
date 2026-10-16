
#ifndef __RCC_REG_H__
#define __RCC_REG_H__

//====== RCC_CR 0x00000000 ======
#define RCC_CR_PLLSTAB_Pos                                25
#define RCC_CR_PLLSTAB_Msk                                (0x1UL << RCC_CR_PLLSTAB_Pos)
#define RCC_CR_PLLEN_Pos                                  24
#define RCC_CR_PLLEN_Msk                                  (0x1UL << RCC_CR_PLLEN_Pos)
#define RCC_CR_HXTAGCSEL_Pos                              18
#define RCC_CR_HXTAGCSEL_Msk                              (0x7UL << RCC_CR_HXTAGCSEL_Pos)
#define RCC_CR_HXTBYPAGC_Pos                              17
#define RCC_CR_HXTBYPAGC_Msk                              (0x1UL << RCC_CR_HXTBYPAGC_Pos)
#define RCC_CR_HXTIOPSEL_Pos                              14
#define RCC_CR_HXTIOPSEL_Msk                              (0x7UL << RCC_CR_HXTIOPSEL_Pos)
#define RCC_CR_HXTRFSEL_Pos                               13
#define RCC_CR_HXTRFSEL_Msk                               (0x1UL << RCC_CR_HXTRFSEL_Pos)
#define RCC_CR_HXTRFEN_Pos                                12
#define RCC_CR_HXTRFEN_Msk                                (0x1UL << RCC_CR_HXTRFEN_Pos)
#define RCC_CR_HXTME_Pos                                  11
#define RCC_CR_HXTME_Msk                                  (0x1UL << RCC_CR_HXTME_Pos)
#define RCC_CR_HXTBPS_Pos                                 10
#define RCC_CR_HXTBPS_Msk                                 (0x1UL << RCC_CR_HXTBPS_Pos)
#define RCC_CR_HXTSTAB_Pos                                9
#define RCC_CR_HXTSTAB_Msk                                (0x1UL << RCC_CR_HXTSTAB_Pos)
#define RCC_CR_HXTEN_Pos                                  8
#define RCC_CR_HXTEN_Msk                                  (0x1UL << RCC_CR_HXTEN_Pos)
#define RCC_CR_HRCSTAB_Pos                                2
#define RCC_CR_HRCSTAB_Msk                                (0x1UL << RCC_CR_HRCSTAB_Pos)
#define RCC_CR_HRCKEREN_Pos                               1
#define RCC_CR_HRCKEREN_Msk                               (0x1UL << RCC_CR_HRCKEREN_Pos)
#define RCC_CR_HRCEN_Pos                                  0
#define RCC_CR_HRCEN_Msk                                  (0x1UL << RCC_CR_HRCEN_Pos)

//====== RCC_ICSCR 0x00000004 ======
#define RCC_ICSCR_HRCFTUNE_Pos                            24
#define RCC_ICSCR_HRCFTUNE_Msk                            (0x3FUL << RCC_ICSCR_HRCFTUNE_Pos)
#define RCC_ICSCR_HRCCTUNE_Pos                            16
#define RCC_ICSCR_HRCCTUNE_Msk                            (0x3FUL << RCC_ICSCR_HRCCTUNE_Pos)

//====== RCC_CFGR 0x00000008 ======
#define RCC_CFGR_CKOPRE_Pos                               28
#define RCC_CFGR_CKOPRE_Msk                               (0x7UL << RCC_CFGR_CKOPRE_Pos)
#define RCC_CFGR_CKO_Pos                                  24
#define RCC_CFGR_CKO_Msk                                  (0xFUL << RCC_CFGR_CKO_Pos)

#define RCC_CFGR_TIMP2S_Pos                               23
#define RCC_CFGR_TIMP2S_Msk                              (0x1UL << RCC_CFGR_TIMP2S_Pos)
#define RCC_CFGR_TIMP1S_Pos                               22
#define RCC_CFGR_TIMP1S_Msk                              (0x1UL << RCC_CFGR_TIMP1S_Pos)


#define RCC_CFGR_CDPRE_Pos                                20
#define RCC_CFGR_CDPRE_Msk                                (0x3UL << RCC_CFGR_CDPRE_Pos)
#define RCC_CFGR_HPRE3_Pos                                18
#define RCC_CFGR_HPRE3_Msk                                (0x3UL << RCC_CFGR_HPRE3_Pos)
#define RCC_CFGR_HPRE2_Pos                                16
#define RCC_CFGR_HPRE2_Msk                                (0x3UL << RCC_CFGR_HPRE2_Pos)
#define RCC_CFGR_HPRE1_Pos                                14
#define RCC_CFGR_HPRE1_Msk                                (0x3UL << RCC_CFGR_HPRE1_Pos)
#define RCC_CFGR_PPRE2_Pos                                11
#define RCC_CFGR_PPRE2_Msk                                (0x7UL << RCC_CFGR_PPRE2_Pos)
#define RCC_CFGR_PPRE1_Pos                                8
#define RCC_CFGR_PPRE1_Msk                                (0x7UL << RCC_CFGR_PPRE1_Pos)
#define RCC_CFGR_SYSPRE_Pos                               4
#define RCC_CFGR_SYSPRE_Msk                               (0xFUL << RCC_CFGR_SYSPRE_Pos)
#define RCC_CFGR_SYSSS_Pos                                2
#define RCC_CFGR_SYSSS_Msk                                (0x3UL << RCC_CFGR_SYSSS_Pos)
#define RCC_CFGR_SYSSW_Pos                                0
#define RCC_CFGR_SYSSW_Msk                                (0x3UL << RCC_CFGR_SYSSW_Pos)

//====== RCC_PLLCFGR 0x0000000C ======
#define RCC_PLLCFGR_PLLNLKBYP_Pos                          29
#define RCC_PLLCFGR_PLLNLKBYP_Msk                          (0x1UL << RCC_PLLCFGR_PLLNLKBYP_Pos)
#define RCC_PLLCFGR_PLLCKBYP_Pos                          28
#define RCC_PLLCFGR_PLLCKBYP_Msk                          (0x1UL << RCC_PLLCFGR_PLLCKBYP_Pos)
#define RCC_PLLCFGR_PLLCUR_Pos                            25
#define RCC_PLLCFGR_PLLCUR_Msk                            (0x7UL << RCC_PLLCFGR_PLLCUR_Pos)
#define RCC_PLLCFGR_PLLVCO_Pos                            19
#define RCC_PLLCFGR_PLLVCO_Msk                            (0xFUL << RCC_PLLCFGR_PLLVCO_Pos)
#define RCC_PLLCFGR_PLLDIN2_Pos                           17
#define RCC_PLLCFGR_PLLDIN2_Msk                           (0x3UL << RCC_PLLCFGR_PLLDIN2_Pos)
#define RCC_PLLCFGR_PLLDIN1_Pos                           8
#define RCC_PLLCFGR_PLLDIN1_Msk                           (0x1FFUL << RCC_PLLCFGR_PLLDIN1_Pos)
#define RCC_PLLCFGR_PLLPRE_Pos                            3
#define RCC_PLLCFGR_PLLPRE_Msk                            (0x1FUL << RCC_PLLCFGR_PLLPRE_Pos)
#define RCC_PLLCFGR_PLLSEL_Pos                            0
#define RCC_PLLCFGR_PLLSEL_Msk                            (0x3UL << RCC_PLLCFGR_PLLSEL_Pos)

//====== RCC_CIER 0x00000018 ======
#define RCC_CIER_LXTMEIE_Pos                              9
#define RCC_CIER_LXTMEIE_Msk                              (0x1UL << RCC_CIER_LXTMEIE_Pos)
#define RCC_CIER_PLLNLKIE_Pos                             6
#define RCC_CIER_PLLNLKIE_Msk                            (0x1UL << RCC_CIER_PLLNLKIE_Pos)
#define RCC_CIER_PLLSTABIE_Pos                            5
#define RCC_CIER_PLLSTABIE_Msk                            (0x1UL << RCC_CIER_PLLSTABIE_Pos)
#define RCC_CIER_HXTSTABIE_Pos                            4
#define RCC_CIER_HXTSTABIE_Msk                            (0x1UL << RCC_CIER_HXTSTABIE_Pos)
#define RCC_CIER_HRCSTABIE_Pos                            3
#define RCC_CIER_HRCSTABIE_Msk                            (0x1UL << RCC_CIER_HRCSTABIE_Pos)
#define RCC_CIER_LXTSTABIE_Pos                            1
#define RCC_CIER_LXTSTABIE_Msk                            (0x1UL << RCC_CIER_LXTSTABIE_Pos)
#define RCC_CIER_LRCSTABIE_Pos                            0
#define RCC_CIER_LRCSTABIE_Msk                            (0x1UL << RCC_CIER_LRCSTABIE_Pos)

//====== RCC_CIFR 0x0000001C ======
#define RCC_CIFR_LXTMEF_Pos                               9
#define RCC_CIFR_LXTMEF_Msk                               (0x1UL << RCC_CIFR_LXTMEF_Pos)
#define RCC_CIFR_CSSF_Pos                                 8
#define RCC_CIFR_CSSF_Msk                                 (0x1UL << RCC_CIFR_CSSF_Pos)
#define RCC_CIFR_PLLNLKF_Pos                              6
#define RCC_CIFR_PLLNLKF_Msk                              (0x1UL << RCC_CIFR_PLLNLKF_Pos)
#define RCC_CIFR_PLLSTABF_Pos                             5
#define RCC_CIFR_PLLSTABF_Msk                             (0x1UL << RCC_CIFR_PLLSTABF_Pos)
#define RCC_CIFR_HXTSTABF_Pos                             4
#define RCC_CIFR_HXTSTABF_Msk                             (0x1UL << RCC_CIFR_HXTSTABF_Pos)
#define RCC_CIFR_HRCSTABF_Pos                             3
#define RCC_CIFR_HRCSTABF_Msk                             (0x1UL << RCC_CIFR_HRCSTABF_Pos)
#define RCC_CIFR_LXTSTABF_Pos                             1
#define RCC_CIFR_LXTSTABF_Msk                             (0x1UL << RCC_CIFR_LXTSTABF_Pos)
#define RCC_CIFR_LRCSTABF_Pos                             0
#define RCC_CIFR_LRCSTABF_Msk                             (0x1UL << RCC_CIFR_LRCSTABF_Pos)

//====== RCC_CICR 0x00000020 ======
#define RCC_CICR_LXTMEC_Pos                               9
#define RCC_CICR_LXTMEC_Msk                               (0x1UL << RCC_CICR_LXTMEC_Pos)
#define RCC_CICR_CSSC_Pos                                 8
#define RCC_CICR_CSSC_Msk                                 (0x1UL << RCC_CICR_CSSC_Pos)
#define RCC_CICR_PLLNLKC_Pos                              6
#define RCC_CICR_PLLNLKC_Msk                             (0x1UL << RCC_CICR_PLLNLKC_Pos)
#define RCC_CICR_PLLSTABC_Pos                             5
#define RCC_CICR_PLLSTABC_Msk                             (0x1UL << RCC_CICR_PLLSTABC_Pos)
#define RCC_CICR_HXTSTABC_Pos                             4
#define RCC_CICR_HXTSTABC_Msk                             (0x1UL << RCC_CICR_HXTSTABC_Pos)
#define RCC_CICR_HRCSTABC_Pos                             3
#define RCC_CICR_HRCSTABC_Msk                             (0x1UL << RCC_CICR_HRCSTABC_Pos)
#define RCC_CICR_LXTSTABC_Pos                             1
#define RCC_CICR_LXTSTABC_Msk                             (0x1UL << RCC_CICR_LXTSTABC_Pos)
#define RCC_CICR_LRCSTABC_Pos                             0
#define RCC_CICR_LRCSTABC_Msk                             (0x1UL << RCC_CICR_LRCSTABC_Pos)

//====== RCC_AHB1RSTR 0x00000028 ======
#define RCC_AHB1RSTR_USBRST_Pos                           24
#define RCC_AHB1RSTR_USBRST_Msk                           (0x1UL << RCC_AHB1RSTR_USBRST_Pos)
#define RCC_AHB1RSTR_CRCRST_Pos                           12
#define RCC_AHB1RSTR_CRCRST_Msk                           (0x1UL << RCC_AHB1RSTR_CRCRST_Pos)
#define RCC_AHB1RSTR_FMCRST_Pos                           8
#define RCC_AHB1RSTR_FMCRST_Msk                           (0x1UL << RCC_AHB1RSTR_FMCRST_Pos)
#define RCC_AHB1RSTR_CORDICRST_Pos                        3
#define RCC_AHB1RSTR_CORDICRST_Msk                        (0x1UL << RCC_AHB1RSTR_CORDICRST_Pos)
#define RCC_AHB1RSTR_DMAMUXRST_Pos                        2
#define RCC_AHB1RSTR_DMAMUXRST_Msk                        (0x1UL << RCC_AHB1RSTR_DMAMUXRST_Pos)
#define RCC_AHB1RSTR_DMA2RST_Pos                          1
#define RCC_AHB1RSTR_DMA2RST_Msk                          (0x1UL << RCC_AHB1RSTR_DMA2RST_Pos)
#define RCC_AHB1RSTR_DMA1RST_Pos                          0
#define RCC_AHB1RSTR_DMA1RST_Msk                          (0x1UL << RCC_AHB1RSTR_DMA1RST_Pos)

//====== RCC_AHB2RSTR 0x0000002C ======
#define RCC_AHB2RSTR_SECURERST_Pos                        24
#define RCC_AHB2RSTR_SECURERST_Msk                        (0x1UL << RCC_AHB2RSTR_SECURERST_Pos)
#define RCC_AHB2RSTR_DAC1RST_Pos                          16
#define RCC_AHB2RSTR_DAC1RST_Msk                          (0x1UL << RCC_AHB2RSTR_DAC1RST_Pos)
#define RCC_AHB2RSTR_ADC3RST_Pos                          14
#define RCC_AHB2RSTR_ADC3RST_Msk                          (0x1UL << RCC_AHB2RSTR_ADC3RST_Pos)
#define RCC_AHB2RSTR_ADC12RST_Pos                         13
#define RCC_AHB2RSTR_ADC12RST_Msk                         (0x1UL << RCC_AHB2RSTR_ADC12RST_Pos)
#define RCC_AHB2RSTR_TESTBOXRST_Pos                       9
#define RCC_AHB2RSTR_TESTBOXRST_Msk                       (0x1UL << RCC_AHB2RSTR_TESTBOXRST_Pos)
#define RCC_AHB2RSTR_GPIOGRST_Pos                         6
#define RCC_AHB2RSTR_GPIOGRST_Msk                         (0x1UL << RCC_AHB2RSTR_GPIOGRST_Pos)
#define RCC_AHB2RSTR_GPIOFRST_Pos                         5
#define RCC_AHB2RSTR_GPIOFRST_Msk                         (0x1UL << RCC_AHB2RSTR_GPIOFRST_Pos)
#define RCC_AHB2RSTR_GPIOERST_Pos                         4
#define RCC_AHB2RSTR_GPIOERST_Msk                         (0x1UL << RCC_AHB2RSTR_GPIOERST_Pos)
#define RCC_AHB2RSTR_GPIODRST_Pos                         3
#define RCC_AHB2RSTR_GPIODRST_Msk                         (0x1UL << RCC_AHB2RSTR_GPIODRST_Pos)
#define RCC_AHB2RSTR_GPIOCRST_Pos                         2
#define RCC_AHB2RSTR_GPIOCRST_Msk                         (0x1UL << RCC_AHB2RSTR_GPIOCRST_Pos)
#define RCC_AHB2RSTR_GPIOBRST_Pos                         1
#define RCC_AHB2RSTR_GPIOBRST_Msk                         (0x1UL << RCC_AHB2RSTR_GPIOBRST_Pos)
#define RCC_AHB2RSTR_GPIOARST_Pos                         0
#define RCC_AHB2RSTR_GPIOARST_Msk                         (0x1UL << RCC_AHB2RSTR_GPIOARST_Pos)

//====== RCC_AHB3RSTR 0x00000030 ======
#define RCC_AHB3RSTR_QSPI2RST_Pos                         8
#define RCC_AHB3RSTR_QSPI2RST_Msk                         (0x1UL << RCC_AHB3RSTR_QSPI2RST_Pos)
#define RCC_AHB3RSTR_FSMCRST_Pos                          0
#define RCC_AHB3RSTR_FSMCRST_Msk                          (0x1UL << RCC_AHB3RSTR_FSMCRST_Pos)

//====== RCC_APB1RSTR1 0x00000038 ======
#define RCC_APB1RSTR1_LPTIM1RST_Pos                       31
#define RCC_APB1RSTR1_LPTIM1RST_Msk                       (0x1UL << RCC_APB1RSTR1_LPTIM1RST_Pos)
#define RCC_APB1RSTR1_I2C3RST_Pos                         30
#define RCC_APB1RSTR1_I2C3RST_Msk                         (0x1UL << RCC_APB1RSTR1_I2C3RST_Pos)
#define RCC_APB1RSTR1_PMURST_Pos                          28
#define RCC_APB1RSTR1_PMURST_Msk                          (0x1UL << RCC_APB1RSTR1_PMURST_Pos)
#define RCC_APB1RSTR1_FDCAN2RST_Pos                       26
#define RCC_APB1RSTR1_FDCAN2RST_Msk                       (0x1UL << RCC_APB1RSTR1_FDCAN2RST_Pos)
#define RCC_APB1RSTR1_FDCAN1RST_Pos                       25
#define RCC_APB1RSTR1_FDCAN1RST_Msk                       (0x1UL << RCC_APB1RSTR1_FDCAN1RST_Pos)
#define RCC_APB1RSTR1_I2C2RST_Pos                         22
#define RCC_APB1RSTR1_I2C2RST_Msk                         (0x1UL << RCC_APB1RSTR1_I2C2RST_Pos)
#define RCC_APB1RSTR1_I2C1RST_Pos                         21
#define RCC_APB1RSTR1_I2C1RST_Msk                         (0x1UL << RCC_APB1RSTR1_I2C1RST_Pos)
#define RCC_APB1RSTR1_UART5RST_Pos                        20
#define RCC_APB1RSTR1_UART5RST_Msk                        (0x1UL << RCC_APB1RSTR1_UART5RST_Pos)
#define RCC_APB1RSTR1_UART4RST_Pos                        19
#define RCC_APB1RSTR1_UART4RST_Msk                        (0x1UL << RCC_APB1RSTR1_UART4RST_Pos)
#define RCC_APB1RSTR1_USART3RST_Pos                       18
#define RCC_APB1RSTR1_USART3RST_Msk                       (0x1UL << RCC_APB1RSTR1_USART3RST_Pos)
#define RCC_APB1RSTR1_USART2RST_Pos                       17
#define RCC_APB1RSTR1_USART2RST_Msk                       (0x1UL << RCC_APB1RSTR1_USART2RST_Pos)
#define RCC_APB1RSTR1_SPI3RST_Pos                         15
#define RCC_APB1RSTR1_SPI3RST_Msk                         (0x1UL << RCC_APB1RSTR1_SPI3RST_Pos)
#define RCC_APB1RSTR1_SPI2RST_Pos                         14
#define RCC_APB1RSTR1_SPI2RST_Msk                         (0x1UL << RCC_APB1RSTR1_SPI2RST_Pos)
#define RCC_APB1RSTR1_CRSRST_Pos                          8
#define RCC_APB1RSTR1_CRSRST_Msk                          (0x1UL << RCC_APB1RSTR1_CRSRST_Pos)
#define RCC_APB1RSTR1_TIM7RST_Pos                         5
#define RCC_APB1RSTR1_TIM7RST_Msk                         (0x1UL << RCC_APB1RSTR1_TIM7RST_Pos)
#define RCC_APB1RSTR1_TIM6RST_Pos                         4
#define RCC_APB1RSTR1_TIM6RST_Msk                         (0x1UL << RCC_APB1RSTR1_TIM6RST_Pos)
#define RCC_APB1RSTR1_TIM5RST_Pos                         3
#define RCC_APB1RSTR1_TIM5RST_Msk                         (0x1UL << RCC_APB1RSTR1_TIM5RST_Pos)
#define RCC_APB1RSTR1_TIM4RST_Pos                         2
#define RCC_APB1RSTR1_TIM4RST_Msk                         (0x1UL << RCC_APB1RSTR1_TIM4RST_Pos)
#define RCC_APB1RSTR1_TIM3RST_Pos                         1
#define RCC_APB1RSTR1_TIM3RST_Msk                         (0x1UL << RCC_APB1RSTR1_TIM3RST_Pos)
#define RCC_APB1RSTR1_TIM2RST_Pos                         0
#define RCC_APB1RSTR1_TIM2RST_Msk                         (0x1UL << RCC_APB1RSTR1_TIM2RST_Pos)

//====== RCC_APB1RSTR2 0x0000003C ======
#define RCC_APB1RSTR2_KSIORST_Pos                         4
#define RCC_APB1RSTR2_KSIORST_Msk                         (0x1UL << RCC_APB1RSTR2_KSIORST_Pos)
#define RCC_APB1RSTR2_UART8RST_Pos                        2
#define RCC_APB1RSTR2_UART8RST_Msk                        (0x1UL << RCC_APB1RSTR2_UART8RST_Pos)
#define RCC_APB1RSTR2_UART7RST_Pos                        0
#define RCC_APB1RSTR2_UART7RST_Msk                        (0x1UL << RCC_APB1RSTR2_UART7RST_Pos)

//====== RCC_APB2RSTR 0x00000040 ======
#define RCC_APB2RSTR_TIM11RST_Pos                         18
#define RCC_APB2RSTR_TIM11RST_Msk                         (0x1UL << RCC_APB2RSTR_TIM11RST_Pos)
#define RCC_APB2RSTR_TIM10RST_Pos                         17
#define RCC_APB2RSTR_TIM10RST_Msk                         (0x1UL << RCC_APB2RSTR_TIM10RST_Pos)
#define RCC_APB2RSTR_TIM9RST_Pos                          16
#define RCC_APB2RSTR_TIM9RST_Msk                          (0x1UL << RCC_APB2RSTR_TIM9RST_Pos)
#define RCC_APB2RSTR_USART1RST_Pos                        14
#define RCC_APB2RSTR_USART1RST_Msk                        (0x1UL << RCC_APB2RSTR_USART1RST_Pos)
#define RCC_APB2RSTR_TIM8RST_Pos                          13
#define RCC_APB2RSTR_TIM8RST_Msk                          (0x1UL << RCC_APB2RSTR_TIM8RST_Pos)
#define RCC_APB2RSTR_SPI1RST_Pos                          12
#define RCC_APB2RSTR_SPI1RST_Msk                          (0x1UL << RCC_APB2RSTR_SPI1RST_Pos)
#define RCC_APB2RSTR_TIM1RST_Pos                          11
#define RCC_APB2RSTR_TIM1RST_Msk                          (0x1UL << RCC_APB2RSTR_TIM1RST_Pos)
#define RCC_APB2RSTR_SDIORST_Pos                          10
#define RCC_APB2RSTR_SDIORST_Msk                          (0x1UL << RCC_APB2RSTR_SDIORST_Pos)
#define RCC_APB2RSTR_UART6RST_Pos                         4
#define RCC_APB2RSTR_UART6RST_Msk                         (0x1UL << RCC_APB2RSTR_UART6RST_Pos)
#define RCC_APB2RSTR_RQEPRST_Pos                          1
#define RCC_APB2RSTR_RQEPRST_Msk                          (0x1UL << RCC_APB2RSTR_RQEPRST_Pos)
#define RCC_APB2RSTR_SYSCFGRST_Pos                        0
#define RCC_APB2RSTR_SYSCFGRST_Msk                        (0x1UL << RCC_APB2RSTR_SYSCFGRST_Pos)

//====== RCC_AHB1ENR 0x00000048 ======
#define RCC_AHB1ENR_USBEN_Pos                             24
#define RCC_AHB1ENR_USBEN_Msk                             (0x1UL << RCC_AHB1ENR_USBEN_Pos)
#define RCC_AHB1ENR_CRCEN_Pos                             12
#define RCC_AHB1ENR_CRCEN_Msk                             (0x1UL << RCC_AHB1ENR_CRCEN_Pos)
#define RCC_AHB1ENR_FMCEN_Pos                             8
#define RCC_AHB1ENR_FMCEN_Msk                             (0x1UL << RCC_AHB1ENR_FMCEN_Pos)
#define RCC_AHB1ENR_CORDICEN_Pos                          3
#define RCC_AHB1ENR_CORDICEN_Msk                          (0x1UL << RCC_AHB1ENR_CORDICEN_Pos)
#define RCC_AHB1ENR_DMAMUXEN_Pos                          2
#define RCC_AHB1ENR_DMAMUXEN_Msk                          (0x1UL << RCC_AHB1ENR_DMAMUXEN_Pos)
#define RCC_AHB1ENR_DMA2EN_Pos                            1
#define RCC_AHB1ENR_DMA2EN_Msk                            (0x1UL << RCC_AHB1ENR_DMA2EN_Pos)
#define RCC_AHB1ENR_DMA1EN_Pos                            0
#define RCC_AHB1ENR_DMA1EN_Msk                            (0x1UL << RCC_AHB1ENR_DMA1EN_Pos)

//====== RCC_AHB2ENR 0x0000004C ======
#define RCC_AHB2ENR_SECUREEN_Pos                          24
#define RCC_AHB2ENR_SECUREEN_Msk                          (0x1UL << RCC_AHB2ENR_SECUREEN_Pos)
#define RCC_AHB2ENR_DAC1EN_Pos                            16
#define RCC_AHB2ENR_DAC1EN_Msk                            (0x1UL << RCC_AHB2ENR_DAC1EN_Pos)
#define RCC_AHB2ENR_ADC3EN_Pos                            14
#define RCC_AHB2ENR_ADC3EN_Msk                            (0x1UL << RCC_AHB2ENR_ADC3EN_Pos)
#define RCC_AHB2ENR_ADC12EN_Pos                           13
#define RCC_AHB2ENR_ADC12EN_Msk                           (0x1UL << RCC_AHB2ENR_ADC12EN_Pos)
#define RCC_AHB2ENR_TESTBOXEN_Pos                         9
#define RCC_AHB2ENR_TESTBOXEN_Msk                         (0x1UL << RCC_AHB2ENR_TESTBOXEN_Pos)
#define RCC_AHB2ENR_GPIOGEN_Pos                           6
#define RCC_AHB2ENR_GPIOGEN_Msk                           (0x1UL << RCC_AHB2ENR_GPIOGEN_Pos)
#define RCC_AHB2ENR_GPIOFEN_Pos                           5
#define RCC_AHB2ENR_GPIOFEN_Msk                           (0x1UL << RCC_AHB2ENR_GPIOFEN_Pos)
#define RCC_AHB2ENR_GPIOEEN_Pos                           4
#define RCC_AHB2ENR_GPIOEEN_Msk                           (0x1UL << RCC_AHB2ENR_GPIOEEN_Pos)
#define RCC_AHB2ENR_GPIODEN_Pos                           3
#define RCC_AHB2ENR_GPIODEN_Msk                           (0x1UL << RCC_AHB2ENR_GPIODEN_Pos)
#define RCC_AHB2ENR_GPIOCEN_Pos                           2
#define RCC_AHB2ENR_GPIOCEN_Msk                           (0x1UL << RCC_AHB2ENR_GPIOCEN_Pos)
#define RCC_AHB2ENR_GPIOBEN_Pos                           1
#define RCC_AHB2ENR_GPIOBEN_Msk                           (0x1UL << RCC_AHB2ENR_GPIOBEN_Pos)
#define RCC_AHB2ENR_GPIOAEN_Pos                           0
#define RCC_AHB2ENR_GPIOAEN_Msk                           (0x1UL << RCC_AHB2ENR_GPIOAEN_Pos)

//====== RCC_AHB3ENR 0x00000050 ======
#define RCC_AHB3ENR_QSPI2EN_Pos                           8
#define RCC_AHB3ENR_QSPI2EN_Msk                           (0x1UL << RCC_AHB3ENR_QSPI2EN_Pos)
#define RCC_AHB3ENR_FSMCEN_Pos                            0
#define RCC_AHB3ENR_FSMCEN_Msk                            (0x1UL << RCC_AHB3ENR_FSMCEN_Pos)

//====== RCC_APB1ENR1 0x00000058 ======
#define RCC_APB1ENR1_LPTIM1EN_Pos                         31
#define RCC_APB1ENR1_LPTIM1EN_Msk                         (0x1UL << RCC_APB1ENR1_LPTIM1EN_Pos)
#define RCC_APB1ENR1_I2C3EN_Pos                           30
#define RCC_APB1ENR1_I2C3EN_Msk                           (0x1UL << RCC_APB1ENR1_I2C3EN_Pos)
#define RCC_APB1ENR1_PMUEN_Pos                            28
#define RCC_APB1ENR1_PMUEN_Msk                            (0x1UL << RCC_APB1ENR1_PMUEN_Pos)
#define RCC_APB1ENR1_FDCAN2EN_Pos                         26
#define RCC_APB1ENR1_FDCAN2EN_Msk                         (0x1UL << RCC_APB1ENR1_FDCAN2EN_Pos)
#define RCC_APB1ENR1_FDCAN1EN_Pos                         25
#define RCC_APB1ENR1_FDCAN1EN_Msk                         (0x1UL << RCC_APB1ENR1_FDCAN1EN_Pos)
#define RCC_APB1ENR1_I2C2EN_Pos                           22
#define RCC_APB1ENR1_I2C2EN_Msk                           (0x1UL << RCC_APB1ENR1_I2C2EN_Pos)
#define RCC_APB1ENR1_I2C1EN_Pos                           21
#define RCC_APB1ENR1_I2C1EN_Msk                           (0x1UL << RCC_APB1ENR1_I2C1EN_Pos)
#define RCC_APB1ENR1_UART5EN_Pos                          20
#define RCC_APB1ENR1_UART5EN_Msk                          (0x1UL << RCC_APB1ENR1_UART5EN_Pos)
#define RCC_APB1ENR1_UART4EN_Pos                          19
#define RCC_APB1ENR1_UART4EN_Msk                          (0x1UL << RCC_APB1ENR1_UART4EN_Pos)
#define RCC_APB1ENR1_USART3EN_Pos                         18
#define RCC_APB1ENR1_USART3EN_Msk                         (0x1UL << RCC_APB1ENR1_USART3EN_Pos)
#define RCC_APB1ENR1_USART2EN_Pos                         17
#define RCC_APB1ENR1_USART2EN_Msk                         (0x1UL << RCC_APB1ENR1_USART2EN_Pos)
#define RCC_APB1ENR1_SPI3EN_Pos                           15
#define RCC_APB1ENR1_SPI3EN_Msk                           (0x1UL << RCC_APB1ENR1_SPI3EN_Pos)
#define RCC_APB1ENR1_SPI2EN_Pos                           14
#define RCC_APB1ENR1_SPI2EN_Msk                           (0x1UL << RCC_APB1ENR1_SPI2EN_Pos)
#define RCC_APB1ENR1_WWDTEN_Pos                           11
#define RCC_APB1ENR1_WWDTEN_Msk                           (0x1UL << RCC_APB1ENR1_WWDTEN_Pos)
#define RCC_APB1ENR1_RTCAPBEN_Pos                         10
#define RCC_APB1ENR1_RTCAPBEN_Msk                         (0x1UL << RCC_APB1ENR1_RTCAPBEN_Pos)
#define RCC_APB1ENR1_CRSEN_Pos                            8
#define RCC_APB1ENR1_CRSEN_Msk                            (0x1UL << RCC_APB1ENR1_CRSEN_Pos)
#define RCC_APB1ENR1_TIM7EN_Pos                           5
#define RCC_APB1ENR1_TIM7EN_Msk                           (0x1UL << RCC_APB1ENR1_TIM7EN_Pos)
#define RCC_APB1ENR1_TIM6EN_Pos                           4
#define RCC_APB1ENR1_TIM6EN_Msk                           (0x1UL << RCC_APB1ENR1_TIM6EN_Pos)
#define RCC_APB1ENR1_TIM5EN_Pos                           3
#define RCC_APB1ENR1_TIM5EN_Msk                           (0x1UL << RCC_APB1ENR1_TIM5EN_Pos)
#define RCC_APB1ENR1_TIM4EN_Pos                           2
#define RCC_APB1ENR1_TIM4EN_Msk                           (0x1UL << RCC_APB1ENR1_TIM4EN_Pos)
#define RCC_APB1ENR1_TIM3EN_Pos                           1
#define RCC_APB1ENR1_TIM3EN_Msk                           (0x1UL << RCC_APB1ENR1_TIM3EN_Pos)
#define RCC_APB1ENR1_TIM2EN_Pos                           0
#define RCC_APB1ENR1_TIM2EN_Msk                           (0x1UL << RCC_APB1ENR1_TIM2EN_Pos)

//====== RCC_APB1ENR2 0x0000005C ======
#define RCC_APB1ENR2_KSIOEN_Pos                           4
#define RCC_APB1ENR2_KSIOEN_Msk                           (0x1UL << RCC_APB1ENR2_KSIOEN_Pos)
#define RCC_APB1ENR2_UART8EN_Pos                          2
#define RCC_APB1ENR2_UART8EN_Msk                          (0x1UL << RCC_APB1ENR2_UART8EN_Pos)
#define RCC_APB1ENR2_UART7EN_Pos                          0
#define RCC_APB1ENR2_UART7EN_Msk                          (0x1UL << RCC_APB1ENR2_UART7EN_Pos)

//====== RCC_APB2ENR 0x00000060 ======
#define RCC_APB2ENR_TIM11EN_Pos                           18
#define RCC_APB2ENR_TIM11EN_Msk                           (0x1UL << RCC_APB2ENR_TIM11EN_Pos)
#define RCC_APB2ENR_TIM10EN_Pos                           17
#define RCC_APB2ENR_TIM10EN_Msk                           (0x1UL << RCC_APB2ENR_TIM10EN_Pos)
#define RCC_APB2ENR_TIM9EN_Pos                            16
#define RCC_APB2ENR_TIM9EN_Msk                            (0x1UL << RCC_APB2ENR_TIM9EN_Pos)
#define RCC_APB2ENR_USART1EN_Pos                          14
#define RCC_APB2ENR_USART1EN_Msk                          (0x1UL << RCC_APB2ENR_USART1EN_Pos)
#define RCC_APB2ENR_TIM8EN_Pos                            13
#define RCC_APB2ENR_TIM8EN_Msk                            (0x1UL << RCC_APB2ENR_TIM8EN_Pos)
#define RCC_APB2ENR_SPI1EN_Pos                            12
#define RCC_APB2ENR_SPI1EN_Msk                            (0x1UL << RCC_APB2ENR_SPI1EN_Pos)
#define RCC_APB2ENR_TIM1EN_Pos                            11
#define RCC_APB2ENR_TIM1EN_Msk                            (0x1UL << RCC_APB2ENR_TIM1EN_Pos)
#define RCC_APB2ENR_SDIOEN_Pos                            10
#define RCC_APB2ENR_SDIOEN_Msk                            (0x1UL << RCC_APB2ENR_SDIOEN_Pos)
#define RCC_APB2ENR_UART6EN_Pos                           4
#define RCC_APB2ENR_UART6EN_Msk                           (0x1UL << RCC_APB2ENR_UART6EN_Pos)
#define RCC_APB2ENR_SYSCFGEN_Pos                          0
#define RCC_APB2ENR_SYSCFGEN_Msk                          (0x1UL << RCC_APB2ENR_SYSCFGEN_Pos)

//====== RCC_AHB1SMENR 0x00000068 ======
#define RCC_AHB1SMENR_USBSMEN_Pos                         24
#define RCC_AHB1SMENR_USBSMEN_Msk                         (0x1UL << RCC_AHB1SMENR_USBSMEN_Pos)
#define RCC_AHB1SMENR_CRCSMEN_Pos                         12
#define RCC_AHB1SMENR_CRCSMEN_Msk                         (0x1UL << RCC_AHB1SMENR_CRCSMEN_Pos)
#define RCC_AHB1SMENR_SRAM2SMEN_Pos                       9
#define RCC_AHB1SMENR_SRAM2SMEN_Msk                       (0x1UL << RCC_AHB1SMENR_SRAM2SMEN_Pos)
#define RCC_AHB1SMENR_FMCSMEN_Pos                         8
#define RCC_AHB1SMENR_FMCSMEN_Msk                         (0x1UL << RCC_AHB1SMENR_FMCSMEN_Pos)
#define RCC_AHB1SMENR_CORDICSMEN_Pos                      3
#define RCC_AHB1SMENR_CORDICSMEN_Msk                      (0x1UL << RCC_AHB1SMENR_CORDICSMEN_Pos)
#define RCC_AHB1SMENR_DMAMUXSMEN_Pos                      2
#define RCC_AHB1SMENR_DMAMUXSMEN_Msk                      (0x1UL << RCC_AHB1SMENR_DMAMUXSMEN_Pos)
#define RCC_AHB1SMENR_DMA2SMEN_Pos                        1
#define RCC_AHB1SMENR_DMA2SMEN_Msk                        (0x1UL << RCC_AHB1SMENR_DMA2SMEN_Pos)
#define RCC_AHB1SMENR_DMA1SMEN_Pos                        0
#define RCC_AHB1SMENR_DMA1SMEN_Msk                        (0x1UL << RCC_AHB1SMENR_DMA1SMEN_Pos)

//====== RCC_AHB2SMENR 0x0000006C ======
#define RCC_AHB2SMENR_SECURESMEN_Pos                      24
#define RCC_AHB2SMENR_SECURESMEN_Msk                      (0x1UL << RCC_AHB2SMENR_SECURESMEN_Pos)
#define RCC_AHB2SMENR_DAC1SMEN_Pos                        16
#define RCC_AHB2SMENR_DAC1SMEN_Msk                        (0x1UL << RCC_AHB2SMENR_DAC1SMEN_Pos)
#define RCC_AHB2SMENR_ADC3SMEN_Pos                        14
#define RCC_AHB2SMENR_ADC3SMEN_Msk                        (0x1UL << RCC_AHB2SMENR_ADC3SMEN_Pos)
#define RCC_AHB2SMENR_ADC12SMEN_Pos                       13
#define RCC_AHB2SMENR_ADC12SMEN_Msk                       (0x1UL << RCC_AHB2SMENR_ADC12SMEN_Pos)
#define RCC_AHB2SMENR_SRAM3SMEN_Pos                       12
#define RCC_AHB2SMENR_SRAM3SMEN_Msk                       (0x1UL << RCC_AHB2SMENR_SRAM3SMEN_Pos)
#define RCC_AHB2SMENR_SRAM4SMEN_Pos                       11
#define RCC_AHB2SMENR_SRAM4SMEN_Msk                       (0x1UL << RCC_AHB2SMENR_SRAM4SMEN_Pos)
#define RCC_AHB2SMENR_SRAM5SMEN_Pos                       10
#define RCC_AHB2SMENR_SRAM5SMEN_Msk                       (0x1UL << RCC_AHB2SMENR_SRAM5SMEN_Pos)
#define RCC_AHB2SMENR_TESTBOXSMEN_Pos                     9
#define RCC_AHB2SMENR_TESTBOXSMEN_Msk                     (0x1UL << RCC_AHB2SMENR_TESTBOXSMEN_Pos)
#define RCC_AHB2SMENR_GPIOGSMEN_Pos                       6
#define RCC_AHB2SMENR_GPIOGSMEN_Msk                       (0x1UL << RCC_AHB2SMENR_GPIOGSMEN_Pos)
#define RCC_AHB2SMENR_GPIOFSMEN_Pos                       5
#define RCC_AHB2SMENR_GPIOFSMEN_Msk                       (0x1UL << RCC_AHB2SMENR_GPIOFSMEN_Pos)
#define RCC_AHB2SMENR_GPIOESMEN_Pos                       4
#define RCC_AHB2SMENR_GPIOESMEN_Msk                       (0x1UL << RCC_AHB2SMENR_GPIOESMEN_Pos)
#define RCC_AHB2SMENR_GPIODSMEN_Pos                       3
#define RCC_AHB2SMENR_GPIODSMEN_Msk                       (0x1UL << RCC_AHB2SMENR_GPIODSMEN_Pos)
#define RCC_AHB2SMENR_GPIOCSMEN_Pos                       2
#define RCC_AHB2SMENR_GPIOCSMEN_Msk                       (0x1UL << RCC_AHB2SMENR_GPIOCSMEN_Pos)
#define RCC_AHB2SMENR_GPIOBSMEN_Pos                       1
#define RCC_AHB2SMENR_GPIOBSMEN_Msk                       (0x1UL << RCC_AHB2SMENR_GPIOBSMEN_Pos)
#define RCC_AHB2SMENR_GPIOASMEN_Pos                       0
#define RCC_AHB2SMENR_GPIOASMEN_Msk                       (0x1UL << RCC_AHB2SMENR_GPIOASMEN_Pos)

//====== RCC_AHB3SMENR 0x00000070 ======
#define RCC_AHB3SMENR_QSPI2SMEN_Pos                       8
#define RCC_AHB3SMENR_QSPI2SMEN_Msk                       (0x1UL << RCC_AHB3SMENR_QSPI2SMEN_Pos)
#define RCC_AHB3SMENR_FSMCSMEN_Pos                        0
#define RCC_AHB3SMENR_FSMCSMEN_Msk                        (0x1UL << RCC_AHB3SMENR_FSMCSMEN_Pos)

//====== RCC_APB1SMENR1 0x00000078 ======
#define RCC_APB1SMENR1_LPTIM1SMEN_Pos                     31
#define RCC_APB1SMENR1_LPTIM1SMEN_Msk                     (0x1UL << RCC_APB1SMENR1_LPTIM1SMEN_Pos)
#define RCC_APB1SMENR1_I2C3SMEN_Pos                       30
#define RCC_APB1SMENR1_I2C3SMEN_Msk                       (0x1UL << RCC_APB1SMENR1_I2C3SMEN_Pos)
#define RCC_APB1SMENR1_PMUSMEN_Pos                        28
#define RCC_APB1SMENR1_PMUSMEN_Msk                        (0x1UL << RCC_APB1SMENR1_PMUSMEN_Pos)
#define RCC_APB1SMENR1_FDCAN2SMEN_Pos                     26
#define RCC_APB1SMENR1_FDCAN2SMEN_Msk                     (0x1UL << RCC_APB1SMENR1_FDCAN2SMEN_Pos)
#define RCC_APB1SMENR1_FDCAN1SMEN_Pos                     25
#define RCC_APB1SMENR1_FDCAN1SMEN_Msk                     (0x1UL << RCC_APB1SMENR1_FDCAN1SMEN_Pos)
#define RCC_APB1SMENR1_I2C2SMEN_Pos                       22
#define RCC_APB1SMENR1_I2C2SMEN_Msk                       (0x1UL << RCC_APB1SMENR1_I2C2SMEN_Pos)
#define RCC_APB1SMENR1_I2C1SMEN_Pos                       21
#define RCC_APB1SMENR1_I2C1SMEN_Msk                       (0x1UL << RCC_APB1SMENR1_I2C1SMEN_Pos)
#define RCC_APB1SMENR1_UART5SMEN_Pos                      20
#define RCC_APB1SMENR1_UART5SMEN_Msk                      (0x1UL << RCC_APB1SMENR1_UART5SMEN_Pos)
#define RCC_APB1SMENR1_UART4SMEN_Pos                      19
#define RCC_APB1SMENR1_UART4SMEN_Msk                      (0x1UL << RCC_APB1SMENR1_UART4SMEN_Pos)
#define RCC_APB1SMENR1_USART3SMEN_Pos                     18
#define RCC_APB1SMENR1_USART3SMEN_Msk                     (0x1UL << RCC_APB1SMENR1_USART3SMEN_Pos)
#define RCC_APB1SMENR1_USART2SMEN_Pos                     17
#define RCC_APB1SMENR1_USART2SMEN_Msk                     (0x1UL << RCC_APB1SMENR1_USART2SMEN_Pos)
#define RCC_APB1SMENR1_SPI3SMEN_Pos                       15
#define RCC_APB1SMENR1_SPI3SMEN_Msk                       (0x1UL << RCC_APB1SMENR1_SPI3SMEN_Pos)
#define RCC_APB1SMENR1_SPI2SMEN_Pos                       14
#define RCC_APB1SMENR1_SPI2SMEN_Msk                       (0x1UL << RCC_APB1SMENR1_SPI2SMEN_Pos)
#define RCC_APB1SMENR1_WWDTSMEN_Pos                       11
#define RCC_APB1SMENR1_WWDTSMEN_Msk                       (0x1UL << RCC_APB1SMENR1_WWDTSMEN_Pos)
#define RCC_APB1SMENR1_RTCAPBSMEN_Pos                     10
#define RCC_APB1SMENR1_RTCAPBSMEN_Msk                     (0x1UL << RCC_APB1SMENR1_RTCAPBSMEN_Pos)
#define RCC_APB1SMENR1_CRSSMEN_Pos                        8
#define RCC_APB1SMENR1_CRSSMEN_Msk                        (0x1UL << RCC_APB1SMENR1_CRSSMEN_Pos)
#define RCC_APB1SMENR1_TIM7SMEN_Pos                       5
#define RCC_APB1SMENR1_TIM7SMEN_Msk                       (0x1UL << RCC_APB1SMENR1_TIM7SMEN_Pos)
#define RCC_APB1SMENR1_TIM6SMEN_Pos                       4
#define RCC_APB1SMENR1_TIM6SMEN_Msk                       (0x1UL << RCC_APB1SMENR1_TIM6SMEN_Pos)
#define RCC_APB1SMENR1_TIM5SMEN_Pos                       3
#define RCC_APB1SMENR1_TIM5SMEN_Msk                       (0x1UL << RCC_APB1SMENR1_TIM5SMEN_Pos)
#define RCC_APB1SMENR1_TIM4SMEN_Pos                       2
#define RCC_APB1SMENR1_TIM4SMEN_Msk                       (0x1UL << RCC_APB1SMENR1_TIM4SMEN_Pos)
#define RCC_APB1SMENR1_TIM3SMEN_Pos                       1
#define RCC_APB1SMENR1_TIM3SMEN_Msk                       (0x1UL << RCC_APB1SMENR1_TIM3SMEN_Pos)
#define RCC_APB1SMENR1_TIM2SMEN_Pos                       0
#define RCC_APB1SMENR1_TIM2SMEN_Msk                       (0x1UL << RCC_APB1SMENR1_TIM2SMEN_Pos)

//====== RCC_APB1SMENR2 0x0000007C ======
#define RCC_APB1SMENR2_KSIOSMEN_Pos                       4
#define RCC_APB1SMENR2_KSIOSMEN_Msk                       (0x1UL << RCC_APB1SMENR2_KSIOSMEN_Pos)
#define RCC_APB1SMENR2_UART8SMEN_Pos                      2
#define RCC_APB1SMENR2_UART8SMEN_Msk                      (0x1UL << RCC_APB1SMENR2_UART8SMEN_Pos)
#define RCC_APB1SMENR2_UART7SMEN_Pos                      0
#define RCC_APB1SMENR2_UART7SMEN_Msk                      (0x1UL << RCC_APB1SMENR2_UART7SMEN_Pos)

//====== RCC_APB2SMENR 0x00000080 ======
#define RCC_APB2SMENR_TIM11SMEN_Pos                       18
#define RCC_APB2SMENR_TIM11SMEN_Msk                       (0x1UL << RCC_APB2SMENR_TIM11SMEN_Pos)
#define RCC_APB2SMENR_TIM10SMEN_Pos                       17
#define RCC_APB2SMENR_TIM10SMEN_Msk                       (0x1UL << RCC_APB2SMENR_TIM10SMEN_Pos)
#define RCC_APB2SMENR_TIM9SMEN_Pos                        16
#define RCC_APB2SMENR_TIM9SMEN_Msk                        (0x1UL << RCC_APB2SMENR_TIM9SMEN_Pos)
#define RCC_APB2SMENR_USART1SMEN_Pos                      14
#define RCC_APB2SMENR_USART1SMEN_Msk                      (0x1UL << RCC_APB2SMENR_USART1SMEN_Pos)
#define RCC_APB2SMENR_TIM8SMEN_Pos                        13
#define RCC_APB2SMENR_TIM8SMEN_Msk                        (0x1UL << RCC_APB2SMENR_TIM8SMEN_Pos)
#define RCC_APB2SMENR_SPI1SMEN_Pos                        12
#define RCC_APB2SMENR_SPI1SMEN_Msk                        (0x1UL << RCC_APB2SMENR_SPI1SMEN_Pos)
#define RCC_APB2SMENR_TIM1SMEN_Pos                        11
#define RCC_APB2SMENR_TIM1SMEN_Msk                        (0x1UL << RCC_APB2SMENR_TIM1SMEN_Pos)
#define RCC_APB2SMENR_SDIOSMEN_Pos                        10
#define RCC_APB2SMENR_SDIOSMEN_Msk                        (0x1UL << RCC_APB2SMENR_SDIOSMEN_Pos)
#define RCC_APB2SMENR_UART6SMEN_Pos                       4
#define RCC_APB2SMENR_UART6SMEN_Msk                       (0x1UL << RCC_APB2SMENR_UART6SMEN_Pos)
#define RCC_APB2SMENR_SYSCFGSMEN_Pos                      0
#define RCC_APB2SMENR_SYSCFGSMEN_Msk                      (0x1UL << RCC_APB2SMENR_SYSCFGSMEN_Pos)

//====== RCC_CCIPR1 0x00000088 ======
#define RCC_CCIPR1_PHPRE_Pos                              31
#define RCC_CCIPR1_PHPRE_Msk                              (0x1UL << RCC_CCIPR1_PHPRE_Pos)
#define RCC_CCIPR1_ADC3SEL_Pos                            30
#define RCC_CCIPR1_ADC3SEL_Msk                            (0x1UL << RCC_CCIPR1_ADC3SEL_Pos)
#define RCC_CCIPR1_ADC12SEL_Pos                           28
#define RCC_CCIPR1_ADC12SEL_Msk                           (0x1UL << RCC_CCIPR1_ADC12SEL_Pos)
#define RCC_CCIPR1_FDCAN2SEL_Pos                          26
#define RCC_CCIPR1_FDCAN2SEL_Msk                          (0x3UL << RCC_CCIPR1_FDCAN2SEL_Pos)
#define RCC_CCIPR1_FDCAN1SEL_Pos                          24
#define RCC_CCIPR1_FDCAN1SEL_Msk                          (0x3UL << RCC_CCIPR1_FDCAN1SEL_Pos)
#define RCC_CCIPR1_I2S23SEL_Pos                           22
#define RCC_CCIPR1_I2S23SEL_Msk                           (0x3UL << RCC_CCIPR1_I2S23SEL_Pos)
#define RCC_CCIPR1_SDIOSEL_Pos                            20
#define RCC_CCIPR1_SDIOSEL_Msk                            (0x1UL << RCC_CCIPR1_SDIOSEL_Pos)
#define RCC_CCIPR1_LPTIM1SEL_Pos                          18
#define RCC_CCIPR1_LPTIM1SEL_Msk                          (0x3UL << RCC_CCIPR1_LPTIM1SEL_Pos)
#define RCC_CCIPR1_I2C3SEL_Pos                            16
#define RCC_CCIPR1_I2C3SEL_Msk                            (0x3UL << RCC_CCIPR1_I2C3SEL_Pos)
#define RCC_CCIPR1_I2C2SEL_Pos                            14
#define RCC_CCIPR1_I2C2SEL_Msk                            (0x3UL << RCC_CCIPR1_I2C2SEL_Pos)
#define RCC_CCIPR1_I2C1SEL_Pos                            12
#define RCC_CCIPR1_I2C1SEL_Msk                            (0x3UL << RCC_CCIPR1_I2C1SEL_Pos)
#define RCC_CCIPR1_UART5SEL_Pos                           8
#define RCC_CCIPR1_UART5SEL_Msk                           (0x3UL << RCC_CCIPR1_UART5SEL_Pos)
#define RCC_CCIPR1_UART4SEL_Pos                           6
#define RCC_CCIPR1_UART4SEL_Msk                           (0x3UL << RCC_CCIPR1_UART4SEL_Pos)
#define RCC_CCIPR1_USART3SEL_Pos                          4
#define RCC_CCIPR1_USART3SEL_Msk                          (0x3UL << RCC_CCIPR1_USART3SEL_Pos)
#define RCC_CCIPR1_USART2SEL_Pos                          2
#define RCC_CCIPR1_USART2SEL_Msk                          (0x3UL << RCC_CCIPR1_USART2SEL_Pos)
#define RCC_CCIPR1_USART1SEL_Pos                          0
#define RCC_CCIPR1_USART1SEL_Msk                          (0x3UL << RCC_CCIPR1_USART1SEL_Pos)

//====== RCC_CCIPR2 0x0000008C ======
#define RCC_CCIPR2_BDGSEL_Pos                             10
#define RCC_CCIPR2_BDGSEL_Msk                             (0x1UL << RCC_CCIPR2_BDGSEL_Pos)
#define RCC_CCIPR2_BDGDIV_Pos                             7
#define RCC_CCIPR2_BDGDIV_Msk                             (0x7UL << RCC_CCIPR2_BDGDIV_Pos)
#define RCC_CCIPR2_USBCLKDIV_Pos                          6
#define RCC_CCIPR2_USBCLKDIV_Msk                          (0x1UL << RCC_CCIPR2_USBCLKDIV_Pos)
#define RCC_CCIPR2_UART8SEL_Pos                           4
#define RCC_CCIPR2_UART8SEL_Msk                           (0x3UL << RCC_CCIPR2_UART8SEL_Pos)
#define RCC_CCIPR2_UART7SEL_Pos                           2
#define RCC_CCIPR2_UART7SEL_Msk                           (0x3UL << RCC_CCIPR2_UART7SEL_Pos)
#define RCC_CCIPR2_UART6SEL_Pos                           0
#define RCC_CCIPR2_UART6SEL_Msk                           (0x3UL << RCC_CCIPR2_UART6SEL_Pos)

//====== RCC_BDCR 0x00000090 ======
#define RCC_BDCR_LXTAGCSEL_Pos                            30
#define RCC_BDCR_LXTAGCSEL_Msk                            (0x3UL << RCC_BDCR_LXTAGCSEL_Pos)
#define RCC_BDCR_LXTRFEN_Pos                              29
#define RCC_BDCR_LXTRFEN_Msk                              (0x1UL << RCC_BDCR_LXTRFEN_Pos)
#define RCC_BDCR_LXTRFSEL_Pos                             28
#define RCC_BDCR_LXTRFSEL_Msk                             (0x1UL << RCC_BDCR_LXTRFSEL_Pos)
#define RCC_BDCR_LXTBYPAGC_Pos                            27
#define RCC_BDCR_LXTBYPAGC_Msk                            (0x1UL << RCC_BDCR_LXTBYPAGC_Pos)
#define RCC_BDCR_LXTIOPSEL_Pos                            24
#define RCC_BDCR_LXTIOPSEL_Msk                            (0x7UL << RCC_BDCR_LXTIOPSEL_Pos)
#define RCC_BDCR_LSCOSEL_Pos                              23
#define RCC_BDCR_LSCOSEL_Msk                              (0x1UL << RCC_BDCR_LSCOSEL_Pos)
#define RCC_BDCR_LSCOEN_Pos                               22
#define RCC_BDCR_LSCOEN_Msk                               (0x1UL << RCC_BDCR_LSCOEN_Pos)
#define RCC_BDCR_BDRST_Pos                                16
#define RCC_BDCR_BDRST_Msk                                (0x1UL << RCC_BDCR_BDRST_Pos)
#define RCC_BDCR_RTCEN_Pos                                15
#define RCC_BDCR_RTCEN_Msk                                (0x1UL << RCC_BDCR_RTCEN_Pos)
#define RCC_BDCR_RTCSEL_Pos                               8
#define RCC_BDCR_RTCSEL_Msk                               (0x3UL << RCC_BDCR_RTCSEL_Pos)
#define RCC_BDCR_LXTCSSD_Pos                              6
#define RCC_BDCR_LXTCSSD_Msk                              (0x1UL << RCC_BDCR_LXTCSSD_Pos)
#define RCC_BDCR_LXTCSSON_Pos                             5
#define RCC_BDCR_LXTCSSON_Msk                             (0x1UL << RCC_BDCR_LXTCSSON_Pos)
#define RCC_BDCR_LXTBYP_Pos                               2
#define RCC_BDCR_LXTBYP_Msk                               (0x1UL << RCC_BDCR_LXTBYP_Pos)
#define RCC_BDCR_LXTSTAB_Pos                              1
#define RCC_BDCR_LXTSTAB_Msk                              (0x1UL << RCC_BDCR_LXTSTAB_Pos)
#define RCC_BDCR_LXTEN_Pos                                0
#define RCC_BDCR_LXTEN_Msk                                (0x1UL << RCC_BDCR_LXTEN_Pos)

//====== RCC_CSR 0x00000094 ======
#define RCC_CSR_LPWRRSTF_Pos                              31
#define RCC_CSR_LPWRRSTF_Msk                              (0x1UL << RCC_CSR_LPWRRSTF_Pos)
#define RCC_CSR_WWDTRSTF_Pos                              30
#define RCC_CSR_WWDTRSTF_Msk                              (0x1UL << RCC_CSR_WWDTRSTF_Pos)
#define RCC_CSR_FWDTRSTF_Pos                              29
#define RCC_CSR_FWDTRSTF_Msk                              (0x1UL << RCC_CSR_FWDTRSTF_Pos)
#define RCC_CSR_SFTRSTF_Pos                               28
#define RCC_CSR_SFTRSTF_Msk                               (0x1UL << RCC_CSR_SFTRSTF_Pos)
#define RCC_CSR_BORRSTF_Pos                               27
#define RCC_CSR_BORRSTF_Msk                               (0x1UL << RCC_CSR_BORRSTF_Pos)
#define RCC_CSR_PINRSTF_Pos                               26
#define RCC_CSR_PINRSTF_Msk                               (0x1UL << RCC_CSR_PINRSTF_Pos)
#define RCC_CSR_OBLRSTF_Pos                               25
#define RCC_CSR_OBLRSTF_Msk                               (0x1UL << RCC_CSR_OBLRSTF_Pos)
#define RCC_CSR_BPORRSTF_Pos                              24
#define RCC_CSR_BPORRSTF_Msk                              (0x1UL << RCC_CSR_BPORRSTF_Pos)
#define RCC_CSR_RMVF_Pos                                  23
#define RCC_CSR_RMVF_Msk                                  (0x1UL << RCC_CSR_RMVF_Pos)
#define RCC_CSR_LRCFTUNE_Pos                              2
#define RCC_CSR_LRCFTUNE_Msk                              (0xFUL << RCC_CSR_LRCFTUNE_Pos)
#define RCC_CSR_LRCSTAB_Pos                               1
#define RCC_CSR_LRCSTAB_Msk                               (0x1UL << RCC_CSR_LRCSTAB_Pos)
#define RCC_CSR_LRCEN_Pos                                 0
#define RCC_CSR_LRCEN_Msk                                 (0x1UL << RCC_CSR_LRCEN_Pos)

//====== RCC_TEST 0x0000009C ======
#define RCC_TEST_PLLTESTSEL_Pos                           8
#define RCC_TEST_PLLTESTSEL_Msk                           (0x3UL << RCC_TEST_PLLTESTSEL_Pos)
#define RCC_TEST_LRCCTUNE_Pos                             0
#define RCC_TEST_LRCCTUNE_Msk                             (0x3FUL << RCC_TEST_LRCCTUNE_Pos)

//====== RCC_ADCCFG 0x00000100 ======
#define RCC_ADCCFG_CKMODE12_Pos                           12
#define RCC_ADCCFG_CKMODE12_Msk                           (0x3UL << RCC_ADCCFG_CKMODE12_Pos)
#define RCC_ADCCFG_ADC12CLKC_Pos                          11
#define RCC_ADCCFG_ADC12CLKC_Msk                          (0x1UL << RCC_ADCCFG_ADC12CLKC_Pos)
#define RCC_ADCCFG_ADC12CLKDIV_Pos                        7
#define RCC_ADCCFG_ADC12CLKDIV_Msk                        (0xFUL << RCC_ADCCFG_ADC12CLKDIV_Pos)
#define RCC_ADCCFG_CKMODE3_Pos                            5
#define RCC_ADCCFG_CKMODE3_Msk                            (0x3UL << RCC_ADCCFG_CKMODE3_Pos)
#define RCC_ADCCFG_ADC3CLKC_Pos                           4
#define RCC_ADCCFG_ADC3CLKC_Msk                           (0x1UL << RCC_ADCCFG_ADC3CLKC_Pos)
#define RCC_ADCCFG_ADC3CLKDIV_Pos                         0
#define RCC_ADCCFG_ADC3CLKDIV_Msk                         (0xFUL << RCC_ADCCFG_ADC3CLKDIV_Pos)

//====== RCC_QSPI2CFG 0x00000104 ======
#define RCC_QSPI2CFG_QSPI2CKSF_Pos                        2
#define RCC_QSPI2CFG_QSPI2CKSF_Msk                        (0x1UL << RCC_QSPI2CFG_QSPI2CKSF_Pos)
#define RCC_QSPI2CFG_QSPI2SEL_Pos                         0
#define RCC_QSPI2CFG_QSPI2SEL_Msk                         (0x3UL << RCC_QSPI2CFG_QSPI2SEL_Pos)

typedef struct {
    __IO uint32_t RCC_CR;                       // Address Offset: 0x00000000
    __IO uint32_t RCC_ICSCR;                    // Address Offset: 0x00000004
    __IO uint32_t RCC_CFGR;                     // Address Offset: 0x00000008
    __IO uint32_t RCC_PLLCFGR;                  // Address Offset: 0x0000000C
         uint32_t RESERVED0[2];
    __IO uint32_t RCC_CIER;                     // Address Offset: 0x00000018
    __I  uint32_t RCC_CIFR;                     // Address Offset: 0x0000001C
    __O  uint32_t RCC_CICR;                     // Address Offset: 0x00000020
         uint32_t RESERVED1[1];
    __IO uint32_t RCC_AHB1RSTR;                 // Address Offset: 0x00000028
    __IO uint32_t RCC_AHB2RSTR;                 // Address Offset: 0x0000002C
    __IO uint32_t RCC_AHB3RSTR;                 // Address Offset: 0x00000030
         uint32_t RESERVED2[1];
    __IO uint32_t RCC_APB1RSTR1;                // Address Offset: 0x00000038
    __IO uint32_t RCC_APB1RSTR2;                // Address Offset: 0x0000003C
    __IO uint32_t RCC_APB2RSTR;                 // Address Offset: 0x00000040
         uint32_t RESERVED3[1];
    __IO uint32_t RCC_AHB1ENR;                  // Address Offset: 0x00000048
    __IO uint32_t RCC_AHB2ENR;                  // Address Offset: 0x0000004C
    __IO uint32_t RCC_AHB3ENR;                  // Address Offset: 0x00000050
         uint32_t RESERVED4[1];
    __IO uint32_t RCC_APB1ENR1;                 // Address Offset: 0x00000058
    __IO uint32_t RCC_APB1ENR2;                 // Address Offset: 0x0000005C
    __IO uint32_t RCC_APB2ENR;                  // Address Offset: 0x00000060
         uint32_t RESERVED5[1];
    __IO uint32_t RCC_AHB1SMENR;                // Address Offset: 0x00000068
    __IO uint32_t RCC_AHB2SMENR;                // Address Offset: 0x0000006C
    __IO uint32_t RCC_AHB3SMENR;                // Address Offset: 0x00000070
         uint32_t RESERVED6[1];
    __IO uint32_t RCC_APB1SMENR1;               // Address Offset: 0x00000078
    __IO uint32_t RCC_APB1SMENR2;               // Address Offset: 0x0000007C
    __IO uint32_t RCC_APB2SMENR;                // Address Offset: 0x00000080
         uint32_t RESERVED7[1];
    __IO uint32_t RCC_CCIPR1;                   // Address Offset: 0x00000088
    __IO uint32_t RCC_CCIPR2;                   // Address Offset: 0x0000008C
    __IO uint32_t RCC_BDCR;                     // Address Offset: 0x00000090
    __IO uint32_t RCC_CSR;                      // Address Offset: 0x00000094
         uint32_t RESERVED8[1];
    __IO uint32_t RCC_TEST;                     // Address Offset: 0x0000009C
         uint32_t RESERVED9[24];
    __IO uint32_t RCC_ADCCFG;                   // Address Offset: 0x00000100
    __IO uint32_t RCC_QSPI2CFG;                 // Address Offset: 0x00000104
} RCC_TYPEDEF;

#endif //RCC_REG_H
