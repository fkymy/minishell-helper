
![mini shell of love](https://repository-images.githubusercontent.com/336699843/e13c1180-6bf2-11eb-9b61-49f5cfcac5e9)

> The goal is to make your own shell  
If it moves like bash,  
If it doesn't crash  
It's a beautiful, one and only, minishell.


### Usage

1. Make sure your prompt and error messages are written to `stderr`, like in bash.

2. git clone this repo into your project root and run check.sh.

3. check.sh will run `make -C $SHELL_PATH` with a default path of `../`.

It might help if you have a rule like this in your Makefile:

```Makefile
check:
	@cd minishell-helper && bash check.sh
```

- `./check.sh` runs all tests
- `./check.sh [echo, cd, pwd, export, unset, env, exit]` runs builtin command tests
- `./check.sh [mytest.txt]` runs commandlines from a custom text file



Feel free to contribute!
