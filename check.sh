#!/bin/bash

# User Settings
readonly SHELL_PATH='..'
readonly LOG_FILE='results.txt'

# Flags
TEST_ALL=0
CREATE_FILES=0
PASS=0
FAIL=0

RESET="\033[0m"
BLACK="\033[30m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
WHITE="\033[37m"
BOLDBLACK="\033[1m\033[30m"
BOLDRED="\033[1m\033[31m"
BOLDGREEN="\033[1m\033[32m"
BOLDYELLOW="\033[1m\033[33m"
BOLDBLUE="\033[1m\033[34m"
BOLDMAGENTA="\033[1m\033[35m"
BOLDCYAN="\033[1m\033[36m"
BOLDWHITE="\033[1m\033[37m"

init_files () {
    touch "${LOG_FILE}" ".files_before" ".files_after"
    ls > ".files_before"
}

build_executable () {
    if ! make -C "${SHELL_PATH}" > /dev/null; then
        echo "Unable to run make"
        exit 1
    fi

    cp "${SHELL_PATH}/minishell" .
}

test_custom () {
    if [[ -f "$1" ]]; then
        while IFS= read -r line; do
            run_test "${line}"
        done < "$1"
    else
        printf "$1: file does not exist\n"
    fi
}

cleanup () {
    ls > ".files_after"
    FILESDIFF=$(diff .files_before .files_after | grep ">" | sed "s|> ||g" | tr '\n' ' ')
    rm $FILESDIFF .files_before .files_after
}

main () {
    init_files
    build_executable

    if (( $# == 0 )); then
        test_all
        return
    fi

    for arg in "$@"; do
        case "${arg}" in
            echo) test_echo ;;
            cd) test_cd ;;
            pwd) test_pwd ;;
            export) test_export ;;
            unset) test_unset ;;
            env) test_env ;;
            exit) test_exit ;;
            *) test_custom "${arg}" ;;
        esac
    done

    final_result
    cleanup
}


create_test_files () {
    for i in {1..6}; do
        echo -n "test" > "test$i.txt"
        for j in $(seq $i); do echo -n $j >> "test$i.txt"; done
    done
}

run_test () {
    if [ $CREATE_FILES -eq 1 ]; then
        create_test_files
    fi
	MSH_RESULT=$(echo $@ "; exit" | ./minishell 2> /dev/null)
	MSH_STATUS=$?
    if [ $CREATE_FILES -eq 1 ]; then
        rm test[1-6].txt
    fi

    if [ $CREATE_FILES -eq 1 ]; then
        create_test_files
    fi
	BASH_RESULT=$(echo $@ "; exit" | bash 2> /dev/null)
	BASH_STATUS=$?
    if [ $CREATE_FILES -eq 1 ]; then
        rm test[1-6].txt
    fi

	if [ "$MSH_RESULT" == "$BASH_RESULT" ] && [ "$MSH_STATUS" == "$BASH_STATUS" ]; then
        echo "[OK] " $@ >> results.txt
	else
        echo "[KO] " $@ >> results.txt
	fi
    echo $MSH_RESULT >> results.txt
    echo $BASH_RESULT >> results.txt
    echo >> results.txt
	if [ "$MSH_RESULT" == "$BASH_RESULT" ] && [ "$MSH_STATUS" == "$BASH_STATUS" ]; then
		printf " $GREEN%s$RESET" "[OK] "
		let PASS++
	else
		printf " $RED%s$RESET" "[KO] "
		let FAIL++
	fi
	printf "$CYAN%s$RESET" "\"$@\""
	if [ "$MSH_RESULT" != "$BASH_RESULT" ]; then
		echo
		echo
		printf $RED"Your output : \n%.20s\n$RED$MSH_RESULT\n%.20s$RESET\n" "-----------------------------------------" "-----------------------------------------"
		printf $WHITE"Expected output : \n%.20s\n$WHITE$BASH_RESULT\n%.20s$RESET\n" "-----------------------------------------" "-----------------------------------------"
	fi
	if [ "$MSH_STATUS" != "$BASH_STATUS" ]; then
		echo
		echo
		printf $RED"Your exit status : $RED$MSH_STATUS$RESET\n"
		printf $WHITE"Expected exit status : $WHITE$BASH_STATUS$RESET\n"
	fi
	echo
	sleep 0.03
}

