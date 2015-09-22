package flatbuffers;

import haxe.io.Bytes;
import haxe.ds.Vector;
import haxe.Int64;

import flatbuffers.Constants;
using flatbuffers.BytesExtension;

class FlatBufferBuilder
{
	var _space : Int = 0;
	var _bb : Bytes;
	var _minAlign = 1;

	var _vtable : Vector<Int>;
	var _objectStart : Int = 0;
	var _vtables = new Vector<Int>(16);

	var _numVtables = 0;
	var _vectorNumElems = 0;

	public var offset(get, null) : Int;

	function get_offset() return _bb.length - _space;

	public var dataBuffer(get, null) : Bytes;

	function get_dataBuffer() return _bb;

	public function copyBuffer() : Bytes
	{
		var copy = Bytes.alloc(_bb.length - _space);
		copy.blit(0, _bb, _space, copy.length);
		return copy;
	}

	public function new(initialSize : Int)
	{
		if(initialSize <= 0)
			throw "Size must be greater than zero";
		_space = initialSize;
		_bb = Bytes.alloc(initialSize);
	}

	public function clear()
	{

	}

	public function pad(size : Int) : Void
	{
		_bb.fill(_space - size, size, 0);
		_space -= size;
	}
	
	// Doubles the size of the ByteBuffer, and copies the old data towards
   	// the end of the new buffer (since we build the buffer backwards).
	function growBuffer()
	{
		var oldBufSize = _bb.length;
		if ((oldBufSize & 0xC0000000) != 0)
            throw  "Cannot grow buffer beyond 2 gigabytes";

        var newBufSize = oldBufSize << 1;
		var newBuf = Bytes.alloc(newBufSize);
		newBuf.blit(newBufSize - oldBufSize, _bb, 0, oldBufSize);
		_bb = newBuf;

	}

	public function prep(size : Int, additionalBytes : Int) : Void
	{
		// Track the biggest thing we've ever aligned to.
        if (size > _minAlign)
            _minAlign = size;
        // Find the amount of alignment needed such that `size` is properly
        // aligned after `additional_bytes`
        var alignSize =
            ((~(_bb.length - _space + additionalBytes)) + 1) &
            (size - 1);
        // Reallocate the buffer if needed.
        while (_space < alignSize + size + additionalBytes)
        {
            var oldBufSize = _bb.length;
            growBuffer();
            _space += _bb.length - oldBufSize;

        }
        pad(alignSize);
	};

	// Add a scalar to the buffer, backwards from the current location.
    // Doesn't align nor check for space.
	public function putBool(x : Bool) : Void _bb.set(_space -= 1, x ? 1 : 0);
	public function putByte(x : Int) : Void  _bb.set(_space -= 1, x);
	public function putShort(x : Int) : Void  _bb.setUInt16(_space -= 2, x);
	public function putInt(x : Int) : Void _bb.setInt32(_space -= 4, x);
	public function putUint(x : UInt) : Void _bb.setUInt32(_space -= 4, x);
	public function putLong(x : Int64) : Void  _bb.setInt64(_space -= 8, x);
	public function putFloat(x : Float) : Void  _bb.setFloat(_space -= 4, x);
	public function putDouble(x : Float) : Void  _bb.setDouble(_space -= 8, x);

	// Adds a scalar to the buffer, properly aligned, and the buffer grown
    // if needed.
    public function addBool(x : Bool) : Void
    {
    	prep(1, 0);
    	putBool(x);
    }

    public function addByte(x : Int) : Void
    {    	
    	prep(1, 0);
    	putByte(x);
    }

    public function addShort(x : Int) : Void
    {
    	prep(2, 0);
    	putShort(x);
    }

    public function addInt(x : Int) : Void
    {
    	prep(4, 0);
    	putInt(x);
    }

    public function addLong(x : Int64) : Void
    {
    	prep(8, 0);
    	putLong(x);
    }

    public function addFloat(x : Float) : Void
    {
    	prep(4, 0);
    	putFloat(x);
    }

    public function addDouble(x : Float)  : Void
    {
    	prep(8, 0);
    	putDouble(x);
    }

    public function addOffset(off : Int) : Void
    {
    	prep(Constants.SIZE_OF_INT, 0);
    	off = offset - off + Constants.SIZE_OF_INT;
    	putInt(off);
    }

    public function startVector(elemSize : Int, count : Int, alignment : Int)
    {
        //NotNested(); todo assert
        _vectorNumElems = count;
        prep(Constants.SIZE_OF_INT, elemSize * count);
        prep(alignment, elemSize * count); // Just in case alignment > int.
    }

    public function endVector() : Int
    {
        putInt(_vectorNumElems);
        return offset;
    }

    public function createString(s : String) : Int
    {
    	var bytes = Bytes.ofString(s);
    	addByte(0);
    	startVector(1, bytes.length, 1);
    	_bb.blit(_space -= bytes.length, bytes, 0, bytes.length);
    	return endVector();
    }

