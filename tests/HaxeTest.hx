package;

import flatbuffers.Constants;
import flatbuffers.Table;
import flatbuffers.Struct;
import flatbuffers.FlatBufferBuilder;
using flatbuffers.BytesExtension;

import haxe.io.Bytes;
import haxe.Int64;

class Color
{
    public static inline var Red = 1;
    public static inline var Green = 2;
    public static inline var Blue = 8;
}

class Any
{
    public static inline var NONE = 0;
    public static inline var Monster = 1;
    public static inline var TestSimpleTableWithEnum = 2;
}

class Test extends Struct
{
    public function new()
    {
    }

    public function __init(bb_pos : Int, bb : Bytes)
    {       
        this.bb_pos = bb_pos;
        this.bb = bb;
        return this;
    }

    public var a(get, set) : Int;   
    function get_a() return bb.getInt16(bb_pos + 0);
    function set_a(v)
    {
        bb.setInt16(bb_pos + 0, v);
        return v;   
    } 

    public var b(get, set) : Int;
    function get_b() return bb.get(bb_pos + 2);
    function set_b(v)
    {
        bb.set(bb_pos + 2, v);
        return v;
    }

    public static function createTest(builder : FlatBufferBuilder, a : Int, b : Int) : Int {
        builder.prep(2, 4);
        builder.pad(1);
        builder.putByte(b);
        builder.putShort(a);
        return builder.offset;
    }
}

class Vec3 extends Struct
{
    public function new()
    {
    }

    public function __init(bb_pos : Int, bb : Bytes)
    {
        this.bb = bb;
        this.bb_pos = bb_pos;
        return this;
    }

    public var x(get, set) : Float; 
    function get_x() return bb.getFloat(bb_pos + 0);
    function set_x(v)
    {
        bb.setFloat(bb_pos + 0, v);
        return v;   
    }

    public inline function mutateX(v : Float) : Bool
    {
        x = v;
        return true;
    }

    public var y(get, set) : Float;
    function get_y() return bb.getFloat(bb_pos + 4);
    function set_y(v)
    {
        bb.setFloat(bb_pos + 4, v);
        return v;
    }

    public var z(get, set) : Float;
    function get_z() return bb.getFloat(bb_pos + 8);
    function set_z(v) 
    {
        bb.setFloat(bb_pos + 8, v);
        return v;
    }

    public var test1(get, set) : Float;
    function get_test1() return bb.getDouble(bb_pos + 16);
    function set_test1(v) 
    {
        bb.setDouble(bb_pos + 16, v);
        return v;
    }   

    public var test2(get, set) : Int;
    function get_test2() return bb.get(bb_pos + 24);
    function set_test2(v) 
    {
        bb.set(bb_pos + 24, v);
        return v;
    }

    public var test3(get, null) : Test;
    function get_test3() return readTest3(new Test());
    function readTest3(obj : Test)
    {
        return obj.__init(bb_pos + 26, bb);
    }

    public static function createVec3(builder : FlatBufferBuilder, X : Float, Y : Float, Z : Float, Test1 : Float, Test2 : Int, test3_A : Int, test3_B : Int) : Int
    {
        builder.prep(16, 32);
        builder.pad(2);
        builder.prep(2, 4);
        builder.pad(1);
        builder.putByte(test3_B);
        builder.putShort(test3_A);
        builder.pad(1);
        builder.putByte(Test2);
        builder.putDouble(Test1);
        builder.pad(4);
        builder.putFloat(Z);
        builder.putFloat(Y);
        builder.putFloat(X);
        return builder.offset;
    }
}

class Monster extends Table
{
    public static function getRootAsMonster(bb : Bytes, startAt : Int = 0)
    {
        if(!Table.__has_identifier(bb, "MONS"))
            throw "Bad indentifier";
        return new Monster().__init(startAt + bb.getInt32(startAt), bb);
    }

    public function new() {}

    public function __init(bb_pos : Int, bb : Bytes) {
        this.bb = bb;
        this.bb_pos = bb_pos;
        return this;
    }

    public var pos(get, null) : Vec3;
    function get_pos() return readPos(new Vec3());
    function readPos(obj : Vec3)
    {
        var o = __offset(4);
        return o != 0 ? obj.__init(o + bb_pos, bb) : null;
    }

