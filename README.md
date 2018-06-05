This project reproduces a strange behavior in React Native. I've
boiled down this repro from a much larger app.

Check out [`run-test.js`](https://github.com/jlongster/rn-scheduling-repro/blob/master/run-test.js). This code should run the `code` string to
completion, but it pauses in the middle and won't complete execution
until you interact with the screen. The code prints to the console so
you can watch it to see progress. It will pause around "foo2" or
"foo3" and touching the screen will force it to continue.

**This must run in a release build to see the behavior**

Here is the code in `run-test.js` that causes this strange behavior:

```js
function doSomething(str) {
  console.log('doSomething', str);
  return new Promise((resolve, reject) => {
    resolve();
  });
}

export default async function() {
  const code = `
    runMigration(async function() {
      await doSomething('foo1');
      await doSomething('foo2');
      await doSomething('foo3');
      await doSomething('foo4');
      await doSomething('foo5');
      await doSomething('foo6');
      await doSomething('foo7');
      await doSomething('foo8');
      await doSomething('foo9');
    });
  `;

  return new Promise((resolve, reject) => {
    const func = new Function('doSomething', 'runMigration', code);
    func(doSomething, asyncFunc => {
      asyncFunc().then(resolve, err => {
        console.log('Error applying JavaScript:', js);
        reject(err);
      });
    });
  });
}
```