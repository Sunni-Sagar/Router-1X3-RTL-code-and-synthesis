# Router-1X3-RTL-code and synthesis
### Router 1X3  RTL code and synthesis - Maven Silicon
# Top Level Block
![image](https://github.com/user-attachments/assets/63382ed2-419b-47da-bddb-213d4a3f9d79)

A device called a router is used to forward data packets between networks of computers. It is a layer 3 routing device in OSI. Incoming packets are routed to an output channel in accordance with the address field included in the packet header. 

## Introduction to Router
The router 1x3 is designed to operate on a packet-based protocol, and it uses data_in to receive network packets from the source LAN on a byte-by-byte basis at the posedge of the **clock**. A synchronous, active low reset is **resetn**.

Asserting **pkt_valid** indicates the beginning of a new packet, while de-asserting **pkt_valid** indicates the conclusion of the current packet. The concept uses a FIFO to store incoming packets based on their addresses. Three FIFOs are included in the architecture for each destination LAN.

The destination LANs monitor **vld_out_x **(x can be0,1, or2) during packet read operation, and then they assert **read_enb_x** (x can be0,1, or 2). The destination LANs use the channels **data_out_x** to read the packet (x can be 0, 1, or 2).

The signal busy indicator on a router may occasionally suggest that it is busy. In order to make the source wait to send the next packet byte, the busy signal is returned to the source local area network.

A parity check error detection technique has been implemented to verify the accuracy of the packet received by the router. The error signal is asserted if the internal parity determined by the router differs from the parity byte sent by the source LAN. This error signal is returned to the source local area network (LAN) so that it can monitor the same and send the packet again.

## Router Packet Format
![image](https://github.com/user-attachments/assets/ecb18017-8976-4acd-b158-5077e1e6d526)
