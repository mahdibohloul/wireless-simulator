Mac/802_11 set bandwidth_ [lindex $argv 0]
set error_rate [lindex $argv 1]
set dir [lindex $argv 2]


# set MESSAGE_PORT 42
# set BROADCAST_ADDR -1


#set val(chan)           Channel/WirelessChannel    ;#Channel Type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type



set val(mac)            Mac/802_11                 ;# MAC type
#set val(mac)            Mac                 ;# MAC type
#set val(mac)		Mac/Simple


set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         32768                         ;# max packet in ifq


set val(rp) AODV


set ns [new Simulator]

set tracefile [open "$dir/rts-data-ack.tr" w+]
$ns trace-all $tracefile
$ns eventtrace-all

set namfile [open "$dir/rts-data-ack.nam" w+]
$ns namtrace-all-wireless $namfile 800 500

# set up topography object
set topo       [new Topography]

$topo load_flatgrid 700 200

$ns color 3 green;
$ns color 8 red;
$ns color 1 black;
$ns color 7 purple;
$ns color 6 tan;
$ns color 2 orange;
$ns color 5 blue;
$ns color 4 yellow;
$ns color 9 pink;


# set up nodes
create-god 9


#set mac0 [new Mac/802_11]

$ns node-config -adhocRouting $val(rp) \
                -llType $val(ll) \
                -macType $val(mac) \
                -ifqType $val(ifq) \
                -ifqLen $val(ifqlen) \
                -antType $val(ant) \
                -propType $val(prop) \
                -phyType $val(netif) \
                -IncomingErrProc UniformErr \
                -OutgoingErrProc UniformErr \
		-channelType Channel/WirelessChannel \
                -topoInstance $topo \
                -agentTrace ON \
                -routerTrace OFF \
                -macTrace ON \
                -movementTrace OFF 


proc finish {} {
        global ns tracefile namfile val
        $ns flush-trace
        close $tracefile
        close $namfile

}

proc UniformErr {} {
	global error_rate
	set error_model [new ErrorModel]
	$error_model unit pkt
	$error_model set rate_ $error_rate
	$error_model ranvar [new RandomVariable/Uniform]
	return $error_model
}

for {set i 0} {$i < 9} {incr i} {
    set node_($i) [$ns node]
    $node_($i) random-motion 0
    $node_($i) color black
}

## Node B
$node_(0) set X_ 100
$node_(0) set Y_ 400
$node_(0) set Z_ 0

#Node A
$node_(1) set X_ 150
$node_(1) set Y_ 600
$node_(1) set Z_ 0

#Node D
$node_(2) set X_ 150
$node_(2) set Y_ 200
$node_(2) set Z_ 0

#Node C
$node_(3) set X_ 200
$node_(3) set Y_ 500
$node_(3) set Z_ 0

#Node E
$node_(4) set X_ 200
$node_(4) set Y_ 300
$node_(4) set Z_ 0

#Node G
$node_(5) set X_ 250
$node_(5) set Y_ 500
$node_(5) set Z_ 0

#Node F
$node_(6) set X_ 250
$node_(6) set Y_ 300
$node_(6) set Z_ 0

#Node H
$node_(7) set X_ 300
$node_(7) set Y_ 500
$node_(7) set Z_ 0

#Node L
$node_(8) set X_ 300
$node_(8) set Y_ 300
$node_(8) set Z_ 0

set dlUdp [new Agent/UDP]
set dlNull [new Agent/Null]

$ns attach-agent $node_(2) $dlUdp
$ns attach-agent $node_(8) $dlNull
$ns connect $dlUdp $dlNull

set dlCbr [new Application/Traffic/CBR]
$dlCbr set packetSize_ 512
$dlCbr set interval_ 0.01
$dlCbr set rate_ 200kb
$dlCbr attach-agent $dlUdp

$ns at 0.1 "$dlCbr start"
$ns at 20.0 "$dlCbr stop"



set ahUdp [new Agent/UDP]
set ahNull [new Agent/Null]

$ns attach-agent $node_(1) $ahUdp
$ns attach-agent $node_(7) $ahNull
$ns connect $ahUdp $ahNull

set ahCbr [new Application/Traffic/CBR]
$ahCbr set packetSize_ 512
$ahCbr set interval_ 0.01
$ahCbr set rate_ 200kb
$ahCbr attach-agent $ahUdp

$ns at 0.1 "$ahCbr start"
$ns at 20.0 "$ahCbr stop"

for {set i 0} {$i < 9} {incr i} {
    $ns initial_node_pos $node_($i) 30
    $ns at 20.0 "$node_($i) reset";
}

$ns at 20.0 "finish"
$ns at 20.1 "$ns halt"

# puts "Starting simulation...."

$ns run