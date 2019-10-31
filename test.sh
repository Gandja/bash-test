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
test 0 $'file.txt\nfile-test.txt\ntest.sh' ""
for(( i=1;i<=$N;i++ ))
do
	ls 1> "$std" 2> "$err"
	testLoad 0 $'file.txt\nfile-test.txt\ntest.sh' ""
done
echo "   Load test - OK"

#4 test which 
#wich return where is file
echo -n "4. which - "
which ls 1> "$std" 2> "$err"
test 0 "/usr/bin/ls" ""

#5 test cat expect error
#read file
echo -n "5. cat for error - "
cat 123.txt 1> "$std" 2> "$err"
test 1 "" "cat: 123.txt: No such file or directory"

#6 test cat for open file
echo -n "6. cat for open file - "
echo "11" > file.txt
cat file.txt 1> "$std" 2>"$err"
test 0 "11" ""

for(( i=1;i<=$N;i++ ))
do
	echo "11" > file.txt
	cat file.txt 1> "$std" 2>"$err"
	testLoad 0 "11" ""
done
echo "   Load test - OK"

#7 test uname
#return kernel's name
echo -n "7. uname - "
uname -s 1> "$std" 2> "$err"
test 0 "MINGW64_NT-10.0-18362" ""

#8 test whoami
#return user name
echo -n "8. whoami - "
whoami 1> "$std" 2> "$err"
test 0 "dgandzha" ""

#9 test find 
#search file
echo -n "9. find - "
find . -name "test*" 1> "$std" 2> "$err"
test 0 "./test.sh" ""

#10 test head
#show first line in this file
echo -n "10. head - "
head -n 1 test.sh 1> "$std" 2> "$err"
test 0 "#!/bin/bash" ""

#11 test pwd
#show directory
echo -n "11. pwd - "
pwd 1> "$std" 2> "$err"
test 0 "/c/Linux/bash-test" ""

#12 test wc
#show count of word,string,byte,symbols
echo -n "12. wc - "
wc file.txt 1> "$std" 2>"$err"
test 0 "1 1 3 file.txt" ""

#13 test touch
echo -n "13. touch - "
FILE=/c/Linux/bash-test/file-test.txt
touch $FILE 1> "$std" 2> "$err"
test 0 "" ""
 
#14 test grep
echo -n "14. grep - "
echo -e "1\n5\n5\n5\n3" > $FILE
grep "5" $FILE 1> "$std" 2> "$err"
test 0 $'5\n5\n5' ""

for(( i=1;i<=$N;i++ ))
do
	grep "5" $FILE 1> "$std" 2> "$err"
	testLoad 0 $'5\n5\n5' ""
done
echo "    Load test - OK"

#15 test mkdir
echo -n "15. mkdir - "
mkdir -p /c/Linux/a/b 1> "$std" 2>"$err"
test 0 "" ""

#16 test date
echo -n "16. date -  "
date +%Y 1> "$std" 2> "$err"
test 0 "2019" ""

#17 test - date for error
echo -n "17. date fo error - "
date YY 1> "$std" 2> "$err"
test 1 "" "date: invalid date ‘YY’"

#18 test tail 
echo -n "18. tail -  "
tail -n 1 test.sh 1> "$std" 2> "$err"
test 0 "finish=1" ""

#19 test rm  
echo -n "19. rm - "
tmp=$(mktemp)
rm $tmp 1> "$std" 2> "$err"
test 0 "" ""

#20 test file
echo -n "20. file -"
file file.txt 1> "$std" 2> "$err"
test 0 "file.txt: ASCII text" ""

finish=1