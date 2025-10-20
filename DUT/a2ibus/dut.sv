//=====================================================================
// Description:
// This file wraps the dut_top
// Designer : lynnxie@sjtu.edu.cn
// Revision History
// V0 date:2024/11/13 Initial version, lynnxie@sjtu.edu.cn
//=====================================================================

module dut (
    icb_bus     icb,
    apb_bus     apb0,
    apb_bus     apb1,
    apb_bus     apb2,
    apb_bus     apb3
);

    dut_top i_dut(
        .icb_bus(       icb.slave       ),
        .apb_bus_0(     apb0.master     ),
        .apb_bus_1(     apb1.master     ),
        .apb_bus_2(     apb2.master     ),
        .apb_bus_3(     apb3.master     )
    );

// assertion modules
    bind dut_top icb_assertion icb_assertion_bind_dut_top (
       .icb(           icb.others      )
    );
    bind dut_top apb_assertion apb_assertion_bind_dut_top (
       .apb(           apb3.others     )
    );      

endmodule
