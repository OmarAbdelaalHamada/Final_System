module CLK_GATE (
input      CLK_EN,
input      CLK,
output     GATED_CLK
);

//internal signals
reg     Latch_Out ;

//latch to hold the enable signal when clock is low
always @(CLK or CLK_EN)
 begin
  if(!CLK)      // active low
   begin
    Latch_Out <= CLK_EN ;
   end
 end

// AND gate to generate gated clock
assign  GATED_CLK = CLK && Latch_Out ;

endmodule