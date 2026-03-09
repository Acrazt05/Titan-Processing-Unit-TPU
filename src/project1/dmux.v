module dmux(in,sel,a,b);
    input in, sel;
    output a, b;

    assign a = sel ? 0 : in;
    assign b = sel ? in : 0;
  
endmodule