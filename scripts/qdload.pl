#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use Fcntl;

$| = 1;

my @crcTable = (
    0x0000, 0x1189, 0x2312, 0x329b, 0x4624, 0x57ad, 0x6536, 0x74bf,
    0x8c48, 0x9dc1, 0xaf5a, 0xbed3, 0xca6c, 0xdbe5, 0xe97e, 0xf8f7,
    0x1081, 0x0108, 0x3393, 0x221a, 0x56a5, 0x472c, 0x75b7, 0x643e,
    0x9cc9, 0x8d40, 0xbfdb, 0xae52, 0xdaed, 0xcb64, 0xf9ff, 0xe876,
    0x2102, 0x308b, 0x0210, 0x1399, 0x6726, 0x76af, 0x4434, 0x55bd,
    0xad4a, 0xbcc3, 0x8e58, 0x9fd1, 0xeb6e, 0xfae7, 0xc87c, 0xd9f5,
    0x3183, 0x200a, 0x1291, 0x0318, 0x77a7, 0x662e, 0x54b5, 0x453c,
    0xbdcb, 0xac42, 0x9ed9, 0x8f50, 0xfbef, 0xea66, 0xd8fd, 0xc974,
    0x4204, 0x538d, 0x6116, 0x709f, 0x0420, 0x15a9, 0x2732, 0x36bb,
    0xce4c, 0xdfc5, 0xed5e, 0xfcd7, 0x8868, 0x99e1, 0xab7a, 0xbaf3,
    0x5285, 0x430c, 0x7197, 0x601e, 0x14a1, 0x0528, 0x37b3, 0x263a,
    0xdecd, 0xcf44, 0xfddf, 0xec56, 0x98e9, 0x8960, 0xbbfb, 0xaa72,
    0x6306, 0x728f, 0x4014, 0x519d, 0x2522, 0x34ab, 0x0630, 0x17b9,
    0xef4e, 0xfec7, 0xcc5c, 0xddd5, 0xa96a, 0xb8e3, 0x8a78, 0x9bf1,
    0x7387, 0x620e, 0x5095, 0x411c, 0x35a3, 0x242a, 0x16b1, 0x0738,
    0xffcf, 0xee46, 0xdcdd, 0xcd54, 0xb9eb, 0xa862, 0x9af9, 0x8b70,
    0x8408, 0x9581, 0xa71a, 0xb693, 0xc22c, 0xd3a5, 0xe13e, 0xf0b7,
    0x0840, 0x19c9, 0x2b52, 0x3adb, 0x4e64, 0x5fed, 0x6d76, 0x7cff,
    0x9489, 0x8500, 0xb79b, 0xa612, 0xd2ad, 0xc324, 0xf1bf, 0xe036,
    0x18c1, 0x0948, 0x3bd3, 0x2a5a, 0x5ee5, 0x4f6c, 0x7df7, 0x6c7e,
    0xa50a, 0xb483, 0x8618, 0x9791, 0xe32e, 0xf2a7, 0xc03c, 0xd1b5,
    0x2942, 0x38cb, 0x0a50, 0x1bd9, 0x6f66, 0x7eef, 0x4c74, 0x5dfd,
    0xb58b, 0xa402, 0x9699, 0x8710, 0xf3af, 0xe226, 0xd0bd, 0xc134,
    0x39c3, 0x284a, 0x1ad1, 0x0b58, 0x7fe7, 0x6e6e, 0x5cf5, 0x4d7c,
    0xc60c, 0xd785, 0xe51e, 0xf497, 0x8028, 0x91a1, 0xa33a, 0xb2b3,
    0x4a44, 0x5bcd, 0x6956, 0x78df, 0x0c60, 0x1de9, 0x2f72, 0x3efb,
    0xd68d, 0xc704, 0xf59f, 0xe416, 0x90a9, 0x8120, 0xb3bb, 0xa232,
    0x5ac5, 0x4b4c, 0x79d7, 0x685e, 0x1ce1, 0x0d68, 0x3ff3, 0x2e7a,
    0xe70e, 0xf687, 0xc41c, 0xd595, 0xa12a, 0xb0a3, 0x8238, 0x93b1,
    0x6b46, 0x7acf, 0x4854, 0x59dd, 0x2d62, 0x3ceb, 0x0e70, 0x1ff9,
    0xf78f, 0xe606, 0xd49d, 0xc514, 0xb1ab, 0xa022, 0x92b9, 0x8330,
    0x7bc7, 0x6a4e, 0x58d5, 0x495c, 0x3de3, 0x2c6a, 0x1ef1, 0x0f78
);

