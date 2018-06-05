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
