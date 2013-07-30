cohsa
=====

A single-page html+coffee+sass+jsv framework to be used with Phonegap and Node Webkit

To get started

1. Install CJSV

clone from https://github.com/ph-everywhere/cjsv to any folder you like

2. Install CoffeeScript and Compass

3. Clone this repo to a new project folder

4. Set up environment

Add these three lines
alias c_jw='ruby your/path/to/jsv/jsv.rb --input_dir application/views/cjsv/ --output_dir application/views/'
alias c_csw='coffee -wc -o js/ .'
alias cw='compass watch .'

to your .bashrc or similar

Open three terminals (Or a terminal that allows screen splashing, like Terminator) on the project folder, and run each of the aliases previously set.

On this step you will probably get a lot of ruby dependency related problems. I'm counting on you to solve them!

5. Point you browser to index.html and you should see a nice welcome message

6. How can I be able to keep track of cohsa updates while developing my application?
This is simple! 
