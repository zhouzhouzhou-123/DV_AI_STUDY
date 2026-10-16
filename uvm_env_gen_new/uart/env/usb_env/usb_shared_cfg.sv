// ----------------------------------------------------
// Copyright(C) 2024 Chipsea All rights reserved.
// File Name: usb_shared_cfg.sv
// Author:    liucf
// Email:     liucf@chipsea.com
// Date:      2024-11-21
// ----------------------------------------------------


`ifndef USB_SHARED_CFG__SV
`define USB_SHARED_CFG__SV

`ifndef USB_SHARED_CFG_TIMEOUT
    `define USB_SHARED_CFG_TIMEOUT  10ms
`endif

// =============================================================================
/**
 * This class extension defines a custom system configuration data object
 * up through the USB Protocol layer. It is used to encapsulate 2 USB configuration
 * objects. It is also used to encapsulate configuration information that is
 * specific to this environment. An object of this type will be created by
 * the UVM verification environment used by that testcase. The UVM
 * verification environment will then extract the sub-objects that represent the
 * USB system configurations for the 2 separate USB interfaces, and pass them
 * to the correct components.
 *
 */
`ifdef USB_TEST_ON
class usb_shared_cfg extends uvm_object;

    /** timeout Holds the simulation timeout . */
    real timeout = `USB_SHARED_CFG_TIMEOUT;

    // Configuration object used by the HOST Driver objects.
    svt_usb_agent_configuration host_cfg;

    // Configuration object used by the Device Driver objects.
    svt_usb_agent_configuration dev_cfg;

    /**
        * Variable used by setup_usb_20_defaults method and
        * setup_usb_20_otg_defaults method to configure the
        * number of endpoints.
    */
    int max_usb_20_endpoints = 7;

    /**
        * Variable used by setup_usb_ss_defaults method
        * to configure the number of endpoints.
    */
    int max_usb_ss_endpoints = 7;

    // A parameter to enable/disable host monitor.
    bit enable_host_mon = 1;

    // A parameter to enable/disable dev monitor.
    bit enable_dev_mon = 1;

    `uvm_object_utils_begin(usb_shared_cfg)
        `uvm_field_object      (host_cfg,      UVM_ALL_ON|UVM_DEEP)
        `uvm_field_object      (dev_cfg,       UVM_ALL_ON|UVM_DEEP)
        `uvm_field_real        (timeout,       UVM_ALL_ON)
        `uvm_field_int         (max_usb_20_endpoints,     UVM_ALL_ON)
        `uvm_field_int         (max_usb_ss_endpoints,     UVM_ALL_ON)
        `uvm_field_int         (enable_host_mon,          UVM_ALL_ON)
        `uvm_field_int         (enable_dev_mon,           UVM_ALL_ON)
    `uvm_object_utils_end

    extern  function            new                         (string name = "usb_shared_cfg_inst");
    extern  function    void    setup_usb_ssp_defaults      ();
    extern  function    void    setup_usb_ss_defaults       ();
    extern  function    void    setup_usb_ss_otg_defaults   ();

    extern  function    void    setup_usb_20_otg_defaults   (svt_usb_types::speed_enum host_speed = svt_usb_types::FS,
                                                                svt_usb_types::speed_enum dev_speed = svt_usb_types::FS);
    extern  function    void    setup_usb_20_defaults       (svt_usb_types::speed_enum host_speed = svt_usb_types::HS,
                                                                svt_usb_types::speed_enum dev_speed = svt_usb_types::HS);

    extern  function    string  get_class_name              ();
    extern  function    bit     is_valid                    (bit silent = 1, int kind = -1);

endclass

function usb_shared_cfg::new(string name = "usb_shared_cfg_inst");
    super.new(name);

    // Create new instance of HOST and DEVICE configuration objects.
    host_cfg                                            = new();
    dev_cfg                                             = new();

    host_cfg.component_type                             = svt_usb_types::HOST;
    dev_cfg.component_type                              = svt_usb_types::DEVICE;

    // Enforce making the top level in the stack the PROTOCOL layer
    host_cfg.top_layer                                  = svt_usb_agent_configuration::PROTOCOL;
    dev_cfg.top_layer                                   = svt_usb_agent_configuration::PROTOCOL;

    /**
        * Host VIP configured to have USB host function
        * Host VIP won't have device function
    */
    host_cfg.local_host_cfg                             = new();
    host_cfg.local_device_cfg_size                      = 0;

    /**
        * Device VIP configured to have one USB device function
        * Device VIP won't have host function
    */
    dev_cfg.local_device_cfg_size                       = 1;
    dev_cfg.local_device_cfg[0]                         = new();
    dev_cfg.local_host_cfg                              = null;

    /**
        * Host VIP's configuration must include the configuration of the
        * targeted Device that would be communicating with Host VIP
        * over standard USB interface.
        * Host VIP uses the targeted Device's configuration information such as
        * endpoint information (how many and their types etc), capability so
        * that the transactions/packets issued to Device are consistent with
        * device's configuration and capability.
        * Since Device is a VIP in these examples, assign the pointer of the
        * Device VIP config's local device configuration to the Host VIP's
        * remote device configuration. So, from now onwards, any changes
        * made to the Device VIP's local_device_cfg will also be reflected
        * in the Host VIP's remote_device_cfg and vice versa.
       */
    host_cfg.remote_device_cfg_size                     = dev_cfg.local_device_cfg_size;
    host_cfg.remote_device_cfg                          = dev_cfg.local_device_cfg;
    host_cfg.remote_host_cfg                            = dev_cfg.local_host_cfg;

    /**
        * Similarly, Device VIP configuration must include the configuration of
        * the Host that it is communicating with.
        * Since Host is a VIP in these examples, assign the pointer of the
        * Host VIP config's local host configuration to the Device VIP's
        * remote host configuration. So, from now onwards, any changes
        * made to the Host VIP's local_host_cfg will also be reflected
        * in the Device VIP's remote_host_cfg and vice versa.
    */
    dev_cfg.remote_host_cfg                             = host_cfg.local_host_cfg;
    dev_cfg.remote_device_cfg_size                      = host_cfg.local_device_cfg_size;

endfunction : new

