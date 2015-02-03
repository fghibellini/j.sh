# JScript

Intelligent file-tree jumping inspired by z.sh

## Usage

1. source this scritp from your `.zsrhc` like this `source j.sh`
2. jump around with *cd* & watch how your *~/.j* file populates
3. run `j folderName` to jump to to the most used folder named folderName

## TODO

This script currently lacks autocompletion, which would extremely
add to its usefullness.

## WHY ???

z.sh analyzes paths like strings, therefore often happened that i wanted to jump to the root
of a project, but z would move me to the test folder of the project simply because
it did match the words and I had spent more time there.
J supposes that your input should describe the destination folder not the entire path.
