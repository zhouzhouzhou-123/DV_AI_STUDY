//------------------------------------------------------------------------
// FILE NAME      : main.c
// DEPARTMENT     : Digital Verification Department
// AUTHOR         : liucf
// AUTHOR'S EMAIL : liucf@chipsea.com
// DATE           : 2024-05-21 15:00:54
// ABSTACT        :
//
//-------------------------------------------------------------------------

void I2CM_IRQHandler()
{
    check(I2CM->I2CM_SR & 0x1<<1, 0x1<<1, 200);
    I2CM->I2CM_SR_CLR = 0xffffffff;
    check(I2CM->I2CM_SR, 0x0, 201);

    ccode_send_label(666);
    ccode_send_label(777);
    print_ok(222);
    print_info(I2CM->I2CM_BUF);
    print_ok(223);
}

void I2CM_config()
{
    I2CM->I2CM_CFG |= 0x5a<<16 | 120<<0;

    // RX DEPTH = 4
    I2CM->I2CM_SIZE_ADDR |= 0x4<<0;

    I2CM->I2CM_MR |= 0x1<<3 | 0x1<<7 | 0x1<<1;

    // enable RX start;
    I2CM->I2CM_MR |= 0x1<<3;

}

void gpio_config()
{
    config_gpio_mode(GPIO4, AF, AF2);
    config_gpio_mode(GPIO5, AF, AF2);
}

//Main function
int main (void) {

    print_ok(100);

    NVIC_EnableIRQ(I2CM_IRQn);

    gpio_config();

    I2CM_config();
    print_ok(101);

    ccode_send_label(100);

}
