/****************************************************************************
 * Author: 
 * Desciption: TCP Client Controller
 ****************************************************************************/

 module tcp_client (input clk, input rst, input[223:0] packet_in, 
                     output[223:0] packet_out);

    /* State Definitions */
    localparam
        STATE_00    = 4'b0000,
        STATE_01    = 4'b0001,
        STATE_02    = 4'b0010,
        STATE_03    = 4'b0011,
        STATE_04    = 4'b0100,
        STATE_05    = 4'b0101,
        STATE_06    = 4'b0110,
        STATE_07    = 4'b0111,
        STATE_08    = 4'b1000,
        STATE_09    = 4'b1001,
        STATE_10    = 4'b1010,
        STATE_11    = 4'b1011,
        STATE_12    = 4'b1100,
        STATE_13    = 4'b1101,
        STATE_14    = 4'b1110,
        STATE_15    = 4'b1111;

    /* Variable List */
    reg[3:0] state;

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

    /* Input Packet */
    reg[15:0] in_dest_port;
    reg[15:0] in_src_port;
    reg[31:0] in_seq_num;
    reg[31:0] in_ack_num;
    reg[15:0] in_window_size;
    reg in_fin;
    reg in_syn;
    reg in_rst;
    reg in_psh;
    reg in_ack;
    reg in_urg;
    reg[5:0] in_reserved_bits;
    reg[3:0] in_header_len;
    reg[15:0] in_urgent_pointer;
    reg[15:0] in_checksum;
    reg[31:0] in_options;
    reg[31:0] in_data;

    /* Output Packet */
    reg[15:0] out_dest_port;
    reg[15:0] out_src_port;
    reg[31:0] out_seq_num;
    reg[31:0] out_ack_num;
    reg[15:0] out_window_size;
    reg out_fin;
    reg out_syn;
    reg out_rst;
    reg out_psh;
    reg out_ack;
    reg out_urg;
    reg[5:0] out_reserved_bits;
    reg[3:0] out_header_len;
    reg[15:0] out_urgent_pointer;
    reg[15:0] out_checksum;
    reg[31:0] out_options;
    reg[31:0] out_data;


    /* State Machine */
    always @ (posedge clk) 
    begin
        if (rst)
          begin
          state <= STATE_00;
          end
        else
          begin
          $display("State = %d", state);
          /* Finite State Machine */
          case(state)
            STATE_00 : 
                begin
                state = STATE_01;
                end
            
            STATE_01 : 
                begin
                /* Await input from user (TestBench) to start */
                if(in_syn == 1)
                state = STATE_02;
                end
            
            STATE_02 : 
                begin
                /* Await SYN ACK Flag from Server */
                if(in_ack_num == 1)
                state = STATE_03;
                
                /* If reset received go back to State 1 */
                if(in_rst == 1)
                state = STATE_01;
                end
            
            /* Establish connection with server */
            STATE_03 : 
                begin

                /* If reset received go back to State 1 */
                if(in_rst == 1)
                state = STATE_01;

                /* Data Transfer between Client and Sever Complete */
                /* Endless loop awaiting Test Bench input or a FIN flag form the server */
                while(in_fin == 0)
                    /* Timeout if packets not within 3 packet attempts */ 
                    if(connectionCounter > 3)
                    /* Go to State 4 if counter reached */ 
                    out_fin = 1;
                    state = STATE_04;
                    connectionCounter++; /* Increment counter */
                
                if(in_fin == 1 && in_ack == 1)  
                state = STATE_04;
            
                
                /* Receive FIN flag from server */
                if(in_fin == 1)
                state = STATE_05;

                end
            
            /* Send FIN Flag to close connection */
            STATE_04 : 
                begin

                if(in_fin == 1 && in_ack == 1) 
                state = STATE_01; 

                end
            
            /* Send the FIN ACK flag to Server */
            STATE_05 : 
                begin

                out_fin = 1;
                out_ack = 1;

                state = STATE_01;
                end
            




            STATE_06 : 
                begin
                state = STATE_07;
                end
            STATE_07 : 
                begin
                state = STATE_08;
                end
            STATE_08 : 
                begin
                state = STATE_09;
                end
            STATE_09 : 
                begin
                state = STATE_10;
                end
            STATE_10 : 
                begin
                state = STATE_11;
                end
            STATE_11 : 
                begin
                state = STATE_12;
                end
            STATE_12 : 
                begin
                state = STATE_13;
                end
            STATE_13 : 
                begin
                state = STATE_14;
                end
            STATE_14 : 
                begin
                state = STATE_15;
                end
            STATE_15 : 
                begin
                state = STATE_00;
                end
          endcase
          end
    end


 endmodule
