module TESTBENCH;

    localparam period = 10ns;
    
       /* State Definitions */
    localparam
        START         = 4'b0000,
        ACK_RCVD      = 4'b0001,
        ESTABLISHED   = 4'b0010,
        FIN_ACK_SEND  = 4'b0011,
        FIN_SEND      = 4'b0100,
        FIN_ACK_LISTEN= 4'b0101,
        STATE_06      = 4'b0110,
        STATE_07      = 4'b0111,
        STATE_08      = 4'b1000,
        STATE_09      = 4'b1001,
        STATE_10      = 4'b1010,
        STATE_11      = 4'b1011,
        STATE_12      = 4'b1100,
        STATE_13      = 4'b1101,
        STATE_14      = 4'b1110,
        STATE_15      = 4'b1111;
        
            /* Packet Address Locations */
    localparam
        TCP_DEST_PORT_ADDR  = 15,  /* WORD 0: 15-0    */
        TCP_SRC_PORT_ADDR   = 31,  /* WORD 0: 31-16   */
        TCP_SEQ_NUM         = 63,  /* WORD 1: 63-32   */
        TCP_ACK_NUM         = 95,  /* WORD 2: 95-64   */
        TCP_WINDOW_SIZE     = 111, /* WORD 3: 111-96  */
        TCP_FIN             = 112, /* WORD 3: 112     */
        TCP_SYN             = 113, /* WORD 3: 113     */
        TCP_RST             = 114, /* WORD 3: 114     */
        TCP_PSH             = 115, /* WORD 3: 115     */
        TCP_ACK             = 116, /* WORD 3: 116     */
        TCP_URG             = 117, /* WORD 3: 117     */
        TCP_RESERVED_BITS   = 123, /* WORD 3: 123-118 */
        TCP_HEADER_LEN      = 127, /* WORD 3: 127-124 */
        TCP_URGENT_POINTER  = 143, /* WORD 4: 143-128 */
        TCP_CHECKSUM        = 159, /* WORD 4: 159-144 */
        TCP_OPTIONS         = 191, /* WORD 5: 191-160 */
        TCP_DATA            = 223; /* WORD 6: 223-192 */
        
    // Setting initial memory
    reg clk = 0;
    reg rst = 0;
    reg go  = 0;
    reg fin = 0;
    reg[223:0] packet_in = 224'b0;
    reg[31:0] old_packet_seq_num = 0;
    reg[31:0] test = 0;
    wire[223:0] packet_out;
    


    tcp_client client (clk,rst,packet_in, go, fin, packet_out);

    always #10 clk=!clk;

    initial
    begin
        //Initialize the system
        clk = 0;
        rst = 1'b1;
        #20 rst = 1'b0;//turn off reset
        
        // Start sending data
        #30 go = 1'b1;
        
        //Check if we recieved sync, if so, move to next ACK_RCVD
        #40 
        begin
        go = 1'b0;
            if (packet_out[TCP_SYN] == 1)
            begin
                packet_in[TCP_SYN] = 1;
                packet_in[TCP_ACK] = 1;
            end
        end    
            
        //Commumcation has been established, reply with ACK number [PACKET 1]
        #50
        begin
        packet_in[TCP_ACK] = 0; //clear ACK
        
            //Check if a new packet has come and if so, send ack for next packet)
            if ((packet_out[TCP_SEQ_NUM:TCP_SRC_PORT_ADDR+1] != old_packet_seq_num)|| (packet_out[TCP_SEQ_NUM:TCP_SRC_PORT_ADDR+1] == 0))
            begin
                packet_in[TCP_ACK_NUM:TCP_SEQ_NUM+1]= packet_out[TCP_SEQ_NUM:TCP_SRC_PORT_ADDR+1] + 32;
                packet_in[TCP_ACK] = 1;
                test = packet_out[TCP_SEQ_NUM:TCP_SRC_PORT_ADDR+1] + 32;
            end
        end

        //Commumcation has been established, reply with ACK number [PACKET 2]        
        #60
        begin
        packet_in[TCP_ACK] = 0; //clear ACK
        
            //Check if a new packet has come and if so, send ack for next packet)
            if ((packet_out[TCP_SEQ_NUM:TCP_SRC_PORT_ADDR+1] != old_packet_seq_num)|| (packet_out[TCP_SEQ_NUM:TCP_SRC_PORT_ADDR+1] == 0))
            begin
                packet_in[TCP_ACK_NUM:TCP_SEQ_NUM+1]= packet_out[TCP_SEQ_NUM:TCP_SRC_PORT_ADDR+1] + 32;
                packet_in[TCP_ACK] = 1;
                test = packet_out[TCP_SEQ_NUM:TCP_SRC_PORT_ADDR+1] + 32;
            end
        end
 
         //Commumcation has been established, reply with ACK number [PACKET 3]       
        #70
        begin
        packet_in[TCP_ACK] = 0; //clear ACK
        
            //Check if a new packet has come and if so, send ack for next packet)
            if ((packet_out[TCP_SEQ_NUM:TCP_SRC_PORT_ADDR+1] != old_packet_seq_num)|| (packet_out[TCP_SEQ_NUM:TCP_SRC_PORT_ADDR+1] == 0))
            begin
                packet_in[TCP_ACK_NUM:TCP_SEQ_NUM+1]= packet_out[TCP_SEQ_NUM:TCP_SRC_PORT_ADDR+1] + 32;
                packet_in[TCP_ACK] = 1;
                test = packet_out[TCP_SEQ_NUM:TCP_SRC_PORT_ADDR+1] + 32;
            end
        end
        
        //Have the server send a reset packet
        //#80 packet_in[TCP_RST] = 1;  
        
        
        //Test Fin from server
//        #90
//        begin
//        packet_in[TCP_FIN] = 1; 
//        end
        
        //Test client to send Fin
        #100
        begin
            packet_in[TCP_ACK] = 0; //clear ACK
            fin = 1;
        end
         
        #110
        begin
         if (packet_out[TCP_FIN])
             begin
                 packet_in[TCP_ACK] = 1;
                 packet_in[TCP_FIN] = 1;
             end
         end
    end


    initial
    #700 $finish;

 endmodule
