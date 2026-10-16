// ----------------------------------------------------
// Copyright(C) 2024 Chipsea All rights reserved.
// File Name: usb_connection.sv
// Author:    liucf
// Email:     liucf@chipsea.com
// Date:      2024-11-21
// ----------------------------------------------------

`ifndef USB_0_CONNECTION__SV
`define USB_0_CONNECTION__SV

`ifdef USB_TEST_ON

// `define USB_TOP     `USB_0_TOP

`ifdef POST_SIM_ON
    `define USB_0_COUNT_CLK   `USB_TOP.u_fs_otg_top_musb2oc_inst_utmi_syn_inst_utmi_ctrl_inst_Count_reg_22_.CK
    `define USB_0_COUNT           {             `USB_TOP.u_fs_otg_top_musb2oc_inst_utmi_syn_inst_utmi_ctrl_inst_Count_reg_22_.Q,             `USB_TOP.u_fs_otg_top_musb2oc_inst_utmi_syn_inst_utmi_ctrl_inst_Count_reg_21_.Q,             `USB_TOP.u_fs_otg_top_musb2oc_inst_utmi_syn_inst_utmi_ctrl_inst_Count_reg_20_.Q,             `USB_TOP.u_fs_otg_top_musb2oc_inst_utmi_syn_inst_utmi_ctrl_inst_Count_reg_19_.Q,             `USB_TOP.u_fs_otg_top_musb2oc_inst_utmi_syn_inst_utmi_ctrl_inst_Count_reg_18_.Q,             `USB_TOP.u_fs_otg_top_musb2oc_inst_utmi_syn_inst_utmi_ctrl_inst_Count_reg_17_.Q,             `USB_TOP.u_fs_otg_top_musb2oc_inst_utmi_syn_inst_utmi_ctrl_inst_Count_reg_16_.Q,             `USB_TOP.u_fs_otg_top_musb2oc_inst_utmi_syn_inst_utmi_ctrl_inst_Count_reg_15_.Q,             `USB_TOP.u_fs_otg_top_musb2oc_inst_utmi_syn_inst_utmi_ctrl_inst_Count_reg_14_.Q,             `USB_TOP.u_fs_otg_top_musb2oc_inst_utmi_syn_inst_utmi_ctrl_inst_Count_reg_13_.Q,             `USB_TOP.u_fs_otg_top_musb2oc_inst_utmi_syn_inst_utmi_ctrl_inst_Count_reg_12_.Q,             `USB_TOP.u_fs_otg_top_musb2oc_inst_utmi_syn_inst_utmi_ctrl_inst_Count_reg_11_.Q,             `USB_TOP.u_fs_otg_top_musb2oc_inst_utmi_syn_inst_utmi_ctrl_inst_Count_reg_10_.Q,             `USB_TOP.u_fs_otg_top_musb2oc_inst_utmi_syn_inst_utmi_ctrl_inst_Count_reg_9_.Q,             `USB_TOP.u_fs_otg_top_musb2oc_inst_utmi_syn_inst_utmi_ctrl_inst_Count_reg_8_.Q,             `USB_TOP.u_fs_otg_top_musb2oc_inst_utmi_syn_inst_utmi_ctrl_inst_Count_reg_7_.Q,             `USB_TOP.u_fs_otg_top_musb2oc_inst_utmi_syn_inst_utmi_ctrl_inst_Count_reg_6_.Q,             `USB_TOP.u_fs_otg_top_musb2oc_inst_utmi_syn_inst_utmi_ctrl_inst_Count_reg_5_.Q,             `USB_TOP.u_fs_otg_top_musb2oc_inst_utmi_syn_inst_utmi_ctrl_inst_Count_reg_4_.Q,             `USB_TOP.u_fs_otg_top_musb2oc_inst_utmi_syn_inst_utmi_ctrl_inst_Count_reg_3_.Q,             `USB_TOP.u_fs_otg_top_musb2oc_inst_utmi_syn_inst_utmi_ctrl_inst_Count_reg_2_.Q,             `USB_TOP.u_fs_otg_top_musb2oc_inst_utmi_syn_inst_utmi_ctrl_inst_Count_reg_1_.Q,             `USB_TOP.u_fs_otg_top_musb2oc_inst_utmi_syn_inst_utmi_ctrl_inst_Count_reg_0_.Q}
