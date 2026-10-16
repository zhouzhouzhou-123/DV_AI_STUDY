
//#define USB             USB_1

void usb_phy_en(void)
{
    // enable PHY
    SYSCFG->SYSCFG_CRG |= 0x1<<17;
    // modify PHY from POWERDOWN to normal
    SYSCFG->SYSCFG_CRG &= ~(0x1<<30);
}

void enable_usb_sram(void)
{
    uint32_t temp_data;
    pmu_clk_en();
    // modify USB sram from ShutDown to normal
    temp_data = PMU->SRAM_CFG0;
    temp_data &= ~(0x3<<14);
    temp_data &= ~(0xff<<24);
    temp_data |= 0x53<<24;

    PMU->SRAM_CFG0 = temp_data;
    while(1)
    {
        if((PMU->SRAM_CFG0 & (0x3<<14)) == 0x0)
        {
            break;
        }
    }
}

//Main function-USB_NORMAL_RUN
int main (void) {

    RCC_USB_60M_Config();//pll_hf/2

    syscfg_clock_en();

    print_ok(118);
    enable_usb_sram();
    print_ok(119);
    usb_phy_en();
    nop_repeat(1000);

    //gpio cfg
    gpio_clock_enable(GPIOF,ENABLE);
    config_gpio_mode(GPIOF, GPIO4, AF, AF0);
    config_gpio_mode(GPIOF, GPIO5, AF, AF0);
    config_gpio_pupd(GPIOF, GPIO4, PU);
    config_gpio_pupd(GPIOF, GPIO5, PD);

    // enable usb digital test
    syscfg_test_unlock();
    SYSCFG->SYSCFG_TEST |= 0x53<<24 | 0x1<<22 | 0x22<<8 | 0x1<<15;

    // entern USB SRAM test
    syscfg_unlock();
    SYSCFG->SRAM4_TEST |= 0x1<<31;

    ccode_send_label(100);
    for(int index=0; index<3; index++)
    {
        ccode_wait_label(101);
        SYSCFG->SRAM4_TEST = ccode_get_data(0) | 0x1<<31;
        PMU->SRAM_CFG0 = 0x53<<24 | ccode_get_data(1)<<14;

        ccode_send_label(102);
    }

    ccode_wait_label(103);
    // exit USB sram test mode
    SYSCFG->SRAM4_TEST = 0x0;
    ccode_send_label(104);
}

void USB_IRQHandler(void){
    uint32_t temp;

    temp = USB->SIE_IntrUSB; //clear int
    temp = USB->SIE_IntrIn; //read 02 intrin and clear ep2 end send int
    temp = USB->SIE_IntrOut; //read 04 introut and clear ep1 end send int
    temp = USB->SIE_OutCount;
}

void BusFault_Handler(void){
    print_error(9999);
}

void UsageFault_Handler(void){
    print_error(8888);
}


