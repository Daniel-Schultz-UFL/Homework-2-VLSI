/****************************************************************************
 * Author:
 * Desciption: TCP Client Controller
 ****************************************************************************/

 module tcp_client (
                    //INPUT
                    input clk,
                    input rst,
                    input[223:0] packet_in,
                    input go,
                    input fin,
                    //OUTPUT
                    output reg[223:0] packet_out);

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

    /* Grabbing the Input TCP Packet and setting the output TCP Packet 
     * should happen regardless of rst. Set outside of if rst else */

    /* Step 1: Grab input packet and decode signals coming from Sever */
    in_dest_port        = packet_in[TCP_DEST_PORT_ADDR:0];
    in_src_port         = packet_in[TCP_SRC_PORT_ADDR:TCP_DEST_PORT_ADDR+1];
    in_seq_num          = packet_in[TCP_SEQ_NUM:TCP_SRC_PORT_ADDR+1];
    in_ack_num          = packet_in[TCP_ACK_NUM:TCP_SEQ_NUM+1];
    in_window_size      = packet_in[TCP_WINDOW_SIZE:TCP_ACK_NUM+1];
    in_fin              = packet_in[TCP_FIN];
    in_syn              = packet_in[TCP_SYN];
    in_rst              = packet_in[TCP_RST];
    in_psh              = packet_in[TCP_PSH];
    in_ack              = packet_in[TCP_ACK];
    in_urg              = packet_in[TCP_URG];
    in_reserved_bits    = packet_in[TCP_RESERVED_BITS:TCP_URG+1];
    in_header_len       = packet_in[TCP_HEADER_LEN:TCP_RESERVED_BITS+1];
    in_urgent_pointer   = packet_in[TCP_URGENT_POINTER:TCP_HEADER_LEN+1];
    in_checksum         = packet_in[TCP_CHECKSUM:TCP_URGENT_POINTER+1];
    in_options          = packet_in[TCP_OPTIONS:TCP_CHECKSUM+1];
    in_data             = packet_in[TCP_DATA:TCP_OPTIONS+1]; 

    /* Step 2: Assign default values for output packet to Server
    packet_out[TCP_DEST_PORT_ADDR:0]                    = {16{1'b1}};
    packet_out[TCP_SRC_PORT_ADDR:TCP_DEST_PORT_ADDR+1]  = {16{1'b1}};
    packet_out[TCP_SEQ_NUM:TCP_SRC_PORT_ADDR+1]         = {32{1'b1}};
    packet_out[TCP_ACK_NUM:TCP_SEQ_NUM+1]               = {32{1'b1}};
    packet_out[TCP_WINDOW_SIZE:TCP_ACK_NUM+1]           = {16{1'b1}};
    packet_out[TCP_FIN]                                 = 1'b1;
    packet_out[TCP_SYN]                                 = 1'b1;
    packet_out[TCP_RST]                                 = 1'b1;
    packet_out[TCP_PSH]                                 = 1'b1;
    packet_out[TCP_ACK]                                 = 1'b1;
    packet_out[TCP_URG]                                 = 1'b1;
    packet_out[TCP_RESERVED_BITS:TCP_URG+1]             = {6{1'b1}};
    packet_out[TCP_HEADER_LEN:TCP_RESERVED_BITS+1]      = {4{1'b1}};
    packet_out[TCP_URGENT_POINTER:TCP_HEADER_LEN+1]     = {16{1'b1}};
    packet_out[TCP_CHECKSUM:TCP_URGENT_POINTER+1]       = {16{1'b1}};
    packet_out[TCP_OPTIONS:TCP_CHECKSUM+1]              = {32{1'b1}};
    packet_out[TCP_DATA:TCP_OPTIONS+1]                  = {32{1'b1}}; */

    /* Step 3: Determine the next state and override any TCP output bits */
    /* Hard reset */
    if (rst)    
      begin
      state <= START;
      
      //clear ouput registers
            out_dest_port      = {16{1'b0}};
            out_src_port       = {16{1'b0}};
            out_seq_num        = {32{1'b0}};
            out_ack_num        = {32{1'b0}};
            out_window_size    = {16{1'b0}};
            out_fin            = 1'b0;
            out_syn            = 1'b0;
            out_rst            = 1'b0;
            out_psh            = 1'b0;
            out_ack            = 1'b0;
            out_urg            = 1'b0;
            out_reserved_bits  = {6{1'b0}};
            out_header_len     = {4{1'b0}};
            out_urgent_pointer = {16{1'b0}};
            out_checksum       = {16{1'b0}};
            out_options        = {32{1'b0}};
            out_data           = {32{1'b0}};
      end
    else
      begin

      /* Finite State Machine */
      case(state)

      /* Await input from user */
        START : 
            begin
            //clear ouput registers
            out_dest_port      = {16{1'b0}};
            out_src_port       = {16{1'b0}};
            out_seq_num        = {32{1'b0}};
            out_ack_num        = {32{1'b0}};
            out_window_size    = {16{1'b0}};
            out_fin            = 1'b0;
            out_syn            = 1'b0;
            out_rst            = 1'b0;
            out_psh            = 1'b0;
            out_ack            = 1'b0;
            out_urg            = 1'b0;
            out_reserved_bits  = {6{1'b0}};
            out_header_len     = {4{1'b0}};
            out_urgent_pointer = {16{1'b0}};
            out_checksum       = {16{1'b0}};
            out_options        = {32{1'b0}};
            out_data           = {32{1'b0}};
            //Send syn message
            if (go)
                begin
                out_syn = 1'b1; /* Yes, then go next state */
                state = ACK_RCVD; /* Yes, then go next state */
                end
            else
                state = START; /* No, then keep listening */
            end
        
        ACK_RCVD : 
            begin
            /* Did we receive ACK from client? */
            if (in_ack)
                begin
                state = ESTABLISHED; /* Yes, go to establish and share data */
                out_ack = 1;
                end
            else
                state = ACK_RCVD; /* No, keep waiting for ack from client */
            end
        
        /* Connection made Server and Client */
        ESTABLISHED : 
            /* This is where we share data */
            begin
            //clear ack in case of server reset
            out_ack = 0;
            
            //send seq number to SERVER
            if  (packet_in[TCP_ACK]== 1)
            out_seq_num = packet_in[TCP_ACK_NUM:TCP_SEQ_NUM+1];            
    
    
             if (packet_in[TCP_RST])//Reset Client if the Server sends a reset
            state = START; /* No, go back and listen */           
            else if(in_fin)
            state = FIN_ACK_SEND;   /* Yes, go and send the FIN/ACK to server */
            /* Decide what variable will end the connection */
            else if(fin)
            begin
            state = FIN_SEND;
            end

            
            end
        
        /* Send the FIN and ACK to server */
        FIN_ACK_SEND:
            begin
            out_fin = 1;    /* FIN Flag */
            out_ack = 1;    /* ACK Flag */
            state = START; /* Go back to Listening */
            end

        /* Terminate connection between Client and Server */
        FIN_SEND :
            begin
            out_fin = 1;
            state = FIN_ACK_LISTEN;
            end

        /* Await FIN/ACK from the Server */
        FIN_ACK_LISTEN:
            begin
            
            if(in_fin && in_ack)
            state = START;
            end



      endcase
      end
    packet_out[TCP_DEST_PORT_ADDR:0]                    = out_dest_port;
    packet_out[TCP_SRC_PORT_ADDR:TCP_DEST_PORT_ADDR+1]  = out_src_port;
    packet_out[TCP_SEQ_NUM:TCP_SRC_PORT_ADDR+1]         = out_seq_num;
    packet_out[TCP_ACK_NUM:TCP_SEQ_NUM+1]               = out_ack_num;
    packet_out[TCP_WINDOW_SIZE:TCP_ACK_NUM+1]           = out_window_size;
    packet_out[TCP_FIN]                                 = out_fin;
    packet_out[TCP_SYN]                                 = out_syn;
    packet_out[TCP_RST]                                 = out_rst;
    packet_out[TCP_PSH]                                 = out_psh;
    packet_out[TCP_ACK]                                 = out_ack;
    packet_out[TCP_URG]                                 = out_urg;
    packet_out[TCP_RESERVED_BITS:TCP_URG+1]             = out_reserved_bits;
    packet_out[TCP_HEADER_LEN:TCP_RESERVED_BITS+1]      = out_header_len;
    packet_out[TCP_URGENT_POINTER:TCP_HEADER_LEN+1]     = out_urgent_pointer;
    packet_out[TCP_CHECKSUM:TCP_URGENT_POINTER+1]       = out_checksum;
    packet_out[TCP_OPTIONS:TCP_CHECKSUM+1]              = out_options;
    packet_out[TCP_DATA:TCP_OPTIONS+1]                  = out_data;    
      
      
    end


 endmodule
