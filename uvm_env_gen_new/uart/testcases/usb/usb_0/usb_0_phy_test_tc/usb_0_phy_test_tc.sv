// ----------------------------------------------------
// Copyright(C) 2024 Chipsea All rights reserved.
// File Name: usb_phy_test_tc.sv
// Author:    liucf
// Email:     liucf@chipsea.com
// Date:      2024-11-21
// ----------------------------------------------------

`ifndef USB_0_PHY_TEST_TC__SV
`define USB_0_PHY_TEST_TC__SV

// `define USB_TOP          `USB_0_TOP

class usb_0_phy_test_tc extends usb_basetest;

    `uvm_component_utils(usb_0_phy_test_tc)

    extern  function new(string name, uvm_component parent);

    extern  task    tc_proc ();
    extern  task    configure_phase(uvm_phase phase);
endclass : usb_0_phy_test_tc

function usb_0_phy_test_tc::new(string name, uvm_component parent);
    super.new(name, parent);
endfunction

task usb_0_phy_test_tc::configure_phase(uvm_phase phase);
    phase.raise_objection(this);

    this.load_hex_file("../ccode/hex/usb_0_phy_test_tc.hex");

    phase.drop_objection(this);
endtask

task usb_0_phy_test_tc::tc_proc();
    bit [31:0]  syscfg_usb_test;
    bit         cid;
    bit         usb_avalid;
    bit         usb_phy_pd;
    bit         usb_vbuslo;
    bit         usb_vbusvalid;
    bit         usb_phy_en;

    `uvm_info("","usb_0_phy_test_tc start",UVM_NONE)

/**********************************************check 1*****************************************************/
    sv_wait_label(100);

    repeat(3)
    begin
        syscfg_usb_test = $urandom_range(0, 'hffff_ffff);
        cid             = $urandom_range(0, 1);
        usb_avalid      = $urandom_range(0, 1);
        usb_phy_pd      = $urandom_range(0, 1);
        usb_vbuslo      = $urandom_range(0, 1);
        usb_vbusvalid   = $urandom_range(0, 1);
        usb_phy_en      = $urandom_range(0, 1);

        sv_send_data(0, syscfg_usb_test);
        sv_send_data(1, cid);
        sv_send_data(2, usb_avalid);
        sv_send_data(3, usb_phy_pd);
        sv_send_data(4, usb_vbuslo);
        sv_send_data(5, usb_vbusvalid);
        sv_send_data(6, usb_phy_en);
        sv_send_label(101);

        sv_wait_label(102);
        repeat(10)
        begin
            #1us;
        `ifndef POST_SIM_ON
            `SIGNAL_VALUE_CHECKING(`USB_TOP.usb_test_en,            1)
            `SIGNAL_VALUE_CHECKING(`USB_TOP.usb_phy_en,             usb_phy_en)
            `SIGNAL_VALUE_CHECKING(`USB_TOP.u_fs_otg_top.AVALID,    usb_avalid)
            `SIGNAL_VALUE_CHECKING(`USB_TOP.u_fs_otg_top.VBUSLO,    usb_vbuslo)
            `SIGNAL_VALUE_CHECKING(`USB_TOP.u_fs_otg_top.VBUSVALID, usb_vbusvalid)


            `SIGNAL_VALUE_CHECKING(`USB_TOP.u_fs_otg_top.fs_otg_ctrl_inst.CID,  cid)

            // rx_rcv_en ( not used in CSCE2500)
            `SIGNAL_VALUE_CHECKING(`USB_TOP.tm_usb_rx_rcv_en,   syscfg_usb_test[0])

            // tx se0
            `SIGNAL_VALUE_CHECKING(`USB_TOP.tm_usb_tx_se0,      syscfg_usb_test[2])
            `SIGNAL_VALUE_CHECKING(`USB_PHY.TX_DM,              syscfg_usb_test[2])

            // tx
            `SIGNAL_VALUE_CHECKING(`USB_TOP.tm_usb_tx_en_n,     syscfg_usb_test[3])
            `SIGNAL_VALUE_CHECKING(`USB_PHY.TX_ENN_DP,          syscfg_usb_test[3])
            `SIGNAL_VALUE_CHECKING(`USB_PHY.TX_ENN_DM,          syscfg_usb_test[3])

            `SIGNAL_VALUE_CHECKING(`USB_TOP.tm_usb_tx_dat,      syscfg_usb_test[1])
            `SIGNAL_VALUE_CHECKING(`USB_PHY.TX_DP,              syscfg_usb_test[1])

            // USB_PD
            `SIGNAL_VALUE_CHECKING(`USB_TOP.tm_usb_pd,          syscfg_usb_test[5])
            `SIGNAL_VALUE_CHECKING(`USB_PHY.PD,                 syscfg_usb_test[5])

            // usb suspend
            `SIGNAL_VALUE_CHECKING(`USB_TOP.tm_usb_suspend,     syscfg_usb_test[4])
            `SIGNAL_VALUE_CHECKING(`USB_PHY.SUSPEND,            syscfg_usb_test[4])

            // pull-up
            `SIGNAL_VALUE_CHECKING(`USB_TOP.tm_usb_dppu,        syscfg_usb_test[6])
            `SIGNAL_VALUE_CHECKING(`USB_PHY.DPPU,               syscfg_usb_test[6])

            `SIGNAL_VALUE_CHECKING(`USB_TOP.tm_usb_dmpu,        syscfg_usb_test[7])
            `SIGNAL_VALUE_CHECKING(`USB_PHY.DMPU,               syscfg_usb_test[7])

            `SIGNAL_VALUE_CHECKING(`USB_TOP.tm_usb_dppu_lo,     syscfg_usb_test[8])
            `SIGNAL_VALUE_CHECKING(`USB_PHY.DPPU_LO,            syscfg_usb_test[8])

            `SIGNAL_VALUE_CHECKING(`USB_TOP.tm_usb_dmpu_lo,     syscfg_usb_test[9])
            `SIGNAL_VALUE_CHECKING(`USB_PHY.DMPU_LO,            syscfg_usb_test[9])

            `SIGNAL_VALUE_CHECKING(`USB_TOP.tm_usb_dppulldn,    syscfg_usb_test[10])
            `SIGNAL_VALUE_CHECKING(`USB_PHY.DPPULLDN,           syscfg_usb_test[10])

            `SIGNAL_VALUE_CHECKING(`USB_TOP.tm_usb_dmpulldn,    syscfg_usb_test[11])
            `SIGNAL_VALUE_CHECKING(`USB_PHY.DMPULLDN,           syscfg_usb_test[11])
        `endif
        end
    end

    sv_send_label(103);
    sv_wait_label(104);
    `uvm_info("","check after exit USB TEST mode", UVM_LOW)
    repeat(10)
    begin
        #1us;
    `ifndef POST_SIM_ON
        `SIGNAL_VALUE_CHECKING(`USB_TOP.usb_test_en,    0)
        `SIGNAL_VALUE_CHECKING(`USB_TOP.usb_phy_en,     usb_phy_en)

        if(usb_phy_en == 0)
        begin
            `SIGNAL_VALUE_CHECKING(`USB_PHY.PD, 1)
        end else begin
            `SIGNAL_VALUE_CHECKING(`USB_PHY.PD, usb_phy_pd)
        end
    `endif
    end

endtask : tc_proc


`endif // USB_0_PHY_TEST_TC__SV