    public var mana(get, null) : Int;
    public function get_mana()
    {
        var o = __offset(6);
        // TODO need getand : Int Haxe Bytes
        return o != 0 ? bb.getInt16(o + bb_pos) : 150;
    }

    public function mutateMana(v : Int) : Bool
    {
        var o = __offset(6);
        if(o != 0)
        {   
            bb.setInt16(o + bb_pos, v);
            return true;
        }
        else return false;
    }

    public var hp(get, null) : Int;
    public function get_hp()
    {
        var o = __offset(8);
        // TODO need getand : Int Haxe Bytes
        return o != 0 ? bb.getInt16(o + bb_pos) : 100;
    }

    public var name(get, null) : String;
    public function get_name()
    {
        var o = __offset(10);
        // TODO need getand : Int Haxe Bytes
        return o != 0 ? __string(o + bb_pos) : null;
    }

    public var testType(get, null) : Int;
    public function get_testType()
    {
        var o = __offset(18);
        return o != 0 ? bb.get(o + bb_pos) : 0;
    }

    public function mutateTestType(v : Int) : Bool
    {
        var o = __offset(18);
        if(o != 0)
        {   
            bb.set(o + bb_pos, v);
            return true;
        }
        else return false;
    }

    @:generic
    public function getTest<TTable:Table>(obj : TTable)
    {
        var o = __offset(20);

        return o != 0 ? __union(obj, o) : null;
    }
    
    public function getTest4(j : Int) : Test
    {
        return readTest4(new Test(), j);
    }

    public function readTest4(obj : Test, j : Int) : Test
    {
        var o : Int = __offset(22);
        // 4 being size of Test
        return o != 0 ? obj.__init(__vector(o) + j * 4, bb) : null;
    }

    public var test4Length(get, null) : Int;
    function get_test4Length()
    {
        var o = __offset(22);
        return o != 0 ? __vector_len(o) : 0;
    }
    
    public function getTestarrayofstring(j : Int) : String
    {
        var o = __offset(24);
        return o != 0 ? __string(__vector(o) + j * 4) : null;
    }

    public var testarrayofstringLength(get, null) : Int;
    function get_testarrayofstringLength()
    {
        var o = __offset(24);
        return o != 0 ? __vector_len(o) : 0;
    }

    public var testbool(get, null) : Bool;
    function get_testbool()
    {
        var o = __offset(34);
        return o != 0 ? (0 != bb.get(o + bb_pos)) : false;
    }

    public function getInventory(j : Int) : Int
    {
        var o = __offset(14);
        return o != 0 ? bb.get(__vector(o) + j * 1) : 0;
    }

    public function mutateInventory(j : Int, v : Int) : Bool
    {
        var o = __offset(14);
        if(o != 0)
        {   
            bb.set(__vector(o) + j * 1, v);
            return true;
        }
        else return false;
    }
    
    public var inventoryLength(get, null) : Int;
    function get_inventoryLength()
    {
        var o = __offset(14);
        return o != 0 ? __vector_len(o) : 0;
    }

    public var testhashu32Fnv1(get, null) : UInt;
    function get_testhashu32Fnv1()
    {
        var o = __offset(38);
        return o != 0 ? bb.getInt32(o + bb_pos) : 0;
    }


    /* Builder */
    public static function startMonster(builder : FlatBufferBuilder) : Void
    {
        builder.startObject(25);
    }

    public static function addPos(builder : FlatBufferBuilder, posOffset : Int)
    {
        builder.addStructAt(0, posOffset, 0);
    }

    public static function addMana(builder : FlatBufferBuilder, mana : Int) : Void
    {
        builder.addShortAt(1, mana, 150);
    }

    public static function addHp(builder : FlatBufferBuilder, hp : Int) : Void {
        builder.addShortAt(2, hp, 100);
    }

    public static function addName(builder : FlatBufferBuilder, nameOffset : Int) : Void
    {
        builder.addOffsetAt(3, nameOffset, 0);
    }

    public static function addInventory(builder : FlatBufferBuilder, inventoryOffset : Int) : Void {
        builder.addOffsetAt(5, inventoryOffset, 0);
    }
    
    public static function createInventoryVector(builder : FlatBufferBuilder, data : Array<Int>) : Int {
        builder.startVector(1, data.length, 1);
        var l = data.length;
        for (i in 0...l) builder.addByte(data[l-i-1]);
        return builder.endVector();
    }
    
