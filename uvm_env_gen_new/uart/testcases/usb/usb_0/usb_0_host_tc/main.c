
// #define USB             USB_0


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


void control_in(void) {
    uint32_t temp;
    //***********************************config fifo
    USB->SIE_Index = 0x0;
    USB->EP_FIFOEn[0] = 0x07010680; //get description
    USB->EP_FIFOEn[0] = 0x01000000;
    //***********************************send setup
    USB->SIE_InCSR = 0xa;//set 12 incsr set setup pkt and txpktrdy to send setup token

    //***********************************wait setup done
    __WFI();
    temp = USB->SIE_IntrIn; //clear int

    for(int i = 0;i<5;i++)
    {
        //***********************************send data IN
        USB->SIE_InCSR |= 0x20;//set 12 incsr set setup statuspkt and reqpkt to send status token

        //***********************************wait status done
        __WFI();
        temp = USB->SIE_IntrIn; //clear int
    }

    //***********************************send status out
    USB->SIE_InCSR = 0x42; //set 12 incsr set setup statuspkt and reqpkt to send status token

    //***********************************wait status done
    __WFI();
    temp = USB->SIE_IntrIn; //clear int

}

void bulk_in(void) {
    uint32_t temp;

    USB->SIE_Index = 0x1; //set 0e index to select ep1 bulk_in
    USB->SIE_TxType = 0x2<<4 | 0x1<<0; //set 1a txtype set bulk trans and ep1
    USB->SIE_RxType = 0x2<<4 | 0x1<<0; //set 1c rxtype set bulk trans and ep1
    temp = USB->SIE_DevCtl;

    USB->SIE_TxFIFOsz = 0x9;
    USB->SIE_RxFIFOsz = 0x9;
    USB->SIE_OutMax = 0xff; //set 14 outmax to set inmax = ff

    for(int i=0;i<4;i++) {
        USB->SIE_OutCSR = 0x20; //set 16 outcsr enable IN
        __WFI();
        temp = USB->SIE_IntrOut; //read 04 introut and clear ep1 end send int
        nop_repeat(5);
    }
    USB->SIE_OutCSR = 0x0;
}

void bulk_out(void) {
    uint32_t temp;

    //**************************************cfg
    USB->SIE_Index = 0x2; //set 0e index to select ep2 bulk_in
    USB->SIE_TxType = 0x2<<4 | 0x2<<0; //set 1a txtype set bulk trans and ep
    USB->SIE_RxType = 0x2<<4 | 0x2<<0; //set 1c rxtype set bulk trans and ep2
    temp = USB->SIE_DevCtl;

    USB->SIE_TxFIFOsz = 0x9;
    USB->SIE_RxFIFOsz = 0x9;
    USB->SIE_InMax = 0xff; //set 10 inmax to set inmax = ff

    USB->EP_FIFOEn[2] = 0x1111; //set 28 ep2_fifoen to write data
    USB->EP_FIFOEn[2] = 0x2222;
    USB->EP_FIFOEn[2] = 0x3333;
    USB->EP_FIFOEn[2] = 0x4444;
    USB->EP_FIFOEn[2] = 0x5555;
    USB->EP_FIFOEn[2] = 0x6666;
    USB->EP_FIFOEn[2] = 0x7777;
    USB->EP_FIFOEn[2] = 0x8888;
    USB->EP_FIFOEn[2] = 0x9999;
    USB->EP_FIFOEn[2] = 0xaaaa;
    USB->EP_FIFOEn[2] = 0xbbbb;
    USB->EP_FIFOEn[2] = 0xcccc;
    USB->EP_FIFOEn[2] = 0xdddd;
    USB->EP_FIFOEn[2] = 0xeeee;
    USB->EP_FIFOEn[2] = 0xffff;

    USB->SIE_InCSR = 0xa041; //set 12 incsr enable OUT
    __WFI();
    temp = USB->SIE_IntrIn; //read 02 intrin and clear ep2 end send int
    nop_repeat(5);
}

//Main function-USB_NORMAL_RUN
int main (void) {
    uint32_t temp;

    RCC_USB_60M_Config();//pll_hf/2

    syscfg_clock_en();
    print_ok(100);
    enable_usb_sram();
    print_ok(101);
    usb_phy_en();
    nop_repeat(1000);

    //gpio cfg
    gpio_clock_enable(GPIOF,ENABLE);
    config_gpio_mode(GPIOF, GPIO4, AF, AF0);
    config_gpio_mode(GPIOF, GPIO5, AF, AF0);
    config_gpio_pupd(GPIOF, GPIO4, PU);
    config_gpio_pupd(GPIOF, GPIO5, PD);

    SYSCFG->SYSCFG_CRG &= ~SYSCFG_CRG_CID_USBFS_Msk; //host
    print_ok(102);

    NVIC_EnableIRQ(USB_IRQn);

    print_ok(103);
    /************ part1: config **************/
    USB->SIE_Testmode = 0x20; //FS
    USB->SIE_LinkInfo = 0x11; //set wtcon = 1 wtid = 1
    USB->SIE_Power = 0x60; //softcon
    USB->SIE_Power = 0x21; //suspendmen
    USB->SIE_IntrUSBE = 0xff; //enable int
    USB->SIE_DevCtl = 1; //start session
    print_ok(104);

    //***********************************wait attach done
    __WFI();

    print_ok(105);
    temp = USB->SIE_IntrUSB; //clear int
    temp = USB->SIE_DevCtl; //start session
    print_ok(106);

    USB->SIE_Power = 0x29; //reset
    print_ok(107);

    ccode_send_label(100);
    ccode_wait_label(101);//wait less 15ms

    USB->SIE_Power = 0x21; //clear reset

    temp = USB->SIE_Power; //read power
    temp = USB->SIE_IntrUSB; //clear int

    print_ok(108);
    __WFI(); //SOF int
    print_ok(109);

    /***************************host*****************************/
	control_in();
    print_ok(110);
    temp = USB->SIE_InCSR;
    print_ok(111);
    USB->SIE_InCSR = 0x40;//write 12 incsr to clear rxpktrdy
    print_ok(112);

    bulk_in();
    print_ok(113);
    nop_repeat(20);

    USB->SIE_Power = 0x29; //reset for sim model skew
    print_ok(114);
    ccode_send_label(102);
    ccode_wait_label(103);//rst

    USB->SIE_Power = 0x21; //clear reset

    bulk_out();
    print_ok(115);
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


