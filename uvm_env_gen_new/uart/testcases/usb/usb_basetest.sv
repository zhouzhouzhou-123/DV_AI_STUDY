// ----------------------------------------------------
// Copyright(C) 2024 Chipsea All rights reserved.
// File Name: usb_basetest.sv
// Author:    liucf
// Email:     liucf@chipsea.com
// Date:      2024-11-21
// ----------------------------------------------------

`ifndef USB_BASETEST__SV
`define USB_BASETEST__SV

class usb_basetest extends basetest;

    usb_shared_cfg  mo_usb_cfg[2];
    usb_shared_cfg  mo_swap_cfg[2];

    `uvm_component_utils(usb_basetest)

    extern          function            new                 (string name, uvm_component parent);
    extern  virtual function    void    build_phase         (uvm_phase phase);
    extern  virtual function    void    modify_usb_cfg_0  ();
    extern  virtual function    void    modify_usb_cfg_1  ();

endclass : usb_basetest

function usb_basetest::new(string name, uvm_component parent);
    super.new(name, parent);
endfunction

function void usb_basetest::modify_usb_cfg_0();
    // this.mo_usb_cfg.setup_usb_20_defaults();
    this.mo_usb_cfg[0].setup_usb_20_defaults(svt_usb_types::FS,svt_usb_types::FS);

    this.mo_usb_cfg[0].host_cfg.enable_debug_ports = 1;
    this.mo_usb_cfg[0].dev_cfg.enable_debug_ports = 1;
    /**
     * Enable XML File generation for  2.0 Host VIP
     *  2.0 'prot' options are 0=no xml, 1=transfers, 2=transfers & transactions
     *  2.0 'link' options are 0=no xml, 1=packets, 2=packets and link commands
     *  'phys' options have no relevance to 2.0 operation
     */
    this.mo_usb_cfg[0].host_cfg.enable_prot_xml_gen = 0;
    this.mo_usb_cfg[0].host_cfg.enable_link_xml_gen = 0;
    this.mo_usb_cfg[0].host_cfg.enable_payload_xml_gen = 0;
    this.mo_usb_cfg[0].host_cfg.enable_phys_xml_gen = 0;

    /**
     * Enable XML File generation for  2.0 Device VIP
     *  2.0 'prot' options are 0=no xml, 1=transfers, 2=transfers & transactions
     *  2.0 'link' options are 0=no xml, 1=packets, 2=packets and link commands
     *  'phys' options have no relevance to 2.0 operation
     */
    this.mo_usb_cfg[0].dev_cfg.enable_prot_xml_gen = 0;
    this.mo_usb_cfg[0].dev_cfg.enable_link_xml_gen = 0;
    this.mo_usb_cfg[0].dev_cfg.enable_payload_xml_gen = 0;
    this.mo_usb_cfg[0].dev_cfg.enable_phys_xml_gen = 0;

    /**
     * For shorter simulation time, set VIPs timers to Scale Down values. Otherwise,
     * VIPs timers contain values as defined in USB specification.Refer to VIP class
     * reference to know scale down values of VIP timers.
     * Note: Scale down timer values apply to both  transmission and reception (min/max checking) by VIP.
     */
    void'(this.mo_usb_cfg[0].host_cfg.set_timer_values(svt_usb_configuration::USB_VIP_SCALEDOWN_TIMER_VALUES));
    void'(this.mo_usb_cfg[0].dev_cfg.set_timer_values(svt_usb_configuration::USB_VIP_SCALEDOWN_TIMER_VALUES));
    /**
     *  For illustration purpose only,  delay Device VIP’s attachment (enabling of FS terminations and D+ pull-up)
     *  The timeunit of the delay count would be the same as the timeunit of the timescale used in testbench.
     */
    this.mo_usb_cfg[0].dev_cfg.poweron_auto_attach_delay = 8.5ms;

    /**
        * Enable FSDB File generation for  Host VIP
        *  'prot' options are 0=no fsdb, 1=transfers, 2=transfers & transactions
        *  'link' options are 0=no fsdb, 1=packets, 2=packets and link commands,
        *            3=packets, link commands and symbol sets, 4=packets, link commands, symbol sets and LTSSM states
        *  'phys' options are 0=no fsdb, 1= LFPS signaling
    */
    this.mo_usb_cfg[0].host_cfg.enable_prot_pa_gen = 0;
    this.mo_usb_cfg[0].host_cfg.enable_link_pa_gen = 0;
    this.mo_usb_cfg[0].host_cfg.enable_phys_pa_gen = 0;

    /**
        * Enable FSDB File generation for  Device VIP
        *  'prot' options are 0=no fsdb, 1=transfers, 2=transfers & transactions
        *  'link' options are 0=no fsdb, 1=packets, 2=packets and link commands,
        *            3=packets, link commands and symbol sets, 4=packets, link commands, symbol sets and LTSSM states
        *  'phys' options are 0=no fsdb, 1= LFPS signaling
    */
    this.mo_usb_cfg[0].dev_cfg.enable_prot_pa_gen = 0;
    this.mo_usb_cfg[0].dev_cfg.enable_link_pa_gen = 0;
    this.mo_usb_cfg[0].dev_cfg.enable_phys_pa_gen = 0;

    // Enable most of the Link tracking choices
    this.mo_usb_cfg[0].host_cfg.enable_link_chk        = 0;
    this.mo_usb_cfg[0].host_cfg.enable_link_reporting  = 0;
    this.mo_usb_cfg[0].host_cfg.enable_link_tracing    = 0;
    this.mo_usb_cfg[0].dev_cfg.enable_link_chk         = 0;
    this.mo_usb_cfg[0].dev_cfg.enable_link_reporting   = 0;
    this.mo_usb_cfg[0].dev_cfg.enable_link_tracing     = 0;
    this.mo_usb_cfg[0].host_cfg.enable_prot_chk        = 0;
    this.mo_usb_cfg[0].dev_cfg.enable_prot_chk         = 0;
    this.mo_usb_cfg[0].host_cfg.enable_prot_tracing    = 0;
    this.mo_usb_cfg[0].dev_cfg.enable_prot_tracing     = 0;
endfunction : modify_usb_cfg_0

function void usb_basetest::modify_usb_cfg_1();
    // this.mo_usb_cfg.setup_usb_20_defaults();
    this.mo_usb_cfg[1].setup_usb_20_defaults(svt_usb_types::FS,svt_usb_types::FS);

    this.mo_usb_cfg[1].host_cfg.enable_debug_ports = 1;
    this.mo_usb_cfg[1].dev_cfg.enable_debug_ports = 1;
    /**
     * Enable XML File generation for  2.0 Host VIP
     *  2.0 'prot' options are 0=no xml, 1=transfers, 2=transfers & transactions
     *  2.0 'link' options are 0=no xml, 1=packets, 2=packets and link commands
     *  'phys' options have no relevance to 2.0 operation
     */
    this.mo_usb_cfg[1].host_cfg.enable_prot_xml_gen = 0;
    this.mo_usb_cfg[1].host_cfg.enable_link_xml_gen = 0;
    this.mo_usb_cfg[1].host_cfg.enable_payload_xml_gen = 0;
    this.mo_usb_cfg[1].host_cfg.enable_phys_xml_gen = 0;

    /**
     * Enable XML File generation for  2.0 Device VIP
     *  2.0 'prot' options are 0=no xml, 1=transfers, 2=transfers & transactions
     *  2.0 'link' options are 0=no xml, 1=packets, 2=packets and link commands
     *  'phys' options have no relevance to 2.0 operation
     */
    this.mo_usb_cfg[1].dev_cfg.enable_prot_xml_gen = 0;
    this.mo_usb_cfg[1].dev_cfg.enable_link_xml_gen = 0;
    this.mo_usb_cfg[1].dev_cfg.enable_payload_xml_gen = 0;
    this.mo_usb_cfg[1].dev_cfg.enable_phys_xml_gen = 0;

    /**
     * For shorter simulation time, set VIPs timers to Scale Down values. Otherwise,
     * VIPs timers contain values as defined in USB specification.Refer to VIP class
     * reference to know scale down values of VIP timers.
     * Note: Scale down timer values apply to both  transmission and reception (min/max checking) by VIP.
     */
    void'(this.mo_usb_cfg[1].host_cfg.set_timer_values(svt_usb_configuration::USB_VIP_SCALEDOWN_TIMER_VALUES));
    void'(this.mo_usb_cfg[1].dev_cfg.set_timer_values(svt_usb_configuration::USB_VIP_SCALEDOWN_TIMER_VALUES));
    /**
     *  For illustration purpose only,  delay Device VIP’s attachment (enabling of FS terminations and D+ pull-up)
     *  The timeunit of the delay count would be the same as the timeunit of the timescale used in testbench.
     */
    this.mo_usb_cfg[1].dev_cfg.poweron_auto_attach_delay = 8.5ms;

    /**
        * Enable FSDB File generation for  Host VIP
        *  'prot' options are 0=no fsdb, 1=transfers, 2=transfers & transactions
        *  'link' options are 0=no fsdb, 1=packets, 2=packets and link commands,
        *            3=packets, link commands and symbol sets, 4=packets, link commands, symbol sets and LTSSM states
        *  'phys' options are 0=no fsdb, 1= LFPS signaling
    */
    this.mo_usb_cfg[1].host_cfg.enable_prot_pa_gen = 0;
    this.mo_usb_cfg[1].host_cfg.enable_link_pa_gen = 0;
    this.mo_usb_cfg[1].host_cfg.enable_phys_pa_gen = 0;

    /**
        * Enable FSDB File generation for  Device VIP
        *  'prot' options are 0=no fsdb, 1=transfers, 2=transfers & transactions
        *  'link' options are 0=no fsdb, 1=packets, 2=packets and link commands,
        *            3=packets, link commands and symbol sets, 4=packets, link commands, symbol sets and LTSSM states
        *  'phys' options are 0=no fsdb, 1= LFPS signaling
    */
    this.mo_usb_cfg[1].dev_cfg.enable_prot_pa_gen = 0;
    this.mo_usb_cfg[1].dev_cfg.enable_link_pa_gen = 0;
    this.mo_usb_cfg[1].dev_cfg.enable_phys_pa_gen = 0;

    // Enable most of the Link tracking choices
    this.mo_usb_cfg[1].host_cfg.enable_link_chk        = 0;
    this.mo_usb_cfg[1].host_cfg.enable_link_reporting  = 0;
    this.mo_usb_cfg[1].host_cfg.enable_link_tracing    = 0;
    this.mo_usb_cfg[1].dev_cfg.enable_link_chk         = 0;
    this.mo_usb_cfg[1].dev_cfg.enable_link_reporting   = 0;
    this.mo_usb_cfg[1].dev_cfg.enable_link_tracing     = 0;
    this.mo_usb_cfg[1].host_cfg.enable_prot_chk        = 0;
    this.mo_usb_cfg[1].dev_cfg.enable_prot_chk         = 0;
    this.mo_usb_cfg[1].host_cfg.enable_prot_tracing    = 0;
    this.mo_usb_cfg[1].dev_cfg.enable_prot_tracing     = 0;
endfunction : modify_usb_cfg_1


function void usb_basetest::build_phase(uvm_phase phase);
    super.build_phase(phase);

    // ------------------ USB CFG-0 ------------------ //
    this.mo_usb_cfg[0] = usb_shared_cfg::type_id::create("mo_usb_cfg[0]", this);
    this.mo_swap_cfg[0] = usb_shared_cfg::type_id::create("mo_swap_cfg[0]", this);
    this.modify_usb_cfg_0();
    `uvm_info("", $sformatf("cfg passed is_valid() check. Contents:\n%0s", this.mo_usb_cfg[0].sprint()), UVM_LOW)
    uvm_config_db#(usb_shared_cfg)::set(this, "mo_env.mo_usb_env[0]", "usb_cfg", this.mo_usb_cfg[0]);
    uvm_config_db#(usb_shared_cfg)::set(this, "mo_env.mo_usb_env[0]", "swap_cfg", this.mo_swap_cfg[0]);

    // ------------------ USB CFG-1 ------------------ //
    this.mo_usb_cfg[1] = usb_shared_cfg::type_id::create("mo_usb_cfg[1]", this);
    this.mo_swap_cfg[1] = usb_shared_cfg::type_id::create("mo_swap_cfg[1]", this);
    this.modify_usb_cfg_1();
    `uvm_info("", $sformatf("cfg passed is_valid() check. Contents:\n%0s", this.mo_usb_cfg[1].sprint()), UVM_LOW)
    uvm_config_db#(usb_shared_cfg)::set(this, "mo_env.mo_usb_env[1]", "usb_cfg", this.mo_usb_cfg[1]);
    uvm_config_db#(usb_shared_cfg)::set(this, "mo_env.mo_usb_env[1]", "swap_cfg", this.mo_swap_cfg[1]);


endfunction : build_phase

`endif // USB_BASETEST__SV

