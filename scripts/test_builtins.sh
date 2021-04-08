test_echo ()
{
    # run_test 'echo $_ | echo $_ ; echo $_'
    # run_test 'echo $_ | echo $_ ; echo $_ ; echo $_'
    # run_test 'echo 1 2 3 ; echo $_ ; echo $_'
    run_test "echo | cat -e"
    run_test "echo 1 | cat -e"
    run_test "echo 1 2 3 | cat -e"
    run_test "echo 1 2 3      | cat -e"
    run_test "echo 1 2                      3 | cat -e"
    run_test 'echo -n | cat -e'
    run_test 'echo -""n | cat -e'
    run_test 'echo ""-""n"" | cat -e'
    run_test 'echo -n hello | cat -e'
    run_test 'echo -n ""h""el""""lo | cat -e'
    run_test 'echo -nnnnnnnn hello | cat -e'
    run_test 'echo ""-nn""n""""nnn""nn hello | cat -e'
    run_test 'echo -n1 | cat -e'
    run_test 'echo -n -n | cat -e'
    run_test 'echo -n -n hello | cat -e'
    run_test 'echo -n -nnnnn hello | cat -e'
    run_test 'echo -nnnnn -nnnnn hello | cat -e'
    run_test 'echo -n -n -n | cat -e'
    run_test 'echo -n -n -n hello | cat -e'
    run_test 'echo -n -nnnn -n hello -n -nnnnn -n | cat -e'
    run_test 'echo -nnnn -nnnn -n hello -n -nnnnn -n | cat -e'
    run_test 'echo -n -nnnn -n hello -n -nnnnn -n world | cat -e'
    run_test 'echo -""n -nnnn -n hello -n -nnnnn -n world | cat -e'
    run_test "echo - n1 | cat -e"
    run_test "echo - n 1 | cat -e"
    run_test "echo -n 1 | cat -e"
    run_test "echo -n 1 2 3 | cat -e"
    run_test "echo -n 1 2                      3 | cat -e"
    run_test "echo 1 2 3 -n | cat -e"
    run_test "echo -n 1 2 3 -n | cat -e"
    run_test "echo -n 1 2 -n 3 -n | cat -e"
    run_test "       echo 1 2 3 -n | cat -e"
    run_test "       echo -n 1 2 3 -n | cat -e"
    run_test "echo a '' b '' c '' d | cat -e"
    run_test 'echo a "" b "" c "" d | cat -e'
    run_test "echo -n a '' b '' c '' d | cat -e"
    run_test 'echo -n a "" b "" c "" d | cat -e'
    run_test "echo '' '' ''          Echo 1 | cat -e"
    run_test "eCho 1 | cat -e"
    run_test "ecHo 1 | cat -e"
    run_test "echO 1 | cat -e"
    run_test "EchO 1 | cat -e"
    run_test "eCHo 1 | cat -e"
    run_test "EcHo 1 | cat -e"
    run_test "eChO 1 | cat -e"
    run_test "ECHO 1 | cat -e"
    run_test "unset PATH ; echo 1 | /bin/cat -e"
    run_test "unset PATH ; ECHO 1 | /bin/cat -e"
    run_test "''e''c''h''o'' 1 | cat -e"
    run_test "''e''c''h''o'''''' 1 | cat -e"
    run_test '""e""c""h""o"" 1 | cat -e'
    run_test '""e""c""h""o"""""" 1 | cat -e'
    run_test 'echo "" "" "" a'
    # run_test 'echo 1 ; echo $_'
    # run_test 'ls ; echo $_'
    # run_test '1 ; echo $_'
    # run_test '1 ; echo $_ ; echo $_'
    # run_test '1 | echo $_'
    # run_test '1 | echo $_ | echo $_'
    # run_test '1 | echo $_ ; echo $_'
    # run_test 'echo $_ | echo $_'
    # run_test 'echo $_ | echo $_ ; echo $_'
    # run_test 'echo $_ | echo $_ ; echo $_ ; echo $_'
    # run_test 'echo 1 2 3 ; echo $_ ; echo $_'
    # run_test 'echo "1 2 3" ; echo $_ ; echo $_'
}

