//------------------------------------------------------------------------
// FILE NAME      : main.c
// DEPARTMENT     : Digital Verification Department
// AUTHOR         : liucf
// AUTHOR'S EMAIL : liucf@chipsea.com
// DATE           : 2024-05-21 15:00:54
// ABSTACT        :
//
//-------------------------------------------------------------------------
// ----------------------------------------------------
// Copyright(C) 2024 Chipsea All rights reserved.
// File Name: main.c
// Author:    liucf
// Email:     liucf@chipsea.com
// Date:      2024-12-04
// ----------------------------------------------------

void I2CS_IRQHandler()
{
    check(I2CS->I2CS_SR & 0x1<<3, 0x1<<3, 200);
    I2CS->I2CS_SRCLR = 0xffffffff;
    check(I2CS->I2CS_SR, 0x0, 201);

    check(I2CS->I2CS_DATA, 0x5d5c5b5a, 202);

    ccode_send_label(666);
    ccode_send_label(777);
    print_ok(222);
}

void i2cs_config()
{
    I2CS->I2CS_DAR = 0x19;
    // RX buff3 int en
    I2CS->I2CS_IEN |= 0x1<<3;
}

void gpio_config()
{
    config_gpio_mode(GPIO2, AF, AF1);
    config_gpio_mode(GPIO5, AF, AF1);
}

//Main function
int main (void) {

    print_ok(100);

    NVIC_EnableIRQ(I2CS_IRQn);
    NVIC_EnableIRQ(I2CM_IRQn);

    gpio_config();

    i2cs_config();

    ccode_send_label(100);

}
