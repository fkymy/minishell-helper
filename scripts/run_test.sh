prepare_test_files () {
    for i in {1..6}; do
        echo -n "test" > "test$i.txt"
        for j in $(seq $i); do echo -n $j >> "test$i.txt"; done
    done
}

run_test () {
    if [ $CREATE_FILES -eq 1 ]; then
        prepare_test_files
    fi
	MSH_RESULT=$(echo $@ "; exit" | ./minishell 2> /dev/null)
	MSH_STATUS=$?
    if [ $CREATE_FILES -eq 1 ]; then
        rm test[1-6].txt
    fi

    if [ $CREATE_FILES -eq 1 ]; then
        prepare_test_files
    fi
	BASH_RESULT=$(echo $@ "; exit" | bash 2> /dev/null)
	BASH_STATUS=$?
    if [ $CREATE_FILES -eq 1 ]; then
        rm test[1-6].txt
    fi

	if [ "$MSH_RESULT" == "$BASH_RESULT" ] && [ "$MSH_STATUS" == "$BASH_STATUS" ]; then
        echo "[OK] " $@ >> "${LOG_FILE}"
	else
        echo "[KO] " $@ >> "${LOG_FILE}"
	fi
    echo $MSH_RESULT >> "${LOG_FILE}"
    echo $BASH_RESULT >> "${LOG_FILE}"
    echo >> "${LOG_FILE}"
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
        echo "[OK] " $@ >> "${LOG_FILE}"
	else
        echo "[KO] " $@ >> "${LOG_FILE}"
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