test_cd () {
    run_test 'mkdir a b ; cd a ; cd ../b ; pwd ; cd .. ; pwd ; echo $PWD ; echo $OLDPWD ; rm -rf a b'
    run_test 'mkdir -p a/aa b ; cd a/aa ; cd ../../b/bb ; pwd ; echo $PWD ; echo $OLDPWD ; cd ../.. ; rm -fr a b'
    run_test 'mkdir a ; ln -s a aa ; cd aa ; rm ../aa ; cd . ; pwd ; echo $PWD ; echo $OLDPWD ; rm -fr a'
    run_test 'mkdir a ; cd a ; rm -fr ../a ; cd ; pwd ; rm -rf a'
    run_test 'mkdir a ; cd a ; rm -fr ../a ; cd "" ; pwd ; rm -rf a'
    run_test 'mkdir a ; cd a ; rm -fr ../a ; cd . ; pwd ; rm -rf a'
    run_test 'mkdir a ; cd a ; rm -fr ../a ; cd ./ ; pwd ; rm -rf a'
    run_test 'mkdir a ; cd a ; rm -fr ../a ; cd ./././ ; pwd ; rm -rf a'
    run_test 'mkdir a ; cd a ; rm -fr ../a ; cd ./././///././///// ; pwd ; rm -rf a'
    run_test 'mkdir a ; cd a ; rm -fr ../a ; cd .. ; pwd ; rm -rf a'
    run_test 'mkdir a ; cd a ; rm -fr ../a ; cd ../ ; pwd ; rm -rf a'
    run_test 'mkdir a ; cd a ; rm -fr ../a ; export HOME= PWD= OLDPWD= ; cd ; pwd ; echo $HOME $PWD $OLDPWD ; rm -rf a'
    run_test 'mkdir a ; cd a ; rm -fr ../a ; export HOME= PWD= OLDPWD= ; cd "" ; pwd ; echo $HOME $PWD $OLDPWD ; rm -rf a'
    run_test 'mkdir a ; cd a ; rm -fr ../a ; export HOME= PWD= OLDPWD= ; cd $HOME ; pwd ; echo $HOME $PWD $OLDPWD ; rm -rf a'
    run_test 'mkdir a ; cd a ; rm -fr ../a ; export HOME= PWD= OLDPWD= ; cd . ; pwd ; echo $HOME $PWD $OLDPWD ; rm -rf a'
    run_test 'mkdir a ; cd a ; rm -fr ../a ; export HOME= PWD= OLDPWD= ; cd . ; pwd ; echo $HOME $PWD $OLDPWD ; cd . ; pwd ; echo $HOME $PWD $OLDPWD ; rm -rf a'
    run_test 'mkdir a ; cd a ; rm -fr ../a ; export HOME= PWD= OLDPWD= ; cd . ; pwd ; echo $HOME $PWD $OLDPWD ; cd . ; pwd ; echo $HOME $PWD $OLDPWD ; cd // ; pwd ; cd home ; pwd ; echo $HOME $PWD $OLDPWD ; rm -rf a'
    run_test 'mkdir a ; cd a ; rm -fr ../a ; export HOME= PWD= OLDPWD= ; cd .. ; pwd ; echo $HOME $PWD $OLDPWD ; rm -rf a'
    run_test 'cd /.// ; pwd'
    run_test 'cd /./////././//// ; pwd'
    run_test 'cd // ; pwd'
    run_test 'cd //...........////// ; pwd'
    run_test 'cd // ; pwd ; cd / ; pwd'
    run_test 'cd // ; pwd ; cd / ; pwd ; cd /// ; pwd'
    run_test 'cd // ; pwd ; cd bin ; pwd'
    run_test 'cd //. ; pwd'
    run_test 'cd //./ ; pwd'
    run_test 'cd //.///./././//// ; pwd'
    run_test 'cd /// ; pwd'
    run_test 'cd ///./// ; pwd'
    run_test 'cd //// ; pwd'
    run_test 'cd ////./././////// ; pwd'
    run_test 'cd ///// ; pwd'
    run_test 'cd /bin ; pwd'
    run_test 'cd /usr/bin ; pwd'
    run_test 'cd /home ; pwd'
    run_test 'cd /home ; pwd ; cd .. ; ls -l'
    run_test 'cd //home ; pwd'
    run_test 'cd //home ; pwd ; cd .. ; ls -l'
    run_test 'cd //./home ; pwd'
    run_test 'cd //./home ; pwd ; cd .. ; ls -l'
    run_test 'cd "//home" ; pwd'
    run_test 'cd "//home" ; pwd ; cd .. ; ls -l'
    run_test 'mkdir test_dir ; cd test_dir ; rm -rf ../test_dir ; pwd ; echo $PWD $OLDPWD ; unset PWD OLDPWD ; pwd ; echo $PWD $OLDPWD ; cd . ; pwd ; echo $PWD $OLDPWD ; cd . ; pwd ; echo $PWD $OLDPWD ; cd .. ; pwd ; echo $PWD $OLDPWD'
    run_test 'mkdir test_dir ; cd test_dir ; rm -rf ../test_dir ; cd . ; pwd ; cd . ; pwd ; cd .. ; pwd'
    run_test 'mkdir test_dir ; cd test_dir ; rm -rf ../test_dir ; cd . ; cd . ; echo $PWD ; echo $OLDPWD ; cd .. ; pwd'
    run_test 'mkdir test_dir ; cd test_dir ; rm -rf ../test_dir ; cd . ; pwd ; cd . ; pwd ; cd .. ; pwd'
    run_test 'unset PWD ; cd ; echo $? ; pwd ; echo $PWD ; echo $OLDPWD'
    run_test 'unset PWD ; cd "" ; echo $? ; pwd ; echo $PWD ; echo $OLDPWD'
    run_test 'unset OLDPWD ; cd ; echo $? ; pwd ; echo $PWD ; echo $OLDPWD'
    run_test 'unset OLDPWD ; cd "" ; echo $? ; pwd ; echo $PWD ; echo $OLDPWD'
    run_test 'unset PWD OLDPWD ; cd ; echo $? ; pwd ; unset PWD ; pwd ; echo $PWD ; echo $OLDPWD'
    run_test 'unset PWD OLDPWD ; cd "" ; echo $? ; pwd ;unset PWD ; pwd ; echo $PWD ; echo $OLDPWD'
    run_test 'cd ; echo $HOME ; echo $PWD ; echo $OLDPWD ; echo $?'
    run_test 'cd "" ; echo $HOME ; echo $PWD ; echo $OLDPWD ; echo $?'
    run_test 'export HOME=aaaa ; cd ; echo $HOME ; echo $PWD ; echo $OLDPWD ; echo $?'
    run_test 'export HOME=aaaa ; cd "" ; echo $HOME ; echo $PWD ; echo $OLDPWD ; echo $?'
    run_test 'export HOME= ; export PWD= ; export OLDPWD= ; cd ; echo $HOME ; echo $PWD ; echo $OLDPWD ; echo $?'
    run_test 'export HOME= ; cd ; echo $HOME ; echo $PWD ; echo $OLDPWD ; echo $?'
    run_test 'export HOME= ; export PWD= ; export OLDPWD= ; cd "" ; echo $HOME ; echo $PWD ; echo $OLDPWD ; echo $?'
    run_test 'cd aaaaaa'
    run_test 'cd aaaaaa ; pwd'
    run_test 'echo $PWD ; echo $OLDPWD ; cd aaaaaa ; echo $PWD ; echo $OLDPWD'
    run_test 'cd ""'
    run_test 'cd "" ; pwd'
    run_test 'echo $PWD ; echo $OLDPWD ; cd "" ; echo $PWD ; echo $OLDPWD'
    run_test 'cd " "'
    run_test 'cd " " ; pwd'
    run_test 'echo $PWD ; echo $OLDPWD ; cd " " ; echo $PWD ; echo $OLDPWD'
    run_test 'cd ./'
    run_test 'cd ./ ; pwd'
    run_test 'echo $PWD ; echo $OLDPWD ; cd ./ ; echo $PWD ; echo $OLDPWD'
    run_test 'echo $OLDPWD'
    run_test 'cd $OLDPWD ; pwd'
    run_test 'cd $OLDPWD ; cd $OLDPWD ; pwd'
    run_test 'unset OLDPWD ; cd $OLDPWD ; pwd ; echo $PWD ; echo $OLDPWD'
    run_test 'unset OLDPWD ; cd $OLDPWD ; pwd ; echo $OLDPWD ; echo $PWD'
    run_test 'cd $WWW ; pwd'
    run_test 'cd $WWW$WWW../../ ; pwd'
    run_test 'cd $WWW./$WWW../$WWW ; pwd'
    run_test 'cd ../../../../../../../ ; pwd'
    run_test 'cd ../.././.././.././.././.././../ ; pwd'
    run_test '""c""d"" . ; pwd'
    run_test 'cd . ; pwd'
    run_test 'cd .. ; pwd'
    run_test 'cd .."""" ; pwd'
    run_test 'cd "".""."""" ; pwd'
    run_test 'cd ... ; pwd'
    run_test 'cd ../.. ; pwd'
    run_test 'cd ../. ; pwd'
    run_test 'cd ./. ; pwd'
    run_test 'cd / ; pwd'
    run_test 'cd // ; pwd'
    run_test 'cd //home ; pwd'
    run_test 'cd "//home" ; pwd'
    run_test 'echo $PWD; echo $OLDPWD; cd "/"; pwd; echo $PWD; echo $OLDPWD'
    run_test 'echo $PWD; echo $OLDPWD; cd "//"; pwd; echo $PWD; echo $OLDPWD'
    run_test 'cd /// ; pwd'
    run_test 'cd // ; cd / ; env | grep | sort | PWD'
    run_test 'cd / ; cd // ; env | grep | sort | PWD'
    run_test 'cd /. ; cd //. ; env | grep | sort | PWD'
    run_test 'cd /.. ; cd //.. ; env | grep | sort | PWD'
    run_test 'cd ; pwd'
    run_test 'cd                    ; pwd'
    run_test 'cd        ""    ""        ; pwd'
    run_test 'cd        " "        ; echo $?'
    # run_test 'cd ~ ; pwd'
    # run_test 'cd ~/ ; pwd'
    # run_test 'cd ~/. ; pwd'
    run_test 'unset HOME ; cd ; echo $? ; pwd'
    run_test 'unset HOME ; cd "" ; echo $? ; pwd'
    # run_test 'unset HOME ; cd ~ ; pwd'
    run_test 'mkdir d ; ln -s d dd ; cd dd ; pwd ; chmod 777 ../d ; rm -r ../d ../dd'
    run_test 'mkdir -m 000 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 001 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 002 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 003 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 004 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 005 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 006 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 007 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 010 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 020 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 030 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 040 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 050 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 060 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 070 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 100 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 200 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 300 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 400 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 500 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 600 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 700 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 755 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 644 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 311 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 111 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 222 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 333 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 0777 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 1000 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 2000 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 3000 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 4000 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 5000 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 6000 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 7000 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 1777 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 2777 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 3777 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 4777 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 5777 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 6777 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 7777 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    run_test 'mkdir -m 0000 d ; echo $PWD ; echo $OLDPWD ; cd d ; echo $OLDPWD'
    rm -rf a
    rm -rf b
    chmod 777 d; rm -rf d
}