function void usb_shared_cfg::setup_usb_ssp_defaults();
    host_cfg.capability                                            = svt_usb_configuration::PLAIN;
    dev_cfg.capability                                             = svt_usb_configuration::PLAIN;
    host_cfg.speed                                                 = svt_usb_types::ESSG2;
    dev_cfg.speed                                                  = svt_usb_types::ESSG2;

    host_cfg.usb_ss_signal_interface                               = svt_usb_configuration::USB_SS_SERIAL_IF;
    dev_cfg.usb_ss_signal_interface                                = svt_usb_configuration::USB_SS_SERIAL_IF;

    dev_cfg.local_device_cfg[0].device_address                     = 0;
    dev_cfg.local_device_cfg[0].connected_bus_speed                = svt_usb_types::ESSG2;
    dev_cfg.local_device_cfg[0].connected_hub_device_address       = 0;
    dev_cfg.local_device_cfg[0].functionality_support              = svt_usb_types::SS;
    dev_cfg.local_device_cfg[0].num_endpoints                      = max_usb_ss_endpoints;
    host_cfg.usb_capability                                        = svt_usb_configuration::USB_SS_ONLY;
    dev_cfg.usb_capability                                         = svt_usb_configuration::USB_SS_ONLY;
    host_cfg.usb_ss_initial_ltssm_state                            = svt_usb_types::U0;
    dev_cfg.usb_ss_initial_ltssm_state                             = svt_usb_types::U0;
    host_cfg.usb_20_signal_interface                               = svt_usb_configuration::NO_20_IF;
    dev_cfg.usb_20_signal_interface                                = svt_usb_configuration::NO_20_IF;
    host_cfg.usb_ss_rx_buffer_mode                                 = svt_usb_configuration::NOMINAL_EMPTY;
    dev_cfg.usb_ss_rx_buffer_mode                                  = svt_usb_configuration::NOMINAL_EMPTY;
    host_cfg.usb_ss_rx_buffer_latency                              = 0;
    dev_cfg.usb_ss_rx_buffer_latency                               = 0;
    host_cfg.usb_ess_speed_max = svt_usb_types::ESSG2;
    dev_cfg.usb_ess_speed_max = svt_usb_types::ESSG2;

    if (max_usb_ss_endpoints <= 0)begin
      `uvm_fatal("setup_usb_ssp_defaults", $sformatf("The max_usb_ss_endpoints property is set to %0d. This property must be set to a value >=1. Unable to continue",
                 max_usb_ss_endpoints))
    end

    for (int ep_num = 0; ep_num < max_usb_ss_endpoints; ep_num++) begin
      dev_cfg.local_device_cfg[0].endpoint_cfg[ep_num] = new();
    end

    if (max_usb_ss_endpoints >= 1) begin
      /**
       * Configuring End point '0' to CONTROL
       * NOTE: 'direction' is irrelevant for a CONTROL endpoint. Though
       * direction is chosen as 'IN' here, this endpoint will support both
       * IN and OUT transfers
       */
      dev_cfg.local_device_cfg[0].endpoint_cfg[0].ep_number          = 0;
      dev_cfg.local_device_cfg[0].endpoint_cfg[0].direction          = svt_usb_types::IN;
      dev_cfg.local_device_cfg[0].endpoint_cfg[0].ep_type            = svt_usb_types::CONTROL;
      dev_cfg.local_device_cfg[0].endpoint_cfg[0].max_burst_size     = 0;
      dev_cfg.local_device_cfg[0].endpoint_cfg[0].max_packet_size    = `SVT_USB_SS_CONTROL_MAX_PACKET_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[0].supports_ustreams  = 1'b0;
    end

    if (max_usb_ss_endpoints >= 2) begin
      /**
       * Configuring End point '1' to BULK IN
       */
      dev_cfg.local_device_cfg[0].endpoint_cfg[1].ep_number          = 1;
      dev_cfg.local_device_cfg[0].endpoint_cfg[1].direction          = svt_usb_types::IN;
      dev_cfg.local_device_cfg[0].endpoint_cfg[1].ep_type            = svt_usb_types::BULK;
      dev_cfg.local_device_cfg[0].endpoint_cfg[1].allow_aligned_transfer_without_zero_length = 0;
      dev_cfg.local_device_cfg[0].endpoint_cfg[1].max_burst_size     = `SVT_USB_MAX_BURST_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[1].max_packet_size    = `SVT_USB_SS_MAX_PACKET_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[1].supports_ustreams  = 1'b0;
    end

    if (max_usb_ss_endpoints >= 3) begin
      /**
       * Configuring End point '2' to BULK OUT
       */
      dev_cfg.local_device_cfg[0].endpoint_cfg[2].ep_number          = 1;
      dev_cfg.local_device_cfg[0].endpoint_cfg[2].direction          = svt_usb_types::OUT;
      dev_cfg.local_device_cfg[0].endpoint_cfg[2].ep_type            = svt_usb_types::BULK;
      dev_cfg.local_device_cfg[0].endpoint_cfg[2].allow_aligned_transfer_without_zero_length = 0;
      dev_cfg.local_device_cfg[0].endpoint_cfg[2].max_burst_size     = `SVT_USB_MAX_BURST_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[2].max_packet_size    = `SVT_USB_SS_MAX_PACKET_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[2].supports_ustreams  = 1'b0;
    end

    if (max_usb_ss_endpoints >= 4) begin
      /**
       * Configuring End point '3' to ISOC IN
       */
      dev_cfg.local_device_cfg[0].endpoint_cfg[3].ep_number          = 2;
      dev_cfg.local_device_cfg[0].endpoint_cfg[3].direction          = svt_usb_types::IN;
      dev_cfg.local_device_cfg[0].endpoint_cfg[3].ep_type            = svt_usb_types::ISOCHRONOUS;
      dev_cfg.local_device_cfg[0].endpoint_cfg[3].allow_aligned_transfer_without_zero_length = 0;
      dev_cfg.local_device_cfg[0].endpoint_cfg[3].interval           = 1;
      dev_cfg.local_device_cfg[0].endpoint_cfg[3].max_burst_size     = `SVT_USB_MAX_BURST_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[3].max_packet_size    = `SVT_USB_SS_MAX_PACKET_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[3].supports_ustreams  = 1'b0;
    end

    if (max_usb_ss_endpoints >= 5) begin
      /**
       * Configuring End point '4' to ISOC OUT
       */
      dev_cfg.local_device_cfg[0].endpoint_cfg[4].ep_number          = 2;
      dev_cfg.local_device_cfg[0].endpoint_cfg[4].direction          = svt_usb_types::OUT;
      dev_cfg.local_device_cfg[0].endpoint_cfg[4].ep_type            = svt_usb_types::ISOCHRONOUS;
      dev_cfg.local_device_cfg[0].endpoint_cfg[4].allow_aligned_transfer_without_zero_length = 0;
      dev_cfg.local_device_cfg[0].endpoint_cfg[4].interval           = 1;
      dev_cfg.local_device_cfg[0].endpoint_cfg[4].max_burst_size     = `SVT_USB_MAX_BURST_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[4].max_packet_size    = `SVT_USB_SS_MAX_PACKET_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[4].supports_ustreams  = 1'b0;
    end

    if (max_usb_ss_endpoints >= 6) begin
      /**
       * Configuring End point '5' to INTR IN
       */
      dev_cfg.local_device_cfg[0].endpoint_cfg[5].ep_number          = 3;
      dev_cfg.local_device_cfg[0].endpoint_cfg[5].direction          = svt_usb_types::IN;
      dev_cfg.local_device_cfg[0].endpoint_cfg[5].ep_type            = svt_usb_types::INTERRUPT;
      dev_cfg.local_device_cfg[0].endpoint_cfg[5].allow_aligned_transfer_without_zero_length = 0;
      dev_cfg.local_device_cfg[0].endpoint_cfg[5].interval           = 1;
      dev_cfg.local_device_cfg[0].endpoint_cfg[5].max_burst_size     = `SVT_USB_INTERRUPT_EP_MAX_BURST_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[5].max_packet_size    = `SVT_USB_SS_MAX_PACKET_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[5].supports_ustreams  = 1'b0;
    end

    if (max_usb_ss_endpoints >= 7) begin
      /**
       * Configuring End point '6' to INTR OUT
       */
      dev_cfg.local_device_cfg[0].endpoint_cfg[6].ep_number          = 3;
      dev_cfg.local_device_cfg[0].endpoint_cfg[6].direction          = svt_usb_types::OUT;
      dev_cfg.local_device_cfg[0].endpoint_cfg[6].ep_type            = svt_usb_types::INTERRUPT;
      dev_cfg.local_device_cfg[0].endpoint_cfg[6].allow_aligned_transfer_without_zero_length = 0;
      dev_cfg.local_device_cfg[0].endpoint_cfg[6].interval           = 1;
      dev_cfg.local_device_cfg[0].endpoint_cfg[6].max_burst_size     = `SVT_USB_INTERRUPT_EP_MAX_BURST_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[6].max_packet_size    = `SVT_USB_SS_MAX_PACKET_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[6].supports_ustreams  = 1'b0;
    end

    if (max_usb_ss_endpoints >= 8)
    begin
      `uvm_warning("setup_usb_ssp_defaults",
            $sformatf("The max_usb_ss_endpoints property is set to %0d. Configured 7 endpoints . Other endpoints must be configured in the testcase.",
                 max_usb_ss_endpoints));
    end
endfunction

function void usb_shared_cfg::setup_usb_ss_defaults();
    host_cfg.capability                                            = svt_usb_configuration::PLAIN;
    dev_cfg.capability                                             = svt_usb_configuration::PLAIN;
    host_cfg.speed                                                 = svt_usb_types::SS;
    dev_cfg.speed                                                  = svt_usb_types::SS;

    host_cfg.usb_ss_signal_interface                               = svt_usb_configuration::USB_SS_SERIAL_IF;
    dev_cfg.usb_ss_signal_interface                                = svt_usb_configuration::USB_SS_SERIAL_IF;

    dev_cfg.local_device_cfg[0].device_address                     = 0;
    dev_cfg.local_device_cfg[0].connected_bus_speed                = svt_usb_types::SS;
    dev_cfg.local_device_cfg[0].connected_hub_device_address       = 0;
    dev_cfg.local_device_cfg[0].functionality_support              = svt_usb_types::SS;
    dev_cfg.local_device_cfg[0].num_endpoints                      = max_usb_ss_endpoints;
    host_cfg.usb_capability                                        = svt_usb_configuration::USB_SS_ONLY;
    dev_cfg.usb_capability                                         = svt_usb_configuration::USB_SS_ONLY;
    host_cfg.usb_ss_initial_ltssm_state                            = svt_usb_types::RX_DETECT;
    dev_cfg.usb_ss_initial_ltssm_state                             = svt_usb_types::RX_DETECT;
    host_cfg.usb_20_signal_interface                               = svt_usb_configuration::NO_20_IF;
    dev_cfg.usb_20_signal_interface                                = svt_usb_configuration::NO_20_IF;
    host_cfg.usb_ss_rx_buffer_mode                                 = svt_usb_configuration::NOMINAL_EMPTY;
    dev_cfg.usb_ss_rx_buffer_mode                                  = svt_usb_configuration::NOMINAL_EMPTY;
    host_cfg.usb_ss_rx_buffer_latency                              = 0;
    dev_cfg.usb_ss_rx_buffer_latency                               = 0;

    if (max_usb_ss_endpoints <= 0) begin
      `uvm_fatal("setup_usb_ss_defaults", $sformatf("The max_usb_ss_endpoints property is set to %0d. This property must be set to a value >=1. Unable to continue",
                 max_usb_ss_endpoints))
    end

    for (int ep_num = 0; ep_num < max_usb_ss_endpoints; ep_num++) begin
      dev_cfg.local_device_cfg[0].endpoint_cfg[ep_num] = new();
    end

    if (max_usb_ss_endpoints >= 1) begin
      /**
       * Configuring End point '0' to CONTROL
       * NOTE: 'direction' is irrelevant for a CONTROL endpoint. Though
       * direction is chosen as 'IN' here, this endpoint will support both
       * IN and OUT transfers
       */
      dev_cfg.local_device_cfg[0].endpoint_cfg[0].ep_number          = 0;
      dev_cfg.local_device_cfg[0].endpoint_cfg[0].direction          = svt_usb_types::IN;
      dev_cfg.local_device_cfg[0].endpoint_cfg[0].ep_type            = svt_usb_types::CONTROL;
      dev_cfg.local_device_cfg[0].endpoint_cfg[0].max_burst_size     = 0;
      dev_cfg.local_device_cfg[0].endpoint_cfg[0].max_packet_size    = `SVT_USB_SS_CONTROL_MAX_PACKET_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[0].supports_ustreams  = 1'b0;
    end

    if (max_usb_ss_endpoints >= 2) begin
      /**
       * Configuring End point '1' to BULK IN
       */
      dev_cfg.local_device_cfg[0].endpoint_cfg[1].ep_number          = 1;
      dev_cfg.local_device_cfg[0].endpoint_cfg[1].direction          = svt_usb_types::IN;
      dev_cfg.local_device_cfg[0].endpoint_cfg[1].ep_type            = svt_usb_types::BULK;
      dev_cfg.local_device_cfg[0].endpoint_cfg[1].allow_aligned_transfer_without_zero_length = 0;
      dev_cfg.local_device_cfg[0].endpoint_cfg[1].max_burst_size     = `SVT_USB_MAX_BURST_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[1].max_packet_size    = `SVT_USB_SS_MAX_PACKET_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[1].supports_ustreams  = 1'b0;
    end

    if (max_usb_ss_endpoints >= 3) begin
      /**
       * Configuring End point '2' to BULK OUT
       */
      dev_cfg.local_device_cfg[0].endpoint_cfg[2].ep_number          = 1;
      dev_cfg.local_device_cfg[0].endpoint_cfg[2].direction          = svt_usb_types::OUT;
      dev_cfg.local_device_cfg[0].endpoint_cfg[2].ep_type            = svt_usb_types::BULK;
      dev_cfg.local_device_cfg[0].endpoint_cfg[2].allow_aligned_transfer_without_zero_length = 0;
      dev_cfg.local_device_cfg[0].endpoint_cfg[2].max_burst_size     = `SVT_USB_MAX_BURST_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[2].max_packet_size    = `SVT_USB_SS_MAX_PACKET_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[2].supports_ustreams  = 1'b0;
    end

    if (max_usb_ss_endpoints >= 4) begin
      /**
       * Configuring End point '3' to ISOC IN
       */
      dev_cfg.local_device_cfg[0].endpoint_cfg[3].ep_number          = 2;
      dev_cfg.local_device_cfg[0].endpoint_cfg[3].direction          = svt_usb_types::IN;
      dev_cfg.local_device_cfg[0].endpoint_cfg[3].ep_type            = svt_usb_types::ISOCHRONOUS;
      dev_cfg.local_device_cfg[0].endpoint_cfg[3].allow_aligned_transfer_without_zero_length = 0;
      dev_cfg.local_device_cfg[0].endpoint_cfg[3].interval           = 1;
      dev_cfg.local_device_cfg[0].endpoint_cfg[3].max_burst_size     = `SVT_USB_MAX_BURST_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[3].max_packet_size    = `SVT_USB_SS_MAX_PACKET_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[3].supports_ustreams  = 1'b0;
    end

    if (max_usb_ss_endpoints >= 5) begin
      /**
       * Configuring End point '4' to ISOC OUT
       */
      dev_cfg.local_device_cfg[0].endpoint_cfg[4].ep_number          = 2;
      dev_cfg.local_device_cfg[0].endpoint_cfg[4].direction          = svt_usb_types::OUT;
      dev_cfg.local_device_cfg[0].endpoint_cfg[4].ep_type            = svt_usb_types::ISOCHRONOUS;
      dev_cfg.local_device_cfg[0].endpoint_cfg[4].allow_aligned_transfer_without_zero_length = 0;
      dev_cfg.local_device_cfg[0].endpoint_cfg[4].interval           = 1;
      dev_cfg.local_device_cfg[0].endpoint_cfg[4].max_burst_size     = `SVT_USB_MAX_BURST_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[4].max_packet_size    = `SVT_USB_SS_MAX_PACKET_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[4].supports_ustreams  = 1'b0;
    end

    if (max_usb_ss_endpoints >= 6) begin
      /**
       * Configuring End point '5' to INTR IN
       */
      dev_cfg.local_device_cfg[0].endpoint_cfg[5].ep_number          = 3;
      dev_cfg.local_device_cfg[0].endpoint_cfg[5].direction          = svt_usb_types::IN;
      dev_cfg.local_device_cfg[0].endpoint_cfg[5].ep_type            = svt_usb_types::INTERRUPT;
      dev_cfg.local_device_cfg[0].endpoint_cfg[5].allow_aligned_transfer_without_zero_length = 0;
      dev_cfg.local_device_cfg[0].endpoint_cfg[5].interval           = 1;
      dev_cfg.local_device_cfg[0].endpoint_cfg[5].max_burst_size     = `SVT_USB_INTERRUPT_EP_MAX_BURST_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[5].max_packet_size    = `SVT_USB_SS_MAX_PACKET_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[5].supports_ustreams  = 1'b0;
    end

    if (max_usb_ss_endpoints >= 7) begin
      /**
       * Configuring End point '6' to INTR OUT
       */
      dev_cfg.local_device_cfg[0].endpoint_cfg[6].ep_number          = 3;
      dev_cfg.local_device_cfg[0].endpoint_cfg[6].direction          = svt_usb_types::OUT;
      dev_cfg.local_device_cfg[0].endpoint_cfg[6].ep_type            = svt_usb_types::INTERRUPT;
      dev_cfg.local_device_cfg[0].endpoint_cfg[6].allow_aligned_transfer_without_zero_length = 0;
      dev_cfg.local_device_cfg[0].endpoint_cfg[6].interval           = 1;
      dev_cfg.local_device_cfg[0].endpoint_cfg[6].max_burst_size     = `SVT_USB_INTERRUPT_EP_MAX_BURST_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[6].max_packet_size    = `SVT_USB_SS_MAX_PACKET_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[6].supports_ustreams  = 1'b0;
    end

    if (max_usb_ss_endpoints >= 8) begin
      `uvm_warning("setup_usb_ss_defaults", $sformatf("The max_usb_ss_endpoints property is set to %0d. Configured 7 endpoints . Other endpoints must be configured in the testcase.",
                 max_usb_ss_endpoints));
    end
