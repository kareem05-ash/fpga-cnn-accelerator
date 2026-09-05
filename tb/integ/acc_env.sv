
class acc_env extends uvm_env;

    `uvm_component_utils(acc_env)

    acc_config     cfg;
    acc_agent      agent;
    acc_coverage   coverage;
    acc_scoreboard scoreboard;

    function new(string name = "acc_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("ENV", "acc_env build_phase", UVM_LOW)
        `uvm_info("ENV", "acc_env build_phase", UVM_MEDIUM)
        `uvm_info("ENV", "acc_env build_phase", UVM_HIGH)
        `uvm_info("ENV", "acc_env build_phase", UVM_FULL)

        if (!uvm_config_db#(acc_config)::get(this, "", "cfg", cfg))
            `uvm_fatal("ENV", "acc_config not found in config_db")

        agent      = acc_agent::type_id::create("agent", this);
        coverage   = acc_coverage::type_id::create("coverage", this);
        scoreboard = acc_scoreboard::type_id::create("scoreboard", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent.monitor.ap.connect(scoreboard.sb_imp);
        agent.monitor.ap.connect(coverage.cov_imp);
    endfunction

endclass : acc_env