sub writeMagic {
    my $fd = shift;

    return undef
      if (
        !sendPacket(
            $fd,
            deserialize(
"01 51 43 4f 4d 20 66 61 73 74 20 64 6f 77 6e 6c 6f 61 64 20 70 72 6f 74 6f 63 6f 6c 20 68 6f 73 74 03 03 09"
            )
        )
      );

    return 1;
}

sub writeChunk {
    my $fd      = shift;
    my $address = shift;
    my $chunk   = shift;

    my $length = length($chunk);
    my $response;

    #print "Writing chunk...\n";
    if (
        !sendPacket(
            $fd,
            deserialize(
                    "0f "
                  . serial32($address) . " "
                  . serial16($length) . " "
                  . serialize($chunk)
            )
        )
      )
    {
        print "Failed to send chunk.\n";
        return undef;
    }
    if ( !( $response = readPacket( $fd, 2.0 ) ) ) {
        print "Failed to get response.\n";
        return undef;
    }

    my @responseBytes = unpack( 'C*', $response );
    if ( scalar @responseBytes != 1 || $responseBytes[0] != 2 ) {
        print "Invalid Response: ", serialize($response), "\n";
        return undef;
    }
    return 1;
}

sub writeChunk2 {
    my $fd             = shift;
    my $address        = shift;
    my $chunk          = shift;
    my $sentPacketsRef = shift;

    my $length = length($chunk);
    my $response;

    #print "Writing chunk...\n";
    if (
        !sendPacket(
            $fd,
            deserialize(
                "07 " . serial32le($address) . " " . serialize($chunk)
            )
        )
      )
    {
        print "Failed to send chunk.\n";
        return undef;
    }
    $sentPacketsRef->{ sprintf( "%0.8x", $address ) } = 1;

    my $outstanding = scalar keys %{$sentPacketsRef};
    my $acktimeout;

    if ( $outstanding > 8 ) {
        $acktimeout = 2.0;
    }
    elsif ( $outstanding > 4 ) {
        $acktimeout = 0.25;
    }
    else {
        $acktimeout = 0.01;
    }

    $acktimeout = 10.0;

    while ( $response = readPacket( $fd, $acktimeout ) ) {
        my @responseBytes = unpack( 'C*', $response );
        if ( scalar @responseBytes != 5 || $responseBytes[0] != 8 ) {
            print "Invalid Response: ", serialize($response), "\n";
            exit 1;
        }

        my $ackpacket;
        $ackpacket = sprintf(
            '%.2x%.2x%.2x%.2x',
            $responseBytes[4], $responseBytes[3],
            $responseBytes[2], $responseBytes[1]
        );

        delete $sentPacketsRef->{$ackpacket};

        $outstanding = scalar keys %{$sentPacketsRef};

        print "Response: ACK 0x", $ackpacket, " (outstanding: ",
          $outstanding, ")\n";
        if ( $outstanding == 0 ) {
            $acktimeout = 0.0001;
        }
    }
    return 1;
}

sub uploadFile {
    my $fd       = shift;
    my $address  = shift;
    my $filename = shift;

    local $/ = undef;

    return undef if ( !open( FILE, $filename ) );
    my $data = <FILE>;
    close FILE;

    while ( length $data ) {
        my $chunk = substr( $data, 0, 1024 );

        my $restOfData =
          substr( $data, length($chunk), length($data) - length($chunk) );

        print "Writing ", length($chunk), " bytes to 0x",
          sprintf( '%.8x', $address ), "; ", length($restOfData),
          " bytes left.\n";

        if ( !writeChunk( $fd, $address, $chunk ) ) {
            print "uploadFile failed.\n";
            exit 1;
        }

        $address += length($chunk);
        $data = $restOfData;
    }
    return 1;
}

