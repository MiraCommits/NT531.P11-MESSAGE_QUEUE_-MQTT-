#Create a simulator object
set ns [new Simulator]

#Define different colors for data flows (for NAM)
$ns color 1 blue
$ns color 2 red
$ns color 3 green
$ns color 4 black

#Open the NAM trace file
set nf [open scenario4b.nam w]
$ns namtrace-all $nf

#open the trace file
set tf [open scenario4b.tr w]
$ns trace-all $tf

#Define a 'finish' procedure
proc finish {} {
        global ns nf tf
        $ns flush-trace
	#Close the trace file
	close $tf
        #Close the NAM trace file
        close $nf
        #Execute NAM on the trace file
        exec nam scenario4b.nam &
        exit 0
}

#Create six nodes
for {set i 0} {$i < 6} {incr i} {
    set n$i [$ns node]
}

#Create links between the nodes
$ns duplex-link $n0 $n4 10Mb 20ms DropTail
$ns duplex-link $n1 $n4 10Mb 20ms DropTail
$ns duplex-link $n2 $n4 10Mb 20ms DropTail
$ns duplex-link $n3 $n4 100Mb 20ms DropTail
$ns duplex-link $n4 $n5 50Mb 10ms DropTail

#Set Queue Size of link (n2-n3) to 10
$ns queue-limit $n4 $n5 10

#Give node position (for NAM)
$ns duplex-link-op $n0 $n4 orient 315deg
$ns duplex-link-op $n1 $n4 orient 345deg
$ns duplex-link-op $n2 $n4 orient 15deg
$ns duplex-link-op $n3 $n4 orient 45deg

$ns duplex-link-op $n4 $n5 orient right

#Monitor the queue for link (n2-n3). (for NAM)
$ns duplex-link-op $n4 $n5 queuePos 0.5


#Setup a TCP connection from Node0 to Node5
set tcp1 [new Agent/TCP]
$tcp1 set class_ 2
$ns attach-agent $n0 $tcp1
set sink1 [new Agent/TCPSink]
$ns attach-agent $n5 $sink1
$ns connect $tcp1 $sink1
$tcp1 set fid_ 2

#Setup a TCP connection from Node1 to Node5
set tcp2 [new Agent/TCP]
$tcp2 set class_ 2
$ns attach-agent $n1 $tcp2
set sink2 [new Agent/TCPSink]
$ns attach-agent $n5 $sink2
$ns connect $tcp2 $sink2
$tcp2 set fid_ 1


#Setup a FTP over TCP connection from Node0 to Node5
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ftp1 set type_ FTP
$ftp1 set packet_size_ 1000

#Setup a FTP over TCP connection from Node1 to Node5
set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2
$ftp2 set type_ FTP
$ftp2 set packet_size_ 1000


#Setup a UDP connection from Node2 to Node5
set udp1 [new Agent/UDP]
$ns attach-agent $n2 $udp1
set null1 [new Agent/Null]
$ns attach-agent $n5 $null1
$ns connect $udp1 $null1
$udp1 set fid_ 3

#Setup a UDP connection from Node3 to Node5
set udp2 [new Agent/UDP]
$ns attach-agent $n3 $udp2
set null2 [new Agent/Null]
$ns attach-agent $n5 $null2
$ns connect $udp2 $null2
$udp2 set fid_ 4

#Setup a CBR over UDP connection from Node2 to Node5
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp1
$cbr1 set type_ CBR
$cbr1 set packet_size_ 1000
$cbr1 set rate_ 1mb
$cbr1 set random_ false

#Setup a CBR over UDP connection from Node3 to Node5
set cbr2 [new Application/Traffic/CBR]
$cbr2 attach-agent $udp2
$cbr2 set type_ CBR
$cbr2 set packet_size_ 1000
$cbr2 set rate_ 1mb
$cbr2 set random_ false

#Schedule events for the CBR and FTP agents
$ns at 0.1 "$ftp1 start"
$ns at 0.2 "$cbr2 start"
$ns at 1.0 "$ftp2 start"
$ns at 1.0 "$cbr1 start"
$ns at 4.5 "$ftp2 stop"
$ns at 5.0 "$ftp1 stop"
$ns at 5.0 "$cbr1 stop"
$ns at 5.0 "$cbr2 stop"

#Detach tcp and sink agents (not really necessary)
#$ns at 4.5 "$ns detach-agent $n1 $tcp2 ; $ns detach-agent $n5 $sink"
#$ns at 5.0 "$ns detach-agent $n0 $tcp1 ; $ns detach-agent $n5 $sink"

#Call the finish procedure after 5 seconds of simulation time
$ns at 5.5 "finish"

#Print CBR packet size and interval
#puts "CBR packet size = [$cbr set packet_size_]"
#puts "CBR interval = [$cbr set interval_]"

#Run the simulation
$ns run