    public static function startInventoryVector(builder : FlatBufferBuilder, numElems : Int) : Void {
        builder.startVector(1, numElems, 1);
    }
  
    public static function addColor(builder : FlatBufferBuilder, color : Int) : Void {
        builder.addByteAt(6, color, 8);
    }
    
    public static function addTestType(builder : FlatBufferBuilder, testType : Int) : Void {
        builder.addByteAt(7, testType, 0);
    }
    
    public static function addTest(builder : FlatBufferBuilder, testOffset : Int) : Void {
        builder.addOffsetAt(8, testOffset, 0);
    }
    
    public static function addTest4(builder : FlatBufferBuilder, test4Offset : Int) : Void {
        builder.addOffsetAt(9, test4Offset, 0);
    }
    
    public static function startTest4Vector(builder : FlatBufferBuilder, numElems : Int) : Void {
        builder.startVector(4, numElems, 2);
    }

    public static function addTestarrayofstring(builder : FlatBufferBuilder, testarrayofstringOffset : Int) : Void {
        builder.addOffsetAt(10, testarrayofstringOffset, 0);
    }
    
    public static function createTestarrayofstringVector(builder : FlatBufferBuilder, data : Array<Int>) : Int {
        builder.startVector(4, data.length, 4);
        for (i in 0...data.length) builder.addOffset(data[data.length-i-1]);
        return builder.endVector();
    }

    public static function startTestarrayofstringVector(builder : FlatBufferBuilder, numElems : Int) : Void {
        builder.startVector(4, numElems, 4);
    }

    public static function addEnemy(builder : FlatBufferBuilder, enemyOffset : Int) : Void {
        builder.addOffsetAt(12, enemyOffset, 0);
    }

    public static function addTestbool(builder : FlatBufferBuilder, testbool : Bool) : Void
    {
        builder.addBoolAt(15, testbool, false);
    }

    public static function addTesthashu32Fnv1(builder : FlatBufferBuilder, testhashu32Fnv1 : Int)
    {
        builder.addIntAt(17, testhashu32Fnv1 & 0xFFFFFFFF, 0);
    }

    public static function endMonster(builder : FlatBufferBuilder) : Int
    {
        var o = builder.endObject();
        //builder.required(o, 10);  // name
        return o;
    }
    
    public static function finishMonsterBuffer(builder : FlatBufferBuilder, offset : Int) : Void
    {
        builder.finishBuffer(offset, "MONS");
    }

}

class BufferTests extends haxe.unit.TestCase
{
    private function __testBuffer(buffer : Bytes)
    {
        assertTrue(buffer != null);

        var monster = Monster.getRootAsMonster(buffer);

        assertEquals(80, monster.hp);
        assertEquals(150, monster.mana);
        assertEquals("MyMonster", monster.name);

        var pos = monster.pos;
        assertEquals(pos.x, 1.0);
        assertEquals(pos.y, 2.0);
        assertEquals(pos.z, 3.0);

        assertEquals(3.0, pos.test1);
        assertEquals(Color.Green, pos.test2);
        var t = pos.test3;
        assertEquals(5, t.a);
        assertEquals(6, t.b);

        assertEquals(Any.Monster, monster.testType);

        var monster2 = new Monster();
        assertTrue(monster.getTest(monster2) != null);
        assertEquals("Fred", monster2.name);

        
        assertEquals(5, monster.inventoryLength);
        var invsum = 0;
        for (i in 0...monster.inventoryLength)
        {
            invsum += monster.getInventory(i);
        }
        assertEquals(10, invsum);

        var test0 = monster.getTest4(0);
        var test1 = monster.getTest4(1);
        assertEquals(2, monster.test4Length);

        
        assertEquals(100, test0.a + test0.b + test1.a + test1.b);

        assertEquals(2, monster.testarrayofstringLength);
        assertEquals("test1", monster.getTestarrayofstring(0));
        assertEquals("test2", monster.getTestarrayofstring(1));

        assertEquals(false, monster.testbool);
    }

    public function testCanReadCppGeneratedWireFile()
    {
        __testBuffer(haxe.Resource.getBytes("test_data"));
    }

