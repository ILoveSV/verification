
module apb_assertion (
    apb_bus.others apb
);
    bit paddr_check, pwrite_check, pwdata_check;

    // (1) 每一个信号在其有效/使用时的X态检查
    property pwrite_no_x_check;
        @(posedge apb.clk) disable iff(!apb.rst_n)
        not ($isunknown(apb.pwrite));
    endproperty

    property psel_no_x_check;
        @(posedge apb.clk) disable iff(!apb.rst_n)
        not ($isunknown(apb.psel));
    endproperty

    property paddr_no_x_check;
        @(posedge apb.clk) disable iff(!apb.rst_n)
        apb.psel |-> (not ($isunknown(apb.paddr)));
    endproperty

    property pwdata_no_x_check;
        @(posedge apb.clk) disable iff(!apb.rst_n)
        (apb.psel && !apb.pwrite) |-> (not ($isunknown(apb.pwdata)));
    endproperty

    property penable_no_x_check;
        @(posedge apb.clk) disable iff(!apb.rst_n)
        not ($isunknown(apb.penable));
    endproperty

    property pready_no_x_check;
        @(posedge apb.clk) disable iff(!apb.rst_n)
        not ($isunknown(apb.pready));
    endproperty

    property prdata_no_x_check;
        @(posedge apb.clk) disable iff(!apb.rst_n)
        apb.pready |-> (not ($isunknown(apb.prdata)));
    endproperty

    // (2) 在psel拉高后，paddr的稳定性检查
    property paddr_stability_check;
        @(posedge apb.clk) disable iff(!apb.rst_n)
        (apb.psel && !paddr_check) |=> $stable(apb.paddr);
    endproperty

    // (3) 在psel拉高后，pwrite的稳定性检查
    property pwrite_stability_check;
        @(posedge apb.clk) disable iff(!apb.rst_n)
        (apb.psel && !pwrite_check) |=> $stable(apb.pwrite);
    endproperty

    // (4) 在psel拉高后且pwrite为高时，pwdata的稳定性检查
    property pwdata_stability_check;
        @(posedge apb.clk) disable iff(!apb.rst_n)
        (apb.psel && apb.pwrite && !pwdata_check) |=> $stable(apb.pwdata);
    endproperty

    // (5) psel、penable与pready的握手检查
    property psel_penable_pready_handshake_check;
        @(posedge apb.clk) disable iff(!apb.rst_n)
        (apb.psel && apb.penable) |-> ##[0:$] apb.pready;
    endproperty

    // (6) penable与pready握手后必须拉低
    property penable_must_low_after_handshake_check;
        @(posedge apb.clk) disable iff(!apb.rst_n)
        (apb.penable && apb.pready) |=> ##[0:$] apb.penable == 0;
    endproperty

    // (7) penable拉高的前一周期，psel必须为高
    property penable_high_psel_must_high_check;
        @(posedge apb.clk) disable iff(!apb.rst_n)
        ($rose(apb.penable)) |-> $past(apb.psel);
    endproperty

    // (8) psel拉高的下一周期，penable必须为高
    property psel_high_penable_must_high_check;
        @(posedge apb.clk) disable iff(!apb.rst_n)
        ($rose(apb.psel)) |=> apb.penable;
    endproperty

    // Assertions
    check_pwrite_no_x: assert property (pwrite_no_x_check) else $error($stime, "\t\t FATAL: pwrite exists X!\n");
    check_psel_no_x: assert property (psel_no_x_check) else $error($stime, "\t\t FATAL: psel exists X!\n");
    check_paddr_no_x: assert property (paddr_no_x_check) else $error($stime, "\t\t FATAL: paddr exists X!\n");
    check_pwdata_no_x: assert property (pwdata_no_x_check) else $error($stime, "\t\t FATAL: pwdata exists X!\n");
    check_penable_no_x: assert property (penable_no_x_check) else $error($stime, "\t\t FATAL: penable exists X!\n");
    check_pready_no_x: assert property (pready_no_x_check) else $error($stime, "\t\t FATAL: pready exists X!\n");
    check_prdata_no_x: assert property (prdata_no_x_check) else $error($stime, "\t\t FATAL: prdata exists X!\n");

    check_paddr_stability: assert property (paddr_stability_check) else $error($stime, "\t\t FATAL: paddr does not stay stable when psel is high!\n");
    check_pwrite_stability: assert property (pwrite_stability_check) else $error($stime, "\t\t FATAL: pwrite does not stay stable when psel is high!\n");
    check_pwdata_stability: assert property (pwdata_stability_check) else $error($stime, "\t\t FATAL: pwdata does not stay stable when psel and pwrite are high!\n");
    check_psel_penable_pready_handshake: assert property (psel_penable_pready_handshake_check) else $error($stime, "\t\t FATAL: psel, penable, pready do not handshake properly!\n");
    check_penable_must_low_after_handshake: assert property (penable_must_low_after_handshake_check) else $error($stime, "\t\t FATAL: penable must be low after handshake with pready!\n");
    check_penable_high_psel_must_high: assert property (penable_high_psel_must_high_check) else $error($stime, "\t\t FATAL: psel must be high before penable is high!\n");
    check_psel_high_penable_must_high: assert property (psel_high_penable_must_high_check) else $error($stime, "\t\t FATAL: penable must be high after psel is high!\n");

endmodule

