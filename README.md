This project reproduces a strange behavior in React Native. I've
boiled down this repro from a much larger app.

Check out `run-test.js`. This code should run the `code` string to
completion, but it pauses in the middle and won't complete execution
until you interact with the screen. The code prints to the console so
you can watch it to see progress. It will pause around "foo2" or
"foo3" and touching the screen will force it to continue.