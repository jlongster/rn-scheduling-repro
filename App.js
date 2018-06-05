import React from 'react';
import { Text, View } from 'react-native';
import runTest from './run-test';

class App extends React.Component {
  componentDidMount() {
    runTest();
  }

  render() {
    return (
      <View>
        <Text>hi</Text>
      </View>
    );
  }
}

export default App;
