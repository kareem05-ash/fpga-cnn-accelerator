
class acc_base_test extends uvm_test;

    `uvm_component_utils(acc_base_test)

    acc_env    env;
    acc_config cfg;

    function new(string name = "acc_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("TEST", "acc_base_test build_phase", UVM_LOW)

        cfg = acc_config::type_id::create("cfg");
        configure_cfg();
        uvm_config_db#(acc_config)::set(this, "*", "cfg", cfg);

        env = acc_env::type_id::create("env", this);
    endfunction

    virtual function void configure_cfg();
    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
    endfunction

    virtual function uvm_object_wrapper get_seq_type();
        return acc_base_seq::type_id::get();
    endfunction

    task run_phase(uvm_phase phase);
        acc_base_seq seq;
        phase.raise_objection(this, "acc_base_test starting sequence");

        if (!$cast(seq, get_seq_type().create_object("seq")))
            `uvm_fatal("TEST", "Failed to create default sequence")
        if (!seq.randomize())
            `uvm_fatal("TEST", "Failed to randomize default sequence")
        seq.start(env.agent.sequencer);

        phase.drop_objection(this, "acc_base_test finished sequence");
    endtask

endclass : acc_base_test
