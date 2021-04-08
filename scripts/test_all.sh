test_syntax_error () {
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
}

test_command_not_found () {
    # command not found should exit with status 127
    run_test 'unknowncommand'
    run_test 'unknowncommand ; commandunknown'
    run_test 'unknowncommand | commandunknown'
    run_test '/bin/ls/asdf ; echo $?'
    run_test '/bin/asdf/asdf ; echo $?'

    # command not found should still open file
    run_test 'unknowncommand > nani ; file nani ; rm nani'
    run_test 'asdfas | echo hello | echo world > WORLD | asdfas ; file WORLD; rm WORLD'

    # command found but not executable should exit with status 126
    run_test "echo '#!/bin/bash' > a ; echo 'echo hello'>>a ; ./a; echo \$?;chmod +x a; ./a; echo \$? ; rm a"
}

test_paths () {
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
}

test_shlvl () {
    ### SHLVL
    # SHLVLV に文字列やINT_MAX, INT_MIN 以外の数字を与える
    # SHLVL の最大値は 1000
    # 1000 は表示されない
    echo
}

test_separator () {
    run_test 'echo hello'
    run_test 'echo hello world'
    run_test 'echo hello ; echo world'
    run_test 'echo hello ; echo world'
    run_test 'echo 01234567890123456789 ; echo;echo;echo'
    run_test 'ls ; ls ; ls ; ls ; ls ; ls ; ls ; ls ; ls ; ls ; ls ; ls ; ls ; ls ; ls'
}

test_pipe () {
    run_test 'ls | wc | wc'
    run_test 'ls | wc | wc ; echo test'
    run_test 'ls | wc | wc ; echo test | wc'
    run_test "echo \$USER \"  \$HOME  \" | cat | head -n 1 | cat | cat | wc"
    run_test 'cat /dev/urandom | head -c 100 | wc -c'
    # run_test 'sleep 1 | echo 1 ; sleep 2 | echo 2'
}

test_redirections () {
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
}

test_quotes () {
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
}

test_vars () {
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