    public function startObject(numFields : Int) : Void
    {
    	// todo assertion
    	_vtable = new Vector<Int>(numFields);
    	for(i in 0...numFields) _vtable[i] = 0;
    	_objectStart = offset;
    }
    // Set the current vtable at `voffset` to the current location in the buffer.
    public function slot(voffset : Int) : Void
    {
    	_vtable[voffset] = offset;
    }

    // Add a scalar to a table at `o` into its vtable, with value `x` and default `d`
    public function addBoolAt(o : Int, x : Bool, d : Bool) : Void
    {
    	if(x != d)
    	{
    		addBool(x);
    		slot(o);
    	}
    }

    public function addByteAt(o : Int, x : Int, d : Int) : Void
    {
    	if(x != d)
    	{
    		addByte(x);
    		slot(o);
    	}
    }

    public function addShortAt(o : Int, x : Int, d : Int) : Void
    {
    	if(x != d)
    	{
    		addShort(x);
    		slot(o);
    	}
    }

    public function addIntAt(o : Int, x : Int, d : Int) : Void
    {
    	if(x != d)
    	{
    		addInt(x);
    		slot(o);
    	}
    }

    public function addLongAt(o : Int, x : Int64, d : Int64) : Void
    {
    	if(x != d)
    	{
    		addLong(x);
    		slot(o);
    	}
    }

    public function addFloatAt(o : Int, x : Float, d : Float) : Void
    {
    	if(x != d)
    	{
    		addFloat(x);
    		slot(o);
    	}
    }

    public function addDoubleAt(o : Int, x : Float, d : Float) : Void
    {
    	if(x != d)
    	{
    		addDouble(x);
    		slot(o);
    	}
    }

    // Structs are stored inline, so nothing additional is being added. `d` is always 0.
    public function addStructAt(o : Int, x : Int, d : Int) : Void
    {
        if(x != d) {
            //Nested(x);
            slot(o);
        }
    }

    public function addOffsetAt(o : Int, x : Int, d : Int) : Void
    {
    	if(x != d)
    	{
    		addOffset(x);
    		slot(o);
    	}
    }

    public function endObject() : Int
    {
    	if(_vtable == null) // todo nested assert
    		throw "endObject() called without startObject()";
    	addInt(0); // Later set to point to object's vtable
    	var vtableLoc = offset;
    	// Write out to the current vtable
    	for(i in 0..._vtable.length)
    	{
    		// Offset relative to the start of the table.
    		var index = _vtable.length-i-1;
    		var off = _vtable[index] != 0 ? vtableLoc - _vtable[index] : 0;
    		addShort(off);
    	}

    	var standardFields = 2; // The fields below:
        addShort(vtableLoc - _objectStart); // length of the object
        // length of obj vtable + 2 these two fields
        addShort((_vtable.length + standardFields) * Constants.SIZE_OF_SHORT);

		// Search for an existing vtable that matches the current one.
		var existingVTable = 0;
		for(i in 0..._numVtables)
		{
			var vt1 = _bb.length - _vtables[i];
			var vt2 = _space;
			var len = _bb.getUInt16(vt1);
			if(len == _bb.getUInt16(vt2))
			{
				var j = Constants.SIZE_OF_SHORT;
				var match = true;
				while(j < len)
				{
					j += Constants.SIZE_OF_SHORT;
					if(_bb.getUInt16(vt1 + j) != _bb.getUInt16(vt2 + j))
					{
						match = false;
						break;
					}
				}
				if(match)
				{
					existingVTable = _vtables[i];
					break;
				}
			}
		}

		if(existingVTable != 0)
		{
			// Found a match:
            // Remove the current vtable.
			_space = _bb.length - vtableLoc;
			_bb.setInt32(_space, existingVTable - vtableLoc);
		}
		else
		{
			// No match:
            // Add the location of the current vtable to the list of vtables.
            if (_numVtables == _vtables.length)
            {
            	// Grow vtables if needed
            	var newVtables = new Vector(_numVtables * 2);
            	Vector.blit(_vtables, 0, newVtables, 0, _numVtables);
            	_vtables = newVtables;	
            } 
            _vtables[_numVtables++] = offset;
            // Point table to current vtable.
            _bb.setInt32(_bb.length - vtableLoc, offset - vtableLoc);
		}

		return vtableLoc;
    }

    public function finish(rootTable : Int) : Void
    {
        prep(_minAlign, Constants.SIZE_OF_INT);
        addOffset(rootTable);
        //bb.position(space);
    }

    public function finishBuffer(rootTable : Int, fileIdentifier : String) : Void {
        prep(_minAlign, Constants.SIZE_OF_INT + Constants.FILE_IDENTIFIER_LENGTH);
        if (fileIdentifier.length != Constants.FILE_IDENTIFIER_LENGTH)
            throw "FlatBuffers: file identifier must be length " + Constants.FILE_IDENTIFIER_LENGTH;
        for (i in 0...Constants.FILE_IDENTIFIER_LENGTH)
        {
            addByte(fileIdentifier.charCodeAt(Constants.FILE_IDENTIFIER_LENGTH-i-1));
        }
        finish(rootTable);
    }


}