run_test_with_files () {
    CREATE_FILES=1
    run_test $@
    CREATE_FILES=0
}

run_syntax_test () {

    MSH_RESULT=$(echo $@ | ./minishell 2> /dev/null)
	MSH_STATUS=$?
	BASH_RESULT=$(echo $@ | bash 2> /dev/null)
	BASH_STATUS=$?

	if [ "$MSH_RESULT" == "$BASH_RESULT" ] && [ $MSH_STATUS -gt 0 ]; then
        echo "[OK] " $@ >> results.txt
	else
        echo "[KO] " $@ >> results.txt
	fi
	if [ "$MSH_RESULT" == "$BASH_RESULT" ] && [ $MSH_STATUS -gt 0 ]; then
		printf " $GREEN%s$RESET" "[OK] "
		let PASS++
	else
		printf " $RED%s$RESET" "[KO] "
		let FAIL++
	fi
	printf "$CYAN \"$@\" $RESET"
	if [ "$MSH_RESULT" != "$BASH_RESULT" ]; then
		echo
		echo
		printf $RED"Your output : \n%.20s\n$RED$MSH_RESULT\n%.20s$RESET\n" "-----------------------------------------" "-----------------------------------------"
		printf $WHITE"Expected output : \n%.20s\n$WHITE$BASH_RESULT\n%.20s$RESET\n" "-----------------------------------------" "-----------------------------------------"
	fi
	if [ $MSH_STATUS -eq 0 ]; then
		echo
		echo
		printf $RED"Your exit status : $RED$MSH_STATUS$RESET\n"
		printf $WHITE"Expected exit status : $WHITE$BASH_STATUS$RESET\n"
	fi
	echo
	sleep 0.03
}

