// --- used by m --- //
// the define will be added by m during simulation automatically

// tc with plusargs
// tc=hello_world                      %   define=AAA+BB % plusargs=CC=2+DD=1
// tc_index=0 % tc=smoke_tc            %  plusargs=CC=1
// tc_index=1 % tc=smoke_tc            %  plusargs=CC=2

// ------- BASETEST TC -------- //
tc=basetest_1                         %   define=
tc=basetest_2                         %   define=
tc=basetest_3                         %   define=

// flash
// tc=flash_bist_tc                    %   define=FLASH_BIST_ON

//I2C
// tc=../testcases/i2c1/i2c_tx_tc.sv   %   define=PA10+PA12
// ------- I2C_0 TC -------- //
tc=i2c_0_dut_slave_rx_tc         % define=I2C_TEST_ON+I2C_0_ON+I2C0_PA2_PA5
tc=i2c_0_dut_slave_tx_tc         % define=I2C_TEST_ON+I2C_0_ON+I2C0_PA2_PA5
tc=i2c_0_dut_master_tx_tc        % define=I2C_TEST_ON+I2C_0_ON+I2C0_PA4_PA5
tc=i2c_0_dut_master_rx_tc        % define=I2C_TEST_ON+I2C_0_ON+I2C0_PA4_PA5

// ------- I2C_1 TC -------- //
tc=i2c_1_dut_slave_rx_tc         % define=I2C_TEST_ON+I2C_1_ON+I2C1_PA2_PA5
tc=i2c_1_dut_slave_tx_tc         % define=I2C_TEST_ON+I2C_1_ON+I2C1_PA2_PA5
tc=i2c_1_dut_master_tx_tc        % define=I2C_TEST_ON+I2C_1_ON+I2C1_PA4_PA5
tc=i2c_1_dut_master_rx_tc        % define=I2C_TEST_ON+I2C_1_ON+I2C1_PA4_PA5

// ------- I2C_2 TC -------- //
tc=i2c_2_dut_slave_rx_tc         % define=I2C_TEST_ON+I2C_2_ON+I2C2_PA2_PA5
tc=i2c_2_dut_slave_tx_tc         % define=I2C_TEST_ON+I2C_2_ON+I2C2_PA2_PA5
tc=i2c_2_dut_master_tx_tc        % define=I2C_TEST_ON+I2C_2_ON+I2C2_PA4_PA5
tc=i2c_2_dut_master_rx_tc        % define=I2C_TEST_ON+I2C_2_ON+I2C2_PA4_PA5

// ------- I2C_3 TC -------- //
tc=i2c_3_dut_slave_rx_tc         % define=I2C_TEST_ON+I2C_3_ON+I2C3_PA2_PA5
tc=i2c_3_dut_slave_tx_tc         % define=I2C_TEST_ON+I2C_3_ON+I2C3_PA2_PA5
tc=i2c_3_dut_master_tx_tc        % define=I2C_TEST_ON+I2C_3_ON+I2C3_PA4_PA5
tc=i2c_3_dut_master_rx_tc        % define=I2C_TEST_ON+I2C_3_ON+I2C3_PA4_PA5

// ------- I2C_4 TC -------- //
tc=i2c_4_dut_slave_rx_tc         % define=I2C_TEST_ON+I2C_4_ON+I2C4_PA2_PA5
tc=i2c_4_dut_slave_tx_tc         % define=I2C_TEST_ON+I2C_4_ON+I2C4_PA2_PA5
tc=i2c_4_dut_master_tx_tc        % define=I2C_TEST_ON+I2C_4_ON+I2C4_PA4_PA5
tc=i2c_4_dut_master_rx_tc        % define=I2C_TEST_ON+I2C_4_ON+I2C4_PA4_PA5

// ------- USB0 TC -------- //
tc=usb_0_host_tc                     %   define=USB_TEST_ON+USB_VIP_0_AS_HOST+HXT_EN
tc=usb_0_fifo_tc                     %   define=USB_TEST_ON+HXT_EN
tc=usb_0_device_tc                   %   define=USB_TEST_ON+USB_VIP_0_AS_DEVICE+HXT_EN
tc=usb_0_device_suspend_tc           %   define=USB_TEST_ON+USB_VIP_0_AS_DEVICE+HXT_EN
tc=usb_0_device_for_all_endpoint_tc  %   define=USB_TEST_ON+USB_VIP_0_AS_DEVICE+HXT_EN
tc=usb_0_phy_test_tc                 %   define=USB_TEST_ON+HXT_EN
tc=usb_0_sram_test_tc                %   define=USB_TEST_ON+HXT_EN

// ------- USB1 TC -------- //
tc=usb_1_host_tc                     %   define=USB_TEST_ON+USB_VIP_1_AS_HOST+HXT_EN
tc=usb_1_fifo_tc                     %   define=USB_TEST_ON+HXT_EN
tc=usb_1_device_tc                   %   define=USB_TEST_ON+USB_VIP_1_AS_DEVICE+HXT_EN
tc=usb_1_device_suspend_tc           %   define=USB_TEST_ON+USB_VIP_1_AS_DEVICE+HXT_EN
tc=usb_1_device_for_all_endpoint_tc  %   define=USB_TEST_ON+USB_VIP_1_AS_DEVICE+HXT_EN
tc=usb_1_phy_test_tc                 %   define=USB_TEST_ON+HXT_EN
tc=usb_1_sram_test_tc                %   define=USB_TEST_ON+HXT_EN

