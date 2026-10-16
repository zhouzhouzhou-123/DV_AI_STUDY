// ----------------------------------------------------
// Copyright(C) 2024 Chipsea All rights reserved.
// File Name: usb_sram_test_tc.sv
// Author:    liucf
// Email:     liucf@chipsea.com
// Date:      2024-11-21
// ----------------------------------------------------

`ifndef USB_0_SRAM_TEST_TC__SV
`define USB_0_SRAM_TEST_TC__SV

// `define USB_TOP          `USB_0_TOP

class usb_0_sram_test_tc extends usb_basetest;

    `uvm_component_utils(usb_0_sram_test_tc)

    extern  function new(string name, uvm_component parent);

    extern  task    tc_proc ();
    extern  task    configure_phase(uvm_phase phase);
endclass : usb_0_sram_test_tc

function usb_0_sram_test_tc::new(string name, uvm_component parent);
    super.new(name, parent);
endfunction

task usb_0_sram_test_tc::configure_phase(uvm_phase phase);
    phase.raise_objection(this);

    this.load_hex_file("../ccode/hex/usb_0_sram_test_tc.hex");

    phase.drop_objection(this);
endtask

task usb_0_sram_test_tc::tc_proc();
    bit [31:0]  sram_test;
    bit [1:0]   sram_low_power_mode;
    bit [7:0]   expected_usb_dout;

    `uvm_info("","usb_0_sram_test_tc start",UVM_NONE)

/**********************************************check 1*****************************************************/
    sv_wait_label(100);

    repeat(3)
    begin
        sram_test = $urandom_range(0, 'hffff_ffff);
        sram_low_power_mode = $urandom_range(0, 'b11);

        sv_send_data(0, sram_test);
        sv_send_data(1, sram_low_power_mode);
        sv_send_label(101);

        sv_wait_label(102);
        case(sram_low_power_mode)
            2'b00   :   expected_usb_dout[2:0]  = 'b000;
            2'b01   :   expected_usb_dout[2:0]  = 'b100;
            2'b10   :   expected_usb_dout[2:0]  = 'b010;
            2'b11   :   expected_usb_dout[2:0]  = 'b001;
        endcase
        // sram_test1
        expected_usb_dout[6] = sram_test[30];
        // sram_rme
        expected_usb_dout[5] = sram_test[29];
        // sram_rm
        expected_usb_dout[4:3] = sram_test[27:24];
        repeat(10)
        begin
            #1us;
        `ifndef POST_SIM_ON
            `SIGNAL_VALUE_CHECKING(`USB_TOP.usb_sram_dbg_en,        1)
            `SIGNAL_VALUE_CHECKING(`USB_TOP.u_usb_sram_wrap.RME,    sram_test[29])
            `SIGNAL_VALUE_CHECKING(`USB_TOP.u_usb_sram_wrap.RM,     sram_test[27:24])
            `SIGNAL_VALUE_CHECKING(`USB_TOP.u_usb_sram_wrap.TEST1,  sram_test[30])

            `SIGNAL_VALUE_CHECKING(`USB_TOP.usb2mdbg_dout,          expected_usb_dout)
            `SIGNAL_VALUE_CHECKING(top.PL[4:0],                     expected_usb_dout[4:0])
            `SIGNAL_VALUE_CHECKING(top.PK[2:0],                     expected_usb_dout[7:5])
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
        `SIGNAL_VALUE_CHECKING(`USB_TOP.usb_sram_dbg_en,        0)
        // `SIGNAL_VALUE_CHECKING(`USB_TOP.u_usb_sram_wrap.RME,    0)
        // `SIGNAL_VALUE_CHECKING(`USB_TOP.u_usb_sram_wrap.RM,     0)
        // `SIGNAL_VALUE_CHECKING(`USB_TOP.u_usb_sram_wrap.TEST1,  0)
    `endif
    end

endtask : tc_proc

`endif // USB_0_SRAM_TEST_TC__SV