test_pwd () {
    run_test 'pwd'
    run_test 'pwd | cat -e'
    run_test 'unset PWD ; pwd'
    run_test 'unset PWD ; pwd ; echo $PWD'
    run_test 'export PWD=test ; pwd ; echo $PWD'
    run_test 'cd / ; cd home ; pwd'
    run_test 'cd / ; cd home ; pwd ; cd .. ; pwd'
    run_test 'cd // ; cd home ; pwd'
    run_test 'cd // ; cd home ; pwd ; cd .. ; pwd'
    run_test 'echo $PWD ; echo $OLDPWD ; cd / ; pwd ; echo $PWD ; echo $OLDPWD'
    run_test 'echo $PWD ; echo $OLDPWD ; cd /. ; pwd ; echo $PWD ; echo $OLDPW'
    run_test 'echo $PWD ; echo $OLDPWD ; cd /./ ; pwd ; echo $PWD ; echo $OLDPW'
    run_test 'echo $PWD ; echo $OLDPWD ; cd /././././ ; pwd; echo $PWD ; echo $OLDPW'
    run_test 'echo $PWD ; echo $OLDPWD ; cd // ; pwd ; echo $PWD ; echo $OLDPW'
    run_test 'echo $PWD ; echo $OLDPWD ; cd /// ; pwd ; echo $PWD ; echo $OLDPW'
    run_test 'echo $PWD ; echo $OLDPWD ; cd //// ; pwd ; echo $PWD ; echo $OLDPWD'
    run_test 'echo $PWD ; echo $OLDPWD ; cd ///// ; pwd ; echo $PWD ; echo $OLDPWD'
    run_test 'echo $PWD ; echo $OLDPWD ; cd ; echo $PWD ; echo $OLDPWD'
    run_test 'echo $PWD ; echo $OLDPWD ; cd ; echo $OLDPWD'
}

