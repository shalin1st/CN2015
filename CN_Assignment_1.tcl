#Shalin Momin
#131049
#Computer networks

#Lansimulation
set ns [new Simulator]
#definecolorfordataflows
$ns color 1 Blue
$ns color 2 Red
#opentracefiles
set tracefile1 [open out.tr w]
set winfile [open winfile w]
$ns trace-all $tracefile1
#opennamfile
set namfile [open out.nam w]
$ns namtrace-all $namfile
#definethefinishprocedure
proc finish {} {
global ns tracefile1 namfile
$ns flush-trace
close $tracefile1
close $namfile
exec nam out.nam &
exit 0
}
#createsixnodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]
set n8 [$ns node]
set n9 [$ns node]
set n10 [$ns node]
#createlinksbetweenthenodes
$ns duplex-link $n0 $n1 2Mb 10ms DropTail
$ns duplex-link $n0 $n3 2Mb 10ms DropTail
$ns duplex-link $n3 $n2 2Mb 10ms DropTail
$ns duplex-link $n1 $n2 2Mb 100ms DropTail
#$ns duplex-link $n2 $n4 2Mb 100ms DropTail
#$ns duplex-link $n2 $n9 2Mb 100ms DropTail
$ns duplex-link $n4 $n5 2Mb 100ms DropTail
$ns duplex-link $n5 $n6 2Mb 100ms DropTail
$ns duplex-link $n6 $n7 2Mb 100ms DropTail
$ns duplex-link $n6 $n8 2Mb 100ms DropTail
$ns duplex-link $n9 $n10 2Mb 100ms DropTail

set lan [$ns newLan "$n2 $n4 $n9" 0.5Mb 40ms LL Queue/DropTail MAC/Csma/cd Channel]
#Givenodeposition
$ns duplex-link-op $n0 $n1 orient down
$ns duplex-link-op $n0 $n3 orient right
$ns duplex-link-op $n3 $n2 orient down
$ns duplex-link-op $n1 $n2 orient right
#$ns duplex-link-op $n2 $n4 orient top-top-right
#$ns duplex-link-op $n2 $n9 orient down-right
$ns duplex-link-op $n4 $n5 orient top-right
$ns duplex-link-op $n5 $n6 orient down-right
$ns duplex-link-op $n6 $n7 orient down-left
$ns duplex-link-op $n6 $n8 orient down-right
$ns duplex-link-op $n9 $n10 orient right

#setupTCPconnection
set tcp [new Agent/TCP/Newreno]
$ns attach-agent $n2 $tcp
set sink [new Agent/TCPSink/DelAck]
$ns attach-agent $n7 $sink
$ns connect $tcp $sink
$tcp set fid_ 1
$tcp set packet_size_ 552


#setftpovertcpconnection
set ftp [new Application/FTP]
$ftp attach-agent $tcp


#setupaUDPconnection
set udp1 [new Agent/UDP]
$ns attach-agent $n1 $udp1
set null [new Agent/Null]
$ns attach-agent $n10 $null
$ns connect $udp1 $null
$udp1 set fid_ 2

#

#setupaCBRoverUDPconnection
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp1
$cbr1 set type_ CBR
$cbr1 set packet_size_ 1000
$cbr1 set rate_ 0.01Mb
$cbr1 set random_ false
#
set udp2 [new Agent/UDP]
$ns attach-agent $n8 $udp2
set null [new Agent/Null]
$ns attach-agent $n0 $null
$ns connect $udp2 $null
$udp2 set fid_ 3
#
#setupaCBRoverUDPconnection
set cbr2 [new Application/Traffic/CBR]
$cbr2 attach-agent $udp2
$cbr2 set type_ CBR
$cbr2 set packet_size_ 1000
$cbr2 set rate_ 0.01Mb
$cbr2 set random_ false


#schedulingtheevents
$ns at 0.1 "$cbr1 start"
$ns at 0.5 "$ftp start"
$ns at 1.0 "$cbr2 start"
$ns at 3.5 "$cbr2 stop"
$ns at 4.0 "$ftp stop"
$ns at 4.5 "$cbr1 stop"
proc plotWindow {tcpSource file} 	{
global ns
set time 0.1
set now [$ns now]
set cwnd [ $tcpSource set cwnd_]
puts $file "$now $cwnd"
$ns at [expr $now+$time] "plotWindow $tcpSource $file"
}
$ns at 0.1 "plotWindow $tcp $winfile"
$ns at 125.0 "finish"
$ns run
