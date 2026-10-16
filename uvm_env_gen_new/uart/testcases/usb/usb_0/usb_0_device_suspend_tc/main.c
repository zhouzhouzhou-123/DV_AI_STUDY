
// #define USB      USB_0

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

void control_in()
{
    uint32_t temp;

    print_ok(200);
    ccode_send_label(200);
    //***********************************trans setup
    __WFI();
    temp = USB->SIE_OutCount; //read 18 outcount and clear ep0 int
    temp = USB->EP_FIFOEn[0]; //read 20 ep0fifo read ep0 data
    temp = USB->EP_FIFOEn[0];
    temp = USB->SIE_InCSR; //read 12 incsr
    // USB->SIE_InCSR = 0xd0; //write 12 incsr and clear ep0 int

    // ahb_read('h400,read_data); //read 02 intrin and clear ep0 int

    //***********************************trans IN
    USB->EP_FIFOEn[0] = 0x1111; //set 20 ep0_fifoen to write data
    USB->EP_FIFOEn[0] = 0x2222;
    USB->EP_FIFOEn[0] = 0x3333;
    USB->EP_FIFOEn[0] = 0x4444;
    USB->EP_FIFOEn[0] = 0x5555;
    USB->EP_FIFOEn[0] = 0x6666;
    USB->EP_FIFOEn[0] = 0x7777;
    USB->EP_FIFOEn[0] = 0x8888;
    USB->EP_FIFOEn[0] = 0x9999;
    USB->EP_FIFOEn[0] = 0xaaaa;
    USB->EP_FIFOEn[0] = 0xbbbb;
    USB->EP_FIFOEn[0] = 0xcccc;
    USB->EP_FIFOEn[0] = 0xdddd;
    USB->EP_FIFOEn[0] = 0xeeee;
    USB->EP_FIFOEn[0] = 0xffff;

    USB->SIE_InCSR = 0xa; //write 12 incsr send IN data 1

    print_ok(201);
    __WFI();
    print_ok(202);
    temp = USB->SIE_InCSR;

    //***********************************trans status OUT
    print_ok(203);
    __WFI();
    print_ok(204);
    ccode_send_label(201);
}

void control_out(void) {
    uint32_t temp;

    print_ok(300);
    ccode_send_label(300);
    //***********************************trans setup
    print_ok(301);
    __WFI();
    print_ok(302);
    temp = USB->SIE_OutCount; //read 18 outcount and clear ep0 int
    temp = USB->EP_FIFOEn[0]; //read 20 ep0fifo read ep0 data
    temp = USB->SIE_InCSR; //read 12 incsr
    USB->SIE_InCSR = 0xd0; //write 12 incsr and clear ep0 int

    // ahb_read('h400,read_data); //read 02 intrin and clear ep0 int

    //***********************************trans OUT
    print_ok(303);
    __WFI();
    print_ok(304);
    temp = USB->SIE_OutCount; //read 18 outcount and clear ep0 int
    temp = USB->EP_FIFOEn[0]; //read 20 ep0fifo read ep0 data
    temp = USB->SIE_InCSR; //read 12 incsr
    USB->SIE_InCSR = 0xd0; //write 12 incsr and clear ep0 int

    //***********************************trans status IN
    print_ok(305);
    __WFI();
    print_ok(306);
    USB->SIE_InCSR = 0xd0; //write 12 incsr and clear ep0 int
    print_ok(307);
    __WFI();
    print_ok(308);
    ccode_send_label(301);
}
void bulk_in(void) {
    print_ok(400);

    //**************************************cfg
    USB->SIE_Index = 0x2; //set 0e index to select ep2 bulk_in
    USB->SIE_InMax = 0xff; //set 10 inmax set inmax = ff
    USB->SIE_InCSR = 0x81; //set 12 incsr enable autoset and inpktrdy
    print_ok(401);

    //***********************************trans IN
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
    print_ok(402);

    USB->SIE_InCSR = 0x8001; //set 12 incsr enable autoset and inpktrdy

    ccode_send_label(400);
    ccode_wait_label(401);//send control_out
}

