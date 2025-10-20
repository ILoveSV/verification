
class mhsa_scb extends uvm_scoreboard;
  `uvm_component_utils(mhsa_scb);
  
  // Configuration subcomponents
  apb_seq_item expect_queue[$];
  semaphore queue_sem = new(1);
  
  uvm_blocking_get_port #(apb_seq_item) exp_port;
  uvm_blocking_get_port #(apb_seq_item) act_port;
  
  int match_count = 0;
  int mismatch_count = 0;
  
  // Constructor
  function new(string name="mhsa_scb", uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build Phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    exp_port = new("exp_port", this);
    act_port = new("act_port", this);
  endfunction

  // Run Phase
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    fork
      process_expected_transactions();
      process_actual_transactions();
    join_none
  endtask

  // Process Transaction Tasks
  task process_expected_transactions();
    apb_seq_item get_expect;
    forever begin
      exp_port.get(get_expect);
      queue_sem.get(1);
      expect_queue.push_back(get_expect);
      queue_sem.put(1);
    end
  endtask 

  task process_actual_transactions();
    apb_seq_item get_actual, tmp_tran ;
    forever begin
      act_port.get(get_actual);


      `uvm_info("SCB/ACT", $sformatf("Received actual transaction:\n%s", 
                  get_actual.sprint()), UVM_HIGH)
      queue_sem.get(1);
      if (expect_queue.size() == 0) begin
        `uvm_error("SCB/ERR", "Received actual transaction with empty expectation queue!")
        queue_sem.put(1);
        continue;
      end
      tmp_tran = expect_queue.pop_front();
      queue_sem.put(1);


      if (!compare_transactions(tmp_tran, get_actual)) begin
        `uvm_error("SCB/ERR", $sformatf("Transaction mismatch!\nExpected:\n%s\nActual:\n%s", 
                   tmp_tran.sprint(), get_actual.sprint()))
        mismatch_count++;
      end else begin
        `uvm_info("SCB/MATCH", "Transaction matched successfully", UVM_MEDIUM)
        match_count++;
      end


    end
  endtask

  //Compare Task
  function bit compare_transactions(apb_seq_item expected, apb_seq_item actual);
    bit status = 1;
        if (expected == null || actual == null) begin
        `uvm_error("SCB/CMP", "empty transaction detected!")
        return 0;
    end
    
    if (!expected.compare(actual)) begin
      `uvm_warning("SCB/CMP", $sformatf("final result mismatch!"))
      status = 0;
    end

 //   if (uvm_report_enabled(UVM_HIGH, UVM_INFO, "SCOREBOARD"))
    begin
      `uvm_info("SCOREBOARD", "actual:", UVM_HIGH)
      actual.print_arrays("DUT_ITEM");
      
      `uvm_info("SCOREBOARD", "expected:", UVM_HIGH)
      expected.print_arrays("REF_ITEM");
    end

    return status;
  endfunction

  // Report Phase
  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("SCB/STAT", $sformatf("Comparison Summary:\nMatches: %0d\nMismatches: %0d\nRemaining expected: %0d", 
               match_count, mismatch_count, expect_queue.size()), UVM_LOW)
    
    if (expect_queue.size() > 0) begin
      `uvm_error("SCB/ERR", $sformatf("Unprocessed expected transactions remaining: %0d", 
                 expect_queue.size()))
      foreach (expect_queue[i]) begin
        `uvm_info("SCB/UNPROCESSED", $sformatf("Unprocessed transaction #%0d:\n%s", 
                  i, expect_queue[i].sprint()), UVM_LOW)
      end
    end
  endfunction
endclass
