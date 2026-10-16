//----------------------------------------------------------------
//Copyright:COMPANY: Undefined variable.
//Filename :cm0_tarmac_top.v
//Author   :wangky
//----------------------------------------------------------------
//History:
//Revsion           data               code by          description
//1.0.1          2021.04.15          wangky        create new
//
//----------------------------------------------------------------
//Clock Domain  :clk_xx
//Reset Strategy:rst_xx_n,Asynchronous,active low
//------------------------------------------------------------------
//Module Function description:
//
//
// -----------------------------------------------------------------

`ifndef __CM0_TARMAC_TOP_V__
`define __CM0_TARMAC_TOP_V__

cm0_tarmac
   u_tarmac
     (.enable_i      (1'b1),

      .hclk_i        (`CM0_INST.HCLK),
      .hready_i      (`CM0_INST.HREADY),
      .haddr_i       (`CM0_INST.HADDR[31:0]),
      .hprot_i       (`CM0_INST.HPROT[3:0]),
      .hsize_i       (`CM0_INST.HSIZE[2:0]),
      .hwrite_i      (`CM0_INST.HWRITE),
      .htrans_i      (`CM0_INST.HTRANS[1:0]),
      .hresetn_i     (`CM0_INST.HRESETn),
      .hresp_i       (`CM0_INST.HRESP),
      .hrdata_i      (`CM0_INST.HRDATA[31:0]),
      .hwdata_i      (`CM0_INST.HWDATA[31:0]),
      .lockup_i      (`CM0_INST.LOCKUP),
      .halted_i      (`CM0_INST.HALTED),
      .codehintde_i  (`CM0_INST.CODEHINTDE[2:0]),
      .codenseq_i    (`CM0_INST.CODENSEQ),

      .hdf_req_i     (`CM0_INST.u_top.u_sys.ctl_hdf_request),
      .int_taken_i   (`CM0_INST.u_top.u_sys.dec_int_taken_o),
      .int_return_i  (`CM0_INST.u_top.u_sys.dec_int_return_o),
      .int_pend_i    (`CM0_INST.u_top.u_sys.nvm_int_pend),
      .pend_num_i    (`CM0_INST.u_top.u_sys.nvm_int_pend_num[5:0]),
      .ipsr_i        (`CM0_INST.u_top.u_sys.psr_ipsr[5:0]),

      .ex_last_i     (`CM0_INST.u_top.u_sys.u_core.ctl_ex_last),
      .iaex_en_i     (`CM0_INST.u_top.u_sys.u_core.ctl_iaex_en),
      .reg_waddr_i   (`CM0_INST.u_top.u_sys.u_core.ctl_wr_addr[3:0]),
      .reg_write_i   (`CM0_INST.u_top.u_sys.u_core.ctl_wr_en),
      .xpsr_en_i     (`CM0_INST.u_top.u_sys.u_core.ctl_xpsr_en),
      .fe_addr_i     (`CM0_INST.u_top.u_sys.u_core.pfu_fe_addr[30:0]),
      .int_delay_i   (`CM0_INST.u_top.u_sys.u_core.pfu_int_delay),
      .special_i     (`CM0_INST.u_top.u_sys.u_core.pfu_op_special),
      .opcode_i      (`CM0_INST.u_top.u_sys.u_core.pfu_opcode[15:0]),
      .reg_wdata_i   (`CM0_INST.u_top.u_sys.u_core.psr_gpr_wdata[31:0]),

      .atomic_i      (`CM0_INST.u_top.u_sys.u_core.u_ctl.atomic),
      .atomic_nxt_i  (`CM0_INST.u_top.u_sys.u_core.u_ctl.atomic_nxt),
      .dabort_i      (`CM0_INST.u_top.u_sys.u_core.u_ctl.data_abort),
      .ex_last_nxt_i (`CM0_INST.u_top.u_sys.u_core.u_ctl.ex_last_nxt),
      .int_preempt_i (`CM0_INST.u_top.u_sys.u_core.u_ctl.int_preempt),

      .psp_sel_i     (`CM0_INST.u_top.u_sys.u_core.u_gpr.psp_sel),
      .xpsr_i        (`CM0_INST.u_top.u_sys.u_core.u_gpr.xpsr[31:0]),

      .iaex_i        (`CM0_INST.u_top.u_sys.u_core.u_pfu.iaex[30:0]),
      .iaex_nxt_i    (`CM0_INST.u_top.u_sys.u_core.u_pfu.iaex_nxt[30:0]),
      .opcode_nxt_i  (`CM0_INST.u_top.u_sys.u_core.u_pfu.ibuf_de_nxt[15:0]),
      .delay_count_i (`CM0_INST.u_top.u_sys.u_core.u_pfu.ibuf_lo[13:6]),
      .tbit_en_i     (`CM0_INST.u_top.u_sys.u_core.u_pfu.tbit_en),

      .cflag_en_i    (`CM0_INST.u_top.u_sys.u_core.u_psr.cflag_ena),
      .ipsr_en_i     (`CM0_INST.u_top.u_sys.u_core.u_psr.ipsr_ena),
      .nzflag_en_i   (`CM0_INST.u_top.u_sys.u_core.u_psr.nzflag_ena),
      .vflag_en_i    (`CM0_INST.u_top.u_sys.u_core.u_psr.vflag_ena) );

`endif
