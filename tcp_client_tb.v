/***************************************************************************
 *
 ***************************************************************************/

 module tcp_client_tb;

    localparam period = 10;
    
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

    task send_server_syn;
        inout [223:0] tcp_packet;
        begin
            tcp_packet[TCP_SYN] = 1'b1;
        end
    endtask

    task send_server_ack;
        inout [223:0] tcp_packet;
        begin
            tcp_packet[TCP_ACK] = 1'b1;
        end
    endtask

    reg clk = 0;
    reg rst = 0;
    reg[223:0] packet_in = 224'b1;
    wire[223:0] packet_out;

    tcp_server DUT (.clk(clk), .rst(rst),
                    .packet_in(packet_in), .packet_out(packet_out));

    always #10 clk=!clk;

    initial
    begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tcp_client_tb);
        clk = 0;
        rst = 1'b1;
        #20 rst = 1'b0;
        #40 send_server_syn(packet_in);
        #40 send_server_ack(packet_in);
    end


    initial
    #360 $finish;

 endmodule
