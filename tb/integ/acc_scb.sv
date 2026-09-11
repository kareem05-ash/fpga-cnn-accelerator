package acc_scb_pkg;
  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import acc_txn_pkg::*;
  import acc_cfg_pkg::*;

  class acc_scb #(OUT_DEPTH) extends uvm_scoreboard;
    `uvm_component_param_utils(acc_scb #(OUT_DEPTH))

    uvm_analysis_imp #(acc_txn, acc_scb #(OUT_DEPTH)) push_imp;
    acc_cfg m_cfg;

    function new(string name="acc_scb", uvm_component parent);
      super.new(name, parent);
      push_imp = new("scb_push_imp", this);
      `uvm_info("NEW", get_full_name(), UVM_FULL)
    endfunction //new()

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info("BUILD", get_full_name(), UVM_FULL)

      if (!uvm_config_db #(acc_cfg)::get(this, "", "cfg", m_cfg))
        `uvm_fatal(get_type_name(), "Failed to get the common cfg")
    endfunction

    virtual function void write(acc_txn txn);
      // scb doesn't need mon txn
      // It uses file-based verification mechanism
    endfunction

    virtual function void calc_exp(string gm_rel_path="software_py_model/golden_model.py");
      int status;
      string cmd;

      cmd = $sformatf(
        "python %s --n %0d --img-w %0d --img-h %0d --input %s --kernel %s --output %s",
        gm_rel_path,
        m_cfg.n,
        m_cfg.img_w,
        m_cfg.img_h,
        "input.txt",
        "kernel.txt",
        "golden_output.txt"
      );

      `uvm_info(
        get_type_name(),
        $sformatf("Running golden model: %s", cmd),
        UVM_LOW
      )

      status = $system(cmd);

      if (status != 0)
        `uvm_fatal(
          get_type_name(),
          $sformatf(
            "Golden model execution failed with status %0d",
            status
          )
        )

      `uvm_info(
        get_type_name(),
        "Golden model completed successfully",
        UVM_LOW
      )
    endfunction

    virtual function bit compare();
      int fh_act, fh_exp;
      int    act,    exp;
      bit status = 1'b1;
      fh_act = $fopen("output.txt", "r");
      fh_exp = $fopen("golden_output.txt", "r");

      if (fh_act == 0)
        `uvm_fatal(get_type_name(), "Failed to open output.txt in read mode")
      if (fh_exp == 0)
        `uvm_fatal(get_type_name(), "Failed to open golden_output.txt in read mode")

      for (int idx = 0; idx < OUT_DEPTH; idx++) begin
        if ($fscanf(fh_act, "%d", act) != 1)
          `uvm_fatal(
            get_type_name(),
            $sformatf("Failed to read actual output at pixel %0d", idx)
          )

        if ($fscanf(fh_exp, "%d", exp) != 1)
          `uvm_fatal(
            get_type_name(),
            $sformatf("Failed to read expected output at pixel %0d", idx)
          )

        if (act !== exp) begin
          `uvm_error(
            get_type_name(),
            $sformatf(
              "Missmatch at pixel %05d: actual=%05d, expected=%05d",
              idx, act, exp
            )
          )

          // $fclose(fh_act);
          // $fclose(fh_exp);
          status = 1'b0;
        end else begin
          `uvm_info(
            get_type_name(),
            $sformatf(
              "Matching  at pixel %05d: actual=%05d, expected=%05d",
              idx, act, exp
            ),
            UVM_MEDIUM
          )
        end

      end

      $fclose(fh_act);
      $fclose(fh_exp);

      return status;
    endfunction

    virtual task run_phase(uvm_phase phase);
      forever begin
        @(m_cfg.read_seq_done_e);
          calc_exp();
          
          if (!compare())
            `uvm_fatal(get_type_name(), "FAIL: Accelerator verification failed")
          else
            `uvm_info(
              get_type_name(),
              $sformatf("PASS: %0d output pixels matched", OUT_DEPTH),
              UVM_LOW
            )
      end
    endtask
  endclass //acc_scb extends uvm_scoreboard
endpackage