`endif

svt_usb_if  mo_usb_host_if_0();
svt_usb_if  mo_usb_dev_if_0();

// The nominal USB 20 480Mb/s clock width is 2083ps
parameter simulation_cycle_for_usb_vip_0 = 2.083;

// declare clock for input to VIP's interface
reg clock_for_usb_vip_0;

// clk generator
initial
begin
    clock_for_usb_vip_0 = 0;

    #(simulation_cycle_for_usb_vip_0); // No clock edge at T=0

    forever
    begin
        clock_for_usb_vip_0 = ~clock_for_usb_vip_0;
        repeat(3)
        begin
            #(simulation_cycle_for_usb_vip_0/8);
            clock_for_usb_vip_0 = ~clock_for_usb_vip_0;
        end

        #((simulation_cycle_for_usb_vip_0/2) - (3*(simulation_cycle_for_usb_vip_0/8)));
        clock_for_usb_vip_0 = ~clock_for_usb_vip_0;

        repeat(3)
        begin
            #(simulation_cycle_for_usb_vip_0/8);
            clock_for_usb_vip_0 = ~clock_for_usb_vip_0;
        end
        #(simulation_cycle_for_usb_vip_0 - (simulation_cycle_for_usb_vip_0/2) - (3*(simulation_cycle_for_usb_vip_0/8)));
    end
end

// USB
assign mo_usb_host_if_0.usb_20_serial_if.clk = clock_for_usb_vip_0;
assign mo_usb_dev_if_0.usb_20_serial_if.clk  = clock_for_usb_vip_0;

// set interface by config_db
initial
begin
    uvm_config_db#(virtual svt_usb_if)::set(uvm_root::get(), "uvm_test_top.mo_env.mo_usb_env[0]", "host_usb_if", mo_usb_host_if_0);
    uvm_config_db#(virtual svt_usb_if)::set(uvm_root::get(), "uvm_test_top.mo_env.mo_usb_env[0]", "dev_usb_if", mo_usb_dev_if_0);
end

initial
begin
`ifndef POST_SIM_ON
    // for acc simulation
    force `USB_TOP.u_fs_otg_top.TM1 = 1;
`endif
end

`ifdef USB_VIP_0_AS_HOST
    tran usb_0_dp_tran(`CHIP_TOP.GPF5,       mo_usb_dev_if_0.usb_20_serial_if.dp);
    tran usb_0_dm_tran(`CHIP_TOP.GPF4,       mo_usb_dev_if_0.usb_20_serial_if.dm);
`endif

`ifdef USB_VIP_0_AS_DEVICE
    tran usb_0_dp_tran(`CHIP_TOP.GPF5,       mo_usb_host_if_0.usb_20_serial_if.dp);
    tran usb_0_dm_tran(`CHIP_TOP.GPF4,       mo_usb_host_if_0.usb_20_serial_if.dm);
`endif

initial begin
    force mo_usb_host_if_0.usb_20_serial_if.data_phase_1  = 0;
    force mo_usb_dev_if_0.usb_20_serial_if.data_phase_1   = 0;
    #30ns;
    release mo_usb_host_if_0.usb_20_serial_if.data_phase_1;
    release mo_usb_dev_if_0.usb_20_serial_if.data_phase_1;
end

assign mo_usb_dev_if_0.usb_20_serial_if.vbus = 1;

`endif // USB_TEST_ON

`endif // USB_0_CONNECTION__SV

