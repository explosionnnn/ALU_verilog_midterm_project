`timescale 1ns/1ns
module hazard_unit( rs, rt,
                    IDEX_RegWrite, IDEX_wreg,
                    EXMEM_RegWrite, EXMEM_wreg,
                    MEMWB_RegWrite, MEMWB_wreg,
                    Stall );

input [4:0] rs, rt ;
input IDEX_RegWrite, EXMEM_RegWrite, MEMWB_RegWrite ;
input [4:0] IDEX_wreg, EXMEM_wreg, MEMWB_wreg ;
output Stall ;

wire rs_hzd, rt_hzd ;

assign rs_hzd = ( rs != 5'd0 ) &
                ( ( IDEX_RegWrite  & ( IDEX_wreg  == rs ) ) |
                  ( EXMEM_RegWrite & ( EXMEM_wreg == rs ) ) |
                  ( MEMWB_RegWrite & ( MEMWB_wreg == rs ) ) ) ;

assign rt_hzd = ( rt != 5'd0 ) &
                ( ( IDEX_RegWrite  & ( IDEX_wreg  == rt ) ) |
                  ( EXMEM_RegWrite & ( EXMEM_wreg == rt ) ) |
                  ( MEMWB_RegWrite & ( MEMWB_wreg == rt ) ) ) ;

assign Stall = rs_hzd | rt_hzd ;

endmodule
