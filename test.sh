#!/bin/bash

#two files with random name for writting result
std=$(mktemp)
err=$(mktemp)
#variable for load test
N=10
#file for some tests
touch file.txt
#check comand working
function test {
	#check return code previous comand
	if [ "$?" -ne $1 ]; then 
		echo "Fail return code $?";
		exit 1;
	fi
	STD=`cat $std`
	ERR=`cat $err`
	#check file std contains argument
	if [ "$STD" != "$2" ]; then 
		echo "Fail stdout";
		echo "$STD";
		exit 1;
	fi
	#check file error is empty
	if [ "$ERR" != "$3" ]; then
		echo "Fail stderr";
		echo "$ERR";
		exit 1;
	fi
	echo "OK"
}
#function for load test without stdout
function testLoad  {
#check return code previous comand
	if [ "$?" -ne $1 ]; then 
		exit 1;
	fi
	STD=`cat $std`
	ERR=`cat $err`
	#check file std contains argument
	if [ "$STD" != "$2" ]; then 
		exit 1;
	fi
	#check file error is empty
	if [ "$ERR" != "$3" ]; then
		exit 1;
	fi
}
#1 test echo
echo -n "1. echo - "
echo -n "777" 1> "$std" 2> "$err"
test 0 "777" "" 

for(( i=1;i<=$N;i++ ))
do
	echo -n "777" 1> "$std" 2> "$err"
	testLoad 0 "777" ""
done
echo "   Load test - OK"	

#2 test sort
echo -n "2. sort - "
echo -e '1\n3\n2\n6\n5\n4' | sort 1> "$std" 2> "$err"
test 0 $'1\n2\n3\n4\n5\n6' ""
for(( i=1;i<=$N;i++ ))
do
	echo -e '1\n3\n2\n6\n5\n4' | sort 1> "$std" 2> "$err"
	testLoad 0 $'1\n2\n3\n4\n5\n6' ""
done
echo "   Load test - OK"

#3 test ls
#ls shows what is in directory
echo -n "3. ls - "
ls 1> "$std" 2> "$err"
test 0 $'file.txt\ntest.sh' ""
for(( i=1;i<=$N;i++ ))
do
	ls 1> "$std" 2> "$err"
	testLoad 0 $'file.txt\ntest.sh' ""
done
echo "   Load test - OK"

#4 test which 
#wich return where is file
echo -n "4. which - "
which ls 1> "$std" 2> "$err"
test 0 "/usr/bin/ls" ""

#5 test cat expect error
#read file
echo -n "5. cat - "
cat 123.txt 1> "$std" 2> "$err"
test 1 "" "cat: 123.txt: No such file or directory"

#6 test uname
#return kernel's name
echo -n "6. uname - "
uname -s 1> "$std" 2> "$err"
test 0 "MINGW64_NT-10.0-18362" ""

#7 test whoami
#return user name
echo -n "7. whoami - "
whoami 1> "$std" 2> "$err"
test 0 "dgandzha" ""

#8 test find 
#search file
echo -n "8. find - "
find . -name "test*" 1> "$std" 2> "$err"
test 0 "./test.sh" ""

#9 test head
#show first line in this file
echo -n "9. head - "
head -n 1 test.sh 1> "$std" 2> "$err"
test 0 "#!/bin/bash" ""

#10 test pwd
#show directory
echo -n "10. pwd - "
pwd 1> "$std" 2> "$err"
test 0 "/c/Linux" ""

#11 test wc
#show count of word,string,byte,symbols
echo -n "11. wc - "
wc file.txt 1> "$std" 2>"$err"
test 0 "0 0 0 file.txt" ""

#12 test where is
#show path fo file/directory
echo -n "12. whereis - "
where is file.txt 1>"$std" 2>"$err"
test 0 "C:\Linux\file.txt" ""