endfunction

function void usb_shared_cfg::setup_usb_ss_otg_defaults();
    host_cfg.capability                                            = svt_usb_configuration::OTG;
    dev_cfg.capability                                             = svt_usb_configuration::OTG;
    host_cfg.micro_ab_plug_type                                    = svt_usb_types::A;
    dev_cfg.micro_ab_plug_type                                     = svt_usb_types::B;
    host_cfg.speed                                                 = svt_usb_types::SS;
    dev_cfg.speed                                                  = svt_usb_types::SS;
    host_cfg.ss_otg_issue_warm_reset                               = svt_usb_configuration::SS_OTG_AFTER_PENDING_XFERS;
    dev_cfg.ss_otg_issue_warm_reset                                = svt_usb_configuration::SS_OTG_AFTER_PENDING_XFERS;
    host_cfg.otg_capability                                        = svt_usb_configuration::OTG_SS_CAPABLE;
    dev_cfg.otg_capability                                         = svt_usb_configuration::OTG_SS_CAPABLE;

    host_cfg.usb_ss_signal_interface                               = svt_usb_configuration::USB_SS_SERIAL_IF;
    dev_cfg.usb_ss_signal_interface                                = svt_usb_configuration::USB_SS_SERIAL_IF;
    host_cfg.ss_otg_issue_warm_reset                               = svt_usb_configuration::SS_OTG_IMMEDIATELY;
    dev_cfg.ss_otg_issue_warm_reset                                = svt_usb_configuration::SS_OTG_IMMEDIATELY;

    // Set SS timeout values related to Warm Reset LFPS signaling.
    host_cfg.t_reset_timeout = 160us;
    dev_cfg.t_reset_timeout = 160us;

    host_cfg.u3_no_lfps_response_timeout = 100us;
    dev_cfg.u3_no_lfps_response_timeout = 100us;

    dev_cfg.local_device_cfg[0].device_address                     = 0;
    dev_cfg.local_device_cfg[0].connected_bus_speed                = svt_usb_types::SS;
    dev_cfg.local_device_cfg[0].connected_hub_device_address       = 0;
    dev_cfg.local_device_cfg[0].functionality_support              = svt_usb_types::SS;
    dev_cfg.local_device_cfg[0].num_endpoints                      = max_usb_ss_endpoints;
    host_cfg.usb_capability                                        = svt_usb_configuration::USB_SS_ONLY;
    dev_cfg.usb_capability                                         = svt_usb_configuration::USB_SS_ONLY;
    host_cfg.usb_ss_initial_ltssm_state                            = svt_usb_types::U0;
    dev_cfg.usb_ss_initial_ltssm_state                             = svt_usb_types::U0;
    host_cfg.usb_20_signal_interface                               = svt_usb_configuration::NO_20_IF;
    dev_cfg.usb_20_signal_interface                                = svt_usb_configuration::NO_20_IF;
    host_cfg.usb_ss_rx_buffer_mode                                 = svt_usb_configuration::NOMINAL_EMPTY;
    dev_cfg.usb_ss_rx_buffer_mode                                  = svt_usb_configuration::NOMINAL_EMPTY;
    host_cfg.usb_ss_rx_buffer_latency                              = 0;
    dev_cfg.usb_ss_rx_buffer_latency                               = 0;

    if (max_usb_ss_endpoints <= 0) begin
      `uvm_fatal("setup_usb_ss_otg_defaults", $sformatf("The max_usb_ss_endpoints property is set to %0d. This property must be set to a value >=1. Unable to continue", 
                 max_usb_ss_endpoints));
    end

    for (int ep_num = 0; ep_num < max_usb_ss_endpoints; ep_num++) begin
      dev_cfg.local_device_cfg[0].endpoint_cfg[ep_num] = new();
    end

    if (max_usb_ss_endpoints >= 1) begin
      /**
       * Configuring End point '0' to CONTROL
       * NOTE: 'direction' is irrelevant for a CONTROL endpoint. Though
       * direction is chosen as 'IN' here, this endpoint will support both
       * IN and OUT transfers
       */
      dev_cfg.local_device_cfg[0].endpoint_cfg[0].ep_number          = 0;
      dev_cfg.local_device_cfg[0].endpoint_cfg[0].direction          = svt_usb_types::IN;
      dev_cfg.local_device_cfg[0].endpoint_cfg[0].ep_type            = svt_usb_types::CONTROL;
      dev_cfg.local_device_cfg[0].endpoint_cfg[0].max_burst_size     = 0;
      dev_cfg.local_device_cfg[0].endpoint_cfg[0].max_packet_size    = `SVT_USB_SS_CONTROL_MAX_PACKET_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[0].supports_ustreams  = 1'b0;
    end

    if (max_usb_ss_endpoints >= 2) begin
      /**
       * Configuring End point '1' to BULK IN
       */
      dev_cfg.local_device_cfg[0].endpoint_cfg[1].ep_number          = 1;
      dev_cfg.local_device_cfg[0].endpoint_cfg[1].direction          = svt_usb_types::IN;
      dev_cfg.local_device_cfg[0].endpoint_cfg[1].ep_type            = svt_usb_types::BULK;
      dev_cfg.local_device_cfg[0].endpoint_cfg[1].allow_aligned_transfer_without_zero_length = 0;
      dev_cfg.local_device_cfg[0].endpoint_cfg[1].max_burst_size     = `SVT_USB_MAX_BURST_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[1].max_packet_size    = `SVT_USB_SS_MAX_PACKET_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[1].supports_ustreams  = 1'b0;
    end

    if (max_usb_ss_endpoints >= 3) begin
      /**
       * Configuring End point '2' to BULK OUT
       */
      dev_cfg.local_device_cfg[0].endpoint_cfg[2].ep_number          = 1;
      dev_cfg.local_device_cfg[0].endpoint_cfg[2].direction          = svt_usb_types::OUT;
      dev_cfg.local_device_cfg[0].endpoint_cfg[2].ep_type            = svt_usb_types::BULK;
      dev_cfg.local_device_cfg[0].endpoint_cfg[2].allow_aligned_transfer_without_zero_length = 0;
      dev_cfg.local_device_cfg[0].endpoint_cfg[2].max_burst_size     = `SVT_USB_MAX_BURST_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[2].max_packet_size    = `SVT_USB_SS_MAX_PACKET_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[2].supports_ustreams  = 1'b0;
    end

    if (max_usb_ss_endpoints >= 4) begin
      /**
       * Configuring End point '3' to ISOC IN
       */
      dev_cfg.local_device_cfg[0].endpoint_cfg[3].ep_number          = 2;
      dev_cfg.local_device_cfg[0].endpoint_cfg[3].direction          = svt_usb_types::IN;
      dev_cfg.local_device_cfg[0].endpoint_cfg[3].ep_type            = svt_usb_types::ISOCHRONOUS;
      dev_cfg.local_device_cfg[0].endpoint_cfg[3].allow_aligned_transfer_without_zero_length = 0;
      dev_cfg.local_device_cfg[0].endpoint_cfg[3].interval           = 1;
      dev_cfg.local_device_cfg[0].endpoint_cfg[3].max_burst_size     = `SVT_USB_MAX_BURST_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[3].max_packet_size    = `SVT_USB_SS_MAX_PACKET_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[3].supports_ustreams  = 1'b0;
    end

    if (max_usb_ss_endpoints >= 5) begin
      /**
       * Configuring End point '4' to ISOC OUT
       */
      dev_cfg.local_device_cfg[0].endpoint_cfg[4].ep_number          = 2;
      dev_cfg.local_device_cfg[0].endpoint_cfg[4].direction          = svt_usb_types::OUT;
      dev_cfg.local_device_cfg[0].endpoint_cfg[4].ep_type            = svt_usb_types::ISOCHRONOUS;
      dev_cfg.local_device_cfg[0].endpoint_cfg[4].allow_aligned_transfer_without_zero_length = 0;
      dev_cfg.local_device_cfg[0].endpoint_cfg[4].interval           = 1;
      dev_cfg.local_device_cfg[0].endpoint_cfg[4].max_burst_size     = `SVT_USB_MAX_BURST_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[4].max_packet_size    = `SVT_USB_SS_MAX_PACKET_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[4].supports_ustreams  = 1'b0;
    end

    if (max_usb_ss_endpoints >= 6) begin
      /**
       * Configuring End point '5' to INTR IN
       */
      dev_cfg.local_device_cfg[0].endpoint_cfg[5].ep_number          = 3;
      dev_cfg.local_device_cfg[0].endpoint_cfg[5].direction          = svt_usb_types::IN;
      dev_cfg.local_device_cfg[0].endpoint_cfg[5].ep_type            = svt_usb_types::INTERRUPT;
      dev_cfg.local_device_cfg[0].endpoint_cfg[5].allow_aligned_transfer_without_zero_length = 0;
      dev_cfg.local_device_cfg[0].endpoint_cfg[5].interval           = 1;
      dev_cfg.local_device_cfg[0].endpoint_cfg[5].max_burst_size     = `SVT_USB_INTERRUPT_EP_MAX_BURST_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[5].max_packet_size    = `SVT_USB_SS_MAX_PACKET_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[5].supports_ustreams  = 1'b0;
    end

    if (max_usb_ss_endpoints >= 7) begin
      /**
       * Configuring End point '6' to INTR OUT
       */
      dev_cfg.local_device_cfg[0].endpoint_cfg[6].ep_number          = 3;
      dev_cfg.local_device_cfg[0].endpoint_cfg[6].direction          = svt_usb_types::OUT;
      dev_cfg.local_device_cfg[0].endpoint_cfg[6].ep_type            = svt_usb_types::INTERRUPT;
      dev_cfg.local_device_cfg[0].endpoint_cfg[6].allow_aligned_transfer_without_zero_length = 0;
      dev_cfg.local_device_cfg[0].endpoint_cfg[6].interval           = 1;
      dev_cfg.local_device_cfg[0].endpoint_cfg[6].max_burst_size     = `SVT_USB_INTERRUPT_EP_MAX_BURST_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[6].max_packet_size    = `SVT_USB_SS_MAX_PACKET_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[6].supports_ustreams  = 1'b0;
    end

    if (max_usb_ss_endpoints >= 8) begin
      `uvm_warning("setup_usb_ss_otg_defaults", $sformatf("The max_usb_ss_endpoints property is set to %0d. Configured 7 endpoints. Other endpoints must be configured in the testcase.",
                 max_usb_ss_endpoints));
    end
endfunction

function void usb_shared_cfg::setup_usb_20_otg_defaults(
        svt_usb_types::speed_enum host_speed = svt_usb_types::FS,
        svt_usb_types::speed_enum dev_speed = svt_usb_types::FS
);
    host_cfg.capability                              = svt_usb_configuration::OTG;
    dev_cfg.capability                               = svt_usb_configuration::OTG;
    host_cfg.micro_ab_plug_type                      = svt_usb_types::A;
    dev_cfg.micro_ab_plug_type                       = svt_usb_types::B;
    host_cfg.speed                                   = (host_speed == svt_usb_types::HS) ? svt_usb_types::HS : svt_usb_types::FS;
    dev_cfg.speed                                    = (dev_speed == svt_usb_types::HS) ? svt_usb_types::HS : svt_usb_types::FS;

    host_cfg.usb_20_signal_interface                 = svt_usb_configuration::USB_20_SERIAL_IF;
    dev_cfg.usb_20_signal_interface                  = svt_usb_configuration::USB_20_SERIAL_IF;
    host_cfg.usb_ss_signal_interface                 = svt_usb_configuration::NO_SS_IF;
    dev_cfg.usb_ss_signal_interface                  = svt_usb_configuration::NO_SS_IF;
    host_cfg.usb_capability                          = svt_usb_configuration::USB_20_ONLY;
    dev_cfg.usb_capability                           = svt_usb_configuration::USB_20_ONLY;

    host_cfg.srp_supported                           = 1'b1;
    dev_cfg.srp_supported                            = 1'b1;
    host_cfg.hnp_supported                           = 1'b1;
    dev_cfg.hnp_supported                            = 1'b1;
    host_cfg.adp_supported                           = 1'b1;
    dev_cfg.adp_supported                            = 1'b1;
    dev_cfg.poweron_auto_attach_delay                = -1;

    // Scale down ADP and VBUS timing to reasonable values for testing
    host_cfg.ta_adp_prb    = 1.75us;
    host_cfg.tb_adp_prb    = 2.0us;

    dev_cfg.ta_adp_prb     = 1.75us;
    dev_cfg.tb_adp_prb     = 2.0us;

    host_cfg.tadp_rise     = 175ns;
    host_cfg.tadp_dschg    = 10ns;

    dev_cfg.tadp_rise      = 200ns;
    dev_cfg.tadp_dschg     = 10ns;

    host_cfg.ta_vbus_rise  = 500ns;
    host_cfg.tb_adp_detach = 100ns;

    dev_cfg.tb_adp_detach  = 100ns;
    dev_cfg.ta_vbus_rise   = 500ns;

    if (max_usb_20_endpoints <= 0) begin
      `uvm_fatal("setup_usb_20_otg_defaults", $sformatf("The max_usb_20_endpoints property is set to %0d. This property must be set to a value >=1. Unable to continue", 
                 max_usb_20_endpoints));
    end

    for (int ep_num = 0; ep_num < max_usb_20_endpoints; ep_num++) begin
      dev_cfg.local_device_cfg[0].endpoint_cfg[ep_num] = new();
    end

    dev_cfg.local_device_cfg[0].device_address                 = 0;
    dev_cfg.local_device_cfg[0].connected_bus_speed            = (dev_speed == svt_usb_types::HS) ? svt_usb_types::HS : svt_usb_types::FS;
    dev_cfg.local_device_cfg[0].connected_hub_device_address   = 0;
    dev_cfg.local_device_cfg[0].functionality_support          = (dev_speed == svt_usb_types::HS) ? svt_usb_types::HS : svt_usb_types::FS;
    dev_cfg.local_device_cfg[0].num_endpoints                  = max_usb_20_endpoints;

    if (max_usb_20_endpoints >= 1) begin
      /**
       * Configuring End point '0' to CONTROL
       * NOTE: 'direction' is irrelevant for a CONTROL endpoint. Though
       * direction is chosen as 'IN' here, this endpoint will support both
       * IN and OUT transfers
       */
      dev_cfg.local_device_cfg[0].endpoint_cfg[0].ep_number          = 0;
      dev_cfg.local_device_cfg[0].endpoint_cfg[0].direction          = svt_usb_types::IN;
      dev_cfg.local_device_cfg[0].endpoint_cfg[0].ep_type            = svt_usb_types::CONTROL;
      dev_cfg.local_device_cfg[0].endpoint_cfg[0].interval           = 1;
      dev_cfg.local_device_cfg[0].endpoint_cfg[0].max_burst_size     = 0;
      dev_cfg.local_device_cfg[0].endpoint_cfg[0].max_packet_size    = (dev_speed == svt_usb_types::HS) ? `SVT_USB_HS_CONTROL_MAX_PACKET_SIZE : `SVT_USB_FS_CONTROL_MAX_PACKET_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[0].supports_ustreams  = 1'b0;
    end

    if (max_usb_20_endpoints >= 2) begin
      /**
       * Configuring End point '1' to BULK IN
       */
      dev_cfg.local_device_cfg[0].endpoint_cfg[1].ep_number          = 1;
      dev_cfg.local_device_cfg[0].endpoint_cfg[1].direction          = svt_usb_types::IN;
      dev_cfg.local_device_cfg[0].endpoint_cfg[1].ep_type            = svt_usb_types::BULK;
      dev_cfg.local_device_cfg[0].endpoint_cfg[1].allow_aligned_transfer_without_zero_length = 0;
      dev_cfg.local_device_cfg[0].endpoint_cfg[1].max_burst_size     = 0;
      dev_cfg.local_device_cfg[0].endpoint_cfg[1].max_packet_size    = (dev_speed == svt_usb_types::HS) ? `SVT_USB_HS_BULK_MAX_PACKET_SIZE : `SVT_USB_FS_BULK_MAX_PACKET_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[1].supports_ustreams  = 1'b0;
    end

    if (max_usb_20_endpoints >= 3) begin
      /**
       * Configuring End point '2' to BULK OUT
       */
      dev_cfg.local_device_cfg[0].endpoint_cfg[2].ep_number          = 1;
      dev_cfg.local_device_cfg[0].endpoint_cfg[2].direction          = svt_usb_types::OUT;
      dev_cfg.local_device_cfg[0].endpoint_cfg[2].ep_type            = svt_usb_types::BULK;
      dev_cfg.local_device_cfg[0].endpoint_cfg[2].allow_aligned_transfer_without_zero_length = 0;
      dev_cfg.local_device_cfg[0].endpoint_cfg[2].max_burst_size     = 0;
      dev_cfg.local_device_cfg[0].endpoint_cfg[2].max_packet_size    = (dev_speed == svt_usb_types::HS) ? `SVT_USB_HS_BULK_MAX_PACKET_SIZE : `SVT_USB_FS_BULK_MAX_PACKET_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[2].supports_ustreams  = 1'b0;
    end

    if (max_usb_20_endpoints >= 4) begin
      /**
       * Configuring End point '3' to ISOC IN
       */
      dev_cfg.local_device_cfg[0].endpoint_cfg[3].ep_number          = 2;
      dev_cfg.local_device_cfg[0].endpoint_cfg[3].direction          = svt_usb_types::IN;
      dev_cfg.local_device_cfg[0].endpoint_cfg[3].ep_type            = svt_usb_types::ISOCHRONOUS;
      dev_cfg.local_device_cfg[0].endpoint_cfg[3].allow_aligned_transfer_without_zero_length = 0;
      dev_cfg.local_device_cfg[0].endpoint_cfg[3].interval           = 1;
      dev_cfg.local_device_cfg[0].endpoint_cfg[3].max_packet_size    = (dev_speed == svt_usb_types::HS) ? `SVT_USB_HS_ISOC_MAX_PACKET_SIZE : `SVT_USB_FS_ISOC_MAX_PACKET_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[3].supports_ustreams  = 1'b0;
    end

    if (max_usb_20_endpoints >= 5) begin
      /**
       * Configuring End point '4' to ISOC OUT
       */
      dev_cfg.local_device_cfg[0].endpoint_cfg[4].ep_number          = 2;
      dev_cfg.local_device_cfg[0].endpoint_cfg[4].direction          = svt_usb_types::OUT;
      dev_cfg.local_device_cfg[0].endpoint_cfg[4].ep_type            = svt_usb_types::ISOCHRONOUS;
      dev_cfg.local_device_cfg[0].endpoint_cfg[4].allow_aligned_transfer_without_zero_length = 0;
      dev_cfg.local_device_cfg[0].endpoint_cfg[4].interval           = 1;
      dev_cfg.local_device_cfg[0].endpoint_cfg[4].max_packet_size    = (dev_speed == svt_usb_types::HS) ? `SVT_USB_HS_ISOC_MAX_PACKET_SIZE : `SVT_USB_FS_ISOC_MAX_PACKET_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[4].supports_ustreams  = 1'b0;
    end

    if (max_usb_20_endpoints >= 6) begin
      /**
       * Configuring End point '5' to INTR IN
       */
      dev_cfg.local_device_cfg[0].endpoint_cfg[5].ep_number          = 3;
      dev_cfg.local_device_cfg[0].endpoint_cfg[5].direction          = svt_usb_types::IN;
      dev_cfg.local_device_cfg[0].endpoint_cfg[5].ep_type            = svt_usb_types::INTERRUPT;
      dev_cfg.local_device_cfg[0].endpoint_cfg[5].allow_aligned_transfer_without_zero_length = 0;
      dev_cfg.local_device_cfg[0].endpoint_cfg[5].interval           = 1;
      dev_cfg.local_device_cfg[0].endpoint_cfg[5].max_packet_size    = (dev_speed == svt_usb_types::HS) ? `SVT_USB_HS_INTR_MAX_PACKET_SIZE : `SVT_USB_FS_INTR_MAX_PACKET_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[5].supports_ustreams  = 1'b0;
    end

    if (max_usb_20_endpoints >= 7) begin
      /**
       * Configuring End point '6' to INTR OUT
       */
      dev_cfg.local_device_cfg[0].endpoint_cfg[6].ep_number          = 3;
      dev_cfg.local_device_cfg[0].endpoint_cfg[6].direction          = svt_usb_types::OUT;
      dev_cfg.local_device_cfg[0].endpoint_cfg[6].ep_type            = svt_usb_types::INTERRUPT;
      dev_cfg.local_device_cfg[0].endpoint_cfg[6].allow_aligned_transfer_without_zero_length = 0;
      dev_cfg.local_device_cfg[0].endpoint_cfg[6].interval           = 1;
      dev_cfg.local_device_cfg[0].endpoint_cfg[6].max_packet_size    = (dev_speed == svt_usb_types::HS) ? `SVT_USB_HS_INTR_MAX_PACKET_SIZE : `SVT_USB_FS_INTR_MAX_PACKET_SIZE;
      dev_cfg.local_device_cfg[0].endpoint_cfg[6].supports_ustreams  = 1'b0;
    end

    if (max_usb_20_endpoints >= 8) begin
      `uvm_warning("setup_usb_ss_otg_defaults",
              $sformatf("The max_usb_20_endpoints property is set to %0d. Configured 7 endpoints. Other endpoints must be configured in the testcase.",
                 max_usb_20_endpoints));
    end
endfunction

function void usb_shared_cfg::setup_usb_20_defaults(
        svt_usb_types::speed_enum host_speed = svt_usb_types::HS,
        svt_usb_types::speed_enum dev_speed = svt_usb_types::HS
);
    host_cfg.capability                              = svt_usb_configuration::PLAIN;
    dev_cfg.capability                               = svt_usb_configuration::PLAIN;
    host_cfg.speed                                   = (host_speed == svt_usb_types::HS) ? svt_usb_types::HS : (host_speed == svt_usb_types::FS) ? svt_usb_types::FS : svt_usb_types::LS;
    dev_cfg.speed                                    = (dev_speed == svt_usb_types::HS) ? svt_usb_types::HS : (dev_speed == svt_usb_types::FS) ? svt_usb_types::FS : svt_usb_types::LS;;

    host_cfg.usb_20_signal_interface                 = svt_usb_configuration::USB_20_SERIAL_IF;
    dev_cfg.usb_20_signal_interface                  = svt_usb_configuration::USB_20_SERIAL_IF;
    host_cfg.usb_ss_signal_interface                 = svt_usb_configuration::NO_SS_IF;
    dev_cfg.usb_ss_signal_interface                  = svt_usb_configuration::NO_SS_IF;
    host_cfg.usb_capability                          = svt_usb_configuration::USB_20_ONLY;
    dev_cfg.usb_capability                           = svt_usb_configuration::USB_20_ONLY;

    if (max_usb_20_endpoints <= 0) begin
      `uvm_fatal("setup_usb_20_defaults", $sformatf("The max_usb_20_endpoints property is set to %0d. This property must be set to a value >=1. Unable to continue",
                 max_usb_20_endpoints))
    end

    for (int ep_num = 0; ep_num < max_usb_20_endpoints; ep_num++) begin
      dev_cfg.local_device_cfg[0].endpoint_cfg[ep_num] = new();
    end

    dev_cfg.local_device_cfg[0].device_address                 = 0;
    dev_cfg.local_device_cfg[0].connected_bus_speed            = (dev_speed == svt_usb_types::HS) ? svt_usb_types::HS : (dev_speed == svt_usb_types::FS) ? svt_usb_types::FS : svt_usb_types::LS;
    dev_cfg.local_device_cfg[0].connected_hub_device_address   = 0;
    dev_cfg.local_device_cfg[0].functionality_support          = (dev_speed == svt_usb_types::HS) ? svt_usb_types::HS : (dev_speed == svt_usb_types::FS) ? svt_usb_types::FS : svt_usb_types::LS;
    dev_cfg.local_device_cfg[0].num_endpoints                  = max_usb_20_endpoints;

    if (max_usb_20_endpoints >= 1) begin
      /**
       * Configuring End point '0' to CONTROL
       * NOTE: 'direction' is irrelevant for a CONTROL endpoint. Though
       * direction is chosen as 'IN' here, this endpoint will support both
       * IN and OUT transfers
       */
      dev_cfg.local_device_cfg[0].endpoint_cfg[0].ep_number          = 0;
      dev_cfg.local_device_cfg[0].endpoint_cfg[0].direction          = svt_usb_types::IN;
      dev_cfg.local_device_cfg[0].endpoint_cfg[0].ep_type            = svt_usb_types::CONTROL;
      dev_cfg.local_device_cfg[0].endpoint_cfg[0].interval           = 1;
      dev_cfg.local_device_cfg[0].endpoint_cfg[0].max_burst_size     = 0;
      dev_cfg.local_device_cfg[0].endpoint_cfg[0].max_packet_size    = (dev_speed == svt_usb_types::HS) ? `SVT_USB_HS_CONTROL_MAX_PACKET_SIZE : (dev_speed == svt_usb_types::FS) ? `SVT_USB_FS_CONTROL_MAX_PACKET_SIZE : `SVT_USB_LS_CONTROL_MAX_PACKET_SIZE;
    end

    if (max_usb_20_endpoints >= 2) begin
      /**
       * Configuring End point '1' to BULK IN
       */
      dev_cfg.local_device_cfg[0].endpoint_cfg[1].ep_number          = 1;
      dev_cfg.local_device_cfg[0].endpoint_cfg[1].direction          = svt_usb_types::IN;
      dev_cfg.local_device_cfg[0].endpoint_cfg[1].ep_type            = (dev_speed == svt_usb_types::LS) ? svt_usb_types::INTERRUPT : svt_usb_types::BULK;
      dev_cfg.local_device_cfg[0].endpoint_cfg[1].allow_aligned_transfer_without_zero_length = 0;
      dev_cfg.local_device_cfg[0].endpoint_cfg[1].interval           = 1;
      dev_cfg.local_device_cfg[0].endpoint_cfg[1].max_packet_size    = (dev_speed == svt_usb_types::HS) ? `SVT_USB_HS_BULK_MAX_PACKET_SIZE : (dev_speed == svt_usb_types::FS) ? `SVT_USB_FS_BULK_MAX_PACKET_SIZE : `SVT_USB_LS_INTR_MAX_PACKET_SIZE;
    end

    if (max_usb_20_endpoints >= 3) begin
      /**
       * Configuring End point '2' to BULK OUT
       */
      dev_cfg.local_device_cfg[0].endpoint_cfg[2].ep_number          = 2;
      dev_cfg.local_device_cfg[0].endpoint_cfg[2].direction          = svt_usb_types::OUT;
      dev_cfg.local_device_cfg[0].endpoint_cfg[2].ep_type            = (dev_speed == svt_usb_types::LS) ? svt_usb_types::INTERRUPT : svt_usb_types::BULK;
      dev_cfg.local_device_cfg[0].endpoint_cfg[2].allow_aligned_transfer_without_zero_length = 0;
      /** Out endpoints have their interval forced to 0 */
      dev_cfg.local_device_cfg[0].endpoint_cfg[2].interval           =(dev_speed == svt_usb_types::LS)? 1 : 0;
      dev_cfg.local_device_cfg[0].endpoint_cfg[2].max_packet_size    = (dev_speed == svt_usb_types::HS) ? `SVT_USB_HS_BULK_MAX_PACKET_SIZE : (dev_speed == svt_usb_types::FS) ? `SVT_USB_FS_BULK_MAX_PACKET_SIZE : `SVT_USB_LS_INTR_MAX_PACKET_SIZE;
    end

    if (max_usb_20_endpoints >= 4) begin
      /**
       * Configuring End point '3' to ISOC IN
       */
      dev_cfg.local_device_cfg[0].endpoint_cfg[3].ep_number          = 3;
      dev_cfg.local_device_cfg[0].endpoint_cfg[3].direction          = svt_usb_types::IN;
      dev_cfg.local_device_cfg[0].endpoint_cfg[3].ep_type            = (dev_speed == svt_usb_types::LS) ? svt_usb_types::INTERRUPT : svt_usb_types::ISOCHRONOUS;
      dev_cfg.local_device_cfg[0].endpoint_cfg[3].allow_aligned_transfer_without_zero_length = 0;
      dev_cfg.local_device_cfg[0].endpoint_cfg[3].interval           = 1;
      dev_cfg.local_device_cfg[0].endpoint_cfg[3].max_packet_size    = (dev_speed == svt_usb_types::HS) ? `SVT_USB_HS_ISOC_MAX_PACKET_SIZE : (dev_speed == svt_usb_types::FS) ? `SVT_USB_FS_ISOC_MAX_PACKET_SIZE :  `SVT_USB_LS_INTR_MAX_PACKET_SIZE;
    end

    if (max_usb_20_endpoints >= 5) begin
      /**
       * Configuring End point '4' to ISOC OUT
       */
      dev_cfg.local_device_cfg[0].endpoint_cfg[4].ep_number          = 4;
      dev_cfg.local_device_cfg[0].endpoint_cfg[4].direction          = svt_usb_types::OUT;
      dev_cfg.local_device_cfg[0].endpoint_cfg[4].ep_type            = (dev_speed == svt_usb_types::LS) ? svt_usb_types::INTERRUPT : svt_usb_types::ISOCHRONOUS;
      dev_cfg.local_device_cfg[0].endpoint_cfg[4].allow_aligned_transfer_without_zero_length = 0;
      /** Out endpoints have their interval forced to 1 */
      dev_cfg.local_device_cfg[0].endpoint_cfg[4].interval           = 1;
      dev_cfg.local_device_cfg[0].endpoint_cfg[4].max_packet_size    = (dev_speed == svt_usb_types::HS) ? `SVT_USB_HS_ISOC_MAX_PACKET_SIZE : (dev_speed == svt_usb_types::FS) ? `SVT_USB_FS_ISOC_MAX_PACKET_SIZE :  `SVT_USB_LS_INTR_MAX_PACKET_SIZE;
    end

    if (max_usb_20_endpoints >= 6) begin
      /**
       * Configuring End point '5' to INTR IN
       */
      dev_cfg.local_device_cfg[0].endpoint_cfg[5].ep_number          = 5;
      dev_cfg.local_device_cfg[0].endpoint_cfg[5].direction          = svt_usb_types::IN;
      dev_cfg.local_device_cfg[0].endpoint_cfg[5].ep_type            = svt_usb_types::INTERRUPT;
      dev_cfg.local_device_cfg[0].endpoint_cfg[5].allow_aligned_transfer_without_zero_length = 0;
      dev_cfg.local_device_cfg[0].endpoint_cfg[5].interval           = 1;
      dev_cfg.local_device_cfg[0].endpoint_cfg[5].max_packet_size    = (dev_speed == svt_usb_types::HS) ? `SVT_USB_HS_INTR_MAX_PACKET_SIZE : (dev_speed == svt_usb_types::FS) ? `SVT_USB_FS_INTR_MAX_PACKET_SIZE : `SVT_USB_LS_INTR_MAX_PACKET_SIZE;
    end

    if (max_usb_20_endpoints >= 7) begin
      /**
       * Configuring End point '6' to INTR OUT
       */
      dev_cfg.local_device_cfg[0].endpoint_cfg[6].ep_number          = 6;
      dev_cfg.local_device_cfg[0].endpoint_cfg[6].direction          = svt_usb_types::OUT;
      dev_cfg.local_device_cfg[0].endpoint_cfg[6].ep_type            = svt_usb_types::INTERRUPT;
      dev_cfg.local_device_cfg[0].endpoint_cfg[6].allow_aligned_transfer_without_zero_length = 0;
      /** Out endpoints have their interval forced to 1 */
      dev_cfg.local_device_cfg[0].endpoint_cfg[6].interval           = 1;
      dev_cfg.local_device_cfg[0].endpoint_cfg[6].max_packet_size    = (dev_speed == svt_usb_types::HS) ? `SVT_USB_HS_INTR_MAX_PACKET_SIZE : (dev_speed == svt_usb_types::FS) ? `SVT_USB_FS_INTR_MAX_PACKET_SIZE : `SVT_USB_LS_INTR_MAX_PACKET_SIZE;
    end

    if (max_usb_20_endpoints >= 8) begin
      `uvm_warning("setup_usb_20_defaults", $sformatf("The max_usb_20_endpoints property is set to %0d. Configured 7 endpoints. Other endpoints must be configured in the testcase.",
                 max_usb_20_endpoints));
    end
endfunction

function string usb_shared_cfg::get_class_name();
    get_class_name = "usb_shared_cfg";
endfunction

  /**
   * Checks to see that the data field values are valid, mainly making sure the
   * host and device interface specifications are consistent.
   */
function bit usb_shared_cfg::is_valid(bit silent = 1, int kind = -1);
    is_valid = 1;

    if (!host_cfg.is_valid(silent))
    begin
        if (!silent)
        begin
            `uvm_info("is_valid", $sformatf("Invalid Host configuration. Contents:\n%s", host_cfg.sprint()), UVM_HIGH)
        end
        is_valid = 0;
    end else if (!dev_cfg.is_valid(silent)) begin
        if (!silent)
        begin
            `uvm_info("is_valid", $sformatf("Invalid Device configuration. Contents:\n%s", dev_cfg.sprint()), UVM_HIGH);
        end
        is_valid = 0;
    end
endfunction
`endif//USB_TEST_ON
`endif // GUARD_USB_SHARED_CFG_SV

