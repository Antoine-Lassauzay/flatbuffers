package flatbuffers;

import haxe.io.Bytes;
import flatbuffers.Constants;

class Table
{

	private var bb_pos : Int;
	private var bb : Bytes;

	// Look up a field in the vtable, return an offset into the object, or 0 if the field is not
    // present.
	private function __offset(vtableOffset : Int)
    {
		// Each table starts with a offset to its actual vtable in the bytes
		// The offset points backwards, so it's substracted from this table initial position
		var vtable = bb_pos - bb.getInt32(bb_pos);
		var vtableSize = bb.getUInt16(vtable);
        return vtableOffset < vtableSize ? bb.getUInt16(vtable + vtableOffset) : 0;
	}

	// Retrieve the relative offset stored at "offset"
	private function __indirect(offset : Int)
    {
    	return offset + bb.getInt32(offset);
    }

    // Create String from UTF-8 data stored inside the flatbuffer.
    private function __string(offset : Int)
    {
        offset += bb.getInt32(offset);
        var len = bb.getInt32(offset);
        var startPos = offset + Constants.SIZE_OF_INT; // data starts after the length
        return bb.getString(startPos, len);
    }

    // Get the length of a vector whose offset is stored at "offset" in this object.
    private function __vector_len(offset : Int)
    {
        offset += bb_pos;
        offset += bb.getInt32(offset);
        return bb.getInt32(offset);
    }

    // Get the start of data of a vector whose offset is stored at "offset" in this object.
    private function __vector(offset : Int)
    {
        offset += bb_pos;
        return offset + bb.getInt32(offset) + Constants.SIZE_OF_INT;  // data starts after the length
    }

    // Initialize any Table-derived type to point to the union at the given offset.
    private function __union<TTable : Table>(t : TTable, offset : Int)
    {
        offset += bb_pos;
        t.bb_pos = offset + bb.getInt32(offset);
        t.bb = bb;
        return t;
    }

    private static function __has_identifier(bb : Bytes, ident : String) : Bool
    {
        if (ident.length != Constants.FILE_IDENTIFIER_LENGTH)
            throw "FlatBuffers: file identifier must be length " + Constants.FILE_IDENTIFIER_LENGTH;
        for(i in 0...Constants.FILE_IDENTIFIER_LENGTH)
        {        	
        	if(ident.charCodeAt(i) != bb.get(Constants.SIZE_OF_INT + i))
        	{
        		return false;
        	}        		
        }
        return true;
    }
}