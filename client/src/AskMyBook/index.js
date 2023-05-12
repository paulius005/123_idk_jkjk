import { Button, View, TextArea, Text, Image } from 'reshaped';

import React, { useState } from 'react';
import axios from 'axios';

import './index.css';

const App = () => {
  const [message, setMessage] = useState('');
  const [answer, setAnswer] = useState('');
  const [question, setQuestion] = useState('');

  return (
    <View
      maxWidth='70ch'
      direction='column'
      align='center'
      justify='start'
      gap={6}
      className='mainView'
      padding={4}
    >
      <Image
        className='bookImage'
        src='https://imagedelivery.net/YtcfQnb_m3yN9uzdhMII_A/0980e8bf-715f-4e2a-cb90-ecece879ad00/public'
        height='200px'
      ></Image>
      <Text variant='title-2'>Ask My Book</Text>
      <Text variant='featured-3' color='neutral-faded'>
        This is an experiment in using AI to make my book's content more
        accessible. Ask a question and AI will answer it in real-time:
      </Text>
      <TextArea
        className='mainTextArea'
        placeholder='What is this book about?'
        onChange={({ event, name, value }) => setQuestion(value)}
      ></TextArea>
      <View direction='row' align='center' justify='center' gap={4}>
        <Button
          color='primary'
          size='xlarge'
          onClick={async () => {
            try {
              const response = await axios.post('/questions/ask', { question });
              const { data } = response;

              setAnswer(data.answer);
            } catch (error) {
              console.error('Error fetching data:', error);
            }

            // fetch('/example/message')
            //   .then((response) => response.json())
            //   .then((data) => setMessage(data.message))
            //   .catch((error) => console.error('Error:', error));
          }}
        >
          Ask question
        </Button>
        <Button size='xlarge'>I'm feeling lucky</Button>
      </View>
      <Text variant='featured-3' color='neutral-faded'>
        {message}
      </Text>
      <Text variant='featured-3' color='neutral-faded'>
        {answer}
      </Text>
    </View>
  );
};

export default App;
