/*TESTBENCH*/
program my_mem_pgm(my_mem_interface top_inf);

  	parameter SIZE=6;
    bit clk;
  	int error_count_q = 0;
    int error_count_ck = 0;
    //using assertion
    assert property (@(posedge clk) !(top_inf.write && top_inf.read))
    else begin
        error_count_ck <= error_count_ck + 1;
        $display("Write and read both are high");
    end

  	initial begin
    
      typedef struct {
        
        //16 bits of address
        bit [15:0] addr_to_read;
        //9 bits of data
        bit [8:0] data_to_write;
        //expected data read
        bit [8:0] expected_data_read;
        //actual data read
        bit [8:0] actual_data_read;
      
      }my_mem_struct;

   
    my_mem_struct memst[6];
    
    //intializing clk,read and write7
    top_inf.read<=0; top_inf.write<=0;
    
    //randomize addresses
    for(int i=0; i<SIZE; i++) begin
      memst[i].addr_to_read = $random; //storing random address
      #1 $display("Address [%0d] = %0d",i, memst[i].addr_to_read);
    end
    
    //randomize data
    for(int j=0; j<SIZE; j++) begin
      memst[j].data_to_write = $random; //storing random data
      #1 $display("Data [%0d] = %0d",j, memst[j].data_to_write);
    end

    //set write to 1 to start writing to memory
    top_inf.write<=1;

      for (int i = 0; i < 6; i++)
      begin
        top_inf.address <= memst[i].addr_to_read;
        #20;
        top_inf.data_in <= memst[i].data_to_write;
        #20;
      end
    //check the memst before shuffle
    $display("Data before shuffle:\n", memst);
    memst.shuffle();
    //check the memst before shuffle
    $display("Data after shuffle:\n", memst);

 //   @(top_inf.mem_clock);
    top_inf.write <= 0;
    
    //data expected
    for(int i=0; i < SIZE; i++) begin
      memst[i].expected_data_read = memst[i].data_to_write;
    end
    
//    @(top_inf.mem_clock)
    top_inf.read <= 1;

    //compare data out with data read expected
    $display("********* Starting Test*********");
    // data read in reverse order
    for(int i=SIZE-1; i>=0; i--) begin
      $display("Previous data out: %0d", top_inf.data_out);
      #10;
      top_inf.address <= memst[i].addr_to_read;
      #10;
      //display all variables
      $display("Data expected %0d", memst[i].expected_data_read);
      $display("Current data out %0d", top_inf.data_out);
      //adding to Queue
      memst[i].actual_data_read = top_inf.data_out; //adding data to queue

      if(top_inf.data_out !== memst[i].expected_data_read) begin
        $display("Error!!");
        error_count_q = error_count_q + 1;
        //test to test the checker
      end
      else begin
        $display("\ndata out %0d is equal to data expected.", top_inf.data_out); 
        $display("\n Read Success! \n");
      end
    end

    $display("Total Error Count: %0d\n", error_count_q);
    $display("*************** End Test *************");
    
    $display("\n********* Traversing Queue *********");
    //traverse actual_data_read queue
    for(int i=0; i<SIZE; i++) begin
      //data_read_queue.push_back(data_out);
      $display("\tactual_data_read[%0d]= %0d",i,memst[i].actual_data_read);
    end
    //assinging read and write to 1 for checker task
    top_inf.read <=1; top_inf.write <=1;
    
    $finish;
  end
    //vcd file generation and waveform enablement
    initial begin
      $vcdplusmemon;
      $vcdpluson;
      $dumpfile("dump.vcd");
      $dumpvars;
    end
    
    //end of module
endprogram
