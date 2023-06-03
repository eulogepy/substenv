# substenv

A wrapper bash script which add some extra features like interactivity to envsubst utility.  

![Github Licence Badge](https://img.shields.io/github/license/eulogepy/substenv)
![Github Downloads badge](https://img.shields.io/github/downloads/eulogepy/substenv/total)
!["Github Issues badge"](https://img.shields.io/github/issues/eulogepy/substenv)

## Get Started

Under the hood, substenv uses envsubst utility to substitute the values of environment variables in the standard input content.

This is a standanlone script. Hence it will be executed out of the box in a bash environment, provided you have envsubst and gnu-getopt utilities in your PATH.

1. Download envsubst.sh and move it to your suited your location.
2. Execute it from a terminal running Bash just like you would with envsubst

```bash
cd path/to/substenv
./substenv.sh < /path/to/input_file > /path/to/output_file
```

## How it works

In normal operation mode, standard input is copied to standard output,
with references to environment variables of the form `$VARIABLE` or `${VARIABLE}`
being replaced with the corresponding values.  If a SHELL-FORMAT is given,
only those environment variables that are referenced in SHELL-FORMAT are
substituted; otherwise all environment variables references occurring in
standard input are substituted.

When --variables is used, the output consists
of the environment variables that are referenced either in SHELL-FORMAT if provided or in standard input, one per line.

## Usage

```bash

substenv.sh [OPTIONS] [SHELL-FORMAT]
                [-h|--help] [-V|--version] [-v|--variables] [-i|--interactive] [SHELL-FORMAT]
                [-i|--interactive] [SHELL-FORMAT]
                [-v|--variables] [SHELL-FORMAT]
                [-h|--help]
                [-V|--version]
```

## Options

Operation mode :  
> -i, --interactive  
>> Prompt for a value for each variable discovered in the standard input, prior to performing substitution. Cannot be used in conjonction with -v or --variable switch  
>
> -v, --variables  
>> Output the variables occurring in SHELL-FORMAT or in the input content, if any. Cannot be used in conjonction with -i or --interactive switch.  

Informative output :  
> -h, --help
>> display this help and exit  
>
> -V, --version
>> output version information and exit  

## License  

[MIT](https://choosealicense.com/licenses/mit/ "MIT License")  