sub uploadFile2 {
    my $fd       = shift;
    my $address  = shift;
    my $filename = shift;
    my $response;

    my %sentPackets = ();

    local $/ = undef;

    return undef if ( !open( FILE, $filename ) );
    my $data = <FILE>;
    close FILE;

    while ( length $data ) {
        my $chunk = substr( $data, 0, 1024 );

        my $restOfData =
          substr( $data, length($chunk), length($data) - length($chunk) );

        print "Writing ", length($chunk), " bytes to 0x",
          sprintf( '%.8x', $address ), "; ", length($restOfData),
          " bytes left.\n";

        return undef
          if ( !writeChunk2( $fd, $address, $chunk, \%sentPackets ) );

        $address += length($chunk);
        $data = $restOfData;

        #select(undef, undef, undef, 0.1);
    }

    my $numout = scalar keys %sentPackets;

    while ( $numout > 0 ) {
        if ( !( $response = readPacket( $fd, 5.0 ) ) ) {
            print "Failed to receive ACK for ", $numout, " packets\n";
            foreach my $packet ( keys %sentPackets ) {
                print "Outstanding: 0x", $packet, "\n";
            }
            exit 1;
        }

        my @responseBytes = unpack( 'C*', $response );
        if ( scalar @responseBytes != 5 || $responseBytes[0] != 8 ) {
            print "Invalid Response: ", serialize($response), "\n";
            exit 1;
        }

        my $ackpacket;
        $ackpacket = sprintf(
            '%.2x%.2x%.2x%.2x',
            $responseBytes[4], $responseBytes[3],
            $responseBytes[2], $responseBytes[1]
        );

        delete $sentPackets{$ackpacket};
        $numout = scalar keys %sentPackets;
        print "Response: ACK 0x", $ackpacket, " (outstanding: ", $numout, ")\n";
    }

    return 1;
}

sub getSoftwareVersion {
    my $fd = shift;
    my $response;
    return undef if ( !sendPacket( $fd, deserialize("0c") ) );

    return undef if ( !( $response = readPacket($fd) ) );
    my @responseBytes = unpack( 'C*', $response );
    if ( $responseBytes[0] != 0x0d ) {
        print "Invalid Response: ", serialize($response), "\n";
        return undef;
    }
    return pack( 'C*',
        map { hex } split( /\s/, serialize( substr( $response, 2 ) ) ) );
}