final_result () {
	SUM=PASS
	let SUM+=$FAIL
	if [ $FAIL -ne 0 ] ; then
	echo -ne "$RED
    $PASS / $SUM
    \"The goal is to make your own shell
    If it moves like bash,
    If it doesn't crash
    It's a beautiful, one and only, minishell.\" - Brian Fox

$RESET"
    elif [ $TEST_ALL -eq 1 ] ; then
	echo -ne "$GREEN@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@..... ...  ...,@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@,.... ....... ........,@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@,,.........,,,*,,,..,,,,,..#@@@@@@@@@@@@@
@@@@@@@@@@@@/,,,.,,,,,,,,*,******,**,,,...,@@@@@@@@@@@@
@@@@@@@@@@@*,/,,,,,,,*********//////***,,,.,@@@@@@@@@@@
@@@@@@@@@@*,,*,,,,,,,,****////////////***,,.%@@@@@@@@@@
@@@@@@@@@@*,,,,,,,,,,,******,*****/////**,,,,@@@@@@@@@@
@@@@@@@@@(*,*,,,*,**/*****/**//(((//**///***,(@@@@@@@@@
@@@@@@@@@(//,,,.. ..,,**//**,,.,,*///*///*,*,,@@@@@@@@@
@@@@@@@%*(*/,.,,....,..*/((*,,,,**/**////**,,*##@@@@@@@
@@@@@@@*(*,.....,.....,*///*..,,.#,.***////,*((,(@@@@@@  $PASS / $SUM
@@@@@@@/(/,,,,,,,..,,,*///(/(**////*****///*///(/&@@@@@  Great!
@@@@@@@(#/,,,,,**,,.,**/(/((/*//****/////*/*(*(/&@@@@@@
@@@@@@@/(/****,**,,,.,*/((#(**/*//(//((//***/*/(@@@@@@@
@@@@@@@@((*,,,**,,,. ...,,*/////(/(/(((//**//((@@@@@@@@
@@@@@@@@%/,,,,..        .  ..,////(/(((//////(@@@@@@@@@
@@@@@@@@@(,,,..  .....,,*,/,, . ,*//((/(*/**(@@@@@@@@@@
@@@@@@@@@@/...   ....,.,**/(//*. ./*//(///**/@@@@@@@@@@
@@@@@@@@@@@,,.    .       .,***,,.**,**,****/@@@@@@@@@@
@@@@@@@@@@@%,..  . .,,,,,/,,*,*..,,,,,,,,.,**.@@@@@@@@@
@@@@@@@@@@@(/..    ,..,,,/....   .,,.....,,   ...*@@@@@
@@@@@@@@(,*/,, .    .     .     ... ....       .,,,,,,.
/**,* . . *,...         .     .. .             ...,,,..
,*.      .......          .                   ...,,,.,.
.        ........                              ..,.....
$RESET"
    else
    echo -ne "$GREEN
    $PASS / $SUM Great!

$RESET"
	fi
	printf "%s\n" "Please do your own signal testing."
}

test_all () {
    ### Syntax error
    run_syntax_test ';'
    run_syntax_test '|'
    run_syntax_test '<'
    run_syntax_test '; ; '
    run_syntax_test '| |'
    run_syntax_test '< >'
    run_syntax_test ';; echo'
    run_syntax_test '| echo'
    run_syntax_test 'echo > <'
    run_syntax_test 'echo | |'
    run_syntax_test 'echo hello > |'
    run_syntax_test 'echo hello > ;'
    run_syntax_test 'echo hello >> |'
    run_syntax_test 'echo hello >> ;'
    run_syntax_test 'cat < |'
    run_syntax_test 'cat < ;'
    run_syntax_test 'echo hello > '
    run_syntax_test 'echo hello >>'
    run_syntax_test 'cat < '
    run_syntax_test 'echo hello > > test1.txt'
    run_syntax_test 'echo hello >> >> test1.txt'
    run_syntax_test 'echo hello > >> test1.txt'
    run_syntax_test 'echo hello > < test1.txt'
    run_syntax_test 'cat < < test1.txt'
    ### Commnad not found

    # command not found should exit with status 127
    run_test 'unknowncommand'
    run_test 'unknowncommand ; commandunknown'
    run_test 'unknowncommand | commandunknown'
    run_test '/bin/ls/asdf ; echo $?'
    run_test '/bin/asdf/asdf ; echo $?'

    # command not found should still open file
    run_test 'unknowncommand > nani ; file nani ; rm nani'
    run_test 'asdfas | echo hello | echo world > WORLD | asdfas ; file WORLD; rm WORLD'


    ### Command not executable

    # command found but not executable should exit with status 126
    run_test "echo '#!/bin/bash' > a ; echo 'echo hello'>>a ; ./a; echo \$?;chmod +x a; ./a; echo \$? ; rm a"


    ### Absolute path
    run_test '/bin/ls ; echo $?'
    run_test '/home ; echo $?'
    run_test '$PWD/minishell ; exit'


    ### Relative path
    run_test '$OLDPWD ; echo $?'
    run_test './. ; echo $?'
    run_test './.. ; echo $?'
    run_test './... ; echo $?'
    run_test 'touch aaa ; ./aaa ; rm aaa'
    run_test 'touch bbb ; chmod +x bbb ; ./bbb ; rm bbb'
    run_test 'mkdir ccc ; ./ccc ; rmdir ccc'
    run_test 'mkdir ccc ; touch ccc/ddd ; chmod +x ccc/ddd ; ccc/ddd ; rm -rf ccc'
    run_test 'touch eee ; echo "echo \$SHLVL" > eee ; echo exit >> eee ; ./minishell < eee ; rm eee'
    run_test 'touch fff ; echo "echo \$SHLVL" > fff ; echo exit >> fff ; ././././././././minishell < fff ; rm fff'
    run_test 'touch ggg ; echo "echo \$SHLVL" > ggg ; echo exit >> ggg ; .///././/./././minishell < ggg ; rm ggg'
    run_test 'touch hhh ; echo "echo \$SHLVL" > hhh ; echo \$OLDPWD >> hhh ; echo exit >> hhh ; .///././/./././minishell < hhh; rm hhh'

    run_test "mkdir ccc ; echo '#!/bin/sh' 'echo hello' > ccc/ddd ; chmod +x ccc/ddd ; ccc/ddd ; rm -rf ccc"

    ### Environment PATH
    run_test "cp /bin/ls a ; export PATH=: ; a ; /bin/rm a"
    run_test "cp /bin/ls a ; export PATH=:: ; a ; /bin/rm a"
    run_test "cp /bin/ls a ; export PATH=. ; a ; /bin/rm a"
    run_test "cp /bin/ls ls ; unset PATH ; ls ; /bin/rm ls"
    run_test "cp /bin/ls ls ; export PATH= ; ls ; /bin/rm ls"
    run_test "cp /bin/ls ls ; export PATH='' ; ls ; /bin/rm ls"


    ### SHLVL
    # SHLVLV に文字列やINT_MAX, INT_MIN 以外の数字を与える
    # SHLVL の最大値は 1000
    # 1000 は表示されない


    ### Builtins
    test_builtin

    ### ; Separator
    run_test 'echo hello'
    run_test 'echo hello world'
    run_test 'echo hello ; echo world'
    run_test 'echo hello ; echo world'
    run_test 'echo 01234567890123456789 ; echo;echo;echo'
    run_test 'ls ; ls ; ls ; ls ; ls ; ls ; ls ; ls ; ls ; ls ; ls ; ls ; ls ; ls ; ls'

    ### | Pipe
    run_test 'ls | wc | wc'
    run_test 'ls | wc | wc ; echo test'
    run_test 'ls | wc | wc ; echo test | wc'
    run_test "echo \$USER \"  \$HOME  \" | cat | head -n 1 | cat | cat | wc"
    run_test 'cat /dev/urandom | head -c 100 | wc -c'
    # run_test 'sleep 1 | echo 1 ; sleep 2 | echo 2'


    ### Redirections

    # redirection should work without command
    run_test '>what ; echo $? ; file what; rm what'
    run_test '> echo ; echo $?; file echo ; rm echo'
    run_test '>> echo ; echo $? ; file echo ; rm echo'
    run_test '< echo ; echo $?'
    run_test '>a>b>c ; echo $? ; file a; file b; file c; rm a b c'
    run_test '>>a>>b>>c<a<b<c ; echo $? ; file a; file b; file c; rm a b c'
    run_test 'echo>a>b>c ; <a<b<c ; rm a b c'
    run_test_with_files '<test1.txt'
    run_test_with_files '<test1.txt<test2.txt<test3.txt<test4.txt'

    # < redirection shoud fail if file does not exist
    run_test 'cat < nonexistingfile'
    run_test 'echo hello > a ; cat < nonexistingfile < a; rm a'

    # > redirection should redirect output to file
    run_test 'echo > a ; cat a ; rm a'
    run_test 'echo hello > a world ; cat a ; rm a'
    run_test 'ls > a -l; cat a; rm a'
    run_test '> a ls -l; cat a; rm a'
    run_test 'cat file > file | cat -e; rm file'

    # > redirection should create non-existing file
    run_test 'echo non-existing file > nonexist ; cat nonexist ; rm nonexist'

    # redirection should work with multiple files
    run_test_with_files 'wc < test1.txt < test2.txt < test3.txt < test4.txt < test5.txt ; cat test1.txt test2.txt test3.txt test4.txt test5.txt test6.txt'
    run_test_with_files 'echo aaa > test1.txt > test2.txt > test3.txt > test4.txt > test5.txt > test6.txt ; cat test1.txt test2.txt test3.txt test4.txt test5.txt test6.txt'
    run_test 'rm test1.txt ; echo aaa >> test1.txt ; echo bbb >> test1.txt ; cat test1.txt'
    run_test_with_files 'echo aaa >> test1.txt >> test2.txt >> test3.txt ; echo bbb >> test1.txt >> test2.txt >> test3.txt ; cat test1.txt test2.txt test3.txt'

    # redirections should work in mix
    run_test_with_files 'wc < test1.txt < test2.txt > test3.txt > test4.txt < test5.txt > test6.txt'
    run_test_with_files 'cat > test2.txt > test3.txt > test4.txt < test1.txt'
    run_test_with_files 'echo | cat | wc > a < test6.txt ; cat a; rm a'
    run_test_with_files 'echo test666666 >> test6.txt | head -n 1 < test6.txt > test1.txt ; wc > test2.txt < test1.txt ; cat test2.txt'

    # redirections and pipes
    run_test_with_files 'cat test1.txt | cat < test2.txt'
    run_test_with_files 'cat < test1.txt | cat > test2.txt ; cat test2.txt'

    # redirections with quotes
    run_test "echo hello > 'world' ; cat world ; rm world"
    run_test "echo hello > aaa\"world\" > \" a b c \"; file aaaworld ; cat \" a b c \" ; rm aaaworld \" a b c \""

    # redirections with variables
    run_test "echo hello > \$USER ; cat \$USER ; rm \$USER"
    run_test "echo hello > aaa\$USER\"\$PWD\" ; cat aaa\$USER\"\$PWD\" ; rm aaa\$USER\"\$PWD\""
    run_test "export a="a b c" ; echo hello > \"  \$a  \" ; cat \"  \$a  \" ; rm \"  \$a  \""

    # redirections should fail when permission denied
    run_test "echo hello > a; cat < a;chmod -r a; cat < a; rm a"
    run_test "echo hello > a; cat a;chmod -w a; echo >> a; cat a; rm a"

    ### Quotes

    # quotes should work in simple use cases
    run_test "echo hello'world'foo"
    run_test "echo \"oh'hello\"world\"yeah'wow\""
    run_test "echo \"oh'hello\"wor\"\"''ld\"yeah'wow\""
    run_test "echo \"oh'h\"\"ello\"wor\"\"''''''ld\"yeah'w''ow\""
    run_test "echo hel'lo;''wor|$'''ld yeah"

    # quotes should work empty
    run_test "echo '' | cat -e"
    run_test "echo '''''' | cat -e"
    run_test "echo '' '''' | cat -e"
    run_test "echo \"\" | cat -e"
    run_test "echo \"\" \"\"\"\" | cat -e"
    run_test "echo '' '' ''   ''"
    run_test "echo \" \" \"\" \"\"  \"\""
    run_test "''echo '' | cat -e"
    run_test "''\"\"e'c'\"\"ho'' | cat -e"
    run_test "''\"\"l's''' | cat -e"
    run_test "ls'''''' ''\"\"-la'' | cat -e"
    run_test "echo'''' '' | ''c'at' -\"\"e"
    run_test "echo''\"\" '' '' | \"\"''cat -e"

    # quotes should work with whitespaces
    run_test "echo '   ' | cat -e"
    run_test "echo '   ''      ''  ' | cat -e"
    run_test "echo \"             \" | cat -e"
    run_test "echo \"  \"\"    \"\"         \""

    # quotes should not add operators
    run_test "echo hello ';' cat ; echo hello \";\" cat"
    run_test "echo hello '|' cat ; echo hello \"|\" cat"
    run_test " echo hello '>' '>' ; echo hello \">\" \">\""
    run_test " echo hello '>>' '>>' ; echo hello \">>\" \">>\""
    run_test "echo > \">\" hello ; cat \">\" ; rm \">\""
    run_test "echo hello ' >  > ' > '>' > \" > >\" world ; cat \" > >\" ; rm '>' \" > >\""

    # quotes do not split fields
    run_test "\"echo hello\""
    run_test "'echo hello'"

    # Single quotes

    # single quote should preserve literal values
    run_test "echo 'hello \$USER %* # @ ^ &* ( @ ! ) there | cat ; wc ; {}|\\\\\\ '"

    # Double quotes

    # double quotes should preserve literal values
    run_test "echo \"hello USER %* #' @ ^ &* ( @ ! ) there | cat ; wc ; {}|\""

    # double quotes backslash should escape only if followed by $ " \
    run_test "echo \" hello \;there\2my\0friend\""
    run_test "echo \" hello \there\my\nfriend\""
    run_test "echo \" \\\" lit\\\"erally \""
    run_test "echo \" \\\$USER lit\\\$USERerally \""
    run_test "echo \" \\\\ lit\\\\erally \""
    run_test "echo \"\\\$\$USER\""

    # double quotes should expand $
    run_test "echo \"$\""
    run_test "echo \"  $  $  $ $ $ $\""
    run_test "echo \"   \$USER \$CWD \""
    run_test "echo \"   aaa\$USER bbb\$CWDccc \""
    run_test "\$A"
    run_test "\$OLDPWD"

    # double quotes should add empty to unknown variable
    run_test "echo \"  \$UNKNOWNVARIABLE  \$_WHATIS_this999 \$_32175891  \$________\""


    ### $?

    # $? should print exit status
    run_test 'true ; echo $? ; false ; echo $? ; cat nonexist ; echo $?'
    run_test 'true ;echo $?$?$?'
    run_test "false ; echo \$USER\$?\"\$?\"'\$?' $  \$?"
    run_test "/bin/ls | cat | wc ; echo \$?"

    # $? should work in sequence
    run_test 'echo $? $? $? $? $?'
    run_test 'true ; echo $? ; false ; echo $? ; true | echo $? ; false | echo $?'

    # $? should be undefined in pipe
    run_test 'true ; echo $? | cat | false | echo $?'

    # $? should work in pipes and redirections
    run_test_with_files "false ; echo \$? > test1.txt > test2.txt ; echo \$? | cat >>test2.txt ; cat test2.txt | echo \$?"

    ### Expansion

    # dollar sign preceding double quote
    run_test "echo \$\"\""
    run_test "echo \$\"hello\""
    run_test "echo \$\"USER\$USER what...\""

    # dollar sign should print
    run_test 'echo $'
    run_test 'echo $ $ $    $ $ $ $'

    # dollar sign should expand
    run_test 'echo $USER $ZXY $PWD'
    run_test 'echo $UNKNWONVARIABLE $_WHATis_This999 $_1324810'
    run_test "echo \$USER aaa\$USER\"bbb 'ccc' \"\"\"\"\$USER \"\$USERddd"
    run_test "echo aaa\$USER\"\$ZXY\"\$ZXY"
    run_test "export WOW='hello world' ; cat aaa\$WOW ; cat \"aaa\$WOW\" ; cat 'aaa\$WOW'"
    run_test "echo \$\"\$USER\""
    run_test "echo \$\"a b   \$USER  \""

    # variable expansion should work with ;
    run_test 'export A=aaa ; echo $A ; unset A ; echo $A | cat -e'

    # variable expansion order is undefined in pipe
    run_test 'export B=bbb | echo $B | cat -e'
    run_test 'echo $B | export B=bbb | cat -e'

    # variable expansion is before redirection
    run_test 'export C=ccc ; echo $C > $C ; cat $C ; rm $C'
    run_test "export ECHO='echo what > what.txt' ; \$ECHO"
    run_test "export ECHO='echo what > what.txt' ; \$ECHO > what.txt ; cat what.txt"

    # variable expansion is before word
    run_test 'export ECHO=echo ; export CAT=cat ; $ECHO $CAT | $CAT'

    # variable expansion as special characters
    run_test "export PIPE='|' ; echo \$PIPE ; echo PIPE \$PIPE cat"
    run_test "export PIPE='|' ; export GREATER='>' ; export CAT=cat ; echo \$PIPE | \$CAT ; echo \$PIPE \$GREATER wow | \$CAT"
    run_test "export ECHO='echo hello world' ; \$ECHO ; echo \$ECHO"
    run_test "export ECHO=\"echo hello | cat | wc\" ; \$ECHO ; echo \$ECHO"
    run_test "export CAT=cat ; echo hello | \$CAT"
    run_test "export CAT='cat -e' ; echo hello | \$CAT"
    run_test "export CAT='cat -e | wc' ; echo \$CAT"
    run_test "export CAT='cat -e | wc' ; \$CAT"
    run_test "echo what > what.txt ; export CAT='cat what.txt' ; \$CAT ; rm what.txt"
    run_test "export ECHO='echo hello > what.txt ; cat what.txt' ; \$ECHO"

    # Quotes and Expansions are hard
    run_test "export a=\"aaa\"; echo \"\$a\", '\$a', \$a"
    run_test "echo \"\\\$\$a\""
    run_test "export a=\"echo abc > test1.txt\"; \$a"

    run_test "export A ; echo hello > \$A"
    run_test "export A= ; echo hello > \$A"
    run_test "export A='a b c' ; echo hello > \$A"

    run_test "export a=\"   a   \"; export b=\"  bbb  \"; echo \$a\$b"
    run_test "export a='a' b=' b ' c='c ' d=' d' e='e e'; echo \$a\$a \$a\$b \$a\$c \$a\$d \$a\$e | cat -e; echo \$b\$a \$b\$b \$b\$c \$b\$d \$b\$e | cat -e; echo \$c\$a \$c\$b \$c\$c \$c\$d \$c\$e | cat -e; echo \$d\$a \$d\$b \$d\$c \$d\$d \$d\$e | cat -e; echo \$e\$a \$e\$b \$e\$c \$e\$d \$e\$e | cat -e"

    run_test "export TEST=echo ; ''\$TEST 1"
    run_test "export TEST=echo ; \"\"''\$T'ES'T 1"

    run_test "export ECHO=echo'\"' ; \$ECHO 1"
    run_test "export ECHO=echo\"'\" ; \$ECHO 1"
    run_test "export 'ECHO=echo\"\"' ; \$ECHO 1"
    run_test "export \"ECHO=echo''\" ; \$ECHO 1"
    run_test "export A=\"echo hello\" ; \$A"
    run_test "export B=\"echo hello > a\" ; \$A; file a ; rm a"
    run_test "export A=\"   \" ; \$A ; echo \$A > \$A ; rm \$A"
    run_test "export PATH=' ';echo \$PATH"
    run_test "export A=\"           \" ;echo \$A"

    run_test "export A='' B=\" \" C=\"    \" D=\"  d \" ; echo \$A \$B \$C \$D | cat -e ; echo \$A\$B''\"\$C\"\$D | cat -e"
    run_test "export A='a' B=' ' C=' c ' ; echo \$A\$B\$A | cat -e ; echo \$A\$A\$A \$A \$A | cat -e ; echo \$C\$B \$B\$C | cat -e ; echo \$A\$C \$A\$B\$C"
    run_test "export A='a' B=' ' ; echo \$A\$B\$A ; echo \$A \$B \$A; echo \$A\$B\$B\$B\$A"
}

test_builtin()
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

test_echo()
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

main "$@"
