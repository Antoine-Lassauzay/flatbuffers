package flatbuffers;

import haxe.io.Bytes;

class BytesExtension
{
	// Note: exists mainly for consistency in the code base
	public static function setUInt32(bytes : Bytes, pos : Int, v : UInt) : Void
	{
		bytes.setInt32(pos, v);
	}

	// Note: exists mainly for consistency in the code base
	public static function getUInt32(bytes : Bytes, pos : Int) : UInt
	{
		return bytes.getInt32(pos);
	}

	// Necessary because most Haxe targets don't have a short type 
	// Due to the signed integer representation, we can't just use setUInt16
	// because we would be losing the sign bit
	public static function setInt16(b : Bytes, pos : Int, v : Int)
    {
        // First grab the signed bit from an int32
        var sb = v & (1 << 31);
        // Move to be the leftmost in the first byte
        sb >>= 24;
        // Grab the first byte from the int32
        var byte1 = (v & 0xFF00) >> 8;
        // This crazy thing basically allows to keep the first bit from sb
        // And the rest of the bits from byte1
        b.set(pos + 1, sb ^ ((sb ^ byte1) & (0xFF >> 1)));
        // Just write the second byte
        b.set(pos, v & 0xFF);    
    }

    // Reverse operation
    public static function getInt16(b : Bytes, pos : Int) : Int
    {
        // Get the sign bit and fill int32 accordingly (two's complement)
        // (also, the extra >> 1 is to set the leftmost bit of the 3rd byte
        // which was lost during conversion)
        var r = (b.get(pos + 1) & (1 << 7) == (1 << 7)) ? 0xFFFFFF00 >> 1 : 0;
        // Map Int16 first byte to Int32 last byte (ignoring left most bit)
        r |= b.get(pos + 1) & (0xFF >> 1);
        // Shift to third byte
        r <<= 8;
        // Read fourth byte
        r |= b.get(pos) & 0xFF;
        return r;
    }
}