sub setupTTY {
    my $tty;
    my $fd;
    my @usbDevices;

    my @devices =
      grep { !/\:/ && !/usb/ }
      map { ( split( /\//, $_ ) )[-1] } glob '/sys/bus/usb/devices/*';

    foreach my $device (@devices) {
        my $product = getFile("/sys/bus/usb/devices/$device/idProduct");
        my $vendor  = getFile("/sys/bus/usb/devices/$device/idVendor");

        next if ( !defined $product || !defined $vendor );

        if ( $vendor eq '05c6' && $product eq '9008' ) {

            # it's us.
            my @drivers = grep /^$device:\d+\.\d+$/,
              map { ( split( /\//, $_ ) )[-1] }
              glob "/sys/bus/usb/devices/$device/$device:*";

            foreach my $driver (@drivers) {

                my @ttys =
                  map { ( split( /\//, $_ ) )[-1] }
                  glob "/sys/bus/usb/devices/$device/$driver/tty*";

                if ( scalar @ttys == 1 ) {
                    $tty = "/dev/$ttys[0]";
                }
            }
        }
    }

    if ( defined $tty ) {
        system "/bin/stty raw -iexten -echo < $tty";
        return undef if ( !sysopen( $fd, $tty, O_RDWR | O_SYNC ) );
        return ( $fd, $tty );
    }
    return undef;
}

sub getFile {
    my $file = shift;

    local $/ = undef;

    return undef if ( !open( FILE, $file ) );

    my $content = <FILE>;
    $/ = "\n";
    close FILE;
    chomp $content;
    return $content;
}

sub execute {
    my $fd      = shift;
    my $address = shift;
    my $response;

    if ( !sendPacket( $fd, deserialize( "05 " . serial32($address) ) ) ) {
        print "Failed to send packed\n";
        return undef;
    }
    if ( !( $response = readPacket( $fd, 5.0 ) ) ) {
        print "Failed to get response.\n";
        return undef;
    }

    my @responseBytes = unpack( 'C*', $response );
    if ( scalar @responseBytes != 1 || $responseBytes[0] != 2 ) {
        print "Invalid Response: ", serialize($response), "\n";
        exit 1;
    }
    return 1;
}

sub serialize {
    my $buffer = shift;

    return join( ' ', map { sprintf( '%.2x', $_ ) } unpack( 'C*', $buffer ) );
}

sub deserialize {
    my $buffer = shift;

    return pack( 'C*', map { hex } split( /\s+/, $buffer ) );
}

sub crcByte {
    my $crc = shift;
    my $c   = shift;

    return ( ( $crc >> 8 ) & 0xffff ) ^ $crcTable[ ( $crc ^ $c ) & 0xff ];
}

sub crc {
    my $crc    = shift;
    my $buffer = shift;

    my @bytes = unpack( 'C*', $buffer );

    foreach (@bytes) {
        $crc = crcByte( $crc, $_ );
    }
    return ~$crc & 0xffff;
}

sub swap16 {
    my $short = shift;

    return ( ( $short << 8 ) | ( $short >> 8 ) ) & 0xffff;
}

sub swap32 {
    my $long = shift;

    return ( ( $long << 24 ) | ( ( $long & 0xff00 ) << 8 ) |
          ( ( $long & 0xff0000 ) >> 8 ) | ( $long >> 24 ) );
}

sub setupPacket {
    my $packet = shift;

    my $crc = swap16( crc( 0xffff, $packet ) );
    return deserialize( "7e "
          . serialize( escape( $packet . deserialize( serial16($crc) ) ) )
          . " 7e" );
}

sub escape {
    my $buffer = shift;
    my @bytes = unpack( 'C*', $buffer );
    my @newBytes;
    foreach my $byte (@bytes) {
        if ( $byte == 0x7e ) {
            push @newBytes, 0x7d;
            push @newBytes, 0x5e;
        }
        elsif ( $byte == 0x7d ) {
            push @newBytes, 0x7d;
            push @newBytes, 0x5d;
        }
        else {
            push @newBytes, $byte;
        }
    }

    return pack( 'C*', @newBytes );
}

sub unescape {
    my $buffer = shift;
    my @bytes = unpack( 'C*', $buffer );
    my @newBytes;
    my $escape = 0;

    foreach my $byte (@bytes) {
        if ($escape) {
            if ( $byte == 0x5e ) {
                push @newBytes, 0x7e;
            }
            elsif ( $byte == 0x5d ) {
                push @newBytes, 0x7d;
            }
            else {
                print "Fatal error unescaping buffer!\n";
                return undef;
            }
            $escape = 0;
        }
        else {
            if ( $byte == 0x7d ) {
                $escape = 1;
            }
            else {
                push @newBytes, $byte;
            }
        }
    }
    return pack( 'C*', @newBytes );
}

sub serial16le {
    my $short = shift;
    my $lbyte = $short & 0xff;
    my $hbyte = $short >> 8;

    return sprintf( '%.2x %.2x', $lbyte, $hbyte );
}

sub serial32le {
    my $long = shift;

    my $lshort = $long & 0xffff;
    my $hshort = $long >> 16;

    return serial16le($lshort) . ' ' . serial16le($hshort);
}

sub serial16 {
    my $short = shift;
    my $lbyte = $short & 0xff;
    my $hbyte = $short >> 8;

    return sprintf( '%.2x %.2x', $hbyte, $lbyte );
}

sub serial32 {
    my $long = shift;

    my $lshort = $long & 0xffff;
    my $hshort = $long >> 16;

    return serial16($hshort) . ' ' . serial16($lshort);
}

sub readPacket {
    my $fd      = shift;
    my $timeout = shift;

    my $rfhbits = "";
    my $byte;

    if ( defined($timeout) ) {
        vec( $rfhbits, fileno($fd), 1 ) = 1;
        return undef unless select( $rfhbits, undef, undef, $timeout ) >= 0;
        return undef unless vec( $rfhbits, fileno($fd), 1 );
    }

    my $retval = sysread( $fd, $byte, 1 );

    if ( 0 && !$retval ) {
        print "readPacket_retval: $retval\n";
        print "$!\n";
    }

    return undef if ( !$retval );
    return undef if ( unpack( 'C', $byte ) != 0x7e );

    my @bytes;

    while (1) {
        $retval = sysread( $fd, $byte, 1 );
        if ( !$retval ) {
            if (0) {
                print "retval (while): $retval\n";
                print "$!\n";
            }
            return undef;
        }
        last if ( unpack( 'C', $byte ) == 0x7e );
        push @bytes, unpack( 'C', $byte );
    }
    my $buffer = unescape( pack( 'C*', @bytes ) );

    #print "RECEIVED: " . serialize($buffer) . "\n";
    @bytes = unpack( 'C*', $buffer );
    pop @bytes;
    pop @bytes;
    return deserialize( join( ' ', map { sprintf( '%.2x', $_ ) } @bytes ) );
}

sub sendPacket {
    my $fd     = shift;
    my $buffer = shift;

    #print "SENDING: ", serialize(setupPacket($buffer)), "\n";

    my $retval =
      syswrite( $fd, setupPacket($buffer), length( setupPacket($buffer) ) );

    if ( !$retval ) {
        print "$!\n";
    }

    return undef if ( !$retval );
    return 1;
}

sub doMagic {
    my $fd = shift;
    my $response;
    print "Sending MAGIC...\n";
    writeMagic($fd);
    my $haveGoodResponse    = 0;
    my $haveErrorResponse   = 0;
    my $haveUnknownResponse = 0;
    while ( $response = readPacket( $fd, 2 ) ) {
        my @responseBytes = unpack( 'C*', $response );
        if ( scalar @responseBytes > 35 && $responseBytes[0] == 0x02 ) {
            my $magicCodeCheck = "QCOM fast download protocol targ";
            my $magicCodeRecvd = substr( $response, 1, 32 );
            if ( $magicCodeRecvd eq $magicCodeCheck ) {
                $haveGoodResponse = 1;
            }
        }
        elsif ( $responseBytes[0] == 0x0e ) {

            # msg
            my $msg = pack( 'C*',
                map { hex }
                  split( /\s/, serialize( substr( $response, 1 ) ) ) );
            $msg =~ tr/\n/ /;
            $msg =~ tr/\r/ /;
            print "MSG: ", $msg, "\n";
        }
        elsif ( $responseBytes[0] == 0x0d ) {

            # error
            $haveErrorResponse = 1;
            my $msg = pack( 'C*',
                map { hex }
                  split( /\s/, serialize( substr( $response, 5 ) ) ) );
            $msg =~ tr/\n//d;
            $msg =~ tr/\r//d;
            print "ERROR: ", $msg, "\n";
        }
        else {
            $haveUnknownResponse = 1;
            print "Response: ", serialize($response), "\n";
        }
    }
    if (   $haveGoodResponse != 1
        || $haveErrorResponse == 1
        || $haveUnknownResponse == 1 )
    {
        print "Invalid MAGIC response.\n";
        exit 1;
    }
}

sub doSoftwareVersion {
    my $fd = shift;
    my $response;
    print "Requesting SoftwareVersion...\n";
    my $swver = getSoftwareVersion($fd);
    if ( !defined $swver ) {
        print "Failed to get software version\n";
        exit 1;
    }
    print "Version: $swver\n";
}

sub doRequestDload {
    my $fd = shift;
    my $response;
    print "Requesting Dload...\n";
    if ( !sendPacket( $fd, deserialize("3a") ) ) {
        print "Failed requestDload\n";
        exit 1;
    }
    print "requestDload send ok\n";

    if ( !( $response = readPacket($fd) ) ) {
        print "Failed to read response.\n";
        exit 1;
    }
    print "Param: ", serialize($response), "\n";
}

sub doReboot {
    my $fd = shift;
    my $response;
    print "Requesting Reboot...\n";
    if ( !sendPacket( $fd, deserialize("0a") ) ) {
        print "Failed requestReboot\n";
        exit 1;
    }
    print "requestReboot send ok\n";

    if ( !( $response = readPacket($fd) ) ) {
        print "Failed to read response.\n";
        exit 1;
    }
    print "Param: ", serialize($response), "\n";
}

sub doRequestParam {
    my $fd = shift;
    my $response;
    print "Requesting Params...\n";
    if ( !sendPacket( $fd, deserialize("07") ) ) {
        print "Failed requestParam\n";
        exit 1;
    }

    if ( !( $response = readPacket($fd) ) ) {
        print "Failed to read response.\n";
        exit 1;
    }

    my @responseBytes = unpack( 'C*', $response );
    if ( $responseBytes[0] != 8 ) {
        print "Invalid Response: ", serialize($response), "\n";
        exit 1;
    }
    print "Params: ", serialize( substr( $response, 1 ) ), "\n";
}

#####
##### second stage cmds
#####

sub doCloseFlush {
    my $fd = shift;
    my $response;
    print "Sending CloseFlush...\n";
    if ( !sendPacket( $fd, deserialize("15") ) ) {
        print "Failed CloseFlush\n";
        exit 1;
    }

    if ( !( $response = readPacket( $fd, 2.0 ) ) ) {
        print "Failed to read response.\n";
        exit 1;
    }

    my @responseBytes = unpack( 'C*', $response );
    if ( scalar @responseBytes != 1 || $responseBytes[0] != 0x16 ) {
        print "Invalid Response: ", serialize($response), "\n";
        exit 1;
    }
}

sub doSecureMode {
    my $fd = shift;
    my $response;
    print "Sending secureMode...\n";
    if ( !sendPacket( $fd, deserialize("17 01") ) ) {
        print "Failed secureMode\n";
        exit 1;
    }

    if ( !( $response = readPacket( $fd, 2.0 ) ) ) {
        print "Failed to read response.\n";
        exit 1;
    }

    my @responseBytes = unpack( 'C*', $response );
    if ( scalar @responseBytes != 1 || $responseBytes[0] != 0x18 ) {
        print "Invalid Response: ", serialize($response), "\n";
        exit 1;
    }
}

sub doOpenMulti {
    my $fd = shift;
    my $response;
    print "Sending openMulti ...\n";
    if ( !sendPacket( $fd, deserialize("1b 21") ) ) {
        print "Failed openMulti\n";
        exit 1;
    }
    my $haveGoodResponse    = 0;
    my $haveErrorResponse   = 0;
    my $haveUnknownResponse = 0;
    while ( $response = readPacket( $fd, 2 ) ) {
        my @responseBytes = unpack( 'C*', $response );
        if (   scalar @responseBytes == 2
            && $responseBytes[0] == 0x1c
            && $responseBytes[1] == 0 )
        {
            $haveGoodResponse = 1;
        }
        elsif ( $responseBytes[0] == 0x0e ) {

            # msg
            my $msg = pack( 'C*',
                map { hex }
                  split( /\s/, serialize( substr( $response, 1 ) ) ) );
            $msg =~ tr/\n/ /;
            $msg =~ tr/\r/ /;
            print "MSG: ", $msg, "\n";
        }
        elsif ( $responseBytes[0] == 0x0d ) {

            # error
            $haveErrorResponse = 1;
            my $msg = pack( 'C*',
                map { hex }
                  split( /\s/, serialize( substr( $response, 5 ) ) ) );
            $msg =~ tr/\n//d;
            $msg =~ tr/\r//d;
            print "ERROR: ", $msg, "\n";
        }
        else {
            $haveUnknownResponse = 1;
            print "Response: ", serialize($response), "\n";
        }
    }
    if (   $haveGoodResponse != 1
        || $haveErrorResponse == 1
        || $haveUnknownResponse == 1 )
    {
        print "Invalid openMulti response.\n";
        exit 1;
    }
}

sub doReset2 {
    my $fd = shift;
    my $response;
    print "Requesting Reset...\n";
    if ( !sendPacket( $fd, deserialize("0b") ) ) {
        print "Failed doReset\n";
        exit 1;
    }

    if ( !( $response = readPacket( $fd, 2.0 ) ) ) {
        print "Failed to read response.\n";
        exit 1;
    }

    my @responseBytes = unpack( 'C*', $response );
    if ( scalar @responseBytes != 1 || $responseBytes[0] != 0x0c ) {
        print "Invalid Response: ", serialize($response), "\n";
        exit 1;
    }
}

###
### main stages
###

sub doStage1 {
    my $fname = shift;
    my $retval;
    my $response;
    my ( $fd, $tty ) = setupTTY();

    if ( !defined $fd ) {
        print "Failed to find/open TTY.\n";
        exit 1;
    }

    while ( $response = readPacket( $fd, 0.1 ) ) {
        print "Ignoring response: ", serialize($response), "\n";
    }

    doSoftwareVersion($fd);

    doRequestParam($fd);

    print "Uploading file '", $fname, "' to QDLOAD...\n";
    exit 1 if !defined( uploadFile( $fd, 0x2a000000, $fname ) );

    print "Executing file...\n";
    execute( $fd, 0x2a000000 );
    close($fd);
}

sub doStage2 {
    my $laddr  = shift;
    my $lfname = shift;
    my $retval;
    my $response;
    my ( $fd, $tty ) = setupTTY();

    if ( !defined $fd ) {
        print "Failed to find/open TTY.\n";
        exit 1;
    }

    doMagic($fd);

    #closeFlush($fd);
    doSecureMode($fd);
    doOpenMulti($fd);
    print "Uploading file '", $lfname, "'...\n";
    uploadFile2( $fd, $laddr, $lfname );
    doCloseFlush($fd);
    ###doReset2($fd);
    close($fd);
}

sub doResetStage {
    my $retval;
    my $response;
    my ( $fd, $tty ) = setupTTY();

    if ( !defined $fd ) {
        print "Failed to find/open TTY.\n";
        exit 1;
    }

    doReset2($fd);

    close($fd);
}

sub doHelloCmd {
    my $cmd = shift;
    my $retval;
    my $response;
    my ( $fd, $tty ) = setupTTY();

    if ( !defined $fd ) {
        print "Failed to find/open TTY.\n";
        exit 1;
    }

    doMagic($fd);

    close($fd);
}

sub doTestCmd {
    my $cmd = shift;
    my $retval;
    my $response;
    my ( $fd, $tty ) = setupTTY();

    if ( !defined $fd ) {
        print "Failed to find/open TTY.\n";
        exit 1;
    }

    print "Sending cmd '", $cmd, "'\n";
    if ( !sendPacket( $fd, deserialize($cmd) ) ) {
        print "Failed send\n";
        exit 1;
    }

    while ( $response = readPacket( $fd, 2 ) ) {
        my @responseBytes = unpack( 'C*', $response );
        if ( $responseBytes[0] == 0x0e ) {

            # msg
            my $msg = pack( 'C*',
                map { hex }
                  split( /\s/, serialize( substr( $response, 1 ) ) ) );
            $msg =~ tr/\n/ /;
            $msg =~ tr/\r/ /;
            print "MSG: ", $msg, "\n";
        }
        elsif ( $responseBytes[0] == 0x0d ) {

            # error
            my $msg = pack( 'C*',
                map { hex }
                  split( /\s/, serialize( substr( $response, 5 ) ) ) );
            $msg =~ tr/\n//d;
            $msg =~ tr/\r//d;
            print "ERROR: ", $msg, "\n";
        }
        else {
            print "Response: ", serialize($response), "\n";
        }
    }

    close($fd);
}

sub doUsage {
    print "Usage: qdload --pfile <stage1_bin>\n";
    print "            | --lfile <stage2_file>\n";
    print "            | --lfile <stage2_file> --laddr <stage2_load_addr>\n";
    print "            | --lreset\n";
}

###
### main
###

my $opts_result;
my $opts_pfile;
my $opts_lfile;
my $opts_laddr;
my $opts_lreset;
my $opts_testcmd;
my $opts_hellocmd;

$opts_result = GetOptions(
    "pfile=s"   => \$opts_pfile,
    "lfile=s"   => \$opts_lfile,
    "laddr=o"   => \$opts_laddr,
    "testcmd=s" => \$opts_testcmd,
    "hello"     => \$opts_hellocmd,
    "lreset"    => \$opts_lreset
);

my $num_remaining_args = $#ARGV + 1;

if ( $num_remaining_args > 0 ) {
    doUsage();
    exit(1);
}

if (   !defined($opts_pfile)
    && !defined($opts_lfile)
    && !defined($opts_lreset)
    && !defined($opts_hellocmd)
    && !defined($opts_testcmd) )
{
    doUsage();
    exit(1);
}

if ( defined($opts_testcmd) ) {
    doTestCmd($opts_testcmd);
    exit(0);
}

if ( defined($opts_hellocmd) ) {
    doHelloCmd();
    exit(0);
}

if ( defined($opts_pfile) ) {
    doStage1($opts_pfile);
    sleep(2);
}

if ( defined($opts_lfile) ) {
    my $addr = 0;
    if ( defined($opts_laddr) ) {
        $addr = $opts_laddr;
    }
    doStage2( $addr, $opts_lfile );
}

if ( defined($opts_lreset) ) {
    doResetStage();
}

exit 0;

