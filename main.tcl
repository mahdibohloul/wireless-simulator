Mac/802_11 set bandwidth_ [lindex $argv 0]
Mac/802_11 set PER_ [lindex $argv 1]
set error_rate [lindex $argv 1]
set dir [lindex $argv 2]


# set MESSAGE_PORT 42
# set BROADCAST_ADDR -1


#set val(chan)           Channel/WirelessChannel    ;#Channel Type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type



set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(simulate_time)  100                        ;# seconds to run the simulation


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
                -IncomingErrProc GnrtErr \
                -OutgoingErrProc GnrtErr \
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
        exit 0
}

proc GnrtErr {} {
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
$node_(0) set Y_ 375
$node_(0) set Z_ 0
$ns at 0 "$node_(0) label B"

#Node A
$node_(1) set X_ 250
$node_(1) set Y_ 550
$node_(1) set Z_ 0
$ns at 0 "$node_(1) label A"

#Node D
$node_(2) set X_ 250
$node_(2) set Y_ 150
$node_(2) set Z_ 0
$ns at 0 "$node_(2) label D"

#Node C
$node_(3) set X_ 400
$node_(3) set Y_ 450
$node_(3) set Z_ 0
$ns at 0 "$node_(3) label C"

#Node E
$node_(4) set X_ 400
$node_(4) set Y_ 300
$node_(4) set Z_ 0
$ns at 0 "$node_(4) label E"

#Node G
$node_(5) set X_ 550
$node_(5) set Y_ 450
$node_(5) set Z_ 0
$ns at 0 "$node_(5) label G"

#Node F
$node_(6) set X_ 550
$node_(6) set Y_ 300
$node_(6) set Z_ 0
$ns at 0 "$node_(6) label F"

#Node H
$node_(7) set X_ 700
$node_(7) set Y_ 450
$node_(7) set Z_ 0
$ns at 0 "$node_(7) label H"

#Node L
$node_(8) set X_ 700
$node_(8) set Y_ 300
$node_(8) set Z_ 0
$ns at 0 "$node_(8) label L"


set dlUdp [new Agent/UDP]
set dlNull [new Agent/Null]

$ns attach-agent $node_(2) $dlUdp
$ns attach-agent $node_(8) $dlNull
$ns connect $dlUdp $dlNull

set dlCbr [new Application/Traffic/CBR]
$dlCbr set packetSize_ 512
$dlCbr set rate_ 200kb
$dlCbr attach-agent $dlUdp
$ns at 0 "$dlCbr start"
$ns at $val(simulate_time) "$dlCbr stop"


set ahUdp [new Agent/UDP]
set ahNull [new Agent/Null]

$ns attach-agent $node_(1) $ahUdp
$ns attach-agent $node_(7) $ahNull
$ns connect $ahUdp $ahNull

set ahCbr [new Application/Traffic/CBR]
$ahCbr set packetSize_ 512
$ahCbr set rate_ 200kb
$ahCbr attach-agent $ahUdp
$ns at 0 "$ahCbr start"
$ns at $val(simulate_time) "$ahCbr stop"



for {set i 0} {$i < 9} {incr i} {
    $ns initial_node_pos $node_($i) 40
    $ns at $val(simulate_time) "$node_($i) reset";
}

$ns at $val(simulate_time) "finish"
$ns at [expr $val(simulate_time) + 0.1] "$ns halt"

# puts "Starting simulation...."

$ns run