test_export () {
    run_test 'export | sort | grep -v SHLVL | grep -v _='
    run_test 'export ECHO="echo   " ; $ECHO 1'
    run_test 'export ECHO="echo""   " ; $ECHO 1'
    run_test 'export ECHO=" echo   " ; $ECHO 1'
    run_test 'export ECHO=" echo   " ; $ECHO 1'
    run_test 'export A=aaa ; export B=bbb ; echo $A$B | cat -e'
    run_test 'export A=" aaa " ; export B=" bbb " ; echo $A$B | cat -e'
    run_test 'export TEST=echo ; $TEST 1'
    run_test "export TEST=echo ; ''\$TEST 1"
    run_test 'export TEST=echo ; ""$TEST 1'
    run_test 'export TEST=echo ; "$TEST" 1'
    run_test "export TEST=echo ; '\$TEST' 1"
    run_test "export _A=aaa ; echo \$_A \"\$_A\" '\$_A' ; unset _A ; echo \$_A"
    run_test 'export AB912__2asdvb_ ; export | grep AB912 | cat | wc ; unset AB91 ; export | grep AB912 ; unset AB912__2asdvb_ ; export | grep AB912'
    run_test "export ___A=aaa ___b=bbb ___C=ccc ___ddd='ddd ddd ddd' ___f=  ___g ___A=a ; export | grep ___"
    run_test "export A ; export A= ; export A='hello' ; export A='world' ; export A=\"hello world\" ; echo \$A"
    run_test "export A ; echo \$? ; export A= ; echo \$? ; export A=aaa ; echo \$?"
    run_test "export HELLO ; unset HELLO ; echo \$? ; unset HELLO ; echo \$? ; export HELLO= ; unset HELLO ; echo \$?"
    run_test 'export _A=aaa | echo $_A "$_A" ; echo $_B | export _B=bbb '
    run_test "echo 'export _A=aaa'>export.txt;export < export.txt|grep _A ; echo \$? ; rm export.txt"
    run_test "export A=aaa ; export A+=bbb ; echo \$A"
}

