
// #define USB          USB_0

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
    uint32_t temp;
    int count;
    int endpoint_count;

    ccode_send_label(100);

    ccode_wait_label(101);
    count = ccode_get_data(0);
    endpoint_count = ccode_get_data(1);

    print_ok(100);
    RCC_USB_60M_Config();//pll_hf/2

    syscfg_clock_en();
    print_ok(101);
    enable_usb_sram();
    print_ok(102);
    usb_phy_en();
    nop_repeat(1000);

    //gpio cfg
    gpio_clock_enable(GPIOF,ENABLE);
    config_gpio_mode(GPIOF, GPIO4, AF, AF0);
    config_gpio_mode(GPIOF, GPIO5, AF, AF0);

    SYSCFG->SYSCFG_CRG &= ~SYSCFG_CRG_CID_USBFS_Msk; //host
    print_ok(120);

    NVIC_EnableIRQ(USB_IRQn);

    /************ part1: config **************/
    USB->SIE_Index = 0x1;
    USB->SIE_TxFIFOsz = 0x6;
    USB->SIE_Index = 0x2;
    USB->SIE_TxFIFOsz = 0x6;
    USB->SIE_Index = 0x3;
    USB->SIE_TxFIFOsz = 0x6;
    USB->SIE_Index = 0x4;
    USB->SIE_TxFIFOsz = 0x6;
    for(int i=0;i<endpoint_count;i++)
    {
        USB->SIE_Index = i+1;
        USB->SIE_TxFIFOadd = 0x40 * i;  //64
        for(int j=0;j<count;j++)
        {
            USB->EP_FIFOEn[i+1] = 0x01000000 + i*16 + j;
        }
    }

    for(int i=0;i<endpoint_count;i++)
    {
        USB->SIE_Index = i+1;
        USB->SIE_TxFIFOadd = 0x40 * i + 0x100;  //64
        for(int j=0;j<count;j++)
        {
            USB->EP_FIFOEn[i+1] = 0x10000000 + i*16 + j;
        }
    }

    for(int i=0;i<endpoint_count;i++)
    {
        USB->SIE_Index = i+1;
        USB->SIE_RxFIFOadd = 0x40 * i;  //64
        for(int j=0;j<count;j++)
        {
            temp = USB->EP_FIFOEn[i+1];
            if(i == 0)
            {
                print_info(temp);
                print_info(0x10000000 + 3*16 + j);
                check(temp,(0x10000000 + 3*16 + j), 300);
            } else {
                print_info(temp);
                print_info(0x10000000 + (i-1)*16 + j);
                check(temp,(0x10000000 + (i-1)*16 + j), 301);
            }
        }
    }
    print_ok(222);
    ccode_send_label(102);
}

void USB_IRQHandler(void){
    uint32_t temp;

    temp = USB->SIE_IntrUSB; //clear int
    temp = USB->SIE_IntrIn; //read 02 intrin and clear ep2 end send int
    temp = USB->SIE_IntrOut; //read 04 introut and clear ep1 end send int
}

void BusFault_Handler(void){
    print_error(9999);
}

void UsageFault_Handler(void){
    print_error(8888);
}


