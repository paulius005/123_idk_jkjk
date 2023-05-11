import { View, Reshaped } from 'reshaped';

import React from 'react';

import 'reshaped/themes/reshaped/theme.css';

import AskMyBook from './AskMyBook';

const App = () => {
  return (
    <Reshaped theme='reshaped'>
      <View width='100%' direction='column' align='center' justify='start'>
        <AskMyBook />
      </View>
    </Reshaped>
  );
};

export default App;