test_unset () {
    run_test "unset '   ' ; echo \$?"
    run_test "unset '' '' ; echo \$?"
    run_test "unset \"     USER\" ; echo \$USER ; echo \$?"
    run_test "unset \"     USER\" \" '  USER  '    \" ; unset USER ; echo \$USER ; echo \$?"
    run_test 'unset ; echo $?'
    run_test 'unset ; unset ; unset ; echo $?'
}

test_env () {
    # env
    run_test 'env | sort | grep -v SHLVL | grep -v _='
    run_test 'unset USER HOME AAA; env | sort | grep -v SHLVL | grep -v _='
    run_test "export _ABC ; env | grep _ABC ; export _DEF= ; env | grep _DEF ; export _GHI='hello there' ; env | grep _GHI"
}

test_exit () {
    run_test "exit -"
    run_test "exit '    +1'"
    run_test "exit '    -1'"
    run_test "exit '    '"
    run_test 'exit +1'
    run_test 'exit +0'
    run_test 'exit 0'
    run_test 'exit -0'
    run_test 'exit -1'
    run_test "exit ' 3'"
    run_test "exit '\t\f\r 3'"
    run_test "exit 4294967296"
    run_test "exit -4294967297"
    run_test "exit 4294967295"
    run_test "exit -4294967295"
    run_test "exit Mollitia asperiores"
    run_test "exit 123 456 asperiores"
    run_test "exit 18446744073709551615"
    run_test "exit -922337285"
    run_test "exit +922337285"
    run_test "exit -922337203685"
    run_test "exit +922337203685"
    run_test "exit -9223372036854775"
    run_test "exit +9223372036854775"
    run_test "exit -9223372036854775807"
    run_test "exit -9223372036854775808"
    run_test "exit -9223372036854775809"
    run_test "exit +9223372036854775807"
    run_test "exit +9223372036854775806"
    run_test "exit 9223372036854775808"
    run_test "exit 92233720368547758099999999"
    run_test "exit -92233720368547758099999999"
    run_test "exit +00092233720368547758099999999"
    run_test "exit -0000092233720368547758099999999"
    run_test 'exit ----21'
    run_test 'exit --++-+-21'
    run_test 'exit 255'
    run_test 'exit exit'
    run_test 'exit what ; echo $?'
    run_test 'exit 00000000'
    run_test 'echo | exit > exit.txt ; file exit.txt ; rm exit.txt'
    run_test 'echo 9 > exit.txt ; exit < exit.txt | cat ; rm exit.txt '
    run_test 'echo | exit 99 ; echo $?'
    run_test 'echo | exit 42 | exit 21 ; echo $?'
    run_test 'echo | exit 999999999999999999 ; echo $?'
    run_test 'echo | exit -12345 ; echo $?'
    run_test 'echo | exit 0 ; echo $?'
    run_test 'echo 123 | exit ; echo $?'
    run_test 'echo -123 | exit ; echo $?'
}

test_builtins ()
{
    test_echo
    test_cd
    test_pwd
    test_export
    test_unset
    test_env
    test_exit

    # builtins should work in pipe
    run_test 'pwd ; cd .. | pwd'
    # builtins should work with redirections
    # ...
}
