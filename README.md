[wip]

Make sure your prompt and error messages are written to stderr, like in bash.

It might help if you have a rule like this in your Makefile:

```Makefile
check:
	@cd minishell-checker && bash check.sh
```