    public function testCanCreateNewFlatBufferFromScratch()
    {
        // Second, let's create a FlatBuffer from scratch in Haxe, and test it also.
        // We use an initial size of 1 to exercise the reallocation algorithm,
        // normally a size larger than the typical FlatBuffer you generate would be
        // better for performance.
        var fbb = new FlatBufferBuilder(1);

        // We set up the same values as monsterdata.json:
        var str = fbb.createString("MyMonster");
        
        var inv = Monster.createInventoryVector(fbb, [0, 1, 2, 3, 4]);
        
        var fred = fbb.createString("Fred");
        Monster.startMonster(fbb);
        Monster.addName(fbb, fred);
        var mon2 = Monster.endMonster(fbb);

        Monster.startTest4Vector(fbb, 2);
        Test.createTest(fbb, 10, 20);
        Test.createTest(fbb, 30, 40);
        var test4 = fbb.endVector();

        var testArrayOfString = Monster.createTestarrayofstringVector(fbb, [
            fbb.createString("test1"),
            fbb.createString("test2")
        ]);

        Monster.startMonster(fbb);
        Monster.addPos(fbb, Vec3.createVec3(fbb, 1.0, 2.0, 3.0, 3.0, Color.Green, 5, 6));
        Monster.addHp(fbb, 80);
        Monster.addName(fbb, str);
        Monster.addInventory(fbb, inv);
        Monster.addTestType(fbb, Any.Monster);
        Monster.addTest(fbb, mon2);
        Monster.addTest4(fbb, test4);
        Monster.addTestarrayofstring(fbb, testArrayOfString);
        Monster.addTestbool(fbb, false);
        var mon = Monster.endMonster(fbb);
        
        Monster.finishMonsterBuffer(fbb, mon);

        #if neko
        sys.io.File.saveBytes("monsterdata_hx_test.mon", fbb.copyBuffer());
        #end

        // Now assert the buffer
        __testBuffer(fbb.copyBuffer()); 

        //Attempt to mutate Monster fields and check whether the buffer has been mutated properly
        // revert to original values after testing
        var monster = Monster.getRootAsMonster(fbb.copyBuffer());

        // mana is optional and does not exist in the buffer so the mutation should fail
        // the mana field should retain its default value
        assertEquals(monster.mutateMana(10), false);
        assertEquals(monster.mana, 150);

        // testType is an existing field and mutating it should succeed
        assertEquals(monster.testType, Any.Monster);
        assertEquals(monster.mutateTestType(Any.NONE), true);
        assertEquals(monster.testType, Any.NONE);
        assertEquals(monster.mutateTestType(Any.Monster), true);
        assertEquals(monster.testType, Any.Monster);
        
        //mutate the inventory vector
        assertEquals(monster.mutateInventory(0, 1), true);
        assertEquals(monster.mutateInventory(1, 2), true);
        assertEquals(monster.mutateInventory(2, 3), true);
        assertEquals(monster.mutateInventory(3, 4), true);
        assertEquals(monster.mutateInventory(4, 5), true);

        for (i in 0...monster.inventoryLength)
        {
            assertEquals(monster.getInventory(i), i + 1);
        }

        //reverse mutation
        assertEquals(monster.mutateInventory(0, 0), true);
        assertEquals(monster.mutateInventory(1, 1), true);
        assertEquals(monster.mutateInventory(2, 2), true);
        assertEquals(monster.mutateInventory(3, 3), true);
        assertEquals(monster.mutateInventory(4, 4), true);
        
        // get a struct field and edit one of its fields
        var pos = monster.pos;
        assertEquals(pos.x, 1.0);
        pos.mutateX(55.0);
        assertEquals(pos.x, 55.0);
        pos.mutateX(1.0);
        assertEquals(pos.x, 1.0);

        __testBuffer(fbb.copyBuffer());
    }

}

class BytesExtensionTests extends haxe.unit.TestCase
{
    public function testBytesExtension()
    {               
        var bytes = Bytes.alloc(2);
        
        for(i in -32768...32768) // range of int16
        {
            bytes.setInt16(0, i);
            assertEquals(i, bytes.getInt16(0));
        }
    }
}

class HaxeTest
{
    public static function main()
    {
        var r = new haxe.unit.TestRunner();
        r.add(new BufferTests());    
        r.add(new BytesExtensionTests());   
        r.run();
    }
}