pushd "$(dirname $0)" > /dev/null
set -e
test_dir="$(pwd)"

function compile_tests() {
	echo Testing Haxe target $1
	echo \# Compiling tests
    haxe -main HaxeTest --cwd ${test_dir} -cp ../haxe/ -resource monsterdata_test.mon@test_data $1 $2
    if ! [ "$?" = "0" ]; then
    	exit 1
    fi
}

function run_tests() {
	echo \# Running tests
	if [ -z $2 ]; then		
		$1
	else		
		$1 $2
	fi
	if ! [ "$?" = "0" ]; then		
    	exit 1
    fi
    echo
}

compile_tests -neko ${test_dir}/HaxeTest.n
run_tests neko ${test_dir}/HaxeTest.n

compile_tests -js ${test_dir}/HaxeTest.js
run_tests node ${test_dir}/HaxeTest.js

compile_tests -cpp ${test_dir}/HaxeTest_cpp/
run_tests ${test_dir}/HaxeTest_cpp/HaxeTest

compile_tests -php ${test_dir}/HaxeTest_php/
run_tests php ${test_dir}/HaxeTest_php/index.php

compile_tests -swf ${test_dir}/HaxeTest.swf

compile_tests -python ${test_dir}/HaxeTest.py
run_tests python3 ${test_dir}/HaxeTest.py