void bulk_out(void) {
    uint32_t temp_data[25];
    print_ok(500);

    //**************************************cfg
    USB->SIE_TxFIFOsz = 0x6; //set 62 63 fifosz
    USB->SIE_RxFIFOsz = 0x6;
    USB->SIE_Index = 0x2; //set 0e index to select ep2 bulk_out
    USB->SIE_OutMax = 0xff; //set 14 outmax set inmax = ff
    USB->SIE_OutCSR = 0x8000; //set 16 outcsr enable autoclear and inpktrdy

    ccode_send_label(500);
    print_ok(501);

    //**************************************recive 1st packet
    print_ok(502);
    __WFI();
    print_ok(503);

    for(int i=0;i<16;i=i+1) {
        temp_data[i] = USB->EP_FIFOEn[2];
    }

    //**************************************recive 2ed packet
    USB->SIE_OutCSR = 0x8000; //set 16 outcsr enable autoclear and inpktrdy
    print_ok(504);
    __WFI();
    print_ok(505);
    for(int i=0;i<16;i=i+1)
        check(temp_data[i],(i | (i + 1)<<8 | (i + 2)<<16 | (i + 3)<<24 ), i+2000);

    print_ok(506);
    for(int i=16;i<25;i=i+1)
        check(USB->EP_FIFOEn[2],(i | (i + 1)<<8 | (i + 2)<<16 | (i + 3)<<24 ), i+2000);

    USB->SIE_OutCSR = 0x8000; //set 16 outcsr enable autoclear and inpktrdy

    ccode_send_label(501);
}
void usb_exti_enable()
{
	// enable EXTI clock;
	RCC->RCC_APB3EN |= 1<<12;

    // EXTI26
    EXTI->EXTI_EMR[4] |= 0x1<<17;
    EXTI->EXTI_FTSR[4] |= 0x1<<17;
}

int suspend_en = 0;

//Main function-USB_NORMAL_RUN
int main (void) {
    print_ok(100);
    RCC_USB_60M_Config();//pll_hf/2
    print_ok(101);

    syscfg_clock_en();
    print_ok(102);
    enable_usb_sram();
    print_ok(103);
    usb_phy_en();
    print_ok(104);
    nop_repeat(1000);

    //gpio cfg
    gpio_clock_enable(GPIOF,ENABLE);
    config_gpio_mode(GPIOF, GPIO4, AF, AF0);
    config_gpio_mode(GPIOF, GPIO5, AF, AF0);

    SYSCFG->SYSCFG_CRG |= SYSCFG_CRG_CID_USBFS_Msk; // device

    NVIC_EnableIRQ(USB_IRQn);

    usb_exti_enable();

    /************ part1: config **************/
    USB->SIE_Testmode = 0x20; //FS
    USB->SIE_Power = 0x40; //softcon
    USB->SIE_IntrInE = 0xffff; //enable all int
    USB->SIE_IntrOutE = 0xffff; //enable all int
    USB->SIE_IntrUSBE = 0xff; //enable int

    //***********************************wait reset done
    print_ok(105);
    __WFI();
    print_ok(106);
    control_in();
    nop_repeat(50);

    ccode_send_label(100);
    // wait suspend wakeup int
    __WFI();

    // config USB PHY to LP
    USB->SIE_Power |= 1;
    ccode_send_label(101);

    nop_repeat(5000);
    ccode_send_label(102);
    suspend_en = 1;
    print_ok(107);
    PMU_enter_deepsleep2(WFI);
    suspend_en = 0;
    print_ok(108);
    ccode_send_label(103);

    control_in();
    nop_repeat(50);

    control_out();
    nop_repeat(50);

    bulk_in();
    nop_repeat(50);

    bulk_out();
}


void USB_IRQHandler(void){
    uint32_t    temp;
    if(suspend_en == 1)
    {
        print_ok(300);
        // re-config PLL for USB
        RCC_USB_60M_Config();//pll_hf/2
        USB->SIE_Power &= ~(0x1);
        // if((USB->SIE_Power & (0x1<<1)) != (0x1<<1))
        // {
        //     print_info(USB->SIE_Power);
        //     print_error(200);
        // } else {
        //     print_info(USB->SIE_Power);
        //     print_ok(200);
        // }
    }

    print_ok(7